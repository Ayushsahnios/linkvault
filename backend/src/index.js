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
