package handlers

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
)

type QuizRequest struct {
	LectureID int64 `json:"lecture_id"`
}

type Quiz struct {
	Question      string   `json:"question"`
	Options       []string `json:"options"`
	CorrectAnswer string   `json:"correct_answer"`
}

func (h *Handler) HandleGenerateQuiz(w http.ResponseWriter, r *http.Request) {
	var req QuizRequest
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

	quizQuestions, err := callMLQuizGenerator(content)
	if err != nil {
		http.Error(w, "ml error", http.StatusInternalServerError)
		return
	}

	// сохраняем каждый вопрос
	for _, q := range quizQuestions {
		_, err := h.DB.Exec(context.Background(),
			`INSERT INTO quizzes (lecture_id, question, options, correct_answer)
			 VALUES ($1, $2, $3, $4)`,
			req.LectureID, q.Question, q.Options, q.CorrectAnswer)
		if err != nil {
			http.Error(w, "db error", http.StatusInternalServerError)
			return
		}
	}

	json.NewEncoder(w).Encode(map[string]interface{}{
		"status":    "quiz created",
		"questions": quizQuestions,
	})
}

func callMLQuizGenerator(text string) ([]Quiz, error) {
	payload := map[string]string{"text": text}
	jsonData, _ := json.Marshal(payload)

	resp, err := http.Post("http://ml:8000/quiz", "application/json", bytes.NewReader(jsonData))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var result []Quiz
	err = json.NewDecoder(resp.Body).Decode(&result)
	if err != nil {
		return nil, err
	}
	return result, nil
}
