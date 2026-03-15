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
