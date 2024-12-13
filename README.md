# Developer Drive

## Project Overview

Developer Drive is a Docker container configuration project for development environments, supporting Node.js and MongoDB. This project includes Docker configuration files for both Mac and Windows, aiming to provide a consistent development experience.

## Directory Structure
```bash
+---Mac
\---Windows
    |   docker-compose.yml
    |   Dockerfile.mongodb
    |   Dockerfile.nodejs
    |
    \---.devcontainer
            devcontainer.json
```

## Usage Instructions

### Prerequisites

- Docker
- Docker Compose

### Setting Up the Development Environment

#### Mac

1. Clone the project to your local machine:
    ```bash
    git clone <repository-url>
    cd <repository-directory>/Mac
    ```

2. Start the MongoDB container:
    ```bash
    docker-compose up -d mongodb
    ```

3. (Optional) Start the Node.js container:
    ```bash
    # Uncomment the nodejs service in docker-compose.yml
    docker-compose up -d nodejs
    ```

#### Windows

1. Clone the project to your local machine:
    ```bash
    git clone <repository-url>
    cd <repository-directory>/Windows
    ```

2. Start the MongoDB container:
    ```bash
    docker-compose up -d mongodb
    ```

3. (Optional) Start the Node.js container:
    ```bash
    # Uncomment the nodejs service in docker-compose.yml
    docker-compose up -d nodejs
    ```

## Custom Configuration

### VS Code Extensions and Settings

In the [devcontainer.json](http://_vscodecontentref_/2) file, you can find pre-installed VS Code extensions and settings. You can modify them as needed.

### Zbash Configuration

The `Dockerfile` includes some common Zbash aliases and tools installation. You can modify them as needed.

## License

This project is licensed under the MIT License.
