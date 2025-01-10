#!/bin/bash

# 定义镜像列表
images=(
  "jimmidyson/configmap-reload:v0.5.0"
  "prom/prometheus:v2.34.0"
  "docker.io/jaegertracing/all-in-one:1.35"
  "grafana/grafana:9.0.1"
)

# 私有仓库地址
private_registry="1.95.55.88:5000"

# 1. 拉取镜像
echo "正在拉取镜像..."
for image in "${images[@]}"; do
  docker pull $image
done

echo "镜像拉取完成。请确认是否推送到私有仓库 (y/n):"
read confirmation

if [[ $confirmation == "y" || $confirmation == "Y" ]]; then
  # 2. 推送镜像到私有仓库
  echo "正在推送镜像到私有仓库..."
  for image in "${images[@]}"; do
    # 提取镜像名和标签
    image_name=$(echo $image | awk -F/ '{print $NF}' | awk -F: '{print $1}')
    tag=$(echo $image | awk -F: '{print $2}')
    
    # 构建新的镜像标签，使用私有仓库地址作为前缀
    new_image="$private_registry/$image_name:$tag"
    
    # 重新标记镜像
    docker tag $image $new_image
    
    # 推送镜像到私有仓库
    docker push $new_image
    
    # 删除本地镜像
    docker rmi $image $new_image
  done

  echo "镜像推送完成。"
else
  echo "操作取消。"
fi
