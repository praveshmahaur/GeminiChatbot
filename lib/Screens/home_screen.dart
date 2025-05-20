import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:geminichatbot/Provider/themeProvider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final gemini = Gemini.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  String _userId = "";
  String? _userName;
  String? _userEmail;

  ChatUser Me = ChatUser(id: "temp_id", firstName: "User");
  ChatUser GeminiUser = ChatUser(id: "gemini", firstName: "Gemini");

  List<ChatMessage> Allmessages = [];
  List<ChatUser> typing = <ChatUser>[];
  String currentChatId = "";

  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _userId = user.uid;

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_userId).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        _userName = userData['name'];
        _userEmail = userData['email'];
      }

      // Initialize chat user with setState
      setState(() {
        Me = ChatUser(id: _userId, firstName: _userName ?? "User");
      });

      // Check if user has any chats
      QuerySnapshot chatsSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('chats')
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();

      // If user has chats, load the most recent one
      if (chatsSnapshot.docs.isNotEmpty) {
        String chatId = chatsSnapshot.docs.first.id;
        setState(() {
          currentChatId = chatId;
        });
        await loadMessages(chatId);
      } else {
        // If no chats exist, create a new one
        await createNewChat();
      }

      // Mark initialization as complete
      setState(() {
        _isInitializing = false;
      });
    }
  }

  void sendMessage(ChatMessage message) async {
    if (currentChatId.isEmpty) {
      await createNewChat();
    }

    setState(() {
      typing.add(GeminiUser);
      Allmessages = [message, ...Allmessages];
    });

    try {
      String question = message.text;
      List<Uint8List>? images;

      if (message.medias?.isNotEmpty ?? false) {
        images = [
          File(message.medias!.first.url).readAsBytesSync(),
        ];
      }

      // Save the user message to Firestore first
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('chats')
          .doc(currentChatId)
          .collection('messages')
          .add({
        'user': message.user.toJson(),
        'text': message.text,
        'createdAt': message.createdAt.toIso8601String(),
        'isMedia': message.medias?.isNotEmpty ?? false,
        'mediaPath': message.medias?.isNotEmpty ?? false
            ? message.medias!.first.url
            : null,
      });

      // Update the model parameter to use gemini-1.5-flash
      String responseText = "";

      gemini
          .streamGenerateContent(
        question,
        images: images,
        modelName: "gemini-1.5-flash", // Correctly specifying the model
      )
          .listen(
        (event) {
          // Process each chunk of the response
          String chunk = event.output ?? "";
          responseText += chunk;

          // Update the UI with each chunk
          ChatMessage messageG = ChatMessage(
            user: GeminiUser,
            createdAt: DateTime.now(),
            text: responseText,
          );

          setState(() {
            // Remove the previous Gemini message if it exists
            Allmessages = Allmessages.where((m) =>
                m.user.id != GeminiUser.id ||
                m.createdAt.millisecondsSinceEpoch !=
                    messageG.createdAt.millisecondsSinceEpoch).toList();
            // Add the updated message
            Allmessages = [messageG, ...Allmessages];
          });
        },
        onError: (error) {
          log("Stream error: $error");
          setState(() {
            typing.remove(GeminiUser);
          });
        },
        onDone: () async {
          // When the stream is complete
          setState(() {
            typing.remove(GeminiUser);
          });

          // Save the final Gemini response to Firestore
          if (responseText.isNotEmpty) {
            await _firestore
                .collection('users')
                .doc(_userId)
                .collection('chats')
                .doc(currentChatId)
                .collection('messages')
                .add({
              'user': GeminiUser.toJson(),
              'text': responseText,
              'createdAt': DateTime.now().toIso8601String(),
              'isMedia': false,
              'mediaPath': null,
            });

            // Update last message in the chat document
            await _firestore
                .collection('users')
                .doc(_userId)
                .collection('chats')
                .doc(currentChatId)
                .update({
              'lastMessage': responseText.length > 50
                  ? '${responseText.substring(0, 50)}...'
                  : responseText,
              'updatedAt': DateTime.now().toIso8601String(),
            });
          }
        },
      );
    } catch (e) {
      log("Error: $e");
      setState(() {
        typing.remove(GeminiUser);
      });
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
        .collection('users')
        .doc(_userId)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .get();

    setState(() {
      Allmessages = messagesSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        // Check for media messages
        if (data['isMedia'] == true && data['mediaPath'] != null) {
          ChatMessage msg = ChatMessage.fromJson(data);
          msg.medias = [
            ChatMedia(
                url: data['mediaPath'], fileName: "", type: MediaType.image)
          ];
          return msg;
        }
        return ChatMessage.fromJson(data);
      }).toList();
    });
  }

  Future<String> createNewChat() async {
    // Generate a unique chat ID
    String newChatId = DateTime.now().millisecondsSinceEpoch.toString();

    // Clear the current chat UI and prepare for a new chat session
    setState(() {
      currentChatId = newChatId; // Update the current chat ID
      Allmessages.clear(); // Clear the messages for a new chat session
    });

    // Create a new chat document in Firestore under the user's collection
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('chats')
        .doc(newChatId)
        .set({
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'lastMessage': '', // Initialize with an empty last message
      'title': 'New Chat', // Add a title field
    });

    return newChatId;
  }

  void renameChatTitle(String chatId, String newTitle) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('chats')
        .doc(chatId)
        .update({
      'title': newTitle,
    });
  }

  void deleteChat(String chatId) async {
    // Delete all messages in the chat
    final messagesSnapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();

    for (var doc in messagesSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete the chat document
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('chats')
        .doc(chatId)
        .delete();

    // If the deleted chat was the current one, create a new chat or load another
    if (chatId == currentChatId) {
      // Get the next available chat
      final chatsSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('chats')
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();

      if (chatsSnapshot.docs.isNotEmpty) {
        String nextChatId = chatsSnapshot.docs.first.id;
        setState(() {
          currentChatId = nextChatId;
        });
        loadMessages(nextChatId);
      } else {
        createNewChat();
      }
    }
  }

  void _showChatOptionsDialog(String chatId, String title) {
    TextEditingController titleController = TextEditingController(text: title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chat Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Chat Title',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              deleteChat(chatId);
              Navigator.pop(context);
            },
            child: const Text('Delete Chat'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                renameChatTitle(chatId, titleController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _signOut() async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Gemini",
          style: GoogleFonts.lato(
            textStyle: const TextStyle(
                color: Colors.grey,
                letterSpacing: .4,
                fontWeight: FontWeight.w400),
          ),
        ),
        centerTitle: true,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.logout),
          //   onPressed: _signOut,
          //   tooltip: 'Logout',
          // ),
        ],
      ),
      drawer: Drawer(
        child: _isInitializing
            ? const Center(child: CircularProgressIndicator())
            : FutureBuilder<QuerySnapshot>(
                future: _firestore
                    .collection('users')
                    .doc(_userId)
                    .collection('chats')
                    .orderBy('updatedAt', descending: true)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final chatDocs = snapshot.data!.docs;

                  return Column(
                    children: [
                      UserAccountsDrawerHeader(
                        accountName: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_userName ?? 'User',
                                    style: TextStyle(fontSize: 18)),
                                Text(_userEmail ?? '',
                                    style: TextStyle(fontSize: 14)),
                                // Text('Additional Text', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Text("Dark Mode", style: TextStyle(fontSize: 12),),
                                Consumer<ThemeProvider>(
                                  builder: (context, themeProvider, child) {
                                    return Switch(
                                      activeColor: Colors.black87,
                                      value: themeProvider.themeMode ==
                                          ThemeMode.dark,
                                      onChanged: (value) {
                                        themeProvider.toggleTheme();
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        accountEmail: null,
                        // accountName: Text(_userName ?? 'User'),
                        // accountEmail: Text(_userEmail ?? ''),
                        currentAccountPicture: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          child: Text(
                            (_userName?.isNotEmpty ?? false)
                                ? _userName![0].toUpperCase()
                                : 'U',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.add_circle_outline),
                        title: const Text("New Chat"),
                        onTap: () {
                          createNewChat();
                          Navigator.pop(context);
                        },
                      ),
                      const Divider(),

                      // ListView ko Expand karna taaki properly render ho
                      Expanded(
                        child: ListView.builder(
                          itemCount: chatDocs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> data =
                                chatDocs[index].data() as Map<String, dynamic>;
                            String title = data['title'] ??
                                'Chat ${chatDocs[index].id.substring(0, 8)}';
                            String lastMessage =
                                data['lastMessage'] ?? 'No messages yet';
                            bool isActive = chatDocs[index].id == currentChatId;

                            return ListTile(
                              leading: const Icon(Icons.chat_bubble_outline),
                              // title: Text(
                              //   title,
                              //   style: isActive
                              //       ? const TextStyle(
                              //           fontWeight: FontWeight.bold)
                              //       : null,
                              // ),
                              title: Text(
                                lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              tileColor: isActive
                                  ? Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1)
                                  : null,
                              onTap: () {
                                loadMessages(chatDocs[index].id);
                                setState(() {
                                  currentChatId = chatDocs[index].id;
                                });
                                Navigator.pop(context);
                              },
                              onLongPress: () {
                                Navigator.pop(context);
                                _showChatOptionsDialog(
                                    chatDocs[index].id, title);
                              },
                            );
                          },
                        ),
                      ),

                      const Divider(), // Drawer aur bottom ke content ke beech separator

                      // Dark Mode Toggle Switch
                      // Padding(
                      //   padding: const EdgeInsets.all(16.0),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Text("Light Mode"),
                      //       Consumer<ThemeProvider>(
                      //         builder: (context, themeProvider, child) {
                      //           return Switch(
                      //             value: themeProvider.themeMode == ThemeMode.dark,
                      //             onChanged: (value) {
                      //               themeProvider.toggleTheme();
                      //             },
                      //           );
                      //         },
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: InkWell(
                          onTap: _signOut,
                          child: Row(
                            children: [
                              Text(
                                "Logout",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w500),
                              ),
                              IconButton(
                                icon: const Icon(Icons.logout),
                                onPressed: null,
                                tooltip: 'Logout',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : DashChat(
              currentUser: Me,
              onSend: sendMessage,
              messages: Allmessages,
              typingUsers: typing,

  //             messageOptions: MessageOptions(
  //   currentUserContainerColor: Colors.white, // your message bubble
  //   // containerColor: Colors.grey[300], // other messages
  //   textColor: Colors.black,
  // ),
              
              inputOptions: InputOptions(alwaysShowSend: true, leading: [
                IconButton(
                  onPressed: sendImageInput,
                  icon: const Icon(Icons.image),
                ),
              ],
              ),
            ),
    );
  }
}
