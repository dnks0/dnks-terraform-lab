# Design: Modularize `azure-terragrunt-simple-mws` Terraform

**Date:** 2026-07-17
**Scope:** `azure-terragrunt-simple-mws/` only. No other stack is touched.
**Goal:** Refactor the flat `.tf` piles inside each Terraform root module into focused,
individually toggleable child modules, so the stack is modular and supports flexible
configuration — including configuration that reaches into surrounding Azure
infrastructure — without breaking the Terragrunt layer that sits on top.

---

## 1. Background & constraints

### 1.1 Current shape

The Terragrunt `live/` tree calls four Terraform **root modules** via
`terraform { source = ".../modules/<name>" }`:

| Root module | Provider plane | Terragrunt units that consume it |
|---|---|---|
| `account-config` | `databricks.mws` (account) | `common/account-config` (once) |
| `workspace` | `azurerm` + `databricks.mws` | `bu-*/workspace` (per BU) |
| `workspace-config` | `azurerm` + `databricks.workspace` | `bu-*/workspace-config` (per BU) |
| `security-analysis-tool` | `databricks.workspace` | `bu-*/security-analysis-tool` (per BU) |

Internally each root module is a flat pile of `.tf` files mixing several concerns.

### 1.2 Documented constraints that drive the design

Researched against official Databricks provider, HashiCorp `azurerm`, Terragrunt, and
HashiCorp module-composition docs, plus the Databricks Security Reference Architecture
(`github.com/databricks/terraform-databricks-sra/tree/main/azure`).

1. **Terragrunt binds to a root module's interface, not its internals.** A unit couples
   only through its `inputs = {}` map (root module input variables) and the `outputs`
   that `dependency` blocks read. Preserve those names/types and the internal module tree
   can change freely.
2. **Three provider planes → three natural state/root boundaries** (already how the four
   roots are split): `azurerm` infra, account-plane `databricks.mws`, workspace-plane
   `databricks.workspace`. The workspace-plane provider's `host` derives from the
   workspace resource output; a provider cannot be reliably configured from a resource
   created in the same apply. **The refactor must not move resources across these planes.**
3. **Child modules must contain no `provider` blocks** — only `required_providers` (with
   `configuration_aliases` where an aliased provider is needed). Providers are configured
   in the root module and passed to children: `azurerm` inherited implicitly; aliased
   `databricks` providers passed explicitly via `providers = {}` on the `module` block.
   Keep the tree flat (one level of children).
4. **Azure networking facts:** VNet-injection fields on `azurerm_databricks_workspace`
   are ForceNew; the workspace consumes NSG-**association** IDs (not subnet IDs); NAT
   gateway egress is effectively mandatory for new workspaces (post-2026-03-31 Azure
   default); two distinct private-endpoint families exist — workspace backend
   (`databricks_ui_api`, DNS `privatelink.azuredatabricks.net`) vs storage (`dfs`/`blob`,
   one PE per subresource, own DNS zones).
5. **SRA precedent:** the reference architecture bundles vnet+subnets+dns in one
   `virtual_network` module, keeps each resource's private endpoints **with the resource
   they front** (`workspace/*_privatelink.tf`, `catalog/private_endpoint.tf`), and keeps
   `sat` standalone. This design follows that grain.

### 1.3 Non-goals

- No changes to `aws-*`, `azure-terragrunt-hub-spoke-mws`, or the standalone `gcp*`/`aim-test` dirs.
- No behavioural change to deployed infrastructure. Same resources, same providers, same
  order. This is a structural refactor + explicit-dependency cleanup, not a feature change.
- `security-analysis-tool` is left as-is (already single-purpose).

---

## 2. Target module layout

Child modules are nested **inside** each root module under `modules/<root>/modules/`.
This is the standard HashiCorp nested-`modules/` structure (one level deep). Because the
children live under the root, Terragrunt's local-path copy of `source` pulls the whole
subtree and the root wires children with plain relative paths (`./modules/networking`) —
no `//` copy-root marker required.

```
azure-terragrunt-simple-mws/modules/
├── account-config/                 # ROOT — provider: databricks.mws
│   ├── main.tf variables.tf outputs.tf versions.tf
│   └── modules/
│       ├── identities/             # admin group + SP member + admin (user) members
│       ├── metastore/              # databricks_metastore
│       └── networking/             # NCC + account network policy          [toggle]
│
├── workspace/                      # ROOT — providers: azurerm (default) + databricks.mws
│   ├── main.tf variables.tf outputs.tf versions.tf
│   └── modules/
│       ├── networking/             # rg, vnet, nsg + rules, subnets, nsg assoc,
│       │                           #   nat gw + pip + assoc, 3 private-dns zones + vnet links
│       ├── workspace/              # azurerm_databricks_workspace
│       │                           #   + backend PE + managed-storage dfs/blob PEs   [PE toggle]
│       └── bindings/               # metastore assign, permission assign,
│                                   #   ncc binding, workspace network option
│
├── workspace-config/               # ROOT — providers: azurerm (default) + databricks.workspace
│   ├── main.tf variables.tf outputs.tf versions.tf
│   └── modules/
│       ├── default-storage/        # storage acct + access connector + roles
│       │                           #   + container + dfs/blob PEs                     [PE toggle]
│       ├── unity-catalog/          # storage credential, ext location, catalog,
│       │                           #   schema, default namespace, grants
│       ├── default-compute/        # default cluster + sql warehouse                  [toggle]
│       └── settings/               # disable legacy dbfs / legacy access              [toggle]
│
└── security-analysis-tool/         # ROOT — unchanged
```

---

## 3. Resource → child-module mapping

Every resource currently in the stack maps to exactly one child module. No resource is
added or removed.

### 3.1 `account-config` root

| Child module | Resources moved in | Provider |
|---|---|---|
| `identities` | `databricks_group.admin_group`, `databricks_group_member.service-principal-admin-member`, `databricks_group_member.account-admin-members`, data `databricks_service_principal.this`, data `databricks_user.account-admins`, `locals.databricks_account_admins` | `databricks.mws` |
| `metastore` | `databricks_metastore.this` | `databricks.mws` |
| `networking` | `databricks_mws_network_connectivity_config.this`, `databricks_account_network_policy.this` | `databricks.mws` |

Root wiring: `metastore` receives the admin group display name from `identities`;
`networking` is gated by `enable_serverless_connectivity` (NCC) — the network policy is
always created (matches current behaviour where the policy has no `count`).

### 3.2 `workspace` root

| Child module | Resources moved in | Provider |
|---|---|---|
| `networking` | `azurerm_resource_group.this`, `azurerm_virtual_network.this`, `azurerm_network_security_group.this`, `azurerm_network_security_rule.aad`, `azurerm_network_security_rule.azfrontdoor`, `azurerm_subnet.{container,host,privatelink}`, `azurerm_subnet_network_security_group_association.{container,host}`, `azurerm_nat_gateway.this`, `azurerm_public_ip.this`, `azurerm_nat_gateway_public_ip_association.res-1`, `azurerm_subnet_nat_gateway_association.{container,host}`, `azurerm_private_dns_zone.{backend,dfs,blob}`, `azurerm_private_dns_zone_virtual_network_link.{backend,dfs,blob}` | `azurerm` |
| `workspace` | `random_string.this`, `azurerm_databricks_workspace.this`, `azurerm_private_endpoint.backend`, `azurerm_private_endpoint.dfs`, `azurerm_private_endpoint.blob`, `locals.workspace_root_storage_name` | `azurerm` |
| `bindings` | `databricks_metastore_assignment.this`, `time_sleep.wait_for_permission_apis`, `databricks_mws_permission_assignment.account-admins`, `databricks_mws_ncc_binding.this`, `databricks_workspace_network_option.this` | `databricks.mws` |

Notes:
- The NAT association and NSG association on the same subnet are orthogonal (routing vs
  filtering) and both remain, as today.
- The three `azurerm_private_endpoint` resources currently in the `workspace` root point
  at the workspace (`backend`) and the **managed-RG root DBFS storage** (`dfs`/`blob`).
  They move into the `workspace` child alongside the workspace resource, gated by the PE
  toggle. The DNS zones they resolve against move into `networking` (shared with the
  UC-storage PEs downstream).
- `random_string.this` + `locals.workspace_root_storage_name` move with the `workspace`
  child because the workspace resource consumes the generated storage name.

### 3.3 `workspace-config` root

| Child module | Resources moved in | Provider |
|---|---|---|
| `default-storage` | `azurerm_databricks_access_connector.this`, `azurerm_storage_account.this`, `azurerm_storage_container.this`, `azurerm_role_assignment.{blob_data_contrib,queue_contrib,event_contrib}`, `azurerm_private_endpoint.{dfs,blob}`, data `http.this` (ifconfig) + `locals.ifconfig_co_json` | `azurerm` |
| `unity-catalog` | `databricks_storage_credential.this`, `databricks_external_location.this`, `databricks_catalog.this`, `databricks_schema.this`, `databricks_default_namespace_setting.this`, `databricks_grant.{storage-credential,external-location,catalog,schema}` | `databricks.workspace` |
| `default-compute` | `databricks_cluster.default-classic-single-node`, `databricks_sql_endpoint.default-serverless-warehouse-small`, data `databricks_node_type.smallest`, data `databricks_spark_version.latest-lts` | `databricks.workspace` |
| `settings` | `databricks_disable_legacy_access_setting.this`, `databricks_disable_legacy_dbfs_setting.this` | `databricks.workspace` |

Notes:
- `data.databricks_node_type`/`data.databricks_spark_version` are consumed only by the
  compute resources → they live in `default-compute`.
- **DNS-zone lookup replaced by explicit dependency (the one interface change).** Today
  `default-storage`'s dfs/blob private endpoints resolve zones via
  `data "azurerm_private_dns_zone" {dfs,blob}` (name lookup in the workspace RG) and
  `data "azurerm_subnet" "privatelink"` (name lookup). These implicit,
  lookup-by-convention dependencies are replaced by explicit inputs
  (`dfs_private_dns_zone_id`, `blob_private_dns_zone_id`, `privatelink_subnet_id`) passed
  from the `workspace` unit's outputs through Terragrunt. This is the "config that impacts
  other Azure infra" seam made explicit.

---

## 4. Root-module public interfaces (the Terragrunt contract)

### 4.1 Inputs — unchanged names/types, plus new **optional** toggles

All existing input variable names and types on every root module are preserved, so the
current `inputs = {}` maps in `live/` keep working untouched. New toggles are added with
defaults that reproduce today's behaviour:

| Root | New optional variable | Type | Default | Effect |
|---|---|---|---|---|
| `workspace` | `enable_nat_egress` | `bool` | `true` | NAT gateway + pip + subnet assoc (`count`) |
| `workspace` | `enable_private_link` | `bool` | `true` | backend + managed dfs/blob PEs and their DNS zones/links (`count`) |
| `workspace-config` | `enable_private_link` | `bool` | `true` | UC-storage dfs/blob PEs (`count`) |
| `workspace-config` | `enable_default_compute` | `bool` | `true` | cluster + warehouse (`count`) |
| `workspace-config` | `disable_legacy_features` | `bool` | `true` | legacy dbfs/access settings (`count`) |
| `account-config` | `enable_serverless_connectivity` | `bool` | (already exists) | NCC (`count`) |

Defaults = `true` so a plan/apply with the current `live/` inputs is a no-op diff.

### 4.2 Outputs

| Root | Existing outputs (unchanged) | New outputs |
|---|---|---|
| `account-config` | `metastore_id`, `account_admin_group_id`, `account_admin_group_name`, `network_connectivity_configuration_id`, `network_policy_id` | — |
| `workspace` | `workspace_id`, `workspace_host`, `workspace_name`, `azure_resource_group_name` | `dfs_private_dns_zone_id`, `blob_private_dns_zone_id`, `privatelink_subnet_id` |
| `workspace-config` | `catalog`, `sql_warehouse_id` | — |
| `security-analysis-tool` | (unchanged) | — |

### 4.3 `live/` changes required (kept consistent)

Only the `workspace-config` unit changes, to consume the three new `workspace` outputs:

- `bu-*/workspace-config/terragrunt.hcl`:
  - add `dfs_private_dns_zone_id`, `blob_private_dns_zone_id`, `privatelink_subnet_id` to
    the `dependency "workspace"` block's `mock_outputs`.
  - add the same three keys to `inputs`, sourced from
    `dependency.workspace.outputs.<name>`.

No other `terragrunt.hcl`, `root.hcl`, or `*.hcl` config file changes. The four `source`
paths are unchanged. `terragrunt plan/apply --all` dependency graph is unchanged.

---

## 5. Provider handling

- **Root modules** keep the provider configuration they have today (generated
  `databricks.mws` from `root.hcl`; `databricks.workspace` configured in the
  `workspace-config` root from `var.workspace_host`; `azurerm` from `root.hcl`).
- **Child modules** declare only `terraform { required_providers { ... } }` with
  `configuration_aliases = [databricks.mws]` or `[databricks.workspace]` where they use an
  aliased provider. No `provider` blocks in children.
- The root passes aliased providers explicitly:
  ```hcl
  module "bindings" {
    source    = "./modules/bindings"
    providers = { databricks.mws = databricks.mws }
    ...
  }
  ```
  `azurerm` (default, unaliased) is inherited implicitly and need not be passed.

---

## 6. State migration (no destroy/recreate)

Because resources move into nested child modules, their Terraform addresses change
(e.g. `azurerm_virtual_network.this` → `module.networking.azurerm_virtual_network.this`).
To avoid destroy/recreate on the next apply, each root module ships a
`moved {}` block set (or a documented `terragrunt state mv` script) mapping every old
address to its new nested address. `moved` blocks are preferred — they are declarative,
run automatically on plan, and require no manual state surgery per BU/environment.

Every moved resource address will be enumerated in the implementation plan. Example:

```hcl
moved {
  from = azurerm_virtual_network.this
  to   = module.networking.azurerm_virtual_network.this
}
```

The refactor is verified by a `terragrunt plan --all` showing **only `moved` operations
and zero resource replacements** against existing state.

---

## 7. Open judgment calls (resolved)

- `default-storage` (azurerm) and `unity-catalog` (databricks.workspace) kept **separate**
  rather than merged into one SRA-style `catalog` module — each child stays single-provider,
  cleaner seam, independently testable.
- `default-compute` and `settings` kept as **two** small toggleable children (different
  lifecycles: provisioning vs governance).
- All private endpoints live **with the resource they front** (workspace PEs in the
  `workspace` child, UC-storage PEs in `default-storage`), matching SRA.

---

## 8. Success criteria

1. `terragrunt plan --all --working-dir ./live` (against existing state) shows only
   `moved` operations — **zero** creates/destroys/replacements.
2. All four `source` paths in `live/` are unchanged.
3. Every existing root-module input variable and output name/type is preserved; the only
   `live/` edit is the three added keys in the `workspace-config` unit.
4. No child module contains a `provider` block; aliased providers are passed explicitly.
5. Each toggle defaults to reproducing current behaviour (no-op diff when unset).
6. `terraform validate` passes for each root module.
