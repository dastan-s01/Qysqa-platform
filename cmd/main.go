package main

import (
	"github.com/go-chi/chi/v5"
	"log"
	"net/http"
	"qysqa-platform/db"
	"qysqa-platform/internal/app/handlers"
)

func main() {

	dsn := "postgres://postgres:qysqa123@localhost:5433/qysqa?sslmode=disable"
	dbPool, err := db.ConnectionPg(dsn)
	if err != nil {
		log.Fatalf("❌ Failed to connect to DB: %v", err)
	}
	defer dbPool.Close()
	r := chi.NewRouter()
	h := handlers.NewHandler(dbPool)
	h.RegisterRoutes(r)

	log.Println("🚀 Server running at :8080")
	err = http.ListenAndServe(":8080", r)
	if err != nil {
		log.Fatal(err)
	}
}
