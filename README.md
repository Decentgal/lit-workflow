# WOGO API Enterprise DevSecOps Pipeline

**Project Goal:** A production-ready DevOps infrastructure pipeline for a Python FastAPI application on Azure following this workflow:

**Code > GitHub > PR > Merge > Azure Pipelines > Dev > PR > Merge > Azure Pipelines > Live on Production.*

Terraform creates the base infrastructure to host the application. It's not used in the code push.

This project follows strict separation of duties, Zero-Trust OIDC authentication, and a 4-stage automated security gate.


## The Tech Stack & DevSecOps Tools
* **App:** Python 3.11, FastAPI, Uvicorn.
* **Containerization:** Docker (multi-stage, non-root build).
* **Infrastructure-as-Code:** Terraform (Decoupled Platform & Application layers).
* **Authentication:** OIDC Workload Identity Federation (no stored secrets). 
* **Cloud:**  Azure student account, southafricanorth region, Azure App Service (Linux), Azure Container Registry.
* **CI/CD:** Azure Pipelines.
* **Monitoring & Observability:** Azure Application Insights & Log Analytics
* **Security Scanners:**
  - **Bandit (SAST):** Scans Python code for hardcoded secrets and vulnerabilities.
  - **Trivy (SCA):** Scans dependencies and Docker images for known CVEs.
  - **Checkov (IaC):** Scans Terraform for cloud misconfigurations (open storage account, missing encryption).
  - **OWASP ZAP (DAST):** Attacks the live deployed application to test for runtime exploits (injection, auth bypass, XSS, ect).


## Cost Budget
![alt text](image-2.png)


## Architectural Diagram

This project is named **WOGO** and was built in the **lit-workflow** directory.

![alt text](image.png)

![alt text](image-1.png)

This directory contains: Application codes, Test code, Root/Config files, Terraform, Azure pipelines.


## Architecture & Pipeline Flow

I followed a strict GitOps workflow. 
1. Infrastructure is provisioned once via Terraform. 
2. Push to GitHub feature/branch. All application updates happen automatically via Azure Pipelines.
3. **Pull Request (Feature → Dev):** Triggers `ci-pipeline.yml`. Runs Bandit, Trivy, Checkov, Pytest, and builds the Docker image. *Must pass to merge.*
4. **CD Dev (Merge to Dev):** Triggers `cd-dev.yml`. Deploys to the Dev App Service and runs an OWASP ZAP attack against the live dev environment. 
5. **CD Prod (Merge to Main):** Triggers `cd-prod.yml`. Runs strict security gates (fails on HIGH), builds the prod image, waits for **Manual Approval**, deploys to Prod, and runs a final ZAP verification.


# Branch-strategy
main    → production (protected, requires PR + approval)
dev     → staging (protected, requires PR + status checks)
feature → where all work happens (temporary, deleted after merge)

`Security gates are stricter in production than in dev. A HIGH-severity finding that is reported in dev will block a production deployment entirely.`


## Environment URLs

**Development:** `https://wogo-dev-app-XXXX.azurewebsites.net` triggers merge to dev
**Production:** `https://wogo-prod-app-XXXX.azurewebsites.net` triggers merge to main + manual approval.
**Monitoring Dashboard:** Azure Portal → Application Insights → wogo-appinsights triggers is always on.


## INFRASTRUCTURE SETUP VIA TERRAFORM

# Authenticate to Azure
az login

# Platform Layer (creates Resource Groups & Azure Policy)
cd terraform/platform
cp terraform.tfvars.example terraform.tfvars # Edit with your Sub ID
terraform init && terraform apply

# Application Layer (creates ACR, App Service, Key Vault, Monitoring)
cd ../application
cp terraform.tfvars.example terraform.tfvars # Edit with your Sub ID
terraform init && terraform apply


## 3. AZURE DEVOPS SETUP

To connect the automated pipelines to your new infrastructure:

**Service Connections:** Create an Azure Resource Manager connection using Workload Identity Federation (OIDC) (no secrets stored!) named azure-wogo-sc.

**Variable Group:** Create a library group named wogo-global-vars containing your Terraform outputs (e.g., DEV_APP_URL, ACR_NAME, DEV_RESOURCE_GROUP).

**Run Pipelines:** Import the 3 YAML files from .azure-pipelines/ and run them.

`No one commits directly to main or dev. All changes flow through Pull Requests.`


## API Endpoints

`GET /` - API Status (Root confirms the API is running)
`GET /api/v1/health`  (Health check used by Azure and OWASP ZAP)
`GET /docs` (Interactive Swagger UI)
`GET /openAPI.json` (OpenAPI schema consumed by OWASP ZAP for DAST)


# Monitoring and Observability

Azure Application Insights connects to both App Services automatically via an environment variable injected by Terraform. Once traffic hits the app, the dashboard shows:

- Live requests per second and response times per endpoint
- Failed requests and full exception stack traces.
- Uptime percentage over time and full searchable log history.

An Azure Monitor alert sends an email notification if production returns more than 5 HTTP 500 errors within 5 minutes — the foundation of 99% uptime management.


# Open ID Connect (OIDC) - Zero-Trust Authentication

No client secrets are stored anywhere. Azure Pipelines uses Workload Identity Federation to prove its own identity to Azure and receive a short-lived token on every pipeline run. The Service Principal identity exists while the password does not.


### 1. Local Development
```bash
# Clone and setup virtual environment
git clone [https://github.com/YOUR_USERNAME/lit-workflow.git](https://github.com/YOUR_USERNAME/lit-workflow.git)
cd lit-workflow
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt

# Run the API locally
uvicorn app.main:app --reload --port 8000
# Visit http://localhost:8000/docs

# Run tests 
pytest tests/ -v 

# Run security scans locally 
bandit -r app/ --severity-level medium 
checkov --directory terraform/ --framework terraform


## Note: Restrictions of role assignments (Resource Policy Contributor role ) on the Azure Student account resorted to the manual assignment of the Azure Policy deny guardrail for PostgreSQL and ACRPull permissions for both App Services rather than applying it at the subscription scope.

# In a production enterprise subscription, this policy would be applied as written in the code. Nontheless, both assignments are visible and active in the wogoacrXXXX IAM blade.