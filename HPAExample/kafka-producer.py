import json
import os
import random
import string
import time
from datetime import datetime

from kafka import KafkaProducer

BROKER = os.environ.get("BROKER", "localhost:9094")
TOPIC = os.environ.get("TOPIC", "pythonTestTopic")
RATE = float(os.environ.get("RATE", "1000"))  # 每秒消息数
DURATION = int(os.environ.get("DURATION", "60"))  # 持续秒数
BATCH = int(os.environ.get("BATCH", "200"))  # 批量发送条数

producer = KafkaProducer(
    bootstrap_servers=[BROKER],
    value_serializer=lambda v: json.dumps(v).encode('utf-8'))


def randstr(n=24):
  return ''.join(random.choices(string.ascii_letters + string.digits, k=n))


end = time.time() + DURATION
sent = 0
buf = []
interval = 1.0 / RATE if RATE > 0 else 0

while time.time() < end:
  buf.append({
      "ts": datetime.utcnow().isoformat() + "Z",
      "id": sent,
      "text": randstr()
  })
  sent += 1
  if len(buf) >= BATCH:
    for x in buf:
      producer.send(TOPIC, x)
    producer.flush()
    buf.clear()
  if interval > 0:
    time.sleep(interval)

for x in buf:
  producer.send(TOPIC, x)
producer.flush()
print(f"Sent {sent} messages to {TOPIC} on {BROKER}")
