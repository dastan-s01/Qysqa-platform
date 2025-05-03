import SwiftUI

struct CourseDetailView: View {
    let course: Course
    @EnvironmentObject var courseStore: CourseStore
    @State private var selectedTab = 0
    @State private var showUploadLectureSheet = false
    
    var tabs = ["Course", "Materials", "Grades"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Course Header
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(course.code) \(course.title)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .lineLimit(2)
                        
                        Text(course.instructor)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "arrow.down.circle")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "ellipsis")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
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
                                    .fill(selectedTab == index ? Color.accentColor : Color.clear)
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
            
            // Main Content
            TabView(selection: $selectedTab) {
                // Course Tab (Lectures)
                LecturesListView(course: course)
                    .tag(0)
                
                // Materials Tab
                Text("Course materials will be displayed here")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGray6))
                    .tag(1)
                
                // Grades Tab
                Text("Grades will be displayed here")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGray6))
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(.accentColor)
            }
        }
    }
}

struct LecturesListView: View {
    let course: Course
    @State private var showPreparationSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Lectures List
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(course.lectures) { lecture in
                        NavigationLink(destination: LectureDetailView(lecture: lecture)) {
                            LectureRow(lecture: lecture)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .background(Color.white)
                .cornerRadius(12)
                .padding()
                
                // Additional Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Additional Resources")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    ForEach(["Syllabus", "Course Calendar", "Important Links"], id: \.self) { resource in
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.accentColor)
                            
                            Text(resource)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                }
                .padding()
                
                // Full Preparation Button
                Button(action: {
                    showPreparationSheet = true
                }) {
                    HStack {
                        Image(systemName: "book.fill")
                        Text("Full Preparation")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            
            // Flash Cards button
            HStack(spacing: 0) {
                Button(action: {}) {
                    Text("Preparation")
                        .fontWeight(.medium)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8, corners: [.topLeft, .bottomLeft])
                }
                
                Button(action: {}) {
                    Text("Flash Cards")
                        .fontWeight(.medium)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8, corners: [.topRight, .bottomRight])
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -5)
        }
        .background(Color(.systemGray6))
        .sheet(isPresented: $showPreparationSheet) {
            PreparationSelectionView(course: course)
        }
        
    }
}

struct LectureRow: View {
    let lecture: Lecture
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Lecture \(lecture.number): \(lecture.title)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    ForEach(lecture.materials, id: \.self) { material in
                        Text(material)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(materialColor(for: material))
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                }
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.title3)
                    .foregroundColor(.accentColor)
                    .frame(width: 36, height: 36)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
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

// Helper extension for rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct CourseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CourseDetailView(course: MockData.courses[0])
        }
    }
}
