# LinkVault

A production-grade URL shortener built as a DevOps learning project.

## Stack
- **Backend**: Node.js + Express + SQLite
- **Frontend**: React (Vite)
- **CI/CD**: GitHub Actions
- **Infrastructure**: Terraform + AWS (Stage 3+)

## Getting started

### Backend
```bash
cd backend
npm install
npm run dev
```

API runs at `http://localhost:3000`

### Endpoints
| Method | Route | Description |
|--------|-------|-------------|
| POST | `/shorten` | Create a short link |
| GET | `/:code` | Redirect to original URL |
| GET | `/stats/:code` | Get click stats |

### Run tests
```bash
cd backend
npm test
```

### Run linter
```bash
cd backend
npm run lint
```

## Stages
- [x] Stage 1 — App + CI pipeline
- [ ] Stage 2 — Docker + ECR
- [ ] Stage 3 — Terraform infrastructure
- [ ] Stage 4 — IaC in CI/CD
- [ ] Stage 5 — Guardrails
- [ ] Stage 6 — Production hardening
