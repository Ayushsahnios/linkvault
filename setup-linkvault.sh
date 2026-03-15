#!/bin/bash

# ─────────────────────────────────────────────
#  LinkVault — Stage 1 Project Setup Script
#  Run this inside your cloned GitHub repo
#  Usage: bash setup-linkvault.sh
# ─────────────────────────────────────────────

set -e  # Stop on any error

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log()  { echo -e "${BLUE}[setup]${NC} $1"; }
ok()   { echo -e "${GREEN}[done]${NC}  $1"; }
warn() { echo -e "${YELLOW}[note]${NC}  $1"; }

echo ""
echo "  ██╗     ██╗███╗   ██╗██╗  ██╗██╗   ██╗ █████╗ ██╗  ████████╗"
echo "  ██║     ██║████╗  ██║██║ ██╔╝██║   ██║██╔══██╗██║  ╚══██╔══╝"
echo "  ██║     ██║██╔██╗ ██║█████╔╝ ██║   ██║███████║██║     ██║   "
echo "  ██║     ██║██║╚██╗██║██╔═██╗ ╚██╗ ██╔╝██╔══██║██║     ██║   "
echo "  ███████╗██║██║ ╚████║██║  ██╗ ╚████╔╝ ██║  ██║███████╗██║   "
echo "  ╚══════╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝  ╚═══╝  ╚═╝  ╚═╝╚══════╝╚═╝   "
echo ""
echo "  Stage 1 — Project Setup"
echo "  ─────────────────────────────────────────────────────────────"
echo ""

# ── 1. Check prerequisites ────────────────────────────────────────────────────
log "Checking prerequisites..."

command -v node >/dev/null 2>&1 || { echo "❌  Node.js is not installed. Get it at https://nodejs.org"; exit 1; }
command -v npm  >/dev/null 2>&1 || { echo "❌  npm is not installed."; exit 1; }
command -v git  >/dev/null 2>&1 || { echo "❌  git is not installed."; exit 1; }

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
  echo "❌  Node.js v18+ required. You have $(node -v). Update at https://nodejs.org"
  exit 1
fi

ok "Node $(node -v)  |  npm $(npm -v)  |  git $(git --version | awk '{print $3}')"

# ── 2. Confirm we're in a git repo ───────────────────────────────────────────
if [ ! -d ".git" ]; then
  echo ""
  warn "No .git directory found here."
  warn "Make sure you've cloned your GitHub repo and run this script from inside it."
  echo ""
  read -p "  Continue anyway and init a new git repo here? (y/N): " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    git init
    ok "Git repo initialized"
  else
    echo "  Aborting. Clone your repo first, then re-run."
    exit 1
  fi
fi

REPO_ROOT=$(pwd)
log "Working in: $REPO_ROOT"

# ── 3. Create folder structure ────────────────────────────────────────────────
echo ""
log "Creating folder structure..."

mkdir -p backend/src/routes
mkdir -p backend/tests
mkdir -p frontend
mkdir -p .github/workflows

ok "Folders created"

# ── 4. Backend — package.json ─────────────────────────────────────────────────
log "Writing backend/package.json..."

cat > backend/package.json << 'EOF'
{
  "name": "linkvault-backend",
  "version": "1.0.0",
  "description": "LinkVault URL shortener — backend API",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "test": "jest --forceExit",
    "test:watch": "jest --watch",
    "lint": "eslint src/",
    "lint:fix": "eslint src/ --fix"
  },
  "jest": {
    "testEnvironment": "node",
    "testMatch": ["**/tests/**/*.test.js"]
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
EOF

ok "backend/package.json"

# ── 5. Backend — ESLint config ────────────────────────────────────────────────
log "Writing backend/.eslintrc.json..."

cat > backend/.eslintrc.json << 'EOF'
{
  "env": {
    "node": true,
    "es2021": true,
    "jest": true
  },
  "extends": "eslint:recommended",
  "parserOptions": {
    "ecmaVersion": "latest"
  },
  "rules": {
    "no-console": "off",
    "no-unused-vars": ["warn", { "argsIgnorePattern": "^_" }],
    "semi": ["error", "always"],
    "quotes": ["error", "single"]
  }
}
EOF

ok "backend/.eslintrc.json"

# ── 6. Backend — .env.example ─────────────────────────────────────────────────
log "Writing backend/.env.example..."

cat > backend/.env.example << 'EOF'
PORT=3000
BASE_URL=http://localhost:3000
DB_PATH=./linkvault.db
EOF

cp backend/.env.example backend/.env
ok "backend/.env + .env.example"

# ── 7. Backend — db.js ────────────────────────────────────────────────────────
log "Writing backend/src/db.js..."

cat > backend/src/db.js << 'EOF'
const Database = require('better-sqlite3');
const path = require('path');

const DB_PATH = process.env.DB_PATH || path.join(__dirname, '..', 'linkvault.db');

const db = new Database(DB_PATH);

// Create table if it doesn't exist
db.exec(`
  CREATE TABLE IF NOT EXISTS links (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    code        TEXT    NOT NULL UNIQUE,
    original_url TEXT   NOT NULL,
    clicks      INTEGER NOT NULL DEFAULT 0,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
  )
`);

module.exports = db;
EOF

ok "backend/src/db.js"

# ── 8. Backend — routes/links.js ──────────────────────────────────────────────
log "Writing backend/src/routes/links.js..."

cat > backend/src/routes/links.js << 'EOF'
const express = require('express');
const { nanoid } = require('nanoid');
const db = require('../db');

const router = express.Router();

const BASE_URL = process.env.BASE_URL || 'http://localhost:3000';

// POST /shorten
// Body: { url: "https://example.com/very-long-url" }
// Returns: { code, shortUrl, originalUrl }
router.post('/shorten', (req, res) => {
  const { url } = req.body;

  if (!url) {
    return res.status(400).json({ error: 'url is required' });
  }

  // Basic URL validation
  try {
    new URL(url);
  } catch {
    return res.status(400).json({ error: 'Invalid URL format' });
  }

  const code = nanoid(7); // e.g. "V1StGXR"

  const insert = db.prepare(
    'INSERT INTO links (code, original_url) VALUES (?, ?)'
  );
  insert.run(code, url);

  return res.status(201).json({
    code,
    shortUrl: `${BASE_URL}/${code}`,
    originalUrl: url,
  });
});

// GET /:code
// Redirects to the original URL and increments click count
router.get('/:code', (req, res) => {
  const { code } = req.params;

  const link = db.prepare('SELECT * FROM links WHERE code = ?').get(code);

  if (!link) {
    return res.status(404).json({ error: 'Short link not found' });
  }

  db.prepare('UPDATE links SET clicks = clicks + 1 WHERE code = ?').run(code);

  return res.redirect(302, link.original_url);
});

// GET /stats/:code
// Returns { code, originalUrl, clicks, createdAt }
router.get('/stats/:code', (req, res) => {
  const { code } = req.params;

  const link = db.prepare('SELECT * FROM links WHERE code = ?').get(code);

  if (!link) {
    return res.status(404).json({ error: 'Short link not found' });
  }

  return res.json({
    code: link.code,
    originalUrl: link.original_url,
    clicks: link.clicks,
    createdAt: link.created_at,
  });
});

module.exports = router;
EOF

ok "backend/src/routes/links.js"

# ── 9. Backend — index.js ─────────────────────────────────────────────────────
log "Writing backend/src/index.js..."

cat > backend/src/index.js << 'EOF'
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const linksRouter = require('./routes/links');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', service: 'linkvault' });
});

// Mount stats route BEFORE the /:code wildcard to avoid conflicts
app.use('/stats', require('./routes/links'));
app.use('/', linksRouter);

// Only start listening if this file is run directly (not during tests)
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`LinkVault running on http://localhost:${PORT}`);
  });
}

module.exports = app;
EOF

ok "backend/src/index.js"

# ── 10. Backend — test file ───────────────────────────────────────────────────
log "Writing backend/tests/links.test.js..."

cat > backend/tests/links.test.js << 'EOF'
const request = require('supertest');
const app = require('../src/index');

describe('POST /shorten', () => {
  it('returns 201 and a short code for a valid URL', async () => {
    const res = await request(app)
      .post('/shorten')
      .send({ url: 'https://www.example.com/some/long/path' });

    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty('code');
    expect(res.body).toHaveProperty('shortUrl');
    expect(res.body.originalUrl).toBe('https://www.example.com/some/long/path');
  });

  it('returns 400 if url is missing', async () => {
    const res = await request(app).post('/shorten').send({});
    expect(res.status).toBe(400);
    expect(res.body.error).toBe('url is required');
  });

  it('returns 400 for an invalid URL format', async () => {
    const res = await request(app)
      .post('/shorten')
      .send({ url: 'not-a-valid-url' });
    expect(res.status).toBe(400);
    expect(res.body.error).toBe('Invalid URL format');
  });
});

describe('GET /:code', () => {
  let code;

  beforeAll(async () => {
    const res = await request(app)
      .post('/shorten')
      .send({ url: 'https://www.redirect-target.com' });
    code = res.body.code;
  });

  it('redirects (302) to the original URL', async () => {
    const res = await request(app).get(`/${code}`);
    expect(res.status).toBe(302);
    expect(res.headers.location).toBe('https://www.redirect-target.com');
  });

  it('returns 404 for an unknown code', async () => {
    const res = await request(app).get('/doesnotexist');
    expect(res.status).toBe(404);
  });
});

describe('GET /stats/:code', () => {
  let code;

  beforeAll(async () => {
    const res = await request(app)
      .post('/shorten')
      .send({ url: 'https://www.stats-test.com' });
    code = res.body.code;
  });

  it('returns stats for a valid code', async () => {
    const res = await request(app).get(`/stats/${code}`);
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('code', code);
    expect(res.body).toHaveProperty('originalUrl', 'https://www.stats-test.com');
    expect(res.body).toHaveProperty('clicks');
    expect(typeof res.body.clicks).toBe('number');
  });

  it('returns 404 for unknown code', async () => {
    const res = await request(app).get('/stats/doesnotexist');
    expect(res.status).toBe(404);
  });
});
EOF

ok "backend/tests/links.test.js"

# ── 11. GitHub Actions CI workflow ────────────────────────────────────────────
log "Writing .github/workflows/ci.yml..."

cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches: ["**"]
  pull_request:
    branches: [main]

jobs:
  lint-and-test:
    runs-on: ubuntu-latest

    defaults:
      run:
        working-directory: backend

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: "npm"
          cache-dependency-path: backend/package-lock.json

      - name: Install dependencies
        run: npm ci

      - name: Lint
        run: npm run lint

      - name: Run tests
        run: npm test
EOF

ok ".github/workflows/ci.yml"

# ── 12. Root .gitignore ───────────────────────────────────────────────────────
log "Writing .gitignore..."

cat > .gitignore << 'EOF'
# Dependencies
node_modules/

# SQLite database files
*.db
*.sqlite

# Environment files
.env

# Build output
dist/
build/

# Logs
*.log
npm-debug.log*

# OS files
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
EOF

ok ".gitignore"

# ── 13. Root README ───────────────────────────────────────────────────────────
log "Writing README.md..."

cat > README.md << 'EOF'
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
EOF

ok "README.md"

# ── 14. Summary ───────────────────────────────────────────────────────────────
echo ""
echo "  ─────────────────────────────────────────────────────────────"
echo -e "  ${GREEN}✅  Project structure created!${NC}"
echo "  ─────────────────────────────────────────────────────────────"
echo ""
echo "  📁  What was created:"
echo ""
echo "      .github/workflows/ci.yml   → GitHub Actions pipeline"
echo "      backend/src/index.js       → Express app entry point"
echo "      backend/src/db.js          → SQLite connection + schema"
echo "      backend/src/routes/links.js → All 3 API routes"
echo "      backend/tests/links.test.js → 7 tests ready to run"
echo "      backend/package.json        → Scripts + jest config"
echo "      backend/.eslintrc.json      → ESLint rules"
echo "      backend/.env                → Local env vars"
echo "      .gitignore                  → Node + SQLite ignores"
echo "      README.md                   → Project docs"
echo ""
echo "  ─────────────────────────────────────────────────────────────"
echo "  🚀  Next steps:"
echo ""
echo "      1.  cd backend"
echo "      2.  npm install"
echo "      3.  npm run dev       → start the server"
echo "      4.  npm test          → run the test suite"
echo "      5.  npm run lint      → check for lint errors"
echo "      6.  git add . && git commit -m 'feat: stage 1 project setup'"
echo "      7.  git push → watch the CI pipeline run on GitHub"
echo ""
echo "  Then set up branch protection in:"
echo "  GitHub repo → Settings → Branches → Add rule → main"
echo "  ─────────────────────────────────────────────────────────────"
echo ""
