# azure-terragrunt-simple-mws — modularization & feature-flag plan

**Status:** IMPLEMENTED on branch `feature/azure-simple-modularization`. Validated via `terragrunt validate`
per unit + full-stack DAG check (no cycles); real apply pending Azure credentials.
Final layout: 8 units — `common/account-config`, `bu-1/network` (generic: RG/vnet/NAT/extra_subnets),
`bu-1/databricks/network` (Databricks: NSG+egress rules, delegated subnets, DNS zones), `bu-1/storage`,
`bu-1/databricks/{workspace,workspace-config,uc}`, `bu-1/security-analysis-tool` — over Tier-1 `_blocks`
(resource_group, vnet, nsg, nat, subnet, dns_zone, private_endpoint) + pattern modules.

Post-plan fix: the original single `network` unit was Databricks-centric but sat at BU root, and its private
DNS zones were created unconditionally (ignoring the PL flags). Split into a generic `network` unit and a
Databricks-scoped `databricks/network` unit; DNS zones now gated (backend on enable_backend_privatelink;
dfs/blob on backend OR external_location PL). DAG: network -> databricks/network -> {storage, workspace} -> uc -> ... -> sat.

This supersedes the earlier flat "count-gated files in one workspace module" draft. The stack is being
repositioned from a Databricks-only lab toward a **BU landing-zone reference**: a `bu-X` folder should be
able to hold *all* infrastructure for a business unit (network, storage, governance, Databricks, and
potentially non-Databricks workloads), not just a Databricks workspace.

Design rules come from memory: `feature-flag-cascade-design`, gap context `azure-simple-sra-gap-analysis`.

---

## 1. Three-tier architecture

```
modules/
  _blocks/                 # TIER 1 — granular, generic, reusable resource modules (purpose-AGNOSTIC)
    vnet/  subnet/  nsg/  nat/  dns_zone/  private_endpoint/
    databricks_workspace/  metastore/  ncc/  network_policy/
    storage_account/  access_connector/  external_location/  catalog/  ...
  network/                 # TIER 2 — pattern modules: compose _blocks BY PURPOSE (purpose-SCOPED)
  storage/
  uc/
  account-config/
  workspace/
  workspace-config/
  security-analysis-tool/

live/<env>/<region>/<bu>/  # TIER 3 — Terragrunt units: 1 unit = 1 pattern module = 1 STATE
```

- **Tier 1 (`_blocks`)** — generic capability, knows nothing about Databricks. Takes inputs (delegations, NSG
  rules, CIDRs), returns outputs. Blocks NEVER reference each other or Tier 2. This is where per-resource
  granularity lives — NOT in extra Terragrunt units.
- **Tier 2 (pattern modules)** — opinionated composition of blocks for one purpose. This is where the
  Databricks-specific knowledge lives (e.g. the `Microsoft.Databricks/workspaces` subnet delegation,
  `AllowAAD`/`AllowAzureFrontDoor` NSG rules).
- **Tier 3 (Terragrunt units)** — one pattern module each, own state, wired via `dependency`. Split ONLY at
  ownership/lifecycle seams (see §2). Terragrunt only ever references the Tier-2 pattern module.

### Layer discipline (non-negotiable)
1. `_blocks` are leaves: no block calls another block or a pattern module. Composition only flows down.
2. **Provider aliases are passed in.** Blocks using `databricks.mws` / `databricks.workspace` receive
   `providers = { databricks = ... }` from the pattern module. Get this convention right on block #1.
3. Keep atomic resource groups whole inside one block (nat = gw+ip+associations; a dns_zone block = zone +
   vnet-link). Don't shatter below the atomic-lifecycle line.
4. Don't create a block used exactly once with no variation and no standalone meaning — leave it inline.
   Extract blocks as reuse/variation actually appears, not speculatively.
5. Feature flags become `count`/`for_each` on block calls; the stable-output contract (§4) applies at the
   **pattern module's** outputs (that's what Terragrunt/`dependency` sees).

---

## 2. Terragrunt unit inventory (Tier 3) — the carve

Carve test applied to every candidate: **shared lifecycle + distinct owner + independently applied/reused.**
Strongest signal: "does this outlive the workspace / would you refuse to destroy it with the workspace?"

```
live/dev/westeurope/
  common/
    account-config/          # metastore, account groups, NCC, network policy   (regional / shared)
  bu-1/
    network/                 # vnet, subnets (incl. non-dbx), nsg, nat, dns zones   ← BU-owned landing-zone net
    storage/                 # UC data storage account(s)/container(s) + role assignments  ← longest lifecycle
    databricks/
      uc/                    # external location, storage credential, catalog, schema, grants
      workspace/             # workspace + backend private endpoints + metastore/permission assignments
      workspace-config/      # compute (clusters, warehouses) + workspace settings (legacy toggles)
    security-analysis-tool/  # SAT (already its own unit)
```

**Carved (passed the test):**
- `network` — separate lifecycle, network/platform-team owned, reused by workspace AND non-Databricks
  workloads. Directly answers "BU wants to plug an extra subnet in" (see §3).
- `storage` — data outlives every workspace; data/governance-team owned; `force_destroy=false` discipline.
- `uc` — governance layer; consumes `storage` + `account-config`; renamed from "catalog", placed under
  `databricks/` since it's Databricks-domain governance on top of BU-owned storage.
- `account-config` — account/regional altitude (already correct).
- `security-analysis-tool` — account-wide tool (already correct).

**NOT carved (would be over-decomposition):**
- Compute → stays in `workspace-config` (ephemeral, workspace-local, cheap to recreate).
- Workspace root DBFS storage → Azure-managed in the managed RG, not ours to split.
- Inside `network`: vnet/subnet/nsg/nat/dns all share one owner+lifecycle → stay one unit. Granularity comes
  from `_blocks`, not more units. **`network` is NOT split further.**

**DAG (one-directional):**
`account-config → network, storage → uc → workspace → workspace-config → sat`
(`uc` depends on storage + account-config; `workspace` depends on network + uc; backend PEs live in
`workspace` and consume dns_zone_ids from `network`.)

### Placement decisions locked
- backend private endpoints live in the **`workspace`** unit (they need the workspace resource ID),
  consuming `dns_zone_ids` from the `network` dependency — keeps `network` free of any workspace dependency.
- NAT + DNS zones live in **`network`**.

---

## 3. The "extra non-Databricks subnet" scenario (design driver)

Because `network` is BU-owned (not workspace-owned), adding a non-Databricks subnet is **data, not code**.
The network pattern module exposes subnets as a map (SRA convention):

```hcl
variable "extra_subnets" {
  type    = map(object({ name = string, new_bits = number }))
  default = {}
}
```
```hcl
# live/.../bu-1/network/terragrunt.hcl
inputs = {
  extra_subnets = { app-tier = { name = "app-snt", new_bits = 4 } }   # non-Databricks subnet
}
```
The `workspace` unit consumes only its subnets via a typed `network_configuration` object; the extra subnet
ID is a separate `network` output another workload consumes. One VNet, multiple consumers, clean seams.

---

## 4. Interface conventions (SRA-aligned — the real alignment payload)

1. **Typed `network_configuration` object** output by `network`, consumed by `workspace` as one variable:
   `{ virtual_network_id, private_subnet_id, public_subnet_id, private_endpoint_subnet_id,
      private_subnet_nsg_association_id, public_subnet_nsg_association_id }`.
   This single seam is what makes **BYO-network** a wiring swap later (dependency → external state / data
   source) with no module rewrite.
2. **`dns_zone_ids` object** `{ backend, dfs, blob }` output by `network`, consumed by `workspace` (backend
   PEs) and `uc`/`storage` (external-location PEs) — replaces today's fragile name-based
   `data.azurerm_private_dns_zone` lookup in `workspace-config`.
3. **Pass-through chaining outputs** — each module re-emits `resource_suffix`, `tags`, and the IDs downstream
   needs, so consumers read upstream outputs instead of re-deriving.
4. **Stable output contract** — output shape never changes with a flag. `count`-gated resource → scalar id
   `""` when off (`one(res[*].id)` normalized), object → keys always present with `""` values. `mock_outputs`
   in each leaf `terragrunt.hcl` mirror the shape. Combination-validation (e.g. "external-location PL needs
   dns zones") lives in module `variable validation`, not Terragrunt.
5. Provider version pinning: add `versions.tf` per module (today `required_providers` has `source` but no
   `version`).

---

## 5. Feature flags — existing functionality only

Defaults preserve current behavior. Flags gate resources that exist in the repo today.

| Flag | Gates (existing) | Owning unit | Default | Cascade level |
|---|---|---|---|---|
| `enable_serverless_connectivity` | NCC (already gated) + account network policy | account-config | `false` | env / common |
| `enable_nat_gateway` | nat block (gw+ip+assoc) | network | `true` | BU / leaf |
| `enable_backend_privatelink` | backend PEs (dns zones stay always-on) | workspace | `true` | BU / leaf |
| `enable_external_location_privatelink` | dfs/blob PEs for UC storage | uc / storage | `true` | BU / leaf |
| `enable_default_compute` | sample cluster + SQL warehouse | workspace-config | `true` | env / leaf |
| `disable_legacy_access` | disable legacy access + dbfs settings | workspace-config | `true` | env |

**Reserved extension points (NOT built — flag names + `# extension point` markers only):**
- `cmk_enabled` → `workspace` (Key Vault + managed_disk/services CMK + infra encryption).
- `enable_compliance_profile` → `workspace` (`enhanced_security_compliance {}` block).
- `enable_frontend_privatelink` → `workspace` (flips the currently-hardcoded `public_network_access_enabled`).
- **NSP** → reserved `nsp/` unit seam + optional `nsp_association` input on `storage`. NSP was fully removed
  from the modules already (deliberate; only dangling var/output stubs remained). Model later as its own
  `nsp/` unit (perimeter + profile + associations, taking resource IDs via dependency) IF re-adopted — it's
  security-team-owned and spans multiple resources. Preview-adjacent, so reserve-only for now.
- **DNS altitude** → if private DNS zones ever get centralized org-wide, they migrate from `network` to
  `common`/global and `network` consumes them (swappable zone source: create-in-network vs. BYO zone-ids).
  Reserve the seam; don't build.

---

## 6. Cascade wiring (extends existing files — no parallel tree)

**`live/root.hcl`** (next to `default_tags`):
```hcl
feature_baseline = {
  enable_serverless_connectivity       = false
  enable_nat_gateway                   = true
  enable_backend_privatelink           = true
  enable_external_location_privatelink = true
  enable_default_compute               = true
  disable_legacy_access                = true
  # reserved extension points (kept false):
  cmk_enabled                          = false
  enable_compliance_profile            = false
  enable_frontend_privatelink          = false
}
feature_flags = merge(
  local.feature_baseline,
  try(local.environment.features, {}),
  try(local.region.features, {}),
  try(local.business_unit.features, {}),
)
```
- `environment.hcl` / `region.hcl` / `business-unit.hcl` gain an OPTIONAL `features = {}` local (omit keys you
  don't override; `try(..., {})` makes every level optional). Flat bool map (shallow-merge safe).
- leaf `terragrunt.hcl`: `flags = merge(include.root.locals.feature_flags, { <this-workspace overrides> })`,
  then pass only the flags the module consumes into `inputs`.

---

## 7. Incremental execution order

Each step = one reviewable change; `terragrunt plan` (mock-driven) after each. Extract blocks as needed per
step — don't pre-build all of `_blocks`.

1. **Cascade scaffolding** — add `feature_baseline`/`feature_flags` to `root.hcl`; leave hierarchy `features`
   blocks empty. No behavior change. Validates the merge plumbing.
2. **`network` unit** (the reference carve) — extract `network` pattern module from today's `workspace`
   module (vnet, subnets, nsg, nat, dns zones); introduce `_blocks/vnet`, `_blocks/subnet`, `_blocks/nsg`,
   `_blocks/nat`, `_blocks/dns_zone`; output `network_configuration` + `dns_zone_ids`; flag `enable_nat_gateway`;
   `extra_subnets` map. New `live/.../bu-1/network/terragrunt.hcl`.
3. **`workspace` unit** — slim to workspace resource + backend PEs + assignments; consume `network` via
   `dependency` (typed object + dns_zone_ids); flag `enable_backend_privatelink`; reserved extension-point
   markers for cmk/compliance/frontend-PL.
4. **`storage` unit** — carve UC storage account/container/role-assignments out of `workspace-config`;
   `force_destroy=false`; own state.
5. **`uc` unit** — external location + storage credential + catalog + schema + grants; consume `storage` +
   `account-config`; `enable_external_location_privatelink`; place under `databricks/`.
6. **`workspace-config` unit** — slim to compute + settings; flags `enable_default_compute`,
   `disable_legacy_access`; ensure `sql_warehouse_id` `""` sentinel when compute off (SAT consumes it).
7. **`account-config`** — extend `enable_serverless_connectivity` to also gate the account network policy.
8. **Convention cleanups** — fix `variable "region"` "AWS region" descriptions; add `versions.tf`; review
   `account-config/locals.tf` admin fallback (`== [] ` → `length(...) == 0`).

Folder-structure note: step 2+ introduce the `databricks/` sub-grouping and new units. **Decision (resolved):
keep the folder/stack name `azure-terragrunt-simple-mws` and apply this full design in place — no fork, no
rename.** ("simple" stays as the stack name; it is not being split into a separate `azure-landing-zone` stack.)
