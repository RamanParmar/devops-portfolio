# FastAPI DevOps Project

A simple FastAPI app deployed on AWS EC2, with infrastructure created using Terraform and deployment automated using GitHub Actions.

I built this project to learn and practice basic DevOps skills like infrastructure as code, Docker, CI/CD pipelines, and using Nginx as a reverse proxy.

## Live Demo

- App: http://65.0.85.155
- Health check: http://65.0.85.155/health
- API docs (comes built-in with FastAPI): http://65.0.85.155/docs

## How it works (architecture)

```
Developer pushes code to GitHub (main branch)
        |
        v
GitHub Actions runs automatically
        |
        v
Connects to EC2 server using SSH
        |
        v
Pulls latest code, rebuilds Docker image, restarts container
        |
        v
Nginx (port 80) --> Docker container (port 8000) --> Uvicorn --> FastAPI app
```

When someone visits the site, Nginx receives the request first and forwards it to the app running inside a Docker container. The app itself is never directly exposed to the internet - only Nginx is.

## Tools used

- **AWS EC2** - the server that runs everything
- **Terraform** - creates the AWS infrastructure (VPC, subnet, security group, EC2 instance)
- **Docker** - packages the app so it runs the same way every time
- **Nginx** - sits in front of the app and forwards requests to it
- **FastAPI + Uvicorn** - the actual web app and the server that runs it
- **GitHub Actions** - automatically deploys the app whenever I push code

## What happens when I push code

1. GitHub Actions starts automatically
2. It connects to my EC2 server using SSH
3. It pulls the latest code from GitHub
4. It rebuilds the Docker image with the new code
5. It stops the old container and starts a new one
6. It checks if the app is actually responding; if not, it shows an error with logs instead of just saying "done"

## Infrastructure (Terraform)

Terraform creates:
- A VPC and public subnet
- An internet gateway and route table so the server can be reached from the internet
- A security group that only allows traffic on port 22 (SSH) and port 80 (website)
- The EC2 server itself

Sensitive files like the state file, `.tfvars`, and the SSH key are not uploaded to GitHub (they're in `.gitignore`).

## A few decisions I made and why

**Why use Nginx instead of exposing the app directly?**
The app runs only on `127.0.0.1:8000`, which means it can only be reached from inside the server itself, not from the internet. Nginx is the only thing exposed publicly, and it forwards traffic to the app. This is a common and safer way to run apps in production.

**Why Docker?**
Before Docker, I was manually setting up a Python virtual environment on the server every time I deployed. Docker packages the app and everything it needs, so it runs the same way no matter what.

**Why is SSH open to everyone (0.0.0.0/0) instead of just my IP?**
I tried locking SSH to just my own IP, but my home internet's public IP keeps changing, which broke my access. Since I'm using key-based login (not a password), only someone with my private key file can actually log in, so this is a reasonable tradeoff for a personal project.

## What I'd add if I continue this project

- A real domain name and HTTPS (currently it's just plain HTTP with an IP address)
- Store Terraform's state file remotely (like in S3) instead of only on my own machine
- Add Fail2ban to block repeated failed SSH login attempts

## Project files

```
app.py                          - the FastAPI app
Dockerfile                      - instructions to build the Docker image
requirements.txt                - python packages the app needs
main.tf                         - terraform infrastructure code
.terraform.lock.hcl             - locks Terraform provider versions
.github/workflows/deploy.yml    - the CI/CD pipeline
.gitignore
README.md                       - project overview and documents
```