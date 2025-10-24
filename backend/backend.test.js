const request = require('supertest');
const app = require('./server');

describe('Backend Service Tests', () => {
  it('should return health check', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body.status).toBe('ok');
  });

  it('should return public info without auth', async () => {
    const response = await request(app).get('/public-info');
    expect(response.status).toBe(200);
    expect(response.body.message).toBeDefined();
  });

  it('should reject protected endpoint without token', async () => {
    const response = await request(app).get('/profile');
    expect(response.status).toBe(401);
    expect(response.body.error).toBeDefined();
  });
});

