# 使用官方 Tomcat 镜像，基于 JDK 21
FROM tomcat:10.1-jdk21-temurin

# 设置工作目录
WORKDIR /usr/local/tomcat

# 安装 Maven 和 wget（用于构建项目和健康检查）
RUN apt-get update && \
    apt-get install -y maven wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 复制项目文件
COPY pom.xml /tmp/
COPY src /tmp/src

# 使用 Docker 环境的配置文件
RUN cp /tmp/src/main/resources/application-docker.yml /tmp/src/main/resources/application.yml

# 构建 WAR 文件
WORKDIR /tmp
RUN mvn clean package -DskipTests

# 复制 WAR 文件到 Tomcat webapps 目录
RUN cp target/scrib.war /usr/local/tomcat/webapps/

# 注意：不要在这里创建 scrib 目录，让 Tomcat 自动解压 WAR 文件
# uploads 目录会在应用启动后通过 volume 挂载创建

# 暴露端口
EXPOSE 8080

# 启动 Tomcat
CMD ["catalina.sh", "run"]

