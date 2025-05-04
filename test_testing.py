from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
import torch

def test_question_generation_model():
    # Load model and tokenizer
    print("Loading model...")
    tokenizer = AutoTokenizer.from_pretrained("potsawee/t5-large-generation-squad-QuestionAnswer")
    model = AutoModelForSeq2SeqLM.from_pretrained("potsawee/t5-large-generation-squad-QuestionAnswer")
    
    # Set device (use GPU if available, otherwise CPU)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = model.to(device)
    
    # Example context
    context = """Chelsea's mini-revival continued with a third victory in a row as they consigned struggling Leicester City to a fifth consecutive defeat."""
    
    print(f"\nContext: {context}\n")
    
    # Prepare model inputs
    inputs = tokenizer(f"context: {context}", return_tensors="pt").to(device)
    
    # Generate question and answer
    print("Generating question and answer...")
    outputs = model.generate(**inputs, max_length=100)
    
    # Decode the output
    question_answer = tokenizer.decode(outputs[0], skip_special_tokens=True)
    
    # Split into question and answer
    if "?" in question_answer:
        question, answer = question_answer.split("?", 1)
        question = question.strip() + "?"
        answer = answer.strip()
    else:
        # Handle case where there might not be a question mark
        parts = question_answer.split()
        question_end = len(parts) // 2
        question = " ".join(parts[:question_end])
        answer = " ".join(parts[question_end:])
    
    print("\nGenerated Output:")
    print(f"Question: {question}")
    print(f"Answer: {answer}")
    
    # Try with more examples
    more_examples = [
        "The Eiffel Tower, located in Paris, France, was completed in 1889 and stands at a height of 330 meters.",
        "Python is a high-level, general-purpose programming language. Its design philosophy emphasizes code readability with the use of significant indentation.",
        "The first iPhone was introduced by Apple Inc. on January 9, 2007, and released on June 29, 2007."
    ]
    
    print("\n--- Additional Examples ---")
    
    for i, example in enumerate(more_examples, 1):
        print(f"\nExample {i}: {example}")
        
        # Generate question and answer
        inputs = tokenizer(f"context: {example}", return_tensors="pt").to(device)
        outputs = model.generate(**inputs, max_length=100)
        question_answer = tokenizer.decode(outputs[0], skip_special_tokens=True)
        
        # Split into question and answer
        if "?" in question_answer:
            question, answer = question_answer.split("?", 1)
            question = question.strip() + "?"
            answer = answer.strip()
        else:
            parts = question_answer.split()
            question_end = len(parts) // 2
            question = " ".join(parts[:question_end])
            answer = " ".join(parts[question_end:])
        
        print(f"Question: {question}")
        print(f"Answer: {answer}")

if __name__ == "__main__":
    print("Testing the question generation model...")
    test_question_generation_model()