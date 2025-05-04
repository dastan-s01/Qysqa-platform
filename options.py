import torch
from transformers import T5ForConditionalGeneration, T5Tokenizer

def load_model():
    print("Loading model...")
    model_name = "valhalla/t5-small-qa-qg-hl"
    tokenizer = T5Tokenizer.from_pretrained(model_name)
    model = T5ForConditionalGeneration.from_pretrained(model_name)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = model.to(device)
    return tokenizer, model, device

def generate_wrong_options(question, correct_answer, context, num_options=3):
    """Generate incorrect options for a multiple choice question"""
    tokenizer, model, device = load_model()
    
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
        num_return_sequences=num_options,
        num_beams=num_options+1,
        early_stopping=True,
        temperature=0.8,
        diversity_penalty=0.5,
        num_beam_groups=num_options+1
    )
    
    # Decode results and format
    wrong_options = [tokenizer.decode(output, skip_special_tokens=True) for output in outputs]
    
    # Filter out any options that might be too similar to the correct answer
    filtered_options = []
    for option in wrong_options:
        if option.lower().strip() != correct_answer.lower().strip():
            filtered_options.append(option)
    
    # Make sure we have enough options
    while len(filtered_options) < num_options:
        filtered_options.append(f"None of the above options")
    
    return filtered_options[:num_options]

if __name__ == "__main__":
    # Example usage
    question = "What is SEO?"
    correct_answer = "Search Engine Optimization"
    context = """
    Transforming Marketing: IT empowers businesses to reach and engage their customers through digital marketing strategies, allowing for greater precision in targeting.
    Marketing Technologies:
    SEO (Search Engine Optimization): Enhances online visibility and attracts organic traffic to websites.
    Email Marketing Platforms: Automates personalized communication with customers. Example: MailChimp, Constant Contact.
    Social Media Marketing Tools: Platforms like Instagram, Facebook, and LinkedIn enable businesses to engage with customers and share targeted ads.
    """
    
    wrong_options = generate_wrong_options(question, correct_answer, context)
    
    print(f"Question: {question}")
    print(f"Correct Answer: {correct_answer}")
    print("Wrong Options:")
    for i, option in enumerate(wrong_options, 1):
        print(f"{i}. {option}")