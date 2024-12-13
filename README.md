# Developer Drive

## Project Overview

Developer Drive is a Docker container configuration project for development environments, supporting Node.js, MongoDB, Python, Java, and C/C++ (Clang/GCC). This project includes Docker configuration files for both Mac and Windows, aiming to provide a consistent development experience.

## Directory Structure
```bash
+---Mac
|   |   docker-compose.yml
|   |   Dockerfile.mongodb
|   |   Dockerfile.nodejs
|   |   Dockerfile.python
|   |   Dockerfile.javacontainer
|   |   Dockerfile.clang-gcc
|   |
|   \---.devcontainer
|           devcontainer.json
|
\---Windows
    |   docker-compose.yml
    |   Dockerfile.mongodb
    |   Dockerfile.nodejs
    |   Dockerfile.python
    |   Dockerfile.javacontainer
    |   Dockerfile.clang-gcc
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
    git clone git@github.com:TheRealMilesLee/ContainerizedEnvironment.git
    cd ContainerizedEnvironment/Mac
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

4. (Optional) Start the Python container:
    ```bash
    # Uncomment the python service in docker-compose.yml
    docker-compose up -d python
    ```

5. (Optional) Start the Java container:
    ```bash
    # Uncomment the java service in docker-compose.yml
    docker-compose up -d java
    ```

6. (Optional) Start the Clang/GCC container:
    ```bash
    # Uncomment the clang-gcc service in docker-compose.yml
    docker-compose up -d clang-gcc
    ```

#### Windows

1. Clone the project to your local machine:
    ```bash
    git clone git@github.com:TheRealMilesLee/ContainerizedEnvironment.git
    cd ContainerizedEnvironment/Windows
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

4. (Optional) Start the Python container:
    ```bash
    # Uncomment the python service in docker-compose.yml
    docker-compose up -d python
    ```

5. (Optional) Start the Java container:
    ```bash
    # Uncomment the java service in docker-compose.yml
    docker-compose up -d java
    ```

6. (Optional) Start the Clang/GCC container:
    ```bash
    # Uncomment the clang-gcc service in docker-compose.yml
    docker-compose up -d clang-gcc
    ```

## Custom Configuration

### VS Code Extensions and Settings

In the [devcontainer.json](Mac/.devcontainer/devcontainer.json) file, you can find pre-installed VS Code extensions and settings. You can modify them as needed.

### Zsh Configuration

The `Dockerfile` includes some common Zsh aliases and tools installation. You can modify them as needed.

## License

This project is licensed under the MIT License.
