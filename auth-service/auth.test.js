const request = require('supertest');
const app = require('./server');

describe('Auth Service Tests', () => {
  it('should return health check', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body.status).toBe('ok');
  });

  it('should validate required fields on signup', async () => {
    const response = await request(app)
      .post('/signup')
      .send({ email: 'test@example.com' });
    
    expect(response.status).toBe(400);
    expect(response.body.error).toBeDefined();
  });

  it('should validate password length', async () => {
    const response = await request(app)
      .post('/signup')
      .send({
        name: 'Test User',
        email: 'test@example.com',
        password: '123'
      });
    
    expect(response.status).toBe(400);
    expect(response.body.error).toContain('6 characters');
  });
});

