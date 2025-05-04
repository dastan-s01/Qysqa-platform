import SwiftUI

struct CoursesListView: View {
    @EnvironmentObject var courseStore: CourseStore
    @State private var searchText = ""
    @State private var filterSelection = "Current"
    @State private var showFilterOptions = false
    @State private var showAddCourseSheet = false
    
    var filterOptions = ["Current", "Past", "All", "Favorites"]
    
    var filteredCourses: [Course] {
        if searchText.isEmpty {
            return courseStore.courses
        } else {
            return courseStore.courses.filter {
                $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.code.lowercased().contains(searchText.lowercased()) ||
                $0.instructor.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content
            VStack(spacing: 0) {
                // Search and Filter Bar
                VStack(spacing: 16) {
                    HStack {
                        Text("My Courses")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        HStack(spacing: 16) {
                            Button(action: {
                                showAddCourseSheet = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(Color(hex: "#0583F2"))
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "person.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search for courses", text: $searchText)
                            .font(.subheadline)
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    HStack {
                        Button(action: {
                            showFilterOptions.toggle()
                        }) {
                            HStack {
                                Text(filterSelection)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .confirmationDialog("Select Filter", isPresented: $showFilterOptions, titleVisibility: .visible) {
                            ForEach(filterOptions, id: \.self) { option in
                                Button(option) {
                                    filterSelection = option
                                }
                            }
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Button(action: {}) {
                                Image(systemName: "list.bullet")
                                    .font(.subheadline)
                                    .foregroundColor(Color(hex: "#000000"))
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "square.grid.2x2")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                
                // Courses List with bottom padding for tab bar
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredCourses) { course in
                            NavigationLink(destination: CourseDetailView(course: course)) {
                                CourseCard(course: course)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    .padding(.bottom, 50) // Add padding at bottom for tab bar
                }
            }
            
            // Tab bar overlay
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 0) {
                    TabBarButton(title: "Courses", icon: "book.fill", isActive: true)
                    TabBarButton(title: "Themes", icon: "list.bullet.clipboard")
                    TabBarButton(title: "Chat", icon: "message")
                    TabBarButton(title: "Notifications", icon: "bell") {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                    }
                }
                .frame(height: 49)
                .background(Color.white)
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $showAddCourseSheet) {
            AddCourseView()
        }
    }
}

struct AddCourseView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var courseStore: CourseStore
    
    @State private var courseCode = ""
    @State private var courseTitle = ""
    @State private var instructorName = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Course Information")) {
                    TextField("Course Code (e.g. INF 202)", text: $courseCode)
                    TextField("Course Title", text: $courseTitle)
                    TextField("Instructor Name", text: $instructorName)
                }
                
                Section {
                    Button("Create Course") {
                        guard !courseCode.isEmpty, !courseTitle.isEmpty, !instructorName.isEmpty else { return }
                        
                        courseStore.addCourse(
                            code: courseCode,
                            title: courseTitle,
                            instructor: instructorName
                        )
                        
                        dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(canSubmit ? .accentColor : .gray)
                    .disabled(!canSubmit)
                }
            }
            .navigationTitle("Add New Course")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var canSubmit: Bool {
        !courseCode.isEmpty && !courseTitle.isEmpty && !instructorName.isEmpty
    }
}

struct CourseCard: View {
    let course: Course
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(course.color)
                .frame(width: 60, height: 60)
                .overlay(
                    Text(course.code.components(separatedBy: " ").first ?? "")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(course.code) \(course.title)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(course.instructor)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(course.semester)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
            }
            
            Spacer()
            
            Image(systemName: "ellipsis")
                .foregroundColor(.gray)
                .padding(8)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct TabBarButton<Badge: View>: View {
    let title: String
    let icon: String
    var isActive: Bool = false
    let badge: Badge?
    
    init(title: String, icon: String, isActive: Bool = false, @ViewBuilder badge: @escaping () -> Badge) {
        self.title = title
        self.icon = icon
        self.isActive = isActive
        self.badge = badge()
    }
    
    init(title: String, icon: String, isActive: Bool = false) where Badge == EmptyView {
        self.title = title
        self.icon = icon
        self.isActive = isActive
        self.badge = nil
    }
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isActive ? .accentColor : .gray)
                
                if let badge = badge {
                    VStack {
                        HStack {
                            Spacer()
                            badge
                        }
                        Spacer()
                    }
                    .padding(.top, -5)
                    .padding(.trailing, -5)
                }
            }
            
            Text(title)
                .font(.system(size: 9))
                .foregroundColor(isActive ? .accentColor : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CoursesListView_Previews: PreviewProvider {
    static var previews: some View {
        CoursesListView()
    }
}
