#!/bin/bash

echo "部署 NodeJS 和 Nginx 反向代理..."

echo "0. 起Kubernetes服务"
kubectl apply -f ../ingress-nginx.yaml
kubectl apply -f ../MetricsServer.yaml

sleep 5

# 部署 NodeJS 应用
echo "1. 部署 NodeJS 应用..."
kubectl apply -f nodeJSEnvironment.yaml

# 创建 NodeJS Service
echo "2. 创建 NodeJS Service..."
kubectl apply -f NodeJS-Service.yaml
# 创建 NodeJS HPA
kubectl apply -f NodeJS-HorizontalPodAutoscaler.yaml

# 创建 TLS Secret
echo "3. 创建 TLS Secret..."
kubectl create secret tls silverhand-personal-website-tls \
  --cert=secret/silverhand.personal.website.crt \
  --key=secret/silverhand.personal.website.key \
  --dry-run=client -o yaml | kubectl apply -f -

# 创建 Nginx 配置
echo "4. 创建 Nginx 配置..."
kubectl apply -f Nginx-ConfigMap.yaml

# 部署 Nginx
echo "5. 部署 Nginx..."
kubectl apply -f Nginx/NginxEnvironment.yaml

# 创建 Nginx Service
echo "6. 创建 Nginx Service..."
kubectl apply -f Nginx/Service.yaml

sleep 5

# 创建 Ingress (可选)
echo "7. 创建 Ingress..."
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
echo "- 通过 Ingress: https://silverhand.personal.website (需要正确的 DNS/hosts 和 TLS Secret)"
