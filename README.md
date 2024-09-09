# AI Chat App

## Overview

AI Chat App is a Flutter-based application that interacts with the Google Gemini API. It supports both dark and light modes, allows you to clear current and new chats, and provides responses in Markdown format. The app also memorizes previous messages to maintain context.

## Features

- **Markdown Responses**: Responses from the AI come in Markdown format.
- **Message History**: The app can remember previous messages.
- **Dark Mode & Light Mode**: Toggle between dark and light themes.
- **Clear Chat**: Option to clear current chat and start a new conversation.

## Getting Started

To get started with the AI Chat App, follow these steps:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/ai-chat-app.git
   cd ai-chat-app
   ```

2. **Add Your Gemini API Key**:
   - Open `lib/const/api_key.dart`.
   - Add your Gemini API key in the `apiKey` variable.

   ```dart
   final String apiKey = 'YOUR_GEMINI_API_KEY_HERE';
   ```

3. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run the App**:
   ```bash
   flutter run
   ```

## Usage

- **Toggle Dark/Light Mode**: Use the icon in the app bar to switch between dark and light themes.
- **Start a New Chat**: Use the "New Chat" button to clear the current chat and begin a new conversation.
- **View Responses**: Responses from the AI will be displayed in Markdown format.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [Google Gemini API](https://cloud.google.com/ai/gemini)
