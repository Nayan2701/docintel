# Concept Glossary

| Term | Like I'm 17 | Engineer explanation |
|---|---|---|
| Region | Which city's warehouse your stuff lives in | Isolated geographic area (e.g. us-east-1) with its own control plane and endpoints; most resources are regional |
| Availability Zone (AZ) | Separate buildings in the same city | Isolated data centers within a region with independent power, low-latency links; spread across AZs for high availability |
| Root user | The master key that can even sell the building | Account-creation identity with unrestricted access no IAM policy can limit; MFA on, no access keys, used almost never |
| MFA / TOTP | A code from your phone that changes every 30 seconds | HMAC(shared seed, time/30s) truncated to 6 digits; phishable by real-time relay, unlike FIDO2 which binds to the site's origin |
| IAM | Security desk deciding which badge opens which door | Identities (users, groups, roles) plus JSON policies (Effect, Action, Resource, Condition) |
| Policy evaluation | Any "never" beats every "yes"; no rule means no | Explicit Deny wins; otherwise an Allow is required in every applicable layer (SCP, boundary, session, identity/resource); else implicit deny |
| User vs role | Permanent keycard vs a visitor wristband | Users have long-lived credentials; roles are assumed and return temporary STS credentials |
| STS | The wristband desk | Security Token Service: issues access key, secret, session token, and expiry |
| SigV4 | Proving you know a password without saying it | Requests signed with HMAC-SHA256 using a key derived from the secret, date, region, and service; the secret never travels |
| IAM Identity Center | One login screen that hands out wristbands | AWS SSO: permission sets become `AWSReservedSSO_*` roles; CLI uses `aws sso login` for short-lived credentials |
| OAuth device code flow | Logging into Netflix on a TV with a code from your phone | RFC 8628: terminal gets a user code, you approve in a browser, terminal polls for the token; used because Codespaces can't receive a localhost redirect |
| AWS Budgets | Your bank texting you at half your allowance | Threshold alerts on actual or forecasted cost; not real-time, not a kill switch |
| Cost Anomaly Detection | A friend who notices you suddenly spending weird amounts | ML model per service flags unusual spend even under budget |
| Cost allocation tags | Labels on receipts so you know which project spent what | Tag keys activated in Billing so Cost Explorer can filter by `project`, `environment` |
| Monorepo | One binder with tabs | All components in one repo; atomic cross-component commits; needs path-filtered CI |
| Dev container | A cloud kitchen built from a setup list on the door | Docker container defined by `devcontainer.json` holding the toolchain; reproducible environment |
| Codespaces | Renting that kitchen by the hour | GitHub-hosted VM running the dev container; disk persists when stopped, deleted on delete |
| Supply-chain risk | Your build breaking because a supplier changed something | Builds depend on third-party repos, images, and actions; mitigate by pinning versions, digests, SHAs |
| pre-commit hook | Bouncer checking your bag before it goes in the locker | Script run before Git writes a commit; non-zero exit aborts; framework manages hook environments |
| gitleaks / entropy | Spotting random-looking text that's probably a password | Regex rules for known secret formats plus Shannon entropy threshold; allowlists documented example keys |
| Infrastructure as Code | An instruction booklet instead of building from memory | Declarative config describing desired resources; versioned, reviewable, reproducible |
| Terraform provider | A translator to one service's language | Plugin mapping resources to API calls (aws_s3_bucket to CreateBucket, etc.) |
| Dependency graph | Doing steps in the right order, in parallel when possible | Terraform builds a DAG from references; walks it with parallelism 10 by default |
| plan / apply | Showing the teacher what you'll change, then changing it | plan diffs config vs state vs reality without changes; apply executes the diff |
| Terraform state | Terraform's notebook of what it built | JSON mapping config addresses to real resource IDs and attributes; may contain secrets |
| Remote backend | Keeping the notebook in a shared safe | State stored in S3 so humans and CI share one copy |
| State locking | Only one person writes in the notebook at a time | S3 conditional write creates `.tflock`; second writer gets 412 and fails |
| Bootstrap problem | You need a safe to store the safe's combination | State bucket created with local state, then that stack's state migrated into the bucket |
| terraform import | Adding a hand-built piece to the notebook | Import block maps an existing resource ID to an address; plan must show import with no replacement |
| S3 Block Public Access | A door that can never be propped open | Account/bucket setting evaluated before policies and ACLs; overrides any public grant |
| SSE-S3 vs SSE-KMS | Locked box vs locked box with a separately guarded key | Both encrypt at rest; KMS adds key policies, CloudTrail per decrypt, cost per key and request |
| S3 versioning | Keeping every old draft | Each overwrite keeps the prior version; enables rollback; pair with lifecycle expiry |
| CI / CD | Robot that checks homework, then files it | Automated checks per change; automated release of passing changes, optionally gated |
| GitHub Actions runner | A fresh, disposable computer per job | Ephemeral VM executing a job's steps; destroyed afterward |
| OIDC federation | A signed hall pass instead of a house key | CI gets a JWT from GitHub; AWS STS verifies signature and checks claims, then issues temporary credentials |
| JWT | A signed note anyone can read but no one can forge | header.payload.signature (RS256); claims in payload; verified with issuer's public keys (JWKS) |
| aud / sub claims | Who the note is for / who's holding it | `aud` = sts.amazonaws.com; `sub` = repo + context (pull_request, ref, environment) |
| Immutable sub claim | Using ID numbers instead of names on the pass | `repo:owner@ownerId/repo@repoId:...`; prevents takeover by recreating a repo with the same name |
| GitHub Environment | A door that needs a teacher's signature | Deployment target with protection rules (required reviewers, allowed branches); changes the OIDC `sub` |
| Branch ruleset | No one walks straight into the main hall | Rules on main: PR required, status checks required, no force push, no deletion |
