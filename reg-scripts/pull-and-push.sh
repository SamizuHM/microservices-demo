#!/bin/bash

# 定义镜像列表
images=(
  "gcr.io/google-samples/microservices-demo/currencyservice:v0.10.0"
  "gcr.io/google-samples/microservices-demo/loadgenerator:v0.10.0"
  "gcr.io/google-samples/microservices-demo/productcatalogservice:v0.10.0"
  "gcr.io/google-samples/microservices-demo/checkoutservice:v0.10.0"
  "gcr.io/google-samples/microservices-demo/shippingservice:v0.10.0"
  "gcr.io/google-samples/microservices-demo/cartservice:v0.10.0"
  "gcr.io/google-samples/microservices-demo/emailservice:v0.10.0"
  "gcr.io/google-samples/microservices-demo/paymentservice:v0.10.0"
  "gcr.io/google-samples/microservices-demo/frontend:v0.10.0"
  "gcr.io/google-samples/microservices-demo/recommendationservice:v0.10.0"
  "gcr.io/google-samples/microservices-demo/adservice:v0.10.0"
)

server_address=1.95.89.79:5000

# 遍历镜像列表，拉取所有镜像
for image in "${images[@]}"; do
  docker pull $image
done

# 提示用户确认后再推送镜像
read -p "镜像已拉取完成，是否现在推送到服务器的 Docker Registry？(Y/N): " confirm
if [[ $confirm == "Y" || $confirm == "y" ]]; then
  # 遍历镜像列表，推送到服务器的 Docker Registry
  for image in "${images[@]}"; do
    # 提取镜像名和标签
    image_name=$(echo $image | cut -d '/' -f 4)
    
    # 构建新的镜像标签，使用服务器地址作为前缀
    new_image="$server_address/$image_name"
    
    # 重新标记镜像
    docker tag $image $new_image
    
    # 推送镜像到服务器的 Docker Registry
    docker push $new_image
    
    # 删除本地镜像
    docker rmi $image $new_image
  done
  echo "镜像推送完成！"
else
  echo "取消推送镜像。"
fi
