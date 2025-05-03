import SwiftUI

struct LectureDetailView: View {
    let lecture: Lecture
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Lecture \(lecture.number): \(lecture.title)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Date: May \(5 + lecture.number), 2025")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(12)
                
                // Materials Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Materials")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    ForEach(lecture.materials, id: \.self) { material in
                        HStack {
                            Image(systemName: materialIcon(for: material))
                                .foregroundColor(materialColor(for: material))
                                .font(.title3)
                            
                            Text(material)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Image(systemName: "arrow.down.circle")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                }
                .padding()
                
                // Lecture Summary
                VStack(alignment: .leading, spacing: 10) {
                    Text("Summary")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(lecture.summary)
                        .font(.body)
                        .lineSpacing(6)
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {}) {
                            Label("Generate Notes", systemImage: "doc.text")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding()
                        .foregroundColor(.accentColor)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                
                // Key Points
                VStack(alignment: .leading, spacing: 12) {
                    Text("Key Points")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    ForEach(1...4, id: \.self) { index in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(index).")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.accentColor)
                            
                            Text("Key point \(index) about \(lecture.title) explaining important concept related to this lecture.")
                                .font(.subheadline)
                                .lineSpacing(4)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                
                // Related Lectures
                VStack(alignment: .leading, spacing: 10) {
                    Text("Related Lectures")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    ForEach([1, 2, 3].filter { $0 != lecture.number }, id: \.self) { lectureNum in
                        HStack {
                            Text("Lecture \(lectureNum)")
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
            .padding(.vertical)
        }
        .background(Color(.systemGray6))
        .navigationTitle("Lecture \(lecture.number)")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func materialIcon(for type: String) -> String {
        switch type {
        case "Slides":
            return "doc.text"
        case "Video":
            return "play.rectangle"
        case "Quiz":
            return "checkmark.circle"
        case "Practice Problems":
            return "list.bullet"
        case "Case Study":
            return "briefcase"
        case "Group Project":
            return "person.3"
        case "Article":
            return "newspaper"
        default:
            return "doc"
        }
    }
    
    func materialColor(for type: String) -> Color {
        switch type {
        case "Slides":
            return Color.blue
        case "Video":
            return Color.red
        case "Quiz":
            return Color.purple
        case "Practice Problems":
            return Color.green
        case "Case Study":
            return Color.orange
        case "Group Project":
            return Color.teal
        case "Article":
            return Color.indigo
        default:
            return Color.gray
        }
    }
}

struct PreparationSelectionView: View {
    let course: Course
    @State private var selectedLectures = Set<UUID>()
    @State private var navigateToPreparation = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Text("Preparation")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Choose lectures for exam preparation")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Divider()
                        .padding(.vertical, 8)
                }
                .padding()
                
                // Instructions
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    
                    Text("Select one or more lectures to generate study materials")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                // Lecture Selection
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
                        ForEach(course.lectures) { lecture in
                            Button(action: {
                                toggleLecture(lecture.id)
                            }) {
                                VStack {
                                    ZStack {
                                        Circle()
                                            .fill(selectedLectures.contains(lecture.id) ? Color.orange : Color(.systemGray5))
                                            .frame(width: 60, height: 60)
                                        
                                        Text("\(lecture.number)")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(selectedLectures.contains(lecture.id) ? .white : .primary)
                                    }
                                    
                                    Text("Lecture \(lecture.number)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                    
                    // Summary Section
                    if !selectedLectures.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Selected Lectures")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            ForEach(selectedLecturesArray) { lecture in
                                HStack {
                                    Text("Lecture \(lecture.number): \(lecture.title)")
                                        .font(.subheadline)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        toggleLecture(lecture.id)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                    }
                }
                
                // Bottom Buttons
                VStack {
                    NavigationLink(destination: PreparationContentView(lectures: selectedLecturesArray), isActive: $navigateToPreparation) {
                        EmptyView()
                    }
                    
                    Button(action: {
                        if !selectedLectures.isEmpty {
                            navigateToPreparation = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "book.fill")
                            Text("Generate Study Materials")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedLectures.isEmpty ? Color.gray : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.orange.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .disabled(selectedLectures.isEmpty)
                    .padding(.horizontal)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .fontWeight(.medium)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .padding(.vertical)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -5)
            }
            .background(Color(.systemGray6))
            .navigationBarHidden(true)
        }
    }
    
    var selectedLecturesArray: [Lecture] {
        course.lectures.filter { selectedLectures.contains($0.id) }
    }
    
    func toggleLecture(_ id: UUID) {
        if selectedLectures.contains(id) {
            selectedLectures.remove(id)
        } else {
            selectedLectures.insert(id)
        }
    }
}

struct PreparationContentView: View {
    let lectures: [Lecture]
    @State private var selectedTab = 0
    
    var tabs = ["Summary", "Quiz", "Flashcards", "Notes"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Text("Preparation")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Study materials for \(lectures.count) lecture\(lectures.count > 1 ? "s" : "")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Custom Tab Bar
                HStack {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Button(action: {
                            selectedTab = index
                        }) {
                            VStack(spacing: 8) {
                                Text(tabs[index])
                                    .font(.subheadline)
                                    .fontWeight(selectedTab == index ? .semibold : .regular)
                                    .foregroundColor(selectedTab == index ? .primary : .secondary)
                                
                                Rectangle()
                                    .fill(selectedTab == index ? Color.orange : Color.clear)
                                    .frame(height: 3)
                                    .cornerRadius(2)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Content
            TabView(selection: $selectedTab) {
                // Summary Tab
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("SUMMARY")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Text("HERE WILL BE TEST AND ETC.")
                            .font(.title3)
                            .fontWeight(.medium)
                            .padding(.horizontal)
                        
                        ForEach(lectures) { lecture in
                            preparationLectureSummary(lecture)
                        }
                        
                        HStack {
                            Spacer()
                            
                            Button(action: {}) {
                                Label("Download PDF", systemImage: "arrow.down.doc")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.accentColor)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                    }
                    .padding(.vertical)
                }
                .tag(0)
                
                // Quiz Tab
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(1...5, id: \.self) { index in
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Question \(index)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Text("This is a sample question related to the selected lectures content?")
                                    .font(.body)
                                    .padding(.bottom, 8)
                                
                                ForEach(["A. First option", "B. Second option", "C. Third option", "D. Fourth option"], id: \.self) { option in
                                    Button(action: {}) {
                                        HStack(alignment: .top) {
                                            Text(option)
                                                .lineLimit(3)
                                                .multilineTextAlignment(.leading)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "circle")
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        Button(action: {}) {
                            Text("Check Answers")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding()
                    }
                    .padding(.vertical)
                }
                .tag(1)
                
                // Flashcards Tab
                VStack {
                    Text("Flashcards coming soon")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGray6))
                .tag(2)
                
                // Notes Tab
                VStack {
                    Text("Notes coming soon")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGray6))
                .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Date Navigation
            HStack {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "chevron.left")
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.orange)
                    .cornerRadius(10)
                }
                
                Spacer()
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.orange)
                    .cornerRadius(10)
                }
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -5)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.accentColor)
                }
            }
        }
    }
    
    func preparationLectureSummary(_ lecture: Lecture) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Lecture \(lecture.number): \(lecture.title)")
                .font(.headline)
                .padding(.horizontal)
            
            Text(lecture.summary)
                .font(.body)
                .lineSpacing(6)
                .padding(.horizontal)
            
            Divider()
                .padding(.vertical, 8)
            
            Text("Key Terms")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(1...5, id: \.self) { index in
                        Text("Key Term \(index)")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.orange.opacity(0.1))
                            .foregroundColor(.orange)
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
            }
            
            Divider()
                .padding(.vertical, 8)
        }
        .padding(.vertical)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct LectureViews_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                LectureDetailView(lecture: MockData.courses[0].lectures[0])
            }
            
            PreparationSelectionView(course: MockData.courses[0])
            
            NavigationStack {
                PreparationContentView(lectures: [MockData.courses[0].lectures[0], MockData.courses[0].lectures[1]])
            }
        }
    }
}

