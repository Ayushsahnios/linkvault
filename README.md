# LinkVault

A production-grade URL shortener built as a hands-on DevOps learning project — covering CI/CD, Docker, Terraform, Lambda, policy-as-code guardrails, and AWS infrastructure.

---

## Live URLs

| Service | URL |
|---------|-----|
| Frontend | https://dawd0vkp1eihp.cloudfront.net |
| API | https://y5vrif9je5.execute-api.us-east-1.amazonaws.com |

---

## Progress

| Stage | Topic | Status |
|-------|-------|--------|
| Stage 1 | App setup + CI pipeline | ✅ Done |
| Stage 2 | Docker + AWS ECR | ✅ Done |
| Stage 3 | Terraform + Lambda + API Gateway + S3 + CloudFront | ✅ Done |
| Stage 4 | IaC in CI/CD pipeline | 🔜 Next |
| Stage 5 | Guardrails — policy as code | ⬜ Pending |
| Stage 6 | Production hardening | ⬜ Pending |

---

## What's been built

### Stage 1 — App + CI
- Node.js + Express REST API with 3 routes
- Neon Postgres database for link storage
- React frontend (Vite) for shortening URLs
- GitHub Actions CI pipeline: lint → test on every push
- Branch protection: PRs to main require passing CI

### Stage 2 — Docker + ECR
- Multi-stage Dockerfile using AWS Lambda base image
- docker-compose for local development
- AWS ECR repository for storing Docker images
- CI pipeline extended: builds and pushes Docker image to ECR on every merge to main
- Images tagged with git commit SHA for full traceability

### Stage 3 — Terraform + Serverless AWS
- Lambda function running the Express app via serverless-http
- API Gateway (HTTP API) routing all requests to Lambda
- S3 bucket serving the React frontend statically
- CloudFront distribution (PriceClass_100) for global CDN delivery
- Neon Postgres for serverless-compatible database
- Terraform remote state stored in S3 + DynamoDB locking
- make up / make down to spin entire infrastructure on/off

---

## Architecture

```
User
  ↓
CloudFront (CDN)          → serves React frontend from S3
  ↓ (API calls)
API Gateway               → receives HTTP requests
  ↓
Lambda function           → runs Express app
  ↓
Neon Postgres             → stores short links
```

---

## Stack

| Layer | Technology |
|-------|-----------|
| Backend | Node.js, Express |
| Database | Neon Postgres (serverless) |
| Frontend | React, Vite |
| Containerization | Docker (Lambda base image) |
| Registry | AWS ECR |
| Compute | AWS Lambda |
| API | AWS API Gateway (HTTP API) |
| CDN | AWS CloudFront |
| Storage | AWS S3 |
| IaC | Terraform |
| State | S3 + DynamoDB |
| CI/CD | GitHub Actions |

---

## Cost

| Service | Monthly cost |
|---------|-------------|
| Lambda | ~$0 (1M requests free) |
| API Gateway | ~$0 (1M requests free for 12 months) |
| CloudFront | ~$0 (1TB + 10M requests free forever) |
| S3 | ~$0 (5GB free for 12 months) |
| Neon Postgres | ~$0 (free tier) |
| ECR | ~$0.10/month |
| **Total** | **~$0/month** |

---

## Getting started

### Prerequisites
- Node.js v18+
- Docker Desktop
- AWS CLI + credentials configured
- Terraform v1.0+

### Run locally

```bash
# Backend
cd backend
npm install
npm run dev
# API at http://localhost:3000

# Frontend (separate terminal)
cd frontend
npm install
npm run dev
# UI at http://localhost:5173
```

### Run with Docker

```bash
docker compose up --build
```

### Deploy infrastructure

```bash
cd terraform
terraform init
terraform apply
```

### Tear down infrastructure

```bash
cd terraform
terraform destroy
```

### Deploy frontend to S3

```bash
cd frontend
VITE_API_URL=https://y5vrif9je5.execute-api.us-east-1.amazonaws.com npm run build
aws s3 sync dist/ s3://linkvault-staging-frontend --delete
aws cloudfront create-invalidation --distribution-id E26HIN2R1UXHCV --paths "/*"
```

---

## API endpoints

| Method | Route | Description |
|--------|-------|-------------|
| GET | `/health` | Health check |
| POST | `/shorten` | Create a short link |
| GET | `/:code` | Redirect to original URL |
| GET | `/stats/:code` | Get click stats |

### Example

```bash
# Shorten a URL
curl -X POST https://y5vrif9je5.execute-api.us-east-1.amazonaws.com/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://www.google.com"}'

# Get stats
curl https://y5vrif9je5.execute-api.us-east-1.amazonaws.com/stats/0EM7ddY
```

---

## CI/CD pipeline

```
Push to any branch
    → Lint (ESLint)
    → Test (Jest + Neon Postgres)

Merge to main (above must pass)
    → Docker build (Lambda base image)
    → Push to AWS ECR (tagged with git SHA + latest)
```

---

## Project structure

```
linkvault/
├── .github/
│   └── workflows/
│       └── ci.yml              # GitHub Actions pipeline
├── backend/
│   ├── src/
│   │   ├── index.js            # Express entry point
│   │   ├── db.js               # Postgres connection pool
│   │   └── routes/
│   │       └── links.js        # API route handlers
│   ├── tests/
│   │   └── links.test.js       # Jest test suite
│   ├── lambda.js               # Lambda handler wrapper
│   ├── Dockerfile              # Lambda-compatible image
│   └── package.json
├── frontend/
│   └── src/
│       └── App.jsx             # React UI
├── terraform/
│   ├── main.tf                 # Lambda + API Gateway
│   ├── s3-cloudfront.tf        # Frontend infrastructure
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.tf              # S3 remote state
│   └── Makefile                # make up / make down
└── README.md
```

---

## Terraform Makefile commands

```bash
make init   # terraform init
make plan   # preview changes
make up     # terraform apply
make down   # terraform destroy
make fmt    # format all .tf files
```
