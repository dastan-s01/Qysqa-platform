from fastapi import FastAPI, File, UploadFile, Form, Query
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import List, Dict, Any, Optional
import uvicorn
from ai_generators import ContentGenerator

app = FastAPI(title="Educational Content API", description="API для генерации образовательного контента")

# Инициализация генератора контента
content_generator = ContentGenerator()

class MLResponse(BaseModel):
    text: str
    summary: str

class TestRequest(BaseModel):
    text: str
    num_questions: int = 5

class FlashcardRequest(BaseModel):
    text: str
    num_cards: int = 5

class SummaryRequest(BaseModel):
    text: str
    max_length: int = 300

class TestQuestion(BaseModel):
    question: str
    options: List[str]
    correct_index: int

class Flashcard(BaseModel):
    front: str
    back: str

@app.post("/summarize", response_model=MLResponse)
async def summarize(file: UploadFile = File(...)):
    """Суммаризация текста из файла"""
    # Читаем содержимое файла
    content = await file.read()
    text = content.decode("utf-8")
    
    # Генерация саммаризации с помощью модели
    summary = content_generator.generate_summary(text)
    
    # Возвращаем результат
    return MLResponse(
        text=text,
        summary=summary
    )

@app.post("/generate-test", response_model=List[TestQuestion])
async def generate_test(request: TestRequest):
    """Генерация тестовых вопросов на основе текста"""
    # Генерация тестовых вопросов
    questions = content_generator.generate_tests(request.text, request.num_questions)
    
    # Возвращаем результат
    return questions

@app.post("/generate-flashcards", response_model=List[Flashcard])
async def generate_flashcards(request: FlashcardRequest):
    """Генерация флеш-карточек на основе текста"""
    # Генерация флеш-карточек
    flashcards = content_generator.generate_flashcards(request.text, request.num_cards)
    
    # Возвращаем результат
    return flashcards

@app.post("/generate-summary", response_model=str)
async def generate_summary(request: SummaryRequest):
    """Генерация краткого содержания текста"""
    # Генерация краткого содержания
    summary = content_generator.generate_summary(request.text, request.max_length)
    
    # Возвращаем результат
    return summary

@app.post("/all-in-one")
async def generate_all(
    text: str = Form(...),
    num_questions: int = Form(3),
    num_flashcards: int = Form(3)
):
    """Генерация всех типов контента за один запрос"""
    # Генерация всех типов контента
    summary = content_generator.generate_summary(text)
    questions = content_generator.generate_tests(text, num_questions)
    flashcards = content_generator.generate_flashcards(text, num_flashcards)
    
    # Возвращаем результат
    return {
        "summary": summary,
        "test_questions": questions,
        "flashcards": flashcards
    }

if __name__ == "__main__":
    print("Запуск сервера генерации образовательного контента...")
    uvicorn.run(app, host="0.0.0.0", port=8000)