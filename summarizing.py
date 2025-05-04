import torch
from transformers import BartForConditionalGeneration, BartTokenizer

class EnhancedSummarizer:
    def __init__(self):  # Ошибка: init -> __init__
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.tokenizer = BartTokenizer.from_pretrained("facebook/bart-large-cnn")
        self.model = BartForConditionalGeneration.from_pretrained("facebook/bart-large-cnn").to(self.device)

    def generate_summary(self, text):  # Ошибка: отступ (метод должен быть внутри класса)
        # Определение параметров на основе длины текста
        text_length = len(text.split())
        gen_params = self._get_generation_params(text_length)
        
        # Удаляем параметр diversity_penalty, который требует num_beam_groups > 1
        # Либо diversity_penalty не нужен, либо нужно добавить num_beam_groups > 1
        diversity_penalty_value = 0.5  # Сохраняем значение
        
        # Подготовка текста и генерация summary
        inputs = self.tokenizer.encode("summarize: " + text, 
                                     return_tensors="pt", 
                                     max_length=1024, 
                                     truncation=True).to(self.device)
        
        # Генерация с обновленными параметрами
        summary_ids = self.model.generate(
            inputs,
            **gen_params,
            num_return_sequences=1,
            no_repeat_ngram_size=3,
            # diversity_penalty удален отсюда
            early_stopping=True
        )
        
        raw_summary = self.tokenizer.decode(summary_ids[0], skip_special_tokens=True)
        
        # Ошибка: метод _format_summary не определен, возможно, имелся в виду _format_full_summary
        sections = self._split_into_sections(text)
        section_summaries = {}
        for section, content in sections.items():
            params = self._get_generation_params(len(content.split()))
            section_summaries[section] = self._generate_section_summary(content, params)
        
        return self._format_full_summary(section_summaries, text)

    def _split_into_sections(self, text):  # Ошибка: отступ
        sections = {}
        current_section = "General"
        current_text = []
        
        for line in text.split('\n'):
            if line.strip().endswith(':'):
                if current_text:
                    sections[current_section] = '\n'.join(current_text)
                current_section = line.strip()[:-1]
                current_text = []
            else:
                current_text.append(line)
        
        if current_text:
            sections[current_section] = '\n'.join(current_text)
        
        return sections

    def _generate_section_summary(self, text, params):  # Ошибка: отступ
        inputs = self.tokenizer.encode(
            "summarize: " + text,
            return_tensors="pt",
            max_length=1024,
            truncation=True
        ).to(self.device)

        # Ensure num_beam_groups is valid only when num_beams > 1
        if 'num_beam_groups' in params:
            if params['num_beam_groups'] <= 1 or params.get('num_beams', 1) <= 1:
                del params['num_beam_groups']

        # Удаляем diversity_penalty, если num_beam_groups отсутствует
        params_copy = params.copy()  # Создаем копию для безопасного изменения
        
        summary_ids = self.model.generate(
            inputs,
            **params_copy,
            no_repeat_ngram_size=3,
            # diversity_penalty также удален здесь
            num_return_sequences=1
        )
        
        return self.tokenizer.decode(summary_ids[0], skip_special_tokens=True)

    def _get_generation_params(self, text_length):  # Ошибка: отступ
        if text_length < 100:
            return {
                'max_length': 100,
                'min_length': 30,
                'num_beams': 4,
                'length_penalty': 1.5
            }
        elif text_length < 300:
            return {
                'max_length': 150,
                'min_length': 50,
                'num_beams': 4,
                'length_penalty': 2.0
            }
        else:
            return {
                'max_length': 250,
                'min_length': 100,
                'num_beams': 5,
                'length_penalty': 2.0
            }

    def _format_full_summary(self, section_summaries, original_text):  # Ошибка: отступ
        formatted_output = "📑 COMPREHENSIVE SUMMARY\n\n"

        # Добавление краткого обзора
        formatted_output += "🔍 Overview:\n"
        main_params = {'max_length': 150, 'min_length': 50, 'num_beams': 4}
        main_points = self._generate_section_summary(
            original_text,
            main_params
        ).split('. ')
        for i, point in enumerate(main_points[:3], 1):
            formatted_output += f"  {i}. {point.strip()}.\n"
        
        # Добавление детального обзора по секциям
        formatted_output += "\n📋 Detailed Analysis:\n"
        for section, summary in section_summaries.items():
            if section != "General":
                formatted_output += f"\n🔹 {section}:\n"
                points = summary.split('. ')
                for point in points:
                    if point.strip():
                        formatted_output += f"  • {point.strip()}.\n"

        # Добавление ключевых технологий и примеров
        if "Key Technologies" in section_summaries:
            formatted_output += "\n⚙️ Key Technologies & Tools:\n"
            tech_points = section_summaries["Key Technologies"].split('. ')
            for point in tech_points:
                if point.strip():
                    formatted_output += f"  ▪️ {point.strip()}.\n"

        # Добавление выводов
        if "Benefits" in section_summaries:
            formatted_output += "\n✨ Key Benefits:\n"
            benefit_points = section_summaries["Benefits"].split('. ')
            for point in benefit_points:
                if point.strip():
                    formatted_output += f"  ✓ {point.strip()}.\n"

        return formatted_output

# Текст для суммаризации
text = """Targeted Campaigns: Marketing efforts can be tailored to specific customer segments based on data.
Real-Time Interaction: Social media and online platforms allow businesses to interact with customers instantly.
Improved Customer Loyalty: Engaging customers through multiple channels improves their brand loyalty.
Real-World Example:
Nike: Nike uses social media and digital advertising to promote new products and maintain customer engagement.
IT drives efficiency in business operations, from supply chains to workflow management.
Core Applications:
Workflow Automation: Tools like Microsoft Power Automate simplify repetitive processes.
Inventory Management: Technologies like RFID and barcoding improve accuracy.
Supply Chain Optimization: Software ensures timely deliveries and cost efficiency.
Remote Collaboration: Platforms like Slack and Zoom facilitate teamwork across geographies.
Supply Chain Efficiency: Information technology plays a critical role in managing the entire supply chain, from the procurement of raw materials to the delivery of finished products. IT systems allow businesses to streamline operations, track inventory, predict demand, and improve the customer experience.
Key Technologies:
ERP (Enterprise Resource Planning): Integrates all aspects of a company, such as procurement, manufacturing, sales, and inventory, into a unified system.
RFID (Radio Frequency Identification): Tracks products throughout the supply chain, from suppliers to end customers.
Demand Forecasting: Uses predictive analytics to forecast future demand, ensuring businesses can optimize their supply chain.
Benefits:
Cost Savings: Reduced waste and efficient resource utilization through improved tracking and demand forecasting.
Improved Transparency: Real-time tracking of inventory and product movement.
Faster Response: Quick adaptation to market fluctuations and supply chain disruptions.
Real-World Example:
Kaspi.kz: Utilizes advanced IT systems like RFID, cloud-based inventory management, and real-time data analytics to manage its supply chain. This allows Kaspi.kz to efficiently track and manage products across its vast e-commerce and retail network, ensuring that products are readily available to customers in a timely manner.
Businesses can be classified based on ownership structures:
Sole Proprietorship: Owned by one individual; simple to set up but involves high personal risk.
Partnership: Shared ownership between two or more individuals.
Corporation: A separate legal entity owned by shareholders; limited liability.
LLC: Combines the benefits of corporations and partnerships.
Examples:
A local grocery store (sole proprietorship).
Apple Inc. (corporation).
Definition: A sole proprietorship is a business owned and operated by a single individual, with no distinction between the owner and the business. It is the simplest form of business structure.
Characteristics:
Ownership: Owned by one person, who controls all business decisions.
Liability: The owner is personally liable for all debts and obligations of the business.
Taxation: Income is taxed directly to the owner, simplifying tax filings.
Flexibility: The owner has complete control over operations and management."""

# Использование
summarizer = EnhancedSummarizer()
summary = summarizer.generate_summary(text)
print(summary)