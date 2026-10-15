# Interview Cheat Sheet: Document Intelligence Platform

## One-line pitch
A serverless, multimodal RAG platform over real public finance (SEC EDGAR) and healthcare (openFDA, ClinicalTrials.gov, PubMed Central) documents, built with production practices on a $5-15/month budget.

## Architecture (planned; [x] = built)
- [x] Foundations: Identity Center SSO, budget + anomaly alerts, Terraform with S3 remote state, GitHub Actions with OIDC, protected main
- [ ] Ingestion: EventBridge Scheduler -> Lambda fetchers -> S3 raw/, content-hash dedup in DynamoDB
- [ ] Processing: Step Functions -> Docling on Fargate -> multimodal descriptions -> chunking -> metadata -> DQ checks
- [ ] Indexing: Bedrock Titan Embeddings v2 -> LanceDB on S3 (vector + full-text)
- [ ] Query: API Gateway -> Lambda (FastAPI + Mangum) -> router -> hybrid search + RRF -> reranker -> cited answer
- [ ] Quality/ops: RAGAS golden set in CI, Langfuse Cloud, CloudWatch, semantic cache
- [ ] Security: least privilege, permissions boundary, prompt-injection defense, PII handling

## Key numbers
| Metric | Value |
|---|---|
| Documents indexed | TBD (Module 1: target 1,000; later 20,000+) |
| p50 / p95 query latency | TBD (Module 5) |
| Cost per query | TBD (Module 8) |
| RAGAS faithfulness / answer relevancy | TBD (Module 7) |
| Monthly AWS cost so far | ~$0 |

## Module 0: what I built and why
**Account and identity.** Root has MFA, no keys, unused. I log in through IAM Identity Center and get 4-hour credentials; the CLI uses the device code flow because Codespaces can't receive a localhost redirect.

**Cost.** $15 budget with 50/80% actual and 100% forecast alerts, plus anomaly detection at $3. I know billing lags hours, so design (scale to zero, timeouts) is the real control.

**Infrastructure as code.** Terraform with two stacks. Bootstrap holds the state bucket, OIDC provider, and CI roles, applied by me. `envs/dev` holds everything else, applied only by CI. State in S3 with native lockfile locking (conditional writes), versioning, SSE-S3, TLS-only, Block Public Access, `prevent_destroy`. I brought a console-created budget under Terraform with an import block.

**CI/CD.** PRs run pre-commit, a full-history gitleaks scan, `fmt`/`validate`, and a read-only `terraform plan` posted to the job summary. Merges to main run plan then apply, gated by a GitHub Environment requiring approval. AWS access is OIDC; no stored keys anywhere.

## Hard questions
**Q: How does CI deploy to AWS without keys?**
GitHub mints a signed JWT per job. STS verifies it against GitHub's public keys and checks the role's trust policy: `aud` must be sts.amazonaws.com and `sub` must match my exact repo plus context. Plan role trusts PRs and main; apply role trusts only the `dev` environment, which requires approval.

**Q: Tell me about a hard bug.**
CI failed with "Not authorized to perform sts:AssumeRoleWithWebIdentity" even though the trust policy looked right. Instead of guessing, I added a temporary job that decoded the OIDC token claims. GitHub was sending the immutable subject format with numeric owner and repo IDs. I updated the trust policies to match, which is also more secure because a recreated repo with the same name can't assume the role.

**Q: Two people run terraform apply at the same time?**
The second fails to get the lock: Terraform creates the `.tflock` object with a conditional write, and S3 returns 412 if it exists. Without locking, last writer wins and state no longer matches reality.

**Q: Why is your apply role admin? Isn't that bad?**
Terraform has to create IAM roles, Lambdas, and buckets, so the apply role is broad. The control is the trust policy: only an approved job in the `dev` environment from main can assume it, and main is protected. Next step is a permissions boundary so roles Terraform creates can't exceed a ceiling.

**Q: What almost went wrong?**
Running `terraform plan` locally on main before the PR merged showed it wanted to destroy the OIDC provider and CI roles, because main didn't have that code yet. That's why applies happen only from CI on main.

**Q: How do you keep builds reproducible?**
Pinned runner OS (ubuntu-24.04), Terraform version, provider lock file committed, dev container from a Dockerfile. A floating base image tag broke my dev container when a third-party apt repo rotated its key, which is the supply-chain risk pinning prevents.
