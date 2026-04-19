## What this PR do?
It explains what changed and why.

## Related Issue
Closes #

## Types of change
New feature
Bug fix
Security patch
Infrastructure change (PostgreSQL and ACRPull policy removal at sub level)
Pipeline change
Dependency update
Documentation update

## Infrastructure change

Restrictions of role assignments (Resource Policy Contributor role ) on the Azure Student account resorted to the manual assignment of the Azure Policy deny guardrail for PostgreSQL and ACRPull permissions for both App Services rather than applying it at the subscription scope.

**In a production enterprise subscription, this policy would be applied as written in the code. Nontheless, both assignments are visible and active in the wogoacrXXXX IAM blade.*


## Testing Done
I ran uvicorn app.main:app --reload locally — app starts without errors.
I ran `pytest tests/ -v` locally and all tests passed.
I ran `bandit -r app/ --severity-level medium` locally and no new findings.
I built Docker image locally successfully by running `docker build -t wogo .`
I visited http://localhost:8000/docs locally and Swagger UI loads correctly.


## Self-Review Checklist
I tested this project locally before opening the PR.
My code follows the DevOps structure and wogo naming conventions.
If Terraform was updated, run `terraform fmt` and `terraform validate`
`terraform.tfvars` and `.env` files are NOT included in this PR.

## Security Checklist
No secrets, passwords, or API keys are hardcoded in this code.
All user inputs are strictly validated using Pydantic models.
Dependencies are pinned to specific versions in requirements.txt

## Reviewer Notes: