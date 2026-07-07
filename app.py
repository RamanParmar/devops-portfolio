from fastapi import FastAPI
from fastapi.responses import HTMLResponse

app = FastAPI()

@app.get("/", response_class=HTMLResponse)
def read_root():
    return """
    <html>
        <body>
            <h1>My DevOps Portfolio Project</h1>
            <p>FastAPI app deployed on AWS EC2 using Terraform, Docker, Nginx, and GitHub Actions.</p>
            <p><a href="/health">Health Check</a></p>
            <p><a href="/docs">API Docs</a></p>
        </body>
    </html>
    """

@app.get("/health")
def health():
    return {"status": "ok"}