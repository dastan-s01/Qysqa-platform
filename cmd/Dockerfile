# Используем официальный образ для Go
FROM golang:1.20 AS builder

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем go.mod и go.sum для кеширования зависимостей
COPY ../go.mod go.sum ./

# Загружаем все зависимости
RUN go mod tidy

# Копируем весь проект в контейнер
COPY .. .

# Компилируем приложение
RUN go build -o backend ./cmd/main.go

# Финальный образ
FROM gcr.io/distroless/base-debian11

# Копируем скомпилированный файл из builder
COPY --from=builder /app/backend /app/backend

# Устанавливаем рабочую директорию
WORKDIR /app

# Запускаем бэкенд
CMD ["/app/backend"]




