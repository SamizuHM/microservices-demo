#!/bin/bash

# 定义镜像列表
images=(
  "jimmidyson/configmap-reload:v0.5.0"
  "prom/prometheus:v2.34.0"
  "docker.io/jaegertracing/all-in-one:1.35"
  "grafana/grafana:9.0.1"
)

# 私有仓库地址
private_registry="192.168.0.100:5000"


# 3. 从私有仓库拉取并重新标记镜像
echo "正在从私有仓库拉取并重新标记镜像..."
for image in "${images[@]}"; do
  # 提取镜像名和标签
  image_name=$(echo $image | awk -F/ '{print $NF}' | awk -F: '{print $1}')
  tag=$(echo $image | awk -F: '{print $2}')
  
  # 构建新的镜像标签，使用私有仓库地址作为前缀
  new_image="$private_registry/$image_name:$tag"
  
  # 拉取镜像
  docker pull $new_image
  
  # 重新标记镜像
  docker tag $new_image $image
done

echo "镜像拉取并重新标记完成。"
