import SwiftUI

@main
struct EducationApp: App {
    @StateObject private var courseStore = CourseStore()
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .accentColor(Color(hex: "#6FF09F"))
                .environmentObject(courseStore)
        }
    }
}

// MARK: - Models
struct Course: Identifiable {
    let id = UUID()
    let code: String
    let title: String
    let instructor: String
    let semester: String
    let color: Color
    var lectures: [Lecture]
}

// MARK: - Store
class CourseStore: ObservableObject {
    @Published var courses: [Course]
    
    init() {
        self.courses = MockData.courses
    }
    
    func addCourse(code: String, title: String, instructor: String) {
        let newCourse = Course(
            code: code,
            title: title,
            instructor: instructor,
            semester: "Spring 2025",
            color: generateRandomColor(),
            lectures: []
        )
        
        courses.append(newCourse)
    }
    
    func addLecture(to course: Course, number: Int, title: String, fileURLs: [URL]) {
        guard let courseIndex = courses.firstIndex(where: { $0.id == course.id }) else { return }
        
        var materials: [String] = []
        
        // Determine materials from file extensions
        for url in fileURLs {
            let fileExtension = url.pathExtension.lowercased()
            switch fileExtension {
            case "pdf", "doc", "docx":
                if !materials.contains("Document") {
                    materials.append("Document")
                }
            case "ppt", "pptx":
                if !materials.contains("Slides") {
                    materials.append("Slides")
                }
            case "mp4", "mov", "avi":
                if !materials.contains("Video") {
                    materials.append("Video")
                }
            case "xls", "xlsx", "csv":
                if !materials.contains("Spreadsheet") {
                    materials.append("Spreadsheet")
                }
            default:
                if !materials.contains("File") {
                    materials.append("File")
                }
            }
        }
        
        let newLecture = Lecture(
            number: number,
            title: title,
            materials: materials,
            summary: "This is a new lecture added to the course."
        )
        
        courses[courseIndex].lectures.append(newLecture)
        
        // Sort lectures by number
        courses[courseIndex].lectures.sort { $0.number < $1.number }
    }
    
    private func generateRandomColor() -> Color {
        let colors: [Color] = [.blue, .green, .orange, .pink, .purple, .teal, .indigo]
        return colors.randomElement()!.opacity(0.7)
    }
}

struct Lecture: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let materials: [String]
    let summary: String
}

// MARK: - Mock Data
class MockData {
    static let courses = [
        Course(
            code: "INF 202",
            title: "Database Management Systems 1",
            instructor: "Arunaz Makhabayeva",
            semester: "Spring 2025",
            color: Color.blue.opacity(0.7),
            lectures: [
                Lecture(number: 1, title: "Introduction to DBMS", materials: ["Slides", "Video"], summary: "This lecture introduces the foundational concepts of Database Management Systems (DBMS). It begins by explaining the evolution of data management—from flat file systems to modern relational databases—and the limitations that led to the development of DBMS. Key features of a DBMS such as data abstraction, data independence, efficient access, data integrity, and concurrent access are explored in depth. The lecture also highlights real-world applications across sectors like banking, healthcare, education, and e-commerce to illustrate the critical role of databases in today’s digital infrastructure. Finally, it distinguishes between various types of database systems, including hierarchical, network, relational, object-oriented, and NoSQL systems, and sets the stage for the relational model which will be studied in subsequent lectures."),
                
                
                Lecture(number: 2, title: "Entity-Relationship Model", materials: ["Slides", "Practice Problems"], summary: "This lecture delves into conceptual database design through the Entity-Relationship (ER) Model. It introduces the core components: entities (real-world objects), attributes (properties of entities), and relationships (associations between entities). Students learn to distinguish between strong and weak entities, simple and composite attributes, and one-to-one, one-to-many, and many-to-many relationships. Special attention is given to identifying primary keys and understanding participation constraints and cardinality. Through extensive examples and interactive practice problems, students learn to draw ER diagrams and translate informal problem descriptions into formal conceptual schemas. The lecture also introduces enhanced ER features like specialization, generalization, and aggregation, which are crucial for modeling complex data semantics in real-world applications."),
                
                Lecture(number: 3, title: "Relational Model", materials: ["Slides", "Video", "Quiz"], summary: "Building upon the ER model, this lecture focuses on translating conceptual designs into formal relational schemas. It covers the structure of relational databases—tables (relations), rows (tuples), and columns (attributes)—and emphasizes the importance of data types and constraints such as primary keys, foreign keys, and unique constraints. The lecture introduces the concept of relational algebra and provides a high-level overview of query operations like selection, projection, join, union, and difference. A substantial portion is dedicated to normalization, including first (1NF), second (2NF), and third normal forms (3NF), with examples that show how normalization reduces redundancy and improves data integrity. Students also learn about functional dependencies and the trade-offs between normalization and performance in real-world systems.")
            ]
        ),
        Course(
            code: "INF 395",
            title: "Advanced project for information systems",
            instructor: "Sufyan Mustafa",
            semester: "Spring 2025",
            color: Color.pink.opacity(0.7),
            lectures: [
                Lecture(number: 1, title: "Intoduction to Advanced project for IS", materials: ["Slides", "Video"], summary: "..."),
                Lecture(number: 2, title: "Entity-Relationship Model", materials: ["Slides", "Practice Problems"], summary: "Entities, relationships, attributes, and ER diagramming techniques.")
            ]
        ),
        Course(
            code: "INF 207",
            title: "Introduction to Business for IT",
            instructor: "Assyl Abilakim",
            semester: "Spring 2025",
            color: Color.teal.opacity(0.7),
            lectures: [
                Lecture(number: 1, title: "Business Fundamentals", materials: ["Slides", "Case Study"], summary: "Basic business concepts, organizational structures, and business processes."),
                Lecture(number: 2, title: "IT in Business", materials: ["Slides", "Video", "Article"], summary: "Role of information technology in modern businesses and digital transformation.")
            ]
        ),
        Course(
            code: "INF 207",
            title: "Introduction to Business for IT",
            instructor: "Surajyo Raziyeva",
            semester: "Spring 2025",
            color: Color.purple.opacity(0.7),
            lectures: [
                Lecture(number: 1, title: "Business Strategy", materials: ["Slides", "Case Study"], summary: "Strategic planning, competitive advantage, and business models."),
                Lecture(number: 2, title: "Marketing Principles", materials: ["Slides", "Group Project"], summary: "Core marketing concepts, customer segmentation, and digital marketing strategies.")
            ]
        )
    ]
}

// MARK: - Content View
struct ContentView: View {
    var body: some View {
        NavigationStack {
            CoursesListView()
        }
    }
}
