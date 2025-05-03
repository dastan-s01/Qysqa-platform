import SwiftUI
import UniformTypeIdentifiers
import MobileCoreServices

struct UploadLectureView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var courseStore: CourseStore
    
    let course: Course
    
    @State private var lectureNumber = 1
    @State private var lectureTitle = ""
    @State private var selectedFiles: [URL] = []
    @State private var showDocumentPicker = false
    
    // Available lecture numbers (avoiding duplicates)
    var availableLectureNumbers: [Int] {
        let existingNumbers = Set(course.lectures.map { $0.number })
        return (1...30).filter { !existingNumbers.contains($0) }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Lecture Information")) {
                    Picker("Lecture Number", selection: $lectureNumber) {
                        ForEach(availableLectureNumbers, id: \.self) { number in
                            Text("\(number)").tag(number)
                        }
                    }
                    
                    TextField("Lecture Title", text: $lectureTitle)
                }
                
                Section(header: Text("Lecture Materials")) {
                    Button(action: {
                        showDocumentPicker = true
                    }) {
                        Label("Select Files", systemImage: "doc.badge.plus")
                    }
                    
                    if !selectedFiles.isEmpty {
                        ForEach(selectedFiles, id: \.self) { url in
                            HStack {
                                Image(systemName: fileIcon(for: url))
                                    .foregroundColor(fileColor(for: url))
                                
                                VStack(alignment: .leading) {
                                    Text(url.lastPathComponent)
                                        .lineLimit(1)
                                    
                                    Text(fileType(for: url))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    removeFile(url)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button("Upload Lecture") {
                        courseStore.addLecture(
                            to: course,
                            number: lectureNumber,
                            title: lectureTitle,
                            fileURLs: selectedFiles
                        )
                        
                        dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(canSubmit ? .accentColor : .gray)
                    .disabled(!canSubmit)
                }
            }
            .navigationTitle("Upload Lecture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(selectedFiles: $selectedFiles)
            }
        }
    }
    
    private var canSubmit: Bool {
        !lectureTitle.isEmpty && !selectedFiles.isEmpty
    }
    
    private func removeFile(_ url: URL) {
        selectedFiles.removeAll { $0 == url }
    }
    
    private func fileIcon(for url: URL) -> String {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            return "doc.fill"
        case "doc", "docx":
            return "doc.text.fill"
        case "ppt", "pptx":
            return "chart.bar.doc.horizontal.fill"
        case "xls", "xlsx", "csv":
            return "tablecells.fill"
        case "jpg", "jpeg", "png", "gif":
            return "photo.fill"
        case "mp4", "mov", "avi":
            return "play.rectangle.fill"
        case "mp3", "wav", "m4a":
            return "music.note"
        default:
            return "doc"
        }
    }
    
    private func fileColor(for url: URL) -> Color {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            return .red
        case "doc", "docx":
            return .blue
        case "ppt", "pptx":
            return .orange
        case "xls", "xlsx", "csv":
            return .green
        case "jpg", "jpeg", "png", "gif":
            return .purple
        case "mp4", "mov", "avi":
            return .red
        case "mp3", "wav", "m4a":
            return .pink
        default:
            return .gray
        }
    }
    
    private func fileType(for url: URL) -> String {
        let fileExtension = url.pathExtension.lowercased()
        
        switch fileExtension {
        case "pdf":
            return "PDF Document"
        case "doc", "docx":
            return "Word Document"
        case "ppt", "pptx":
            return "Presentation"
        case "xls", "xlsx":
            return "Spreadsheet"
        case "csv":
            return "CSV File"
        case "jpg", "jpeg", "png", "gif":
            return "Image"
        case "mp4", "mov", "avi":
            return "Video"
        case "mp3", "wav", "m4a":
            return "Audio"
        default:
            return fileExtension.uppercased()
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedFiles: [URL]
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let supportedTypes: [UTType] = [
            .pdf,
            .text,
            .image,
            .movie,
            .audio,
            .spreadsheet,
            .presentation,
            .content,
            .item,
            .data
        ]
        
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes)
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.selectedFiles.append(contentsOf: urls)
        }
    }
}

struct UploadLectureView_Previews: PreviewProvider {
    static var previews: some View {
        UploadLectureView(course: MockData.courses[0])
            .environmentObject(CourseStore())
    }
}
