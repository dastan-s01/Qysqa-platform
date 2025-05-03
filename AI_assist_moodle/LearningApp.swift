import SwiftUI

@main
struct LearningApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(CourseStore())
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
                Lecture(number: 1, title: "Introduction to DBMS", materials: ["Slides", "Video"], summary: "Overview of database concepts, types of database systems, and their applications in different domains."),
                Lecture(number: 2, title: "Entity-Relationship Model", materials: ["Slides", "Practice Problems"], summary: "Understanding entities, relationships, attributes, and how to represent them in ER diagrams."),
                Lecture(number: 3, title: "Relational Model", materials: ["Slides", "Video", "Quiz"], summary: "Transforming ER models to relational schemas, normalization concepts and techniques.")
            ]
        ),
        Course(
            code: "INF 202",
            title: "Database Management Systems 1",
            instructor: "Meruyert Raiymbekova",
            semester: "Spring 2025",
            color: Color.pink.opacity(0.7),
            lectures: [
                Lecture(number: 1, title: "Introduction to DBMS", materials: ["Slides", "Video"], summary: "Overview of database concepts, types of database systems, and their applications."),
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
