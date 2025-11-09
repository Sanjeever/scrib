# Scrib 博客系统

Scrib 是一个基于 Java Web 技术栈开发的博客系统，支持用户注册、博客发布、评论、收藏等功能。

## 技术栈

- **后端**: Java 17+ (Jakarta Servlet)
- **数据库**: MySQL 8.0+
- **应用服务器**: Apache Tomcat 10.1
- **构建工具**: Maven
- **前端**: JSP + JSTL

## 功能特性

- 用户注册、登录、个人资料管理
- 博客发布、编辑、删除
- Markdown 格式支持
- 评论系统（支持回复）
- 收藏功能
- 标签管理
- 文件上传（附件、图片）
- 搜索功能

## 环境要求

### 手动部署
- JDK 17 或更高版本
- Maven 3.6+
- MySQL 8.0+
- Apache Tomcat 10.1+

### Docker 部署
- Docker 20.10+
- Docker Compose 2.0+

## 快速开始

### 方式一：Docker 一键部署（推荐）

1. **克隆项目**
```bash
git clone https://github.com/m1aydeng/scrib.git
cd scrib
```

2. **启动服务**
```bash
docker-compose up -d
```

3. **访问应用**
- 应用地址: http://localhost:8080
- MySQL 端口: 3306

4. **停止服务**
```bash
docker-compose down
```

### 方式二：手动部署

#### 1. 数据库准备

创建数据库并导入初始化脚本：

```bash
mysql -u root -p < src/main/resources/init.sql
```

或者手动执行：

```sql
CREATE DATABASE scrib DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE scrib;
-- 然后执行 init.sql 中的表结构
```

#### 2. 配置数据库连接

编辑 `src/main/resources/application.yml`，修改数据库连接信息：

```yaml
database:
  driver: com.mysql.cj.jdbc.Driver
  host: localhost
  port: 3306
  database: scrib
  username: root
  password: your_password
  parameters:
    useUnicode: true
    characterEncoding: UTF-8
    useSSL: false
    serverTimezone: Asia/Shanghai
    allowPublicKeyRetrieval: true
    connectTimeout: 5000
```

#### 3. 构建项目

```bash
mvn clean package
```

构建完成后，WAR 文件位于 `target/scrib.war`

#### 4. 部署到 Tomcat

**方式 A: 直接部署 WAR 文件**

将 `target/scrib.war` 复制到 Tomcat 的 `webapps` 目录：

```bash
cp target/scrib.war $CATALINA_HOME/webapps/
```

然后启动 Tomcat：

```bash
$CATALINA_HOME/bin/startup.sh  # Linux/Mac
# 或
$CATALINA_HOME/bin/startup.bat  # Windows
```

**方式 B: 使用 Maven Tomcat 插件（开发环境）**

```bash
mvn clean package
mvn org.apache.tomcat.maven:tomcat7-maven-plugin:run
```

#### 5. 访问应用

打开浏览器访问：http://localhost:8080/scrib

## Docker 部署说明

### 项目结构

```
scrib/
├── Dockerfile              # 应用镜像构建文件
├── docker-compose.yml      # Docker Compose 配置
├── src/
└── pom.xml
```

### Docker Compose 服务

- **scrib-app**: Tomcat 应用服务（端口 8080）
- **scrib-db**: MySQL 数据库服务（端口 3306）

### 环境变量

可以通过修改 `docker-compose.yml` 中的环境变量来配置：

- `MYSQL_ROOT_PASSWORD`: MySQL root 密码
- `MYSQL_DATABASE`: 数据库名称
- `DB_HOST`: 数据库主机（容器内使用服务名 `scrib-db`）
- `DB_PORT`: 数据库端口
- `DB_USERNAME`: 数据库用户名
- `DB_PASSWORD`: 数据库密码

### 数据持久化

- MySQL 数据存储在 Docker volume `scrib_mysql_data`
- 应用上传的文件存储在容器内的 `/usr/local/tomcat/webapps/scrib/uploads`

### 查看日志

```bash
# 查看所有服务日志
docker-compose logs -f

# 查看应用日志
docker-compose logs -f scrib-app

# 查看数据库日志
docker-compose logs -f scrib-db
```

### 重新构建镜像

```bash
docker-compose build
docker-compose up -d
```

## 开发指南

### 项目结构

```
src/
├── main/
│   ├── java/
│   │   └── cyou/mayloves/
│   │       ├── dao/          # 数据访问层
│   │       ├── filter/        # 过滤器
│   │       ├── listener/      # 监听器
│   │       ├── model/         # 数据模型
│   │       ├── servlet/       # Servlet 控制器
│   │       └── util/          # 工具类
│   ├── resources/
│   │   ├── application.yml    # 数据库配置
│   │   └── init.sql          # 数据库初始化脚本
│   └── webapp/               # Web 资源
│       ├── WEB-INF/
│       │   └── web.xml       # Web 应用配置
│       └── *.jsp             # JSP 页面
└── test/
```

### 本地开发

1. 配置本地 MySQL 数据库
2. 修改 `application.yml` 中的数据库连接
3. 使用 IDE（如 IntelliJ IDEA）导入 Maven 项目
4. 配置 Tomcat 运行配置
5. 启动应用进行开发

### 构建 WAR 文件

```bash
mvn clean package
```

WAR 文件输出位置：`target/scrib.war`

## 常见问题

### 1. 数据库连接失败

- 检查 `application.yml` 中的数据库配置是否正确
- 确认 MySQL 服务已启动
- 检查防火墙设置
- Docker 部署时，确保使用正确的服务名（`scrib-db`）作为主机名

### 2. 端口冲突

如果 8080 或 3306 端口被占用，可以修改 `docker-compose.yml` 中的端口映射：

```yaml
ports:
  - "8081:8080"  # 将 8081 映射到容器的 8080
```

### 3. 文件上传失败

- 检查 Tomcat 的 `webapps/scrib/uploads` 目录权限
- 确保有足够的磁盘空间
- Docker 部署时，检查容器的文件系统权限

### 4. 中文乱码

- 确保数据库使用 `utf8mb4` 字符集
- 检查 Tomcat 的 `server.xml` 中 URI 编码设置
- 确保 JSP 页面使用 UTF-8 编码

## 许可证

本项目采用 MIT 许可证。

## 贡献

欢迎提交 Issue 和 Pull Request！

