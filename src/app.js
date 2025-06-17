const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>CI/CD Pipeline Project</title>
      <style>
        :root {
          --primary: #3498db;
          --secondary: #2c3e50;
          --success: #27ae60;
          --light: #f8f9fa;
          --dark: #343a40;
        }
        
        * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
        }
        
        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          line-height: 1.6;
          background: linear-gradient(135deg, #f5f7fa 0%, #e4e7ec 100%);
          min-height: 100vh;
          padding: 20px;
          color: var(--dark);
        }
        
        .container {
          max-width: 1000px;
          margin: 2rem auto;
          background: white;
          border-radius: 12px;
          box-shadow: 0 10px 30px rgba(0,0,0,0.08);
          overflow: hidden;
        }
        
        header {
          background: var(--secondary);
          color: white;
          padding: 2rem;
          text-align: center;
          position: relative;
        }
        
        header h1 {
          font-size: 2.5rem;
          margin-bottom: 0.5rem;
        }
        
        .tagline {
          font-size: 1.2rem;
          opacity: 0.9;
          max-width: 700px;
          margin: 0 auto;
        }
        
        .badge {
          display: inline-block;
          background: var(--primary);
          color: white;
          padding: 0.3rem 0.8rem;
          border-radius: 20px;
          font-size: 0.9rem;
          margin: 0 0.3rem;
          vertical-align: middle;
        }
        
        .content {
          padding: 2rem;
          display: grid;
          grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
          gap: 2rem;
        }
        
        .card {
          background: var(--light);
          border-radius: 10px;
          padding: 1.5rem;
          box-shadow: 0 4px 6px rgba(0,0,0,0.05);
          transition: transform 0.3s ease;
        }
        
        .card:hover {
          transform: translateY(-5px);
        }
        
        .card h2 {
          color: var(--primary);
          margin-bottom: 1rem;
          padding-bottom: 0.5rem;
          border-bottom: 2px solid var(--primary);
        }
        
        .card ul {
          list-style: none;
        }
        
        .card li {
          padding: 0.7rem 0;
          border-bottom: 1px solid #e9ecef;
        }
        
        .card li:last-child {
          border-bottom: none;
        }
        
        .workflow-step {
          display: flex;
          align-items: flex-start;
          margin-bottom: 1.2rem;
        }
        
        .step-number {
          background: var(--primary);
          color: white;
          width: 30px;
          height: 30px;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          flex-shrink: 0;
          margin-right: 1rem;
          font-weight: bold;
        }
        
        .status-card {
          background: rgba(39, 174, 96, 0.1);
          border-left: 4px solid var(--success);
        }
        
        .status {
          color: var(--success);
          font-weight: bold;
          font-size: 1.1rem;
        }
        
        .docker-info {
          display: flex;
          align-items: center;
          gap: 10px;
          margin-top: 1rem;
          padding: 0.8rem;
          background: #e3f2fd;
          border-radius: 8px;
        }
        
        .docker-icon {
          font-size: 2rem;
          color: var(--primary);
        }
        
        footer {
          text-align: center;
          padding: 1.5rem;
          background: var(--secondary);
          color: white;
        }
        
        a {
          color: var(--primary);
          text-decoration: none;
          transition: opacity 0.3s;
        }
        
        a:hover {
          opacity: 0.8;
        }
        
        @media (max-width: 768px) {
          .content {
            grid-template-columns: 1fr;
          }
          
          header h1 {
            font-size: 2rem;
          }
        }
      </style>
    </head>
    <body>
      <div class="container">
        <header>
          <h1>🚀 CI/CD Pipeline with GitHub Actions & Docker</h1>
          <p class="tagline">No cloud services needed! Full pipeline runs locally using Docker and self-hosted runners</p>
        </header>
        
        <div class="content">
          <div class="card">
            <h2>📋 Project Details</h2>
            <ul>
              <li><strong>GitHub Repo:</strong> 
                <a href="https://github.com/AnugrahMassey/CI-CD-Pipeline-with-GitHub-Actions-Docker" target="_blank">
                  AnugrahMassey/CI-CD-Pipeline-with-GitHub-Actions-Docker
                </a>
              </li>
              <li><strong>Created By:</strong> Anugrah Massey</li>
              <li><strong>Docker Hub:</strong> Anugrah28</li>
              <li><strong>Objective:</strong> Build, test, and deploy locally without cloud services</li>
            </ul>
            
            <div class="docker-info">
              <div class="docker-icon">🐳</div>
              <div>
                <strong>Docker Image:</strong> anugrah28/ci-cd-demo<br>
                <strong>Container ID:</strong> ${process.env.HOSTNAME || 'local'}
              </div>
            </div>
          </div>
          
          <div class="card">
            <h2>⚙️ CI/CD Workflow</h2>
            <div class="workflow-step">
              <div class="step-number">1</div>
              <div>
                <strong>Code Push</strong>
                <p>Push changes to GitHub repository</p>
              </div>
            </div>
            <div class="workflow-step">
              <div class="step-number">2</div>
              <div>
                <strong>GitHub Actions</strong>
                <p>Automated pipeline triggers on push</p>
              </div>
            </div>
            <div class="workflow-step">
              <div class="step-number">3</div>
              <div>
                <strong>Build & Test</strong>
                <p>Docker image built and tests executed</p>
              </div>
            </div>
            <div class="workflow-step">
              <div class="step-number">4</div>
              <div>
                <strong>Local Deployment</strong>
                <p>Deployed to local machine via self-hosted runner</p>
              </div>
            </div>
          </div>
          
          <div class="card status-card">
            <h2>✅ Deployment Status</h2>
            <p class="status">Successfully Deployed</p>
            <p><strong>Deployment Time:</strong> ${new Date().toLocaleString()}</p>
            <p><strong>Running on Port:</strong> ${PORT}</p>
          </div>
          
          <div class="card">
            <h2>🛠️ Technology Stack</h2>
            <ul>
              <li><span class="badge">GitHub Actions</span> CI/CD Pipeline</li>
              <li><span class="badge">Docker</span> Containerization</li>
              <li><span class="badge">Node.js</span> Application Runtime</li>
              <li><span class="badge">Express</span> Web Framework</li>
              <li><span class="badge">Self-Hosted Runner</span> Local Deployment</li>
            </ul>
          </div>
        </div>
        
        <footer>
          <p>CI/CD Pipeline Project | No Cloud Required | Docker & GitHub Actions</p>
        </footer>
      </div>
    </body>
    </html>
  `);
});
module.exports = app;

// Only start server if not in test environment
if (process.env.NODE_ENV !== 'test') {
  const server = app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
  });
  
  // Handle graceful shutdown
  process.on('SIGINT', () => {
    server.close(() => {
      console.log('Server closed');
      process.exit(0);
    });
  });
}