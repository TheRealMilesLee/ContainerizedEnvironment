#!/bin/bash

echo "部署 NodeJS 和 Nginx 反向代理..."

# 部署 NodeJS 应用
echo "1. 部署 NodeJS 应用..."
kubectl apply -f nodeJSEnvironment.yaml

# 创建 NodeJS Service
echo "2. 创建 NodeJS Service..."
kubectl apply -f NodeJS-Service.yaml

# 创建 Nginx 配置
echo "3. 创建 Nginx 配置..."
kubectl apply -f Nginx-ConfigMap.yaml

# 部署 Nginx
echo "4. 部署 Nginx..."
kubectl apply -f Nginx/NginxEnvironment.yaml

# 创建 Nginx Service
echo "5. 创建 Nginx Service..."
kubectl apply -f Nginx/Service.yaml

# 创建 Ingress (可选)
echo "6. 创建 Ingress..."
kubectl apply -f Nginx/ingress.yaml

echo "部署完成！"

echo ""
echo "检查服务状态:"
kubectl get pods
echo ""
kubectl get services
echo ""
echo "访问方式:"
echo "- 集群内部: http://nginx-ha"
echo "- 通过 Ingress: http://nginx.local (需要配置 hosts 文件)"
