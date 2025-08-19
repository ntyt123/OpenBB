FROM python:3.11-slim

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y \
  build-essential \
  curl \
  git \
  libpq-dev \
  gcc \
  g++ \
  && rm -rf /var/lib/apt/lists/*

# 复制项目
COPY . .

# 安装Poetry和TOML
RUN pip install poetry toml

# 进入platform目录
WORKDIR /app/openbb_platform

# 运行开发安装脚本
RUN python dev_install.py

# 回到主目录
WORKDIR /app

# 创建用户
RUN useradd -m -u 1000 openbb && \
  chown -R openbb:openbb /app
USER openbb

EXPOSE 6900

# 启动服务
CMD ["python", "-c", "from openbb_core.api.rest_api import app; import uvicorn; uvicorn.run(app, host='0.0.0.0', port=6900)"]