#!/bin/bash

# 定义镜像列表
images=(
  "currencyservice:v0.10.0"
  "loadgenerator:v0.10.0"
  "productcatalogservice:v0.10.0"
  "checkoutservice:v0.10.0"
  "shippingservice:v0.10.0"
  "cartservice:v0.10.0"
  "emailservice:v0.10.0"
  "paymentservice:v0.10.0"
  "frontend:v0.10.0"
  "recommendationservice:v0.10.0"
  "adservice:v0.10.0"
)

registry_address=192.168.0.172:5000

# 遍历镜像列表，从 Docker Registry 拉取并重新命名
for image in "${images[@]}"; do
  # 拉取镜像
  docker pull $registry_address/$image
  
  # 重新命名镜像为原始名称
  docker tag $registry_address/$image gcr.io/google-samples/microservices-demo/$image
  
  # 删除从 Docker Registry 拉取的镜像
  docker rmi $registry_address/$image
done

echo "镜像拉取并重命名完成！"
