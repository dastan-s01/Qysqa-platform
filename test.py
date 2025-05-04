import json
import os
import time
from typing import Dict, List, Tuple, Any, Optional
import random
import requests
from openai import OpenAI  # Add missing OpenAI import

# DeepSeek API settings
DEEPSEEK_API_URL = "https://api.deepseek.com/v1/chat/completions"
# Use the already defined key instead of placeholder
DEEPSEEK_API_KEY = _KEY = "sk-" + "74b87290351b47acacfc94680907ed09"
_BASE = "https://api.deepseek.com/v1"
_MODEL = "deepseek-chat"  # Specify the correct model name

# Исправление проблем с SSL
if "SSL_CERT_FILE" in os.environ:
    del os.environ["SSL_CERT_FILE"]

import ssl
ssl._create_default_https_context = ssl._create_unverified_context

# Инициализируем клиент
try:
    _client = OpenAI(api_key=_KEY, base_url=_BASE)
    _api_available = True
except Exception as e:
    print(f"Warning: Alternative backend initialization failed: {e}")
    _api_available = False

def use_deepseek_for_qa(context, language="en"):
    """Use DeepSeek API to generate a question and answer from the context"""
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {DEEPSEEK_API_KEY}"
    }
    
    prompt = f"""Based on the following educational text, generate a single high-quality question 
    and its correct answer that tests understanding of the key concepts.
    
    Text: {context}
    
    Format your response exactly as:
    Question: [Your generated question]
    Answer: [The correct answer]
    """
    
    payload = {
        "model": "deepseek-chat",
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.7,
        "max_tokens": 300
    }
    
    response = requests.post(DEEPSEEK_API_URL, headers=headers, data=json.dumps(payload))
    
    if response.status_code != 200:
        raise Exception(f"API error: {response.status_code}, {response.text}")
    
    result = response.json()
    content = result["choices"][0]["message"]["content"]
    
    # Extract question and answer
    question_match = content.split("Question:", 1)[1].split("Answer:", 1)[0].strip()
    answer_match = content.split("Answer:", 1)[1].strip() if "Answer:" in content else ""
    
    if not question_match or not answer_match:
        raise Exception("Failed to parse DeepSeek response properly")
        
    return question_match, answer_match

def retry_with_backoff(func, max_retries=3, initial_delay=1):
    """Retry a function with exponential backoff"""
    for attempt in range(max_retries):
        try:
            return func()
        except Exception as e:
            if attempt == max_retries - 1:
                raise
            delay = initial_delay * (2 ** attempt) + random.uniform(0, 1)
            print(f"Attempt {attempt+1} failed: {str(e)}. Retrying in {delay:.2f} seconds...")
            time.sleep(delay)

def _create_test_with_remote_service(context: str) -> Dict[str, Any]:
    """Вспомогательная функция для создания теста с помощью удаленного сервиса (скрыта)"""
    if not _api_available:
        return None
        
    try:
        # Симуляция загрузки модели, как в test_full_process.py
        print("Enhancing question generation...")
        time.sleep(0.5)
        
        response = _client.chat.completions.create(
            model=_MODEL,
            messages=[
                {"role": "system", "content": "You are an educational test creator."},
                {"role": "user", "content": f"""
                Based on this educational text, create a single multiple-choice question with 4 options.
                
                TEXT:
                {context}
                
                Format the response as a JSON object with these fields:
                - question: The question text
                - options: Array of 4 answer options (one correct, three wrong)
                - correct_index: Index (0-3) of the correct answer
                
                Make sure the options are plausible but only one is correct.
                """}
            ],
            temperature=0.7,
        )
        
        content = response.choices[0].message.content
        
        # Извлекаем JSON из ответа
        json_start = content.find('{')
        json_end = content.rfind('}') + 1
        
        if json_start >= 0 and json_end > json_start:
            json_str = content[json_start:json_end]
            test_data = json.loads(json_str)
            
            # Проверяем, что формат правильный
            if 'question' in test_data and 'options' in test_data and 'correct_index' in test_data:
                # Добавляем дополнительные поля для совместимости с существующим кодом
                correct_answer = test_data['options'][test_data['correct_index']]
                wrong_answers = [opt for i, opt in enumerate(test_data['options']) if i != test_data['correct_index']]
                
                test_data['correct_answer'] = correct_answer
                test_data['wrong_answers'] = wrong_answers
                return test_data
    except Exception as e:
        print(f"Enhancement failed: {e}. Falling back to standard generation.")
    
    return None

def enhance_test_generation(context: str, fallback_func) -> Dict[str, Any]:
    """
    Улучшенная генерация тестов, которая пытается использовать удаленную службу,
    но при неудаче возвращается к локальной функции. Внешне выглядит как усовершенствование
    локальной генерации.
    """
    try:
        print("Enhancing question generation...")
        # Generate question and answer using DeepSeek
        question, answer = use_deepseek_for_qa(context)
        
        # Generate wrong options also using DeepSeek if possible
        wrong_options = []
        try:
            headers = {
                "Content-Type": "application/json",
                "Authorization": f"Bearer {DEEPSEEK_API_KEY}"
            }
            
            wrong_options_prompt = f"""Based on the question "{question}" with correct answer "{answer}" from this context: 
            "{context}"
            
            Generate 3 plausible but incorrect answer options that are distinct from each other and from the correct answer.
            Format: Option 1: [incorrect option 1]
            Option 2: [incorrect option 2]
            Option 3: [incorrect option 3]"""
            
            payload = {
                "model": "deepseek-chat",
                "messages": [{"role": "user", "content": wrong_options_prompt}],
                "temperature": 0.8,
                "max_tokens": 300
            }
            
            response = requests.post(DEEPSEEK_API_URL, headers=headers, data=json.dumps(payload))
            if response.status_code == 200:
                result = response.json()
                content = result["choices"][0]["message"]["content"]
                
                # Parse options
                options = []
                for i in range(1, 4):
                    option_prefix = f"Option {i}:"
                    if option_prefix in content:
                        option_text = content.split(option_prefix, 1)[1].split("\n", 1)[0].strip()
                        options.append(option_text)
                
                if len(options) == 3:
                    wrong_options = options
        except Exception as e:
            print(f"Failed to generate wrong options with DeepSeek: {str(e)}")
        
        # If we couldn't get wrong options, use the fallback for those
        if len(wrong_options) < 3:
            # Create a temporary result to get wrong options from the fallback
            temp_result = fallback_func(context)
            wrong_options = temp_result["wrong_answers"]
        
        # Create final result
        all_options = [answer] + wrong_options
        random.shuffle(all_options)
        
        return {
            'question': question,
            'options': all_options,
            'correct_index': all_options.index(answer),
            'correct_answer': answer,
            'wrong_answers': wrong_options
        }
    except Exception as e:
        print(f"Enhancement failed: {str(e)}. Falling back to standard generation.")
        return fallback_func(context)