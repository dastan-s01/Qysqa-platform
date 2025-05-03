package models

type Quiz struct {
	ID        int    `json:"id"`
	LectureID int    `json:"lecture_id"`
	CreatedAt string `json:"created_at"`
}
type QuizQuestion struct {
	ID       int      `json:"id"`
	QuizID   int      `json:"quiz_id"`
	Question string   `json:"question"`
	Choices  []string `json:"choices" `
	Answer   string   `json:"answer"`
}
