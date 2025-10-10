# ContainerizedEnvironment

> Bilingual README: English follows Chinese. | 双语 README：中文在前，英文在后。

- 简体中文 | Chinese
- English version starts below the Chinese section

---

## 项目简介（中文）

ContainerizedEnvironment 是一个跨平台的容器化开发与部署示例仓库，包含两大部分：

- DockerVersion：为常见语言/工具准备的可复用开发容器（Node.js、Python、Clang/GCC、Java、Kali Linux）以及一个持久化数据卷的 MongoDB 服务，分别提供了 macOS 与 Windows 的 docker-compose 与 Dockerfile。
- KubernetesVersion：用于部署个人网站的 Kubernetes 清单，包含 Deployment、Service、Ingress（含 TLS）与 HPA 示例，并附带用于生成本地 CA 与站点证书的脚本与配置示例。

本仓库旨在帮助你快速搭建统一且可移植的本地开发环境，并提供将服务部署到 Kubernetes 的参考实践。

### 目录结构

```
ContainerizedEnvironment/
├─ LICENSE
├─ DockerVersion/
│  ├─ Mac/
│  │  ├─ docker-compose.yml
│  │  ├─ Dockerfile.nodejs | Dockerfile.python | Dockerfile.clang-gcc | Dockerfile.javacontainer | Dockerfile.kali | Dockerfile.mongodb
│  │  └─ .devcontainer/devcontainer.json
│  └─ Windows/
│     ├─ docker-compose.yml
│     ├─ Dockerfile.nodejs | Dockerfile.python | Dockerfile.clang-gcc | Dockerfile.javacontainer | Dockerfile.kali | Dockerfile.mongodb
│     └─ .devcontainer/devcontainer.json
└─ KubernetesVersion/
   ├─ Mac/secret/    # 证书与脚本示例（包含私钥，切勿用于生产）
   └─ PersonalWebsiteKubernetesDeployment/
      ├─ WebPageDeployment.yaml
      ├─ WebService.yaml
      ├─ Ingress.yaml
      └─ HPA.yaml
```

## 功能特性

- 多语言开发容器：Node.js、Python、C/C++（Clang/GCC）、Java、Kali Linux
- 常用 CLI 工具与 Zsh 环境：oh-my-zsh、lsd、bat、fzf、neovim、glances 等，开箱即用别名配置
- VS Code 开发体验：提供 devcontainer 配置与大量常用扩展列表
- MongoDB 容器：默认暴露 27017 端口并将数据持久化到宿主机目录
- Kubernetes 示例：
  - Deployment（ready/liveness 探针、资源请求/限制）
  - Service（ClusterIP，80/443 -> 3000）
  - Ingress（基于 host therealmileslee.github.io，指定 TLS secret）
  - HPA（autoscaling/v2 格式示例）
- 本地证书示例：提供生成 CA 与站点证书的脚本与配置（仅供学习测试）

## 先决条件

- Docker Desktop 或兼容的 Docker 环境（Compose v2）
- VS Code（可选，用于 Dev Containers 体验）
- Kubernetes（可选，用于部署示例）：已安装 kubectl，集群内安装了 NGINX Ingress Controller 或其他兼容 Ingress 控制器

## 在 Docker 上使用（macOS 与 Windows）

本仓库分别提供了 macOS 与 Windows 的 Compose 文件与 Dockerfile，请根据你的平台选择对应目录。

### macOS（`DockerVersion/Mac`）

- 默认定义了以下服务：
  - nodejs、python、clang-gcc、java、kali-linux（开发容器）
  - mongodb（数据库，端口 27017:27017，数据持久化到 `~/Developer/MongodbData`）
- 挂载卷说明（节选）：
  - 工作目录：`~/Developer` -> 容器内 `/usr/src/app`（或 Kali -> `/root/Developer`）
  - VS Code 扩展/用户设置：映射到容器内用户目录（部分镜像为 root 用户，路径可能并不生效，请按需调整）
- 网络模式：开发容器使用 `network_mode: host`（Docker Desktop for macOS 对 host 网络支持有限，端口暴露/访问建议优先使用端口映射方式）。

常用操作（根据需要选择服务启动）：

```sh
# 进入 macOS 目录
cd DockerVersion/Mac

# 构建并后台启动（示例：启动 Node.js 与 MongoDB）
docker compose up -d nodejs mongodb

# 查看日志
docker compose logs -f mongodb

# 停止并移除容器
docker compose down
```

MongoDB 连接：

- 连接串（本机）：`mongodb://localhost:27017`
- 数据目录：`~/Developer/MongodbData`

进入某个开发容器（例如 nodejs）：

```sh
docker exec -it node-dev-env zsh
```

### Windows（`DockerVersion/Windows`）

- Compose 文件默认仅启用了 `mongodb`（其他开发容器服务已注释）。
- 路径映射使用类似 `/e/Developer`、`/c/Users/<Name>` 的 Docker Desktop Windows 路径风格；请根据你的磁盘与用户名调整。
- 如果需要启用开发容器：
  - 取消对应服务注释并检查卷路径
  - 注意：`network_mode: host` 在 Docker Desktop for Windows 上不受支持，请使用端口映射方案

示例：

```sh
cd DockerVersion/Windows
# 仅启动 MongoDB
docker compose up -d mongodb
```

## 在 VS Code 中使用 Dev Containers（可选）

- 两个平台目录下均提供 `.devcontainer/devcontainer.json`，默认指向对应目录的 `docker-compose.yml`，服务名为 `nodejs`。
- 打开仓库后：
  1. 安装 VS Code 扩展 Remote - Containers
  2. 使用“在容器中重新打开”（Reopen in Container）
  3. VS Code 将以 `nodejs` 服务为基础启动开发容器，并把当前工作区挂载到容器的 `workspaceFolder`（默认 `/workspace`）
- 扩展示例与编辑器设置已在 devcontainer 中预置，可按需裁剪

提示：Compose 中同时将宿主 `~/Developer` 挂载到了 `/usr/src/app`。Dev Containers 会额外挂载当前项目到 `workspaceFolder`，两者互不冲突，但请在项目内注意路径一致性。

## Kubernetes 部署示例

目录：`KubernetesVersion/PersonalWebsiteKubernetesDeployment`

包含：

- `WebPageDeployment.yaml`：部署镜像 `silverhandlee/therealmileslee-github:latest`，容器端口 3000，设置了 `readinessProbe`/`livenessProbe` 指向 `/health`，并定义了资源请求/限制
- `WebService.yaml`：ClusterIP 服务，暴露 80/443，目标容器端口 3000
- `Ingress.yaml`：主机名 `therealmileslee.github.io`，TLS secret 名称 `web-page-tls`
- `HPA.yaml`：autoscaling/v2 示例

应用清单：

```sh
cd KubernetesVersion/PersonalWebsiteKubernetesDeployment
kubectl apply -f WebPageDeployment.yaml
kubectl apply -f WebService.yaml
kubectl apply -f Ingress.yaml
kubectl apply -f HPA.yaml
```

前置条件：

- 已部署 Ingress Controller（如 NGINX Ingress）
- DNS 已将 `therealmileslee.github.io` 指向 Ingress 的对外地址
- 集群中已创建 TLS Secret：`web-page-tls`

创建 TLS Secret 示例（使用你自己的证书与私钥）：

```sh
kubectl create secret tls web-page-tls \
  --cert=path/to/your.crt \
  --key=path/to/your.key \
  -n <your-namespace>
```

### 本地证书与脚本（仅供学习）

`KubernetesVersion/Mac/secret/` 目录包含：

- OpenSSL 配置：`openssl-ca.cnf`、`openssl.cnf`
- 生成脚本：`gen-ca-cert.sh`
- 示例证书与私钥：`silverhand-ca.*`、`silverhand.*`

重要提示：这些文件包含私钥，仅用于学习测试。不要在生产环境或公开仓库中使用或保留真实私钥。请自行按需修改脚本，生成你自己的证书链，并安全地创建 Kubernetes Secret。

### 关于 HPA.yaml 的注意

当前 `HPA.yaml` 使用 `autoscaling/v2`，其 `metrics` 字段在示例里将 CPU 与内存放在同一 `resource` 字段下。Kubernetes 通常要求为每种资源分别提供一个独立的 `metrics` 条目（即 `metrics` 为列表，包含两项：CPU 与内存）。如在你的集群版本上出现解析错误，请将其拆分为两个条目后再应用。

## 常见问题与建议

- host 网络模式：Docker Desktop 在 macOS/Windows 上对 `network_mode: host` 支持有限或不支持。如需服务之间通信或向宿主暴露端口，建议使用端口映射与自定义网络。
- VS Code 用户配置挂载：Compose 中将宿主的 VS Code 扩展/设置目录映射到容器的 `/home/node/...`。对于非 `node` 基础镜像（如 `python`/`openjdk`/`ubuntu`），默认用户为 `root`，这些路径可能无效。可依据实际镜像用户调整路径或移除这些映射。
- 安全：切勿在公共仓库存放私钥与敏感信息。示例证书仅为演示用途。

## 许可协议

本项目基于 [MIT License](./LICENSE) 开源发布。

## 参考与致谢

- Docker 与 Compose 文档：https://docs.docker.com/
- Dev Containers（VS Code）：https://containers.dev/
- Kubernetes 文档：https://kubernetes.io/docs/
- NGINX Ingress Controller：https://kubernetes.github.io/ingress-nginx/
- oh-my-zsh：https://ohmyz.sh/
- rxfetch：https://github.com/mangeshrex/rxfetch

---

## Project Overview (English)

ContainerizedEnvironment is a cross-platform repository for containerized development and deployment. It includes:

- DockerVersion: Reusable development containers for Node.js, Python, Clang/GCC, Java, and Kali Linux, plus a MongoDB service with a persistent host volume. Both macOS and Windows variants are provided.
- KubernetesVersion: Kubernetes manifests to deploy a personal website, including Deployment, Service, Ingress (with TLS), and an HPA example. Example scripts and OpenSSL configs are included for generating a local CA and leaf certificates.

The goal is to help you spin up a consistent, portable local development environment and offer a reference path to deploy to Kubernetes.

### Repository Layout

```
ContainerizedEnvironment/
├─ LICENSE
├─ DockerVersion/
│  ├─ Mac/
│  │  ├─ docker-compose.yml
│  │  ├─ Dockerfile.nodejs | Dockerfile.python | Dockerfile.clang-gcc | Dockerfile.javacontainer | Dockerfile.kali | Dockerfile.mongodb
│  │  └─ .devcontainer/devcontainer.json
│  └─ Windows/
│     ├─ docker-compose.yml
│     ├─ Dockerfile.nodejs | Dockerfile.python | Dockerfile.clang-gcc | Dockerfile.javacontainer | Dockerfile.kali | Dockerfile.mongodb
│     └─ .devcontainer/devcontainer.json
└─ KubernetesVersion/
   ├─ Mac/secret/
   └─ PersonalWebsiteKubernetesDeployment/
      ├─ WebPageDeployment.yaml
      ├─ WebService.yaml
      ├─ Ingress.yaml
      └─ HPA.yaml
```

## Features

- Language-specific dev containers: Node.js, Python, C/C++ (Clang/GCC), Java, Kali Linux
- Rich CLI and shell experience: oh-my-zsh, lsd, bat, fzf, neovim, glances, and handy aliases
- VS Code dev experience: devcontainer config with a curated list of extensions
- MongoDB container: exposes 27017 and persists data to a host folder
- Kubernetes examples:
  - Deployment with readiness/liveness probes and resource requests/limits
  - Service (ClusterIP, 80/443 -> 3000)
  - Ingress for host therealmileslee.github.io with TLS secret
  - HPA example (autoscaling/v2)
- Local PKI examples: scripts/configs to create a CA and leaf certs (for learning only)

## Prerequisites

- Docker Desktop or a compatible Docker setup (Compose v2)
- VS Code (optional, for Dev Containers)
- Kubernetes (optional): kubectl installed, an Ingress controller available in your cluster

## Using Docker (macOS and Windows)

Choose the directory that matches your platform under `DockerVersion`.

### macOS (`DockerVersion/Mac`)

- Defined services:
  - nodejs, python, clang-gcc, java, kali-linux (development containers)
  - mongodb (database, 27017:27017 with data persisted to `~/Developer/MongodbData`)
- Volume mounts (partial):
  - Workdir: `~/Developer` -> `/usr/src/app` (Kali -> `/root/Developer`)
  - VS Code extensions/user settings mapped into the container (paths may not apply to non-node images using root; adjust as needed)
- Network mode: dev containers use `network_mode: host` (Docker Desktop macOS has limited or no host networking; prefer port mappings if needed).

Typical workflow:

```sh
cd DockerVersion/Mac
# Build and start selected services (example: Node.js and MongoDB)
docker compose up -d nodejs mongodb

docker compose logs -f mongodb

docker compose down
```

MongoDB connection:

- URI (localhost): `mongodb://localhost:27017`
- Data dir: `~/Developer/MongodbData`

Shell into a dev container (e.g., nodejs):

```sh
docker exec -it node-dev-env zsh
```

### Windows (`DockerVersion/Windows`)

- By default only `mongodb` is enabled; other dev containers are commented out.
- Paths use Docker Desktop Windows style (`/e/Developer`, `/c/Users/<Name>`). Adjust to your drives and username.
- To enable dev containers:
  - Uncomment the desired services and fix volumes if needed
  - Note: `network_mode: host` is not supported on Docker Desktop for Windows; use port mappings instead

Example:

```sh
cd DockerVersion/Windows
docker compose up -d mongodb
```

## Dev Containers in VS Code (optional)

- Each platform directory contains `.devcontainer/devcontainer.json`, pointing to the local `docker-compose.yml` and the `nodejs` service.
- Steps:
  1. Install the Remote - Containers extension
  2. Reopen the repository in container
  3. VS Code will start the `nodejs` service and mount your current workspace at the `workspaceFolder` (default `/workspace`)
- The extension list and editor settings are preconfigured—trim as you see fit

Note: The Compose files also mount your host `~/Developer` to `/usr/src/app`. Dev Containers will additionally mount your current project to `workspaceFolder`. Be mindful of path consistency.

## Kubernetes Example Deployment

Location: `KubernetesVersion/PersonalWebsiteKubernetesDeployment`

Includes:

- `WebPageDeployment.yaml`: image `silverhandlee/therealmileslee-github:latest`, container port 3000, `/health` readiness/liveness probes, resource requests/limits
- `WebService.yaml`: ClusterIP service exposing 80/443 -> 3000
- `Ingress.yaml`: host `therealmileslee.github.io`, TLS secret `web-page-tls`
- `HPA.yaml`: autoscaling/v2 example

Apply manifests:

```sh
cd KubernetesVersion/PersonalWebsiteKubernetesDeployment
kubectl apply -f WebPageDeployment.yaml
kubectl apply -f WebService.yaml
kubectl apply -f Ingress.yaml
kubectl apply -f HPA.yaml
```

Prerequisites:

- An Ingress controller (e.g., NGINX Ingress) is installed
- DNS for `therealmileslee.github.io` points to your Ingress
- TLS Secret `web-page-tls` exists in the target namespace

Create TLS secret (with your own cert and key):

```sh
kubectl create secret tls web-page-tls \
  --cert=path/to/your.crt \
  --key=path/to/your.key \
  -n <your-namespace>
```

### Local PKI (learning only)

Under `KubernetesVersion/Mac/secret/` you will find OpenSSL configs, a helper script (`gen-ca-cert.sh`), and example CA/leaf materials. These include private keys and are for demonstration only—do not use them in production or commit real keys.

### HPA.yaml caveat

The provided `HPA.yaml` uses `autoscaling/v2`. In the example, CPU and memory are shown under a single `resource` entry. Kubernetes typically expects separate entries in the `metrics` list—one for CPU and another for memory. If your cluster rejects the manifest, split them into two metrics entries before applying.

## FAQs and Tips

- Host networking: macOS/Windows Docker Desktop has limited or no support for `network_mode: host`. Prefer port mappings and user-defined networks.
- VS Code settings mounts: The Compose files map host VS Code paths into `/home/node/...`. For non-node base images (python/openjdk/ubuntu) running as root, these paths may not work—adjust or remove as appropriate.
- Security: Never commit private keys or secrets. The example materials are for learning only.

## License

Released under the [MIT License](./LICENSE).

## References & Credits

- Docker & Compose: https://docs.docker.com/
- Dev Containers (VS Code): https://containers.dev/
- Kubernetes docs: https://kubernetes.io/docs/
- NGINX Ingress Controller: https://kubernetes.github.io/ingress-nginx/
- oh-my-zsh: https://ohmyz.sh/
- rxfetch: https://github.com/mangeshrex/rxfetch
