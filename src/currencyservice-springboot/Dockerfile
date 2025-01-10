# 使用 OpenJDK 17 镜像作为基础
FROM openjdk:17

# 设置工作目录
WORKDIR /app

# 将打包好的 Spring Boot JAR 文件复制到容器中
COPY grpc-service/target/grpc-service-2.6.2.jar app.jar

# 默认的启动命令
CMD ["java", "-jar", "app.jar"]
