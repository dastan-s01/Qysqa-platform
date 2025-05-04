package handlers

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
)

type Flashcard struct {
	id         int
	lecture_id int
	question   string
	answer     string
}
type FlashcardsRequest struct {
	LectureID int64 `json:"lecture_id"`
}

func (h *Handler) HandleGenerateFlashcards(w http.ResponseWriter, r *http.Request) {
	var req FlashcardsRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "bad request", http.StatusBadRequest)
		return
	}

	var content string
	err := h.DB.QueryRow(context.Background(),
		`SELECT content FROM lectures WHERE id = $1`, req.LectureID).Scan(&content)
	if err != nil {
		http.Error(w, "lecture not found", http.StatusNotFound)
		return
	}

	flashcards, err := callMLFlashcardGenerator(content)
	if err != nil {
		http.Error(w, "ml error", http.StatusInternalServerError)
		return
	}

	// сохранить в БД flashcards (таблица flashcards с полями: lecture_id, question, answer)

	// возвращаем пользователю
	json.NewEncoder(w).Encode(map[string]interface{}{
		"flashcards": flashcards,
	})
}
func callMLFlashcardGenerator(text string) ([]Flashcard, error) {
	payload := map[string]string{"text": text}
	jsonData, _ := json.Marshal(payload)

	resp, err := http.Post("http://ml:8000/flashcards", "application/json", bytes.NewReader(jsonData))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var result []Flashcard
	err = json.NewDecoder(resp.Body).Decode(&result)
	if err != nil {
		return nil, err
	}
	return result, nil
}
