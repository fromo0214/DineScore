//
//  ContentView.swift
//  DineScore
//
//  Created by Fernando Romo on 5/28/25.
//
import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices

struct SignInView: View {
    //ViewModel that talks to AuthService
    @StateObject private var vm = SignInViewModel()
    
    //App flags driving navigation
    @AppStorage("userIsLoggedIn") private var userIsLoggedIn = false
    @AppStorage("hasSeenSlideshow") private var hasSeenSlideshow: Bool = false
    
    // View-only state
    @State private var showRegister = false
    @State private var showForgotPassword = false
    
    //keyboard focus fields destinations
    enum Field:Hashable {
        case email
        case password
    }
    
    //focusedField var to tab to next fields
    @FocusState private var focusedField: Field?
    
    var body: some View {
        Group{
            if !userIsLoggedIn{
                //go to home screen
                signInScreen
            }
            else if !hasSeenSlideshow{
                SlideshowView()
            }
            //if user is logged in
            else{
                HomeView()
            }
        }
        .onAppear{
            // 🧪 TEMP: Reset flags for clean testing
            UserDefaults.standard.removeObject(forKey: "hasSeenSlideshow")
            UserDefaults.standard.removeObject(forKey: "userIsLoggedIn")
            
            //checks if user is logged in and has seen slideshow or not
            _ = Auth.auth().addStateDidChangeListener{ auth, user in
                if let user = user, user.isEmailVerified {
                    print("✅ Firebase Auth Listener: user logged in and verified")
                    print("hasSeenSlideshow = \(hasSeenSlideshow)")
                    if UserDefaults.standard.object(forKey: "hasSeenSlideshow") == nil {
                        UserDefaults.standard.set(false, forKey: "hasSeenSlideshow")
                        print("🆕 First-time login: set hasSeenSlideshow = false")
                    }
                    
                    userIsLoggedIn = true
                } else {
                    print("🔁 Firebase Auth Listener: user not logged in")
                    userIsLoggedIn = false
                }}
            
        }
    }
    
    //sign in form view
    var signInScreen: some View{
        NavigationStack{
            ZStack{
                Color.backgroundColor
                    .ignoresSafeArea()
                VStack() {
                    
                    Image("dineScoreSymbol")
                        .resizable()
                        .frame(width:100, height: 100)
                        .scaledToFit()
                    
                    Text("DineScore")
                        .bold()
                        .font(.largeTitle)
                        .foregroundColor(Color.accentColor)
                        .padding(.bottom, 20)
                    
                    Text("To continue sign in to DineScore!")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color.accentColor)
                    
                    TextField("Email", text: $vm.email)
                        .bold()
                        .submitLabel(.next)
                        .foregroundColor(Color.accentColor)
                        .textFieldStyle(.plain)
                        .autocapitalization(.none)
                        .focused($focusedField, equals: .email)
                        .disableAutocorrection(true)
                        .placeholder(when: vm.email.isEmpty){
                            Text("Email")
                                .foregroundColor(Color.accentColor)
                                .bold()
                        }
                        .onSubmit{
                            focusedField = .password
                        }
                    
                    Rectangle()
                        .frame(width: 350, height: 1)
                        .foregroundColor(Color.accentColor)
                    
                    SecureField("Password", text:$vm.password)
                        .foregroundColor(Color.accentColor)
                        .textFieldStyle(.plain)
                        .submitLabel(.done)
                        .focused($focusedField, equals: .password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .bold()
                        .placeholder(when: vm.password.isEmpty){
                            Text("Password")
                                .foregroundColor(Color.accentColor)
                                .bold()
                        }
                        .onSubmit {
                            //dismisses keyboard
                            focusedField = nil
                        }
                    
                    Rectangle()
                        .frame(width: 350, height: 1)
                        .foregroundColor(Color.accentColor)
                    
                    //Sign in button
                    Button{
                        focusedField = nil
                        Task{
                            await vm.signIn()
                            //If authService succeeded, Firebase listener will flip userIsLoggedIn.
                            //Also verify email before proceeding:
                            if let user = Auth.auth().currentUser, user.isEmailVerified{
                                UserDefaults.standard.set(true, forKey: "userIsLoggedIn")
                            } else if Auth.auth().currentUser != nil {
                                vm.errorMessage = "Please verify your email."
                                try? Auth.auth().signOut()
                            }
                        }
                    }label:{
                        HStack{
                            if vm.isLoading { ProgressView() }
                            Text("Sign In")
                        }
                                .bold()
                                .foregroundColor(Color.backgroundColor)
                                .frame(width: 200, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .foregroundColor(Color.accentColor)
                                )
                        
                    }
                    
                    //displays error message
                    if !vm.errorMessage.isEmpty{
                        Text(vm.errorMessage)
                            .foregroundColor(.red)
                    }
                    
                    Button{
                        //registration form view
                        showRegister = true
                    }label:{
                        Text("Don't have an account? Sign up!")
                            .foregroundColor(Color.accentColor)
                            .underline()
                    }
                    Button{
                        //show forgot pasword view
                        showForgotPassword = true
                    }label:{
                        Text("Forgot Password?")
                            .foregroundColor(Color.accentColor)
                            .underline()
                    }
                    Text("Or")
                        .foregroundColor(Color.accentColor)
                        .bold()
                    
                    Button(action: {
                        handleGoogleSignIn()
                    }) {
                        HStack {
                            Image("google_logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                            
                            Text("Continue with Google")
                                .foregroundColor(.black)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1)
                        )
                    }
                    
                    Button(action: {
                        handleFacebookSignIn()
                    }) {
                        HStack {
                            Image("facebook_logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                            
                            Text("Continue with Facebook")
                                .foregroundColor(.black)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .background(.white)
                    }
                    
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authResults):
                                print("✅ Authorization successful: \(authResults)")
                                // Call your handleAppleSignIn() logic here to authenticate with Firebase
                            case .failure(let error):
                                print("❌ Authorization failed: \(error.localizedDescription)")
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.whiteOutline) // or .white, .whiteOutline
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    
                }.frame(width: 350)
                
            }.navigationDestination(isPresented: $showRegister){
                RegisterView()
            }
            .navigationDestination(isPresented:$showForgotPassword){
                ForgotPasswordView()
            }
        }
    }
    
    
    func handleGoogleSignIn(){
        
    }
    
    func handleFacebookSignIn(){
        
    }
    
    
    
}

//Access to hexadecimal colors
extension Color {
    init(hex: Int, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: opacity
        )
        
    }
}

//Colors for application
extension Color{
    static let backgroundColor: Color = Color(hex: 0xf9f8f7)
    static let textColor: Color = Color(hex: 0x3e4949)
    static let accentColor = Color(hex: 0x4b6e7f) // slate blue-gray
}


//placeholder text for fields when empty
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}

//#Preview {
//    SignInView()
//        .onAppear {
//            UserDefaults.standard.set(false, forKey: "userIsLoggedIn")
//            UserDefaults.standard.set(false, forKey: "hasSeenSlideshow")
//        }
//}
