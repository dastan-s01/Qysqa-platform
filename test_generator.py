import nltk
from nltk.tokenize import PunktSentenceTokenizer
import random
import torch
from transformers import T5Tokenizer, T5ForConditionalGeneration
from options import generate_wrong_options

# Download NLTK punkt if not already downloaded
nltk.download('punkt', quiet=True)

# Create sentence tokenizer
sentence_tokenizer = PunktSentenceTokenizer()

# Question generation model setup
def setup_question_model():
    print("Loading question generation model...")
    tokenizer = T5Tokenizer.from_pretrained("potsawee/t5-large-generation-squad-QuestionAnswer")
    model = T5ForConditionalGeneration.from_pretrained("potsawee/t5-large-generation-squad-QuestionAnswer")
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = model.to(device)
    return tokenizer, model, device

# Generate questions and answers from context
def generate_questions_and_answers(context, max_questions=5, words_per_question=100):
    tokenizer, model, device = setup_question_model()
    
    # Tokenize text into sentences
    sentences = sentence_tokenizer.tokenize(context)
    print(f"Total sentences in context: {len(sentences)}")
    
    # Count words in context
    word_count = len(context.split())
    print(f"Word count in context: {word_count}")
    
    # Determine number of questions based on text length
    num_questions = min(max_questions, max(1, word_count // words_per_question))
    print(f"Number of questions to generate: {num_questions}")
    
    questions = []
    for _ in range(num_questions):
        # Select a random sentence from the text
        random_sentence = random.choice(sentences)
        input_text = f'context: {random_sentence}'
        input_ids = tokenizer.encode(input_text, return_tensors="pt").to(device)
        outputs = model.generate(
            input_ids,
            max_length=200,
            num_return_sequences=1,
            num_beams=2,
            temperature=0.7,
            early_stopping=True
        )
        
        # Process result
        qa = tokenizer.decode(outputs[0], skip_special_tokens=True)
        if "?" in qa:
            question, answer = qa.split("?")
            question = question.strip() + "?"
            answer = answer.strip()
            # Check for duplicates
            if question not in [q for q, _ in questions]:
                questions.append((question, answer))
    
    return questions

# Generate multiple choice test from context
def generate_multiple_choice_test(context, max_questions=5, words_per_question=100):
    # Generate questions and answers
    qa_pairs = generate_questions_and_answers(context, max_questions, words_per_question)
    
    # Create multiple choice questions
    mc_questions = []
    for question, correct_answer in qa_pairs:
        # Generate wrong options
        wrong_options = generate_wrong_options(question, correct_answer, context)
        
        # Combine and shuffle options
        options = [correct_answer] + wrong_options
        random.shuffle(options)
        
        # Find the index of the correct answer
        correct_index = options.index(correct_answer)
        
        mc_questions.append({
            'question': question,
            'options': options,
            'correct_index': correct_index,
            'correct_answer': correct_answer
        })
    
    return mc_questions

# Format test questions for display or saving
def format_test_questions(mc_questions, include_answers=True):
    formatted_test = ""
    
    for i, q in enumerate(mc_questions, 1):
        formatted_test += f"Question {i}: {q['question']}\n"
        
        for j, option in enumerate(q['options']):
            formatted_test += f"   {chr(97+j)}) {option}\n"
        
        if include_answers:
            formatted_test += f"Answer: {q['correct_answer']} (option {chr(97+q['correct_index'])})\n"
        
        formatted_test += "\n"
    
    return formatted_test

# Save test to file
def save_test_to_file(mc_questions, filename="generated_test.txt", include_answers=True):
    formatted_test = format_test_questions(mc_questions, include_answers)
    
    with open(filename, 'w', encoding='utf-8') as f:
        f.write(formatted_test)
    
    print(f"Test saved to {filename}")

# Main function for direct script execution
def main():
    print("📚 Multiple Choice Test Generator")
    print("-" * 40)
    
    # Get context
    print("Enter your text (press Enter twice to finish):")
    context_lines = []
    while True:
        line = input()
        if not line:
            break
        context_lines.append(line)
    
    context = "\n".join(context_lines)
    
    # Get number of questions
    try:
        max_questions = int(input("Number of questions to generate (default 5): ") or 5)
    except ValueError:
        print("Invalid input. Using default value.")
        max_questions = 5
    
    # Generate and display test
    mc_questions = generate_multiple_choice_test(context, max_questions)
    
    print("\nGenerated Multiple Choice Test:")
    print(format_test_questions(mc_questions))
    
    # Ask if user wants to save the test
    save = input("\nSave test to file? (y/n): ").lower()
    if save.startswith('y'):
        filename = input("Enter filename (default: generated_test.txt): ") or "generated_test.txt"
        include_answers = input("Include answers in file? (y/n): ").lower().startswith('y')
        save_test_to_file(mc_questions, filename, include_answers)

if __name__ == "__main__":
    main()