
# Kafka + Logstash + KEDA（Kafka scaler）端到端联调

目标：用 Kafka 消息堆积（lag）作为度量，驱动 Logstash 的自动扩缩容。

## 1. 用 Docker 启动 Kafka 并创建 topic

```sh
docker compose up -d
docker exec -it kafka bash /opt/kafka/bin/kafka-topics.sh --create --topic pythonTestTopic --bootstrap-server localhost:9094 --partitions 8 --replication-factor 1
```

> 说明：分区数决定并行消费上限，若希望副本数>1有效提升吞吐，请将分区数设为≥期望副本数。

## 2. 部署 K8s 资源

```sh
kubectl apply -f k8s/external-kafka-service.yaml -n default
kubectl apply -f k8s/logstash-configmap.yaml -n default
kubectl apply -f k8s/logstash-deployment.yaml -n default
```

或使用与 KEDA ScaledObject 对齐的 logs 命名空间版本（StatefulSet 名称匹配）：

```sh
kubectl create ns logs --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f k8s/logstash-configmap-logs.yaml -n logs
kubectl apply -f k8s/logstash-sts-logs.yaml -n logs
```

## 3. 使用 KEDA 进行扩缩容

安装 KEDA（如未安装）：
```sh
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
helm upgrade -i keda kedacore/keda -n keda --create-namespace
```

应用 ScaledObject（示例文件位于 k8s/KEDA-kafka-logstash-external.yaml，注意命名空间与目标 StatefulSet/Dployment 名称需与你环境一致）：
```sh
kubectl apply -f k8s/KEDA-kafka-logstash-external.yaml -n logs
kubectl describe scaledobject servicelogs-logstash-scaler -n logs
```

## 4. 造数压测

使用本地 Python 脚本快速造数：
```sh
pip install kafka-python
BROKER=localhost:9094 TOPIC=pythonTestTopic RATE=5000 DURATION=600 BATCH=1000 python kafka-producer.py
```

或使用 K8s Job（如需）：
```sh
kubectl apply -f k8s/kafka-producer-job-external.yaml -n logs
kubectl logs -f job/kafka-producer-external -n logs
```

## 5. 观察 HPA 自动伸缩

```sh
kubectl get hpa -n logs
kubectl describe hpa -n logs
kubectl get sts logstash-servicelogs-logstash -n logs -w
kubectl logs -n keda deploy/keda-operator | grep -i kafka
```

## 6. 清理

```sh
kubectl delete -f k8s/kafka-producer-job-external.yaml -n default --ignore-not-found
kubectl delete -f k8s/KEDA-kafka-logstash-external.yaml -n logs --ignore-not-found
kubectl delete -f k8s/logstash-deployment.yaml -n default --ignore-not-found
kubectl delete -f k8s/logstash-configmap.yaml -n default --ignore-not-found
```

## 常见问题
- NoBrokersAvailable/connection refused：从 logs 命名空间测试到 external-kafka:9094 的连通性。
- 不扩容：检查 topic/consumerGroup 与 Logstash 一致；分区数是否足够；allowIdleConsumers 是否需要开启。
- 伸缩慢：调整 pollingInterval、cooldownPeriod、HPA behavior 的 stabilizationWindowSeconds。
