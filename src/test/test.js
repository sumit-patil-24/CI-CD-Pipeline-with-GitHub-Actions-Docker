const request = require('supertest');
const { expect } = require('chai');
const app = require('../app');  // Import the app instance

describe('GET /', () => {
  let server;
  
  // Start server before tests
  before((done) => {
    // Use port 0 to get a random available port
    server = app.listen(0, done);
  });
  
  // Close server after tests
  after((done) => {
    server.close(done);
  });

  it('responds with project details page', async () => {
    const response = await request(server).get('/');
    expect(response.status).to.equal(200);
    expect(response.text).to.include('CI/CD Pipeline with GitHub Actions & Docker');
    expect(response.text).to.include('AnugrahMassey/CI-CD-Pipeline-with-GitHub-Actions-Docker');
  });
  
  it('contains Docker information', async () => {
    const response = await request(server).get('/');
    expect(response.text).to.include('Docker Hub');
    expect(response.text).to.include('anugrah28/ci-cd-demo');
  });
  
  it('shows deployment status', async () => {
    const response = await request(server).get('/');
    expect(response.text).to.include('Successfully Deployed');
    expect(response.text).to.include('Deployment Time');
  });
});