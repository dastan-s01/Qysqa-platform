import SwiftUI

struct CourseDetailView: View {
    let course: Course
    @EnvironmentObject var courseStore: CourseStore
    @State private var selectedTab = 0
    @State private var showUploadLectureSheet = false
    
    var tabs = ["Course", "Materials"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Course Header
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(course.code) \(course.title)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .lineLimit(2)
                        
                        Text(course.instructor)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button(action: {}) {
                            Image(systemName: "arrow.down.circle")
                                .font(.title3)
                                .foregroundColor(Color(UIColor.systemGray2))
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "ellipsis")
                                .font(.title3)
                                .foregroundColor(Color(UIColor.systemGray2))
                        }
                    }
                }
                .padding(.bottom, 8)
                
                // Custom Tab Bar
                HStack(spacing: 0) {
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
                                    .fill(selectedTab == index ? Color.blue : Color.clear)
                                    .frame(height: 3)
                                    .cornerRadius(1.5)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
            
            // Main Content
            TabView(selection: $selectedTab) {
                // Course Tab (Lectures)
                LecturesListView(course: course, showUploadLectureSheet: $showUploadLectureSheet)
                    .tag(0)
                
                // Materials Tab
                Text("Course materials will be displayed here")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemGray6))
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 2) {
                   
                }
                .foregroundColor(.blue)
            }
            
            // Add lecture button in toolbar
            ToolbarItem(placement: .navigationBarTrailing) {
                if selectedTab == 0 {
                    Button(action: {
                        showUploadLectureSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.body)
                    }
                }
            }
        }
        .sheet(isPresented: $showUploadLectureSheet) {
            UploadLectureView(course: course)
                .environmentObject(courseStore)
        }
    }
}

struct LecturesListView: View {
    let course: Course
    @Binding var showUploadLectureSheet: Bool
    @State private var showPreparationSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Lectures List
            ScrollView {
                VStack(spacing: 16) {
                    // Lectures section
                    VStack(spacing: 1) {
                        ForEach(course.lectures) { lecture in
                            NavigationLink(destination: LectureDetailView(lecture: lecture)) {
                                LectureRow(lecture: lecture)
                                    .background(Color.white)
                            }
                            .buttonStyle(PlainButtonStyle())
                            Divider()
                                .padding(.horizontal, 16)
                                .opacity(0.6)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
                    
                    // Add Lecture Button
                    Button(action: {
                        showUploadLectureSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            
                            Text("Add Lecture")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                            
                            Spacer()
                        }
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
                    }
                    
                    // Additional Resources Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Additional Resources")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 4)
                            .padding(.bottom, 4)
                        
                        VStack(spacing: 1) {
                            ForEach(["Syllabus", "Course Calendar", "Important Links"], id: \.self) { resource in
                                HStack {
                                    Image(systemName: "doc.text")
                                        .foregroundColor(.blue)
                                        .frame(width: 24)
                                    
                                    Text(resource)
                                        .font(.subheadline)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color(UIColor.systemGray3))
                                        .font(.caption)
                                }
                                .padding(.vertical, 14)
                                .padding(.horizontal, 16)
                                .background(Color.white)
                                
                                if resource != "Important Links" {
                                    Divider()
                                        .padding(.horizontal, 16)
                                        .opacity(0.6)
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
                    }
                    
                    // Full Preparation Button
                    Button(action: {
                        showPreparationSheet = true
                    }) {
                        HStack {
                            Image(systemName: "book.fill")
                                .foregroundColor(.white)
                            Text("Full Preparation")
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(color: Color.blue.opacity(0.25), radius: 4, x: 0, y: 2)
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 16)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .background(Color(UIColor.systemGray6))
            
            // Bottom Buttons
            HStack(spacing: 0) {
                Button(action: {}) {
                    Text("Preparation")
                        .fontWeight(.medium)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10, corners: [.topLeft, .bottomLeft])
                }
                
                Button(action: {}) {
                    Text("Flash Cards")
                        .fontWeight(.medium)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(10, corners: [.topRight, .bottomRight])
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: -3)
        }
        .background(Color(UIColor.systemGray6))
        .sheet(isPresented: $showPreparationSheet) {
            PreparationSelectionView(course: course)
        }
    }
}

struct LectureRow: View {
    let lecture: Lecture
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Lecture \(lecture.number): \(lecture.title)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 6) {
                    ForEach(lecture.materials, id: \.self) { material in
                        Text(material)
                            .font(.caption)
                            .fontWeight(.medium)
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
                    .font(.body)
                    .foregroundColor(.blue)
                    .frame(width: 36, height: 36)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
    }
    
    func materialColor(for type: String) -> Color {
        switch type {
        case "Slides":
            return Color(hex: "3478F6") // iOS blue
        case "Video":
            return Color(hex: "FF3B30") // iOS red
        case "Quiz":
            return Color(hex: "AF52DE") // iOS purple
        case "Practice Problems":
            return Color(hex: "34C759") // iOS green
        case "Case Study":
            return Color(hex: "FF9500") // iOS orange
        case "Group Project":
            return Color(hex: "5AC8FA") // iOS light blue
        case "Article":
            return Color(hex: "5856D6") // iOS indigo
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

// Extension for hex color support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct CourseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CourseDetailView(course: MockData.courses[0])
                .environmentObject(CourseStore())
        }
    }
}
