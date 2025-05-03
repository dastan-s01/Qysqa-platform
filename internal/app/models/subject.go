package models

type Subject struct {
	ID     int    `json:"subjectID"`
	Name   string `json:"subjectName"`
	UserID int    `json:"userID"`
}
