# Используем официальный образ для Go
FROM golang:1.20 AS builder

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем go.mod и go.sum для кеширования зависимостей
COPY go.mod go.sum ./

# Загружаем все зависимости
RUN go mod tidy

# Копируем весь проект в контейнер
COPY . .

# Компилируем приложение
RUN go build -o backend ./cmd

# Финальный образ
FROM gcr.io/distroless/base-debian11

# Копируем скомпилированный файл из builder
COPY --from=builder /app/backend /app/backend

# Устанавливаем рабочую директорию
WORKDIR /app

# Запускаем бэкенд
CMD ["/app/backend"]




# Используем официальный образ для Python
FROM python:3.9-slim

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем requirements.txt для установки зависимостей
COPY requirements.txt .

# Устанавливаем зависимости
RUN pip install --no-cache-dir -r requirements.txt

# Копируем весь проект в контейнер
COPY . .

# Устанавливаем переменную окружения для выполнения main.py
CMD ["python", "main.py"]