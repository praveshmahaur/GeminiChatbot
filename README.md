#Gemini Chatbot
A Flutter application that integrates Google's Gemini AI to create an interactive chatbot with text and image input capabilities. The app features chat history storage on Firestore, authentication, and dark mode support.


✨ Features
Gemini AI Integration: Chat with Google's powerful Gemini AI model
Multimodal Input: Ask questions with both text and images
Authentication: Secure login and signup functionality
Chat History: All conversations are stored in Firestore database
Chat Management: Create new chats and view past conversations
Dark Mode: Toggle between light and dark themes
Responsive UI: Clean interface using Dash_Chat_2 package


🛠️ Technologies Used
Flutter: UI framework for cross-platform development
firebase_auth: For user authentication
cloud_firestore: For storing chat history
flutter_gemini: Integration with Google's Gemini AI model
dash_chat_2: Implementation of chat interface
provider: State management for theme switching

🚀 Getting Started
Prerequisites
Flutter SDK (version 3.0 or above)
Dart SDK (version 2.17 or above)
Android Studio / VS Code
Google Gemini API key
Firebase project setup


Install dependencies:
  flutter_gemini: ^3.0.0
  dash_chat_2: ^0.0.21
  http: ^1.2.1
  image_picker: ^1.1.2
  google_fonts: ^6.2.1
  flutter_dotenv: ^5.1.0
  firebase_core: ^3.10.0
  cloud_firestore: ^5.6.2
  shared_preferences: ^2.5.3
  firebase_auth: ^5.4.2
  provider: ^6.1.4

Create a .env file in the root directory and add your Gemini API key:
Copy GEMINI_API_KEY=your_api_key_here


Configure Firebase:
Create a Firebase project at Firebase Console
Add Android/iOS apps to your Firebase project
Connect flutterApplication to Firebase using Firebase CLI
Enable Authentication and Firestore in Firebase console


📚 Usage
Launch the app and sign in or create a new account
Start a new chat by tapping the "+" button
Type your message or tap the image icon to upload an image
View previous conversations from the drawer menu
Toggle dark mode from the app settings in the drawer


🙏 Acknowledgments
Google Gemini AI for the AI capabilities
Flutter for the amazing cross-platform framework
Dash_Chat_2 for the chat UI components