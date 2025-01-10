#!/bin/bash

# 定义镜像列表
images=(
  "calico/kube-controllers:v3.22.5"
  "calico/cni:v3.22.5"
  "calico/pod2daemon-flexvol:v3.22.5"
  "calico/node:v3.22.5"
)

# 私有镜像仓库地址
server_address=192.168.0.172:5000

# 拉取并重命名镜像
for image in "${images[@]}"; do
  # 提取镜像名和标签
  image_name=$(echo $image | cut -d '/' -f 2)
  
  # 构建新的镜像标签，使用服务器地址作为前缀
  new_image="$server_address/$image_name"
  
  echo "Pulling image: $new_image"
  # 从私有仓库拉取镜像
  docker pull $new_image
  
  # 重新标记镜像
  docker tag $new_image docker.io/calico/$image_name
  
  # 删除临时镜像标签
  # docker rmi $new_image
done

echo "镜像拉取并重命名完成！"
