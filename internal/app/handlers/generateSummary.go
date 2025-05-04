package handlers

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"log"
	"mime/multipart"
	"net/http"
	"strconv"
)

type LectureUploadRequest struct {
	SubjectID  int64
	Title      string
	File       multipart.File
	FileHeader *multipart.FileHeader
}

type MLResponse struct {
	Text    string `json:"text"`
	Summary string `json:"summary"`
}

func parseLectureUpload(r *http.Request) (*LectureUploadRequest, error) {
	err := r.ParseMultipartForm(20 << 20)
	if err != nil {
		log.Println("ParseMultipartForm error:", err)

		return nil, err
	}
	file, fileHeader, err := r.FormFile("file")
	if err != nil {
		log.Println("FormFile error:", err)

		return nil, err
	}
	subjectID, err := strconv.ParseInt(r.FormValue("subject_id"), 10, 64)
	if err != nil {
		log.Println("ParseInt error:", err)

		return nil, err
	}
	return &LectureUploadRequest{
		SubjectID:  subjectID,
		Title:      r.FormValue("title"),
		File:       file,
		FileHeader: fileHeader,
	}, nil
}

func (h *Handler) HandleUploadLecture(w http.ResponseWriter, r *http.Request) {
	req, err := parseLectureUpload(r)
	if err != nil {
		http.Error(w, "bad request", http.StatusBadRequest)
		return
	}
	defer req.File.Close()

	fileBytes, err := io.ReadAll(req.File)
	if err != nil {
		http.Error(w, "file read error", http.StatusInternalServerError)
		return
	}

	summary, err := callMLSummarizer(req.FileHeader.Filename, fileBytes)
	if err != nil {
		http.Error(w, "ml error", http.StatusInternalServerError)
		return
	}

	var id int64
	err = h.DB.QueryRow(context.Background(), `
		INSERT INTO lectures (subject_id, title, content, summary, uploaded_at)
		VALUES ($1, $2, $3, $4, now()) RETURNING id
	`, req.SubjectID, req.Title, summary.Text, summary.Summary).Scan(&id)
	if err != nil {
		http.Error(w, "db error", http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(map[string]interface{}{
		"lecture_id": id,
		"status":     "uploaded",
		"text":       summary.Text,
		"summary":    summary.Summary,
	})
}

func callMLSummarizer(filename string, content []byte) (*MLResponse, error) {
	var buf bytes.Buffer
	writer := multipart.NewWriter(&buf)

	part, _ := writer.CreateFormFile("file", filename)
	part.Write(content)
	writer.Close()

	req, _ := http.NewRequest("POST", "http://ml:8000/summarize", &buf)
	req.Header.Set("Content-Type", writer.FormDataContentType())

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var mlResp MLResponse
	err = json.NewDecoder(resp.Body).Decode(&mlResp)
	if err != nil {
		return nil, err
	}
	return &mlResp, nil
}
