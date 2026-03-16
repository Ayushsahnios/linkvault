# LinkVault

A production-grade URL shortener built as a hands-on DevOps learning project — covering CI/CD, Docker, Terraform, policy-as-code guardrails, and AWS infrastructure.

---

## Progress

| Stage | Topic | Status |
|-------|-------|--------|
| Stage 1 | App setup + CI pipeline | ✅ Done |
| Stage 2 | Docker + AWS ECR | ✅ Done |
| Stage 3 | Terraform infrastructure | 🔜 Next |
| Stage 4 | IaC in CI/CD pipeline | ⬜ Pending |
| Stage 5 | Guardrails — policy as code | ⬜ Pending |
| Stage 6 | Production hardening | ⬜ Pending |

---

## What's been built

### Stage 1 — App + CI
- Node.js + Express REST API with 3 routes
- SQLite database for link storage
- React frontend (Vite) for shortening URLs
- GitHub Actions CI pipeline: lint → test on every push
- Branch protection: PRs to main require passing CI

### Stage 2 — Docker + ECR
- Multi-stage Dockerfile (builder + slim runtime)
- docker-compose for local development
- AWS ECR repository for storing images
- CI pipeline extended: builds and pushes Docker image to ECR on every merge to main
- Images tagged with git commit SHA for full traceability

---

## Stack

| Layer | Technology |
|-------|-----------|
| Backend | Node.js, Express, SQLite |
| Frontend | React, Vite |
| Containerization | Docker, docker-compose |
| Registry | AWS ECR |
| CI/CD | GitHub Actions |
| Infrastructure | Terraform + AWS (Stage 3+) |

---

## Getting started

### Prerequisites
- Node.js v18+
- Docker Desktop
- AWS CLI (Stage 3+)
- Terraform (Stage 3+)

### Run locally (without Docker)

```bash
# Backend
cd backend
npm install
npm run dev
# API runs at http://localhost:3000

# Frontend (separate terminal)
cd frontend
npm install
npm run dev
# UI runs at http://localhost:5173
```

### Run locally (with Docker)

```bash
docker compose up --build
# API runs at http://localhost:3000
```

---

## API endpoints

| Method | Route | Description |
|--------|-------|-------------|
| GET | `/health` | Health check |
| POST | `/shorten` | Create a short link |
| GET | `/:code` | Redirect to original URL |
| GET | `/stats/:code` | Get click stats for a link |

### Example

```bash
# Shorten a URL
curl -X POST http://localhost:3000/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://www.google.com"}'

# Response
# { "code": "0EM7ddY", "shortUrl": "http://localhost:3000/0EM7ddY", "originalUrl": "https://www.google.com" }

# Get stats
curl http://localhost:3000/stats/0EM7ddY
```

---

## CI/CD pipeline

```
Push to any branch
    → Lint (ESLint)
    → Test (Jest)

Merge to main (above must pass first)
    → Docker build
    → Push to AWS ECR (tagged with git commit SHA + latest)
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
│   │   ├── db.js               # SQLite connection + schema
│   │   └── routes/
│   │       └── links.js        # API route handlers
│   ├── tests/
│   │   └── links.test.js       # Jest test suite
│   ├── Dockerfile              # Multi-stage Docker build
│   ├── .dockerignore
│   ├── eslint.config.js
│   └── package.json
├── frontend/
│   └── src/
│       └── App.jsx             # React UI
├── docker-compose.yml
└── README.md
```

---

## Development commands

```bash
# Backend
npm run dev       # start with nodemon (auto-reload)
npm test          # run Jest test suite
npm run lint      # run ESLint

# Docker
docker compose up --build    # start everything
docker compose down          # stop everything
docker images                # list built images
```