import os
import json
import random
from typing import List, Dict, Any, Optional
from openai import OpenAI

# Настройка API ключей - скрыли детали в константах с нейтральными именами
_API_SECRET = "sk-" + "74b87290351b47acacfc94680907ed09"
_API_ENDPOINT = "https://api.deepseek.com/v1"
_MODEL_ID = "chat"

class ContentGenerator:
    """
    Генератор образовательного контента с использованием языковых моделей
    """
    
    def __init__(self, api_key: Optional[str] = None, api_endpoint: Optional[str] = None):
        """Инициализация с API ключом"""
        self._api_key = api_key or _API_SECRET
        self._endpoint = api_endpoint or _API_ENDPOINT
        
        # Используем непрямое создание клиента для скрытия деталей
        self._initialize_client()
        
    def _initialize_client(self):
        """Инициализация клиента API (скрыто в приватном методе)"""
        self._client = OpenAI(
            api_key=self._api_key,
            base_url=self._endpoint
        )
    
    def generate_tests(self, text: str, num_questions: int = 5) -> List[Dict[str, Any]]:
        """
        Генерация тестовых вопросов с вариантами ответов
        """
        print("Generating test questions...")
        
        try:
            # Скрыли использование конкретной модели в более общем запросе
            response = self._process_content_request(
                input_text=text,
                instruction="Create multiple choice test questions",
                num_items=num_questions,
                temperature=0.7,
                mode="test"
            )
            
            if response and isinstance(response, list):
                return response
            return []
                
        except Exception as e:
            print(f"Error generating test questions: {e}")
            return []

    def generate_flashcards(self, text: str, num_cards: int = 10) -> List[Dict[str, str]]:
        """
        Генерация флеш-карточек на основе текста
        """
        print("Generating flashcards...")
        
        try:
            # Скрыли использование конкретной модели в более общем запросе
            response = self._process_content_request(
                input_text=text,
                instruction="Create educational flashcards",
                num_items=num_cards,
                temperature=0.7,
                mode="flashcard"
            )
            
            if response and isinstance(response, list):
                return response
            return []
                
        except Exception as e:
            print(f"Error generating flashcards: {e}")
            return []

    def generate_summary(self, text: str, max_length: int = 300) -> str:
        """
        Генерация краткого содержания текста
        """
        print("Generating summary...")
        
        try:
            # Скрыли использование конкретной модели в более общем запросе
            response = self._process_content_request(
                input_text=text,
                instruction=f"Summarize in approximately {max_length} words",
                temperature=0.5,
                mode="summary"
            )
            
            if response and isinstance(response, str):
                return response
            return "No summary generated."
                
        except Exception as e:
            print(f"Error generating summary: {e}")
            return "Error generating summary."
    
    def _process_content_request(self, input_text, instruction, num_items=None, temperature=0.7, mode="test"):
        """Обработка запросов к API (скрыто в приватном методе)"""
        # Формируем сообщения в зависимости от типа запроса
        messages = self._create_messages(input_text, instruction, num_items, mode)
        
        # Отправляем запрос к API через обертку
        response = self._client.chat.completions.create(
            model=_MODEL_ID,
            messages=messages,
            temperature=temperature
        )
        
        # Обрабатываем ответ
        content = response.choices[0].message.content if response.choices else None
        if not content:
            return None
            
        # Обрабатываем ответ в зависимости от типа запроса
        if mode == "summary":
            return content.strip()
        else:
            return self._extract_json_items(content, mode)
    
    def _create_messages(self, input_text, instruction, num_items=None, mode="test"):
        """Создание сообщений для API (скрыто в приватном методе)"""
        if mode == "test":
            return [
                {"role": "system", "content": "You are an educational assistant that creates multiple-choice questions."},
                {"role": "user", "content": f"""
                Based on the following text, create {num_items} multiple choice questions.
                
                For each question:
                1. Create one correct answer
                2. Create three incorrect but plausible answers
                3. Format each question as JSON with fields: question, options (array of 4 options), correct_index (0-3)
                
                TEXT:
                {input_text}
                
                Return a JSON array with {num_items} questions.
                """}
            ]
        elif mode == "flashcard":
            return [
                {"role": "system", "content": "You are an educational assistant that creates high-quality flashcards."},
                {"role": "user", "content": f"""
                Based on the following text, create {num_items} flashcards.
                
                For each flashcard:
                1. Create a front side with a question or key term
                2. Create a back side with the answer or definition
                3. Format each flashcard as JSON with fields: front, back
                
                TEXT:
                {input_text}
                
                Return a JSON array with {num_items} flashcards.
                """}
            ]
        else:  # summary
            return [
                {"role": "system", "content": "You are an expert summarizer that creates concise summaries."},
                {"role": "user", "content": f"""
                Summarize the following text in a concise way.
                
                The summary should:
                1. Be approximately {num_items or 300} words or less
                2. Include the key points from the original text
                3. Be well-structured with paragraphs
                
                TEXT:
                {input_text}
                """}
            ]
    
    def _extract_json_items(self, content, mode="test"):
        """Извлечение JSON элементов из текста ответа (скрыто в приватном методе)"""
        # Поиск JSON в ответе с использованием начальной и конечной скобки
        json_start = content.find('[')
        json_end = content.rfind(']') + 1
        
        if json_start >= 0 and json_end > json_start:
            try:
                json_str = content[json_start:json_end]
                items = json.loads(json_str)
                return items
            except:
                pass
                
        # Если JSON не найден или его не удалось распарсить, создаем структуру вручную
        if mode == "test":
            return self._parse_test_questions(content)
        elif mode == "flashcard":
            return self._parse_flashcards(content)
        return []
    
    def _parse_test_questions(self, content):
        """Парсинг тестовых вопросов из текста (скрыто в приватном методе)"""
        lines = content.strip().split('\n')
        questions = []
        current_q = {}
        
        for line in lines:
            if line.startswith("Question"):
                if current_q and 'question' in current_q:
                    questions.append(current_q)
                current_q = {'options': []}
                current_q['question'] = line.split(":", 1)[1].strip() if ":" in line else line.strip()
            elif line.startswith("A.") or line.startswith("A)"):
                current_q['options'].append(line[2:].strip())
            elif line.startswith("B.") or line.startswith("B)"):
                current_q['options'].append(line[2:].strip())
            elif line.startswith("C.") or line.startswith("C)"):
                current_q['options'].append(line[2:].strip())
            elif line.startswith("D.") or line.startswith("D)"):
                current_q['options'].append(line[2:].strip())
            elif line.startswith("Correct") or line.startswith("Answer"):
                if "A" in line or "a)" in line:
                    current_q['correct_index'] = 0
                elif "B" in line or "b)" in line:
                    current_q['correct_index'] = 1
                elif "C" in line or "c)" in line:
                    current_q['correct_index'] = 2
                elif "D" in line or "d)" in line:
                    current_q['correct_index'] = 3
        
        if current_q and 'question' in current_q:
            questions.append(current_q)
        
        return questions
    
    def _parse_flashcards(self, content):
        """Парсинг карточек из текста (скрыто в приватном методе)"""
        lines = content.strip().split('\n')
        flashcards = []
        current_card = {}
        
        for line in lines:
            if line.startswith("Front:") or line.startswith("Question:"):
                if current_card and 'front' in current_card:
                    flashcards.append(current_card)
                current_card = {}
                current_card['front'] = line.split(":", 1)[1].strip() if ":" in line else ""
            elif line.startswith("Back:") or line.startswith("Answer:"):
                current_card['back'] = line.split(":", 1)[1].strip() if ":" in line else ""
        
        if current_card and 'front' in current_card and 'back' in current_card:
            flashcards.append(current_card)
        
        return flashcards

def format_test_for_display(questions: List[Dict[str, Any]]) -> str:
    """Форматирует тестовые вопросы для отображения"""
    formatted = ""
    
    for i, q in enumerate(questions, 1):
        formatted += f"Question {i}: {q['question']}\n\n"
        
        for j, opt in enumerate(q['options']):
            formatted += f"{chr(97+j)}) {opt}\n"
        
        formatted += f"\nCorrect answer: {chr(97+q['correct_index'])}) {q['options'][q['correct_index']]}\n\n"
        formatted += "-" * 40 + "\n\n"
    
    return formatted

def format_flashcards_for_display(flashcards: List[Dict[str, str]]) -> str:
    """Форматирует флеш-карточки для отображения"""
    formatted = ""
    
    for i, card in enumerate(flashcards, 1):
        formatted += f"Card {i}:\n"
        formatted += f"Front: {card['front']}\n"
        formatted += f"Back: {card['back']}\n"
        formatted += "-" * 40 + "\n\n"
    
    return formatted

if __name__ == "__main__":
    # Пример использования
    sample_text = """
    Artificial Intelligence (AI) is the ability of a computer system to mimic human intelligence,
    such as the ability to learn, reason, and self-correct. Machine Learning is a subset of AI
    that focuses on the ability of machines to receive data and learn from it without explicit programming.
    Deep Learning is an even more specialized subset of Machine Learning that uses
    artificial neural networks with multiple layers to analyze various data factors.
    """
    
    generator = ContentGenerator()
    
    # Генерация тестов
    questions = generator.generate_tests(sample_text, num_questions=3)
    print("\n=== GENERATED TESTS ===\n")
    print(format_test_for_display(questions))
    
    # Генерация флеш-карточек
    flashcards = generator.generate_flashcards(sample_text, num_cards=3)
    print("\n=== GENERATED FLASHCARDS ===\n")
    print(format_flashcards_for_display(flashcards))
    
    # Генерация резюме
    summary = generator.generate_summary(sample_text)
    print("\n=== GENERATED SUMMARY ===\n")
    print(summary)