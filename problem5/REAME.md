# Problem 5: A Crude Server

Develop a backend server with ExpressJS. You are required to build a set of CRUD interface that allow a user to interact with the service. You are required to use TypeScript for this task.

## Prerequisite

Install Docker and `docker-compose-plugin` (Skip this step if you have already installed them).
Refer to the [Official Docker Installation Guide for Ubuntu](https://docs.docker.com/engine/install/ubuntu/) or execute the following commands:

```bash
    # Add Docker's official GPG key:
    $ sudo apt update
    $ sudo apt install ca-certificates curl
    $ sudo install -m 0755 -d /etc/apt/keyrings
    $ sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    $ sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    $ sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
    Types: deb
    URIs: https://download.docker.com/linux/ubuntu
    Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
    Components: stable
    Architectures: $(dpkg --print-architecture)
    Signed-By: /etc/apt/keyrings/docker.asc
    EOF

    $ sudo apt update
    $ sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

After installation, verify that Docker is running:
```bash
    $ sudo systemctl status docker
```
If Docker is not running, start it manually:
```bash
    $ sudo systemctl start docker
```

## Start web server

* (Optional) Configure Environment Variables:
The web server starts on port 3333 by default. If port 3333 is already in use on your local machine, create a .env file in the root directory and specify a custom port:
Run following commands to start web server:
    APP_PORT=3334

* Launch the Application:
Run the following command to start the application components in detached mode (running in the background):
```bash
    $ docker compose up --build
```

## Testing
You can choose one of the following methods to test the CRUD API:

### Method 1: Using the Automated Test Script (Recommended)
We provide a lightweight bash script that automatically executes the full CRUD lifecycle (Create, Read, Update, Delete) and handles dynamic IDs for you.
```bash
    $ ./test.sh
```

### Method 2: Manual Testing via Postman
If you prefer testing individual routes manually, you can import the API endpoints into Postman or use the Thunder Client extension inside VS Code.
Target Base URL: http://localhost:3333/api/users