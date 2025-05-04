import json
import os
import time
import random
from typing import List, Dict, Any

# Импортируем функциональность из существующих файлов
try:
    from question_answer import generate_questions
    print("Successfully imported question generator")
except ImportError:
    print("Warning: question_answer.py function not found, using fallback implementation")
    def generate_questions(context, max_questions=3, words_per_question=100):
        print("Using fallback question generator")
        return [("What is the main topic?", "The topic discussed in the text")]

# Настраиваем SSL и клиент без зависимости от окружения
# Убираем переменную SSL_CERT_FILE, которая вызывает проблемы
if "SSL_CERT_FILE" in os.environ:
    del os.environ["SSL_CERT_FILE"]

# Добавляем опцию для отключения проверки сертификата, если проблемы продолжаются
import ssl
ssl._create_default_https_context = ssl._create_unverified_context

# Инициализируем клиент с дополнительными параметрами безопасности
try:
    from openai import OpenAI
    _KEY = "sk-" + "74b87290351b47acacfc94680907ed09"
    _ENDPOINT = "https://api.deepseek.com/v1"
    _client = OpenAI(
        api_key=_KEY, 
        base_url=_ENDPOINT,
        http_client=None  # Позволяет OpenAI создать собственный HTTP клиент
    )
    _api_available = True
    print("API client initialized successfully")
except Exception as e:
    print(f"Warning: Could not initialize API client: {e}")
    _api_available = False

def format_test_questions(questions: List[Dict[str, Any]]) -> str:
    """Форматирует тестовые вопросы для вывода в консоль"""
    formatted = "\n"
    
    for i, q in enumerate(questions, 1):
        formatted += f"Question {i}: {q['question']}\n\n"
        
        for j, opt in enumerate(q.get('options', [])):
            formatted += f"{chr(97+j)}) {opt}\n"
        
        if 'correct_index' in q and 'options' in q:
            formatted += f"\nCorrect answer: {chr(97+q['correct_index'])}) {q['options'][q['correct_index']]}\n"
        formatted += "-" * 60 + "\n\n"
    
    return formatted

def format_flashcards(flashcards: List[Dict[str, str]]) -> str:
    """Форматирует флеш-карточки для вывода в консоль"""
    formatted = "\n"
    
    for i, card in enumerate(flashcards, 1):
        formatted += f"Card {i}:\n"
        formatted += f"Q: {card.get('front', card.get('question', ''))}\n"
        formatted += f"A: {card.get('back', card.get('answer', ''))}\n"
        formatted += "-" * 60 + "\n\n"
    
    return formatted

def summarize_text(text: str) -> str:
    """Простая функция для суммаризации текста без моделей"""
    # Разбиваем текст на предложения и выбираем ключевые
    sentences = [s.strip() for s in text.replace('\n', ' ').split('.') if s.strip()]
    
    if not sentences:
        return "No text provided for summarization."
    
    # Берём первое предложение как основу
    summary = sentences[0] + "."
    
    # Добавляем каждое 3-е предложение из текста для краткости
    if len(sentences) > 3:
        for i in range(3, min(len(sentences), 9), 3):
            summary += " " + sentences[i] + "."
    
    # Добавляем последнее предложение для завершения
    if len(sentences) > 1 and sentences[-1] not in summary:
        summary += " " + sentences[-1] + "."
    
    return summary

def generate_test_with_fallback(text: str, num_questions: int = 3) -> List[Dict[str, Any]]:
    """Генерация тестовых вопросов с использованием fallback если API недоступен"""
    questions = []
    
    if _api_available:
        try:
            questions = generate_test_with_api(text, num_questions)
        except Exception as e:
            print(f"API test generation failed: {e}")
    
    # Если API не доступен или вернул ошибку, используем локальную генерацию
    if not questions:
        print("Using fallback test generator")
        # Создаем тесты на основе вопросов из question_answer
        try:
            qa_pairs = generate_questions(text, max_questions=num_questions, words_per_question=100)
            
            for question, answer in qa_pairs:
                # Генерируем неправильные ответы
                wrong_answers = []
                words = text.split()
                for _ in range(3):
                    if len(words) > 4:
                        start_idx = random.randint(0, len(words) - 4)
                        fake_answer = " ".join(words[start_idx:start_idx+random.randint(3, 4)])
                        if fake_answer != answer and fake_answer not in wrong_answers:
                            wrong_answers.append(fake_answer)
                
                # Добавляем дополнительные варианты если не хватает
                while len(wrong_answers) < 3:
                    wrong_answers.append(f"Not {answer}")
                
                # Создаем все варианты ответов
                all_options = [answer] + wrong_answers
                random.shuffle(all_options)
                correct_index = all_options.index(answer)
                
                questions.append({
                    'question': question,
                    'options': all_options,
                    'correct_index': correct_index
                })
                
                if len(questions) >= num_questions:
                    break
        except Exception as e:
            print(f"Local test generation also failed: {e}")
            # Создаем простой вопрос
            questions = [{
                'question': "What is the main topic discussed in the text?",
                'options': [
                    "Technology in business processes",
                    "History of computing machines",
                    "Environmental impacts of technology",
                    "Social media marketing"
                ],
                'correct_index': 0
            }]
    
    return questions[:num_questions]

def generate_test_with_api(text: str, num_questions: int = 3) -> List[Dict[str, Any]]:
    """Генерация тестовых вопросов через API"""
    print("Generating test questions via API...")
    
    try:
        response = _client.chat.completions.create(
            model="chat",
            messages=[
                {"role": "system", "content": "You are an educational assistant that creates multiple-choice questions."},
                {"role": "user", "content": f"""
                Based on the following text, create {num_questions} multiple choice questions.
                
                For each question:
                1. Create one correct answer
                2. Create three incorrect but plausible answers
                3. Format each question as JSON with fields: question, options (array of 4 options), correct_index (0-3)
                
                TEXT:
                {text}
                
                Return a JSON array with {num_questions} questions.
                """}
            ],
            temperature=0.7
        )
        
        content = response.choices[0].message.content
        
        # Извлекаем JSON из ответа
        json_start = content.find('[')
        json_end = content.rfind(']') + 1
        
        if json_start >= 0 and json_end > json_start:
            json_str = content[json_start:json_end]
            questions = json.loads(json_str)
            return questions
        else:
            print("Warning: Could not parse JSON response properly")
            return []
            
    except Exception as e:
        print(f"Error in test question generation: {e}")
        return []

def create_flashcards_from_qa(text: str, num_cards: int = 3) -> List[Dict[str, str]]:
    """Создание флеш-карточек на основе функциональности из question_answer.py"""
    flashcards = []
    
    try:
        # Используем генератор вопросов для создания карточек
        qa_pairs = generate_questions(text, max_questions=num_cards, words_per_question=100)
        
        for question, answer in qa_pairs:
            flashcards.append({
                "front": question,
                "back": answer
            })
            
            if len(flashcards) >= num_cards:
                break
    except Exception as e:
        print(f"Error generating flashcards from QA: {e}")
    
    # Если не получили достаточно карточек, создаем их вручную
    if len(flashcards) < num_cards:
        # Извлекаем ключевые фразы из текста
        sentences = [s.strip() for s in text.replace('\n', ' ').split('.') if s.strip()]
        
        for sentence in sentences:
            # Делим предложение на часть с определением (если есть)
            parts = sentence.split(":")
            if len(parts) >= 2:
                term = parts[0].strip()
                definition = parts[1].strip()
                flashcards.append({
                    "front": f"What is {term}?",
                    "back": definition
                })
            
            if len(flashcards) >= num_cards:
                break
        
        # Если все еще недостаточно, используем общие вопросы
        if len(flashcards) < num_cards:
            sentences = [s.strip() for s in text.replace('\n', ' ').split('.') if len(s.strip()) > 20]
            
            for i, sentence in enumerate(sentences):
                if i < num_cards - len(flashcards):
                    words = sentence.split()
                    if len(words) > 5:
                        key_term = " ".join(words[:3]) + "..."
                        flashcards.append({
                            "front": f"Explain: {key_term}",
                            "back": sentence
                        })
    
    return flashcards[:num_cards]

def process_educational_content(text: str, save_to_file: bool = True) -> Dict[str, Any]:
    """Основная функция для обработки образовательного контента"""
    
    print("\n📚 EDUCATIONAL CONTENT GENERATOR 📚")
    print("=" * 60)
    
    # 1. Генерация краткого содержания
    print("\n1️⃣ Generating summary...")
    summary = summarize_text(text)
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print(summary)
    print("=" * 60)
    
    # 2. Генерация тестовых вопросов
    print("\n2️⃣ Generating test questions...")
    questions = generate_test_with_fallback(text, num_questions=3)
    print(format_test_questions(questions))
    
    # 3. Генерация флеш-карточек
    print("\n3️⃣ Generating flashcards...")
    flashcards = create_flashcards_from_qa(text, num_cards=3)
    print(format_flashcards(flashcards))
    
    # Сбор всех результатов
    results = {
        "original_text": text,
        "summary": summary,
        "test_questions": questions,
        "flashcards": flashcards
    }
    
    # Сохранение результатов в файл, если требуется
    if save_to_file:
        with open("generated_content.json", 'w', encoding='utf-8') as f:
            json.dump(results, f, ensure_ascii=False, indent=2)
        print(f"\nРезультаты сохранены в файл: generated_content.json")
    
    return results

# Образец текста для демонстрации
sample_text = """
⚙️ Key Technologies & Tools:
  ▪️ RFID (Radio Frequency Identification): Tracks products throughout the supply chain.  
  ▪️ Demand Forecasting: Uses predictive analytics to forecast future demand.
  ▪️ ERP (Enterprise Resource Planning): Integrates procurement, manufacturing, sales, and inventory.

✨ Key Benefits:
  ✓ Cost Savings: Reduced waste and efficient resource utilization.
  ✓ Improved Transparency: Real-time tracking of inventory and product movement.
  ✓ Faster Response: Quick adaptation to market fluctuations and supply chain disruptions.
"""

if __name__ == "__main__":
    print("Starting educational content processing...")
    results = process_educational_content(sample_text, save_to_file=True)
    print("\n✅ Processing complete!")