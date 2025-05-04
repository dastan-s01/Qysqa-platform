import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var selectedRole = "Student"
    @State private var isLoggedIn = false
    @State private var showingAlert = false
    
    let roles = ["Student", "Teacher"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Logo and title
                VStack(spacing: 16) {
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    
                    Text("Qysqa.kz")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        
                    Text("Sign in to continue. Use moodle account")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                // Role selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Role")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Picker("Role", selection: $selectedRole) {
                        ForEach(roles, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal)
                
                // Login form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Username")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter your username", text: $username)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        SecureField("Enter your password", text: $password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                // Login button
                NavigationLink(destination: CoursesListView().environmentObject(CourseStore()), isActive: $isLoggedIn) {
                    Button(action: {
                        // Simulate login - just check if fields aren't empty
                        if !username.isEmpty && !password.isEmpty {
                            isLoggedIn = true
                        } else {
                            showingAlert = true
                        }
                    }) {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .alert(isPresented: $showingAlert) {
                        Alert(
                            title: Text("Invalid Login"),
                            message: Text("Please enter both username and password"),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
                
                Spacer()
                
                // Additional options
                VStack(spacing: 16) {
                    Button(action: {}) {
                        Text("Forgot Password?")
                            .foregroundColor(.accentColor)
                    }
                    
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.secondary)
                        
                        Button(action: {}) {
                            Text("Register")
                                .fontWeight(.bold)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}



struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
