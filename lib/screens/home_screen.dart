import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _inputTextController = TextEditingController();
  late DialogFlowtter _dialogFlowtter;

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DialogFlowtter.fromFile(
            path: 'assets/flutter-client-ermf-be36969715bb.json')
        .then((instance) => _dialogFlowtter = instance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot'),
        leading: Icon(Icons.smart_toy_outlined),
        backgroundColor: Colors.blue[700],
      ),
      body: Column(
        children: [
          Expanded(
              child: _MessageList(
            messages: messages,
          )),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            color: Colors.blue[700],
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  showCursor: true,
                  controller: _inputTextController,
                  style: TextStyle(color: Colors.white),
                )),
                IconButton(
                  onPressed: () {
                    sendMessage(_inputTextController.text);
                    _inputTextController.clear();
                  },
                  icon: Icon(Icons.send),
                  color: Colors.white,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void sendMessage(String text) async {
    if (text.isEmpty) return;
    setState(() {
      Message userMessage = Message(text: DialogText(text: [text]));
      addMessage(userMessage, true);
    });
    QueryInput queryInput = QueryInput(text: TextInput(text: text));

    DetectIntentResponse res =
        await _dialogFlowtter.detectIntent(queryInput: queryInput);

    if (res.message == null) return;

    setState(() {
      addMessage(res.message!);
    });
  }

  void addMessage(Message message, [bool isUserMessage = false]) {
    messages.add({
      'message': message,
      'isUserMessage': isUserMessage,
    });
  }
}

class _MessageList extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  const _MessageList({
    Key? key,
    this.messages = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      separatorBuilder: (_, i) => const SizedBox(
        height: 10,
      ),
      itemCount: messages.length,
      itemBuilder: (context, i) {
        var obj = messages[messages.length - 1 - i];
        return _MessageContainer(
          message: obj['message'],
          isUserMessage: obj['isUserMessage'],
        );
      },
      reverse: true,
    );
  }
}

class _MessageContainer extends StatelessWidget {
  final Message message;
  final bool isUserMessage;
  const _MessageContainer({
    Key? key,
    required this.message,
    this.isUserMessage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: 250),
          child: Container(
            decoration: BoxDecoration(
              color: isUserMessage ? Colors.blue[400] : Colors.grey[350],
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.all(10),
            child: Text(
              message.text?.text?[0] ?? '',
              style:
                  TextStyle(color: isUserMessage ? Colors.white : Colors.black),
            ),
          ),
        )
      ],
    );
  }
}
