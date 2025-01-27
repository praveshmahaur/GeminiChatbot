import 'dart:developer';
import 'dart:io';
import 'dart:typed_data'; // Correct import for Uint8List
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final gemini = Gemini.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ChatUser Me = ChatUser(id: "1", firstName: "Pravesh");
  ChatUser GeminiUser = ChatUser(id: "2", firstName: "Gemini");
  List<ChatMessage> Allmessages = [];
  List<ChatUser> typing = <ChatUser>[];
  String currentChatId = DateTime.now().millisecondsSinceEpoch.toString();

 void sendMessage(ChatMessage message) async {
  setState(() {
    // User ka message list me add karo
    typing.add(GeminiUser);
    Allmessages = [message, ...Allmessages];
  });

  try {
    String question = message.text;
    List<Uint8List>? images;

    // Image upload ke liye logic
    if (message.medias?.isNotEmpty ?? false) {
      images = [
        File(message.medias!.first.url).readAsBytesSync(),
      ];
    }

    // Gemini ka response generate karna
    gemini.streamGenerateContent(question, images: images).listen((event) async {
      // Response ka text process karo
      String response = event.content?.parts?.fold(
              "", (previous, current) => "$previous${current.text}") ??
          "";

      // Gemini ka response ke liye naya message banao
      ChatMessage messageG = ChatMessage(
        user: GeminiUser,
        createdAt: DateTime.now(),
        text: response,
      );

      setState(() {
        // Gemini ka typing status remove karo
        typing.remove(GeminiUser);

        // Gemini ka response list me add karo
        Allmessages = [messageG, ...Allmessages];
      });

      // Save User Message and Gemini Reply in Firestore
      await _firestore.collection('chats').doc(currentChatId).collection('messages').add({
        'user': message.user.toJson(),
        'text': message.text,
        'createdAt': message.createdAt.toIso8601String(),
      });

      await _firestore.collection('chats').doc(currentChatId).collection('messages').add({
        'user': messageG.user.toJson(),
        'text': messageG.text,
        'createdAt': messageG.createdAt.toIso8601String(),
      });
    });
  } catch (e) {
    log("Error: $e");
  }
}


  void sendImageInput() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      ChatMessage message = ChatMessage(
        user: Me,
        createdAt: DateTime.now(),
        text: "Describe this picture",
        medias: [
          ChatMedia(url: file.path, fileName: "", type: MediaType.image)
        ],
      );
      sendMessage(message);
    }
  }

  Future<void> loadMessages(String chatId) async {
    final messagesSnapshot = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .get();

    setState(() {
      Allmessages = messagesSnapshot.docs
          .map((doc) => ChatMessage.fromJson(doc.data()))
          .toList();
    });
  }

  void createNewChat() async {
  // Generate a unique chat ID
  String newChatId = DateTime.now().millisecondsSinceEpoch.toString();

  // Clear the current chat UI and prepare for a new chat session
  setState(() {
    currentChatId = newChatId; // Update the current chat ID
    Allmessages.clear(); // Clear the messages for a new chat session
  });

  // Create a new chat document in Firestore
  await _firestore.collection('chats').doc(newChatId).set({
    'createdAt': DateTime.now().toIso8601String(),
    'lastMessage': '', // Initialize with an empty last message
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Gemini",
          style: GoogleFonts.lato(
            textStyle: const TextStyle(
                color: Colors.black,
                letterSpacing: .4,
                fontWeight: FontWeight.w400),
          ),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
  child: FutureBuilder<QuerySnapshot>(
    future: _firestore.collection('chats').get(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final chatDocs = snapshot.data!.docs;

      return ListView(
        children: [
          // New Chat Option
          ListTile(
            title: const Text("New Chat"),
            onTap: () {
              createNewChat(); // Create a new chat session
              Navigator.pop(context); // Close the Drawer
            },
          ),
          // Display existing chats
          ...chatDocs.map((doc) {
            return ListTile(
              title: Text("Chat ${doc.id}"),
              onTap: () {
                loadMessages(doc.id); // Load the selected chat messages
                setState(() {
                  currentChatId = doc.id;
                });
                Navigator.pop(context); // Close the Drawer
              },
            );
          }).toList(),
        ],
      );
    },
  ),
),
      body: DashChat(
        currentUser: Me,
        onSend: sendMessage,
        messages: Allmessages,
        typingUsers: typing,
        inputOptions: InputOptions(alwaysShowSend: true, leading: [
          IconButton(
            onPressed: sendImageInput,
            icon: const Icon(Icons.image),
          ),
        ]),
      ),
    );
  }
}

