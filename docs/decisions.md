# Decision Log

Each entry: what we chose, what else we considered, and why.

## D-001 Region: us-east-1
Alternatives: us-east-2, us-west-2. Bedrock model availability (Claude, Titan Embeddings v2) is widest and earliest in us-east-1, and keeping S3, Lambda, and Bedrock in one region avoids cross-region transfer cost and latency. Tradeoff: us-east-1 has had the most widely felt outages. At company scale, region choice is driven first by data residency.

## D-002 Human access: IAM Identity Center, not IAM users with access keys
Alternatives: IAM user + static keys. Identity Center gives short-lived credentials (4h sessions) through `aws sso login`, with MFA on every sign-in. Static keys never expire and are the most common cause of AWS account compromise. Identity Center is free.

## D-003 Cost guardrails: $15 monthly budget + Cost Anomaly Detection
Alternatives: CloudWatch billing alarms, third-party FinOps tools. Budgets alert at 50%/80% actual and 100% forecast; anomaly detection flags $3+ spikes per service. Both are free. Known limit: billing data lags hours, so alerts are a backstop, not a kill switch. Real protection is scale-to-zero design and timeouts.

## D-004 Repo: public monorepo
Alternatives: polyrepo, private repo. One engineer, frequent cross-component changes, so atomic commits and one CI config win. Public gives unlimited Actions minutes, free secret push protection, and recruiter visibility. Consequence: no secrets or personal values ever committed (tfvars gitignored, email in GitHub secret).

## D-005 Dev environment: GitHub Codespaces with a dev container
Alternatives: local Mac (no disk space), EC2 dev box (idle cost), Cloud9 (closed to new customers). Free quota covers about 60 hours/month on 2-core. Toolchain is version-controlled in `.devcontainer/`. Built from a Dockerfile that removes the base image's stale Yarn apt repo, which otherwise broke every feature install.

## D-006 Secret scanning: pre-commit locally + gitleaks in CI + GitHub push protection
Alternatives: push protection only, TruffleHog. Pre-commit blocks before the commit exists; CI is the enforcement point because local hooks can be skipped; push protection is a third layer. Learned: scanners allowlist documented example keys, and `detect-aws-credentials` only matches keys in local AWS config files, so a passing scan proves little. The real control is having no long-lived secrets.

## D-007 IaC: Terraform, not CDK/CloudFormation/Pulumi
Alternatives: AWS CDK, CloudFormation, Pulumi. Terraform is the most-requested IaC skill in DE/MLE job descriptions, works across clouds and SaaS (Snowflake, GitHub), and its plan output is easy to review. CDK would be reasonable for an AWS-only team.

## D-008 Remote state: S3 with native lockfile, not DynamoDB locking
Alternatives: S3 + DynamoDB lock table (older pattern, now deprecated), Terraform Cloud, local state. Terraform 1.10+ locks with an S3 conditional write (`If-None-Match: *`), so no second service. Bucket has versioning (state rollback), SSE-S3, Block Public Access, TLS-only policy, and `prevent_destroy`.

## D-009 State bucket encryption: SSE-S3, not SSE-KMS
Alternatives: SSE-KMS with a customer-managed key. State holds no real secrets yet; SSE-S3 is free. KMS ($1/key/month plus requests) will be reconsidered for document buckets in Module 9, where separate decrypt control and audit trails matter.

## D-010 Stack layout: bootstrap stack + per-environment stacks
Alternatives: one big stack. Bootstrap (state bucket, OIDC provider, CI roles) is applied by a human because CI cannot create the role it uses to log in. Splitting stacks limits blast radius and lock contention.

## D-011 CI auth: GitHub OIDC federation, not stored AWS keys
Alternatives: IAM user keys in GitHub secrets. OIDC issues a signed JWT per job; AWS verifies it and checks `aud` and `sub` in the role trust policy. Nothing to leak or rotate; credentials expire within an hour.

## D-012 Two CI roles: read-only plan, environment-gated apply
Alternatives: one role for everything. Plan runs on unreviewed PR code, so ReadOnlyAccess plus lockfile write only. Apply trusts only `environment:dev`, which requires main and a human approval. Apply role is AdministratorAccess for now (Terraform must create IAM, Lambda, etc.); Module 9 adds a permissions boundary.

## D-013 OIDC subject format: GitHub immutable IDs
Trust policies match `repo:Nayan2701@90122933/docintel@1409089181:...`, not `repo:Nayan2701/docintel:...`. Found by decoding the token's claims in a workflow after AssumeRoleWithWebIdentity failed. Numeric IDs prevent repo-name takeover: a recreated repo with the same name cannot assume the roles.

## D-014 Apply re-plans on main instead of reusing the PR plan artifact
Alternatives: upload plan file from PR, apply that exact file. Plan files contain variable values in plaintext and artifacts on public repos are downloadable. Re-planning inside the gated apply job is the safe choice for a public repo.

## D-015 Pin runners and base images; avoid floating tags
`runs-on: ubuntu-24.04` instead of `ubuntu-latest` (which moved to Ubuntu 26 on 2026-10-19). Actions upgraded off Node 20. Next step (Module 9): pin actions by commit SHA and base images by digest.

## D-016 Module order: evaluation (Module 7) before Jev routing (Module 6)
Routing exists to cut cost without hurting quality; that claim needs a golden set and baseline RAGAS scores to measure against.

## D-017 Observability: Langfuse Cloud free tier, not self-hosted
Self-hosted Langfuse needs Postgres, ClickHouse, Redis, and S3 running permanently, which exceeds the whole monthly budget while idle.
