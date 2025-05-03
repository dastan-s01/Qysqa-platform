package handlers

import (
	"github.com/go-chi/chi/v5"
	"github.com/jackc/pgx/v4/pgxpool"
)

type Handler struct {
	DB *pgxpool.Pool
}

func NewHandler(db *pgxpool.Pool) *Handler {
	return &Handler{DB: db}
}
func (h *Handler) RegisterRoutes(r chi.Router) {
	r.Post("/api/lecture/upload", h.HandleUploadLecture)
}
