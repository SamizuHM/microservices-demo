#!/bin/bash

# 定义镜像列表
images=(
  "docker.io/calico/kube-controllers:v3.22.5"
  "docker.io/calico/cni:v3.22.5"
  "docker.io/calico/pod2daemon-flexvol:v3.22.5"
  "docker.io/calico/node:v3.22.5"
)

# 私有镜像仓库地址
server_address=1.95.89.79:5000

# 拉取所有镜像
for image in "${images[@]}"; do
  echo "Pulling image: $image"
  docker pull $image
done

echo "所有镜像已拉取完成，请检查并按下任意键继续推送到私有仓库..."
read -n 1 -s -r -p ""

# 推送到私有仓库
for image in "${images[@]}"; do
  # 提取镜像名和标签
  image_name=$(echo $image | cut -d '/' -f 3)
  
  # 构建新的镜像标签，使用服务器地址作为前缀
  new_image="$server_address/$image_name"
  
  # 重新标记镜像
  docker tag $image $new_image
  
  echo "Pushing image: $new_image"
  # 推送镜像到服务器的 Docker Registry
  docker push $new_image
  
  # 删除本地镜像
  # docker rmi $image $new_image
done

echo "镜像推送完成！"
