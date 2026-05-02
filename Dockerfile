FROM python:3.12-slim

# Устанавливаем зависимости для загрузки и работы
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем uv через официальный скрипт (обходим GHCR)
ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh
ENV PATH="/root/.local/bin/:$PATH"

WORKDIR /app

# Копируем конфиги
COPY pyproject.toml uv.lock ./

# Ставим зависимости (без виртуального окружения, так как мы в контейнере)
RUN uv sync --frozen --no-cache

# Докидываем остальное
COPY . .

# Финальный синк проекта
RUN uv sync --frozen

CMD ["uv", "run", "python", "main.py"]