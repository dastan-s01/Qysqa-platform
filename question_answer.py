# QUESTION,ANSWER GENERATION based on context using T5 model
import nltk
from nltk.tokenize import PunktSentenceTokenizer
import random
from transformers import T5Tokenizer, T5ForConditionalGeneration
import torch

# Загрузка модели 'punkt'
nltk.download('punkt')

# Создание токенизатора для предложений
sentence_tokenizer = PunktSentenceTokenizer()


tokenizer = T5Tokenizer.from_pretrained("potsawee/t5-large-generation-squad-QuestionAnswer")
model = T5ForConditionalGeneration.from_pretrained("potsawee/t5-large-generation-squad-QuestionAnswer")
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model = model.to(device)

# Function to generate questions with word-based limits
def generate_questions(context, max_questions=10, words_per_question=100):
    # Разделяем текст на предложения
    sentences = sentence_tokenizer.tokenize(context)
    print(f"Total sentences in context: {len(sentences)}")  # Вывод количества предложений
    
    # Подсчет количества слов в тексте
    word_count = len(context.split())
    print(f"Word count in context: {word_count}")  # Вывод количества слов
    
    # Определяем количество вопросов на основе длины текста
    num_questions = min(max_questions, max(1, word_count // words_per_question))
    print(f"Number of questions to generate: {num_questions}")  # Вывод количества вопросов
    
    questions = []
    for _ in range(num_questions):
        # Выбираем случайное предложение из текста
        random_sentence = random.choice(sentences)
        input_text = f'context: {random_sentence}'
        input_ids = tokenizer.encode(input_text, return_tensors="pt").to(device)
        outputs = model.generate(
            input_ids,
            max_length=200,
            num_return_sequences=1,  # Генерируем один вопрос за раз
            num_beams=2,  # Используем beam search
            temperature=0.7,  # Добавляем случайность в генерацию
            early_stopping=True
        )
        
        # Обрабатываем результат
        qa = tokenizer.decode(outputs[0], skip_special_tokens=True)
        if "?" in qa:
            question, answer = qa.split("?")
            question = question.strip() + "?"
            answer = answer.strip()
            # Проверяем, чтобы вопрос не повторялся
            if question not in [q for q, _ in questions]:
                questions.append((question, answer))
    return questions

# Example usage
context = """
Transforming Marketing: IT empowers businesses to reach and engage their customers through digital marketing strategies, allowing for greater precision in targeting.
Marketing Technologies:
SEO (Search Engine Optimization): Enhances online visibility and attracts organic traffic to websites.
Email Marketing Platforms: Automates personalized communication with customers. Example: MailChimp, Constant Contact.
Social Media Marketing Tools: Platforms like Instagram, Facebook, and LinkedIn enable businesses to engage with customers and share targeted ads.
"""

# Генерация вопросов с учетом длины текста
questions = generate_questions(context, max_questions=10, words_per_question=30)

# Вывод вопросов и ответов
for i, (question, answer) in enumerate(questions, 1):
    print(f'Question {i}: {question}')
    print(f'Answer {i}: {answer}')


