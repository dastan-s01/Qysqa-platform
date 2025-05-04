import torch
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM, T5ForConditionalGeneration, T5Tokenizer
import random
import re

def generate_question_and_answer(context, language="en"):
    """Generate question and answer based on context"""
    print("Loading question generation model...")
    tokenizer = AutoTokenizer.from_pretrained("potsawee/t5-large-generation-squad-QuestionAnswer")
    model = AutoModelForSeq2SeqLM.from_pretrained("potsawee/t5-large-generation-squad-QuestionAnswer")
    
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = model.to(device)
    
    # Generating question and answer
    print(f"Generating question from context...")
    inputs = tokenizer(f"context: {context}", return_tensors="pt").to(device)
    outputs = model.generate(
        inputs["input_ids"],
        max_length=100,
        num_beams=5,
        temperature=0.7,
        early_stopping=True
    )
    question_answer = tokenizer.decode(outputs[0], skip_special_tokens=True)
    
    # Split into question and answer
    if "?" in question_answer:
        question, answer = question_answer.split("?", 1)
        question = question.strip() + "?"
        answer = answer.strip()
    else:
        # Handle case when there's no question mark
        parts = question_answer.split()
        question_end = len(parts) // 2
        question = " ".join(parts[:question_end])
        answer = " ".join(parts[question_end:])
    
    # Check for empty or very short answers
    if not answer or len(answer) < 2:
        answer = "Not enough information"
    
    return question, answer

def generate_wrong_options_custom(question, correct_answer, context, num_options=3):
    """Generate incorrect answer options"""
    print("Loading wrong options generation model...")
    model_name = "valhalla/t5-small-qa-qg-hl"
    tokenizer = T5Tokenizer.from_pretrained(model_name)
    model = T5ForConditionalGeneration.from_pretrained(model_name)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = model.to(device)
    
    # Prepare input for generating wrong options
    input_text = f"question: {question}\ncontext: {context}\ncorrect: {correct_answer}\ngenerate wrong options:"
    
    inputs = tokenizer(input_text, 
                      return_tensors="pt", 
                      max_length=512, 
                      truncation=True).to(device)
    
    # Generate wrong options
    outputs = model.generate(
        inputs["input_ids"],
        max_length=64,
        num_return_sequences=num_options+2,  # Generate extra to select the best ones
        num_beams=num_options+3,
        early_stopping=True,
        temperature=0.8,
        diversity_penalty=0.7,
        num_beam_groups=min(num_options+3, 15)  # Limit number of groups
    )
    
    # Decode results
    wrong_options = [tokenizer.decode(output, skip_special_tokens=True) for output in outputs]
    
    # Filter potentially incorrect options
    filtered_options = []
    for option in wrong_options:
        # Check that the option is different from the correct answer
        if option.lower().strip() != correct_answer.lower().strip() and len(option) > 2:
            # Check for strange characters
            if not re.search(r'[^\w\s\.\,\;\:\-\?\!\"\']', option):
                filtered_options.append(option)
    
    # If not enough suitable options, add meaningful fake options
    while len(filtered_options) < num_options:
        fake_options = [
            "Not mentioned in the text",
            "The opposite statement",
            "A different definition of the concept",
            "None of the above options"
        ]
        for fake in fake_options:
            if fake not in filtered_options and fake.lower() != correct_answer.lower():
                filtered_options.append(fake)
                if len(filtered_options) >= num_options:
                    break
    
    return filtered_options[:num_options]

def create_test_question(context):
    """Create a test question with 1 correct and 3 incorrect answers"""
    # Step 1: Generate question and correct answer
    question, answer = generate_question_and_answer(context)
    
    # Step 2: Generate incorrect answers
    print("Generating wrong answer options...")
    wrong_options = generate_wrong_options_custom(question, answer, context, num_options=3)
    
    # Step 3: Shuffle options for the test
    all_options = [answer] + wrong_options
    random.shuffle(all_options)
    
    # Step 4: Determine the index of the correct answer
    correct_index = all_options.index(answer)
    
    # Format result
    test_question = {
        'question': question,
        'options': all_options,
        'correct_index': correct_index,
        'correct_answer': answer,
        'wrong_answers': wrong_options
    }
    
    return test_question

def format_and_print_question(test_question):
    """Format and display test question"""
    print("\n=== GENERATED TEST QUESTION ===")
    print(f"Question: {test_question['question']}")
    print("\nAnswer options:")
    
    for i, option in enumerate(test_question['options']):
        print(f"{chr(97+i)}) {option}")
    
    correct_letter = chr(97 + test_question['correct_index'])
    print(f"\nCorrect answer: {correct_letter}) {test_question['correct_answer']}")
    
    print("\n=== STRUCTURE CONFIRMATION ===")
    print(f"Total answer options: {len(test_question['options'])}")
    print(f"Correct option: 1")
    print(f"Incorrect options: {len(test_question['wrong_answers'])}")

def main():
    # Example context for testing
    context = """
    Artificial Intelligence (AI) is the ability of a computer system to mimic human intelligence,
    such as the ability to learn, reason, and self-correct. Machine Learning is a subset of AI
    that focuses on the ability of machines to receive data and learn from it without explicit programming.
    Deep Learning is an even more specialized subset of Machine Learning that uses
    artificial neural networks with multiple layers to analyze various data factors.
    """
    
    # Generate and display test question
    print("Starting full test question creation process...")
    test_question = create_test_question(context)
    format_and_print_question(test_question)

if __name__ == "__main__":
    main()