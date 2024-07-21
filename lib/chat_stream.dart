import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'section/chat_input_box.dart';

class SectionStreamChat extends StatefulWidget {
  const SectionStreamChat({super.key});

  @override
  State<SectionStreamChat> createState() => _SectionStreamChatState();
}

class _SectionStreamChatState extends State<SectionStreamChat> {
  final controller = TextEditingController();
  final gemini = Gemini.instance;
  bool _loading = false;

  bool get loading => _loading;

  set loading(bool set) => setState(() => _loading = set);
  final List<Content> chats = [];

  final List<String> gifs = [
    'assets/image/1.gif',
    'assets/image/2.gif',
    'assets/image/3.gif',
    'assets/image/4.gif',
  ];
  late String selectedGif;

  @override
  void initState() {
    super.initState();
    selectedGif = gifs[Random().nextInt(gifs.length)];
  }

  void changeGif() {
    setState(() {
      selectedGif = gifs[Random().nextInt(gifs.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;

    return Column(
      children: [
        SizedBox(height: height / 10),
        Container(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: width / 6),
                  child: Container(
                    padding: EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: Color(0xffeeeeee),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(20.0),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: width / 20, right: width / 13),
                      child: Text("안녕 너의 고민을 나한테 말해줘!"),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: GestureDetector(
                    onTap: changeGif,
                    child: Image.asset(
                      selectedGif,
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
            child: chats.isNotEmpty
                ? Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                reverse: true,
                child: ListView.builder(
                  itemBuilder: chatItem,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: chats.length,
                  reverse: false,
                ),
              ),
            )
                : const Center(child: Text(''))),
        if (loading) const CircularProgressIndicator(),
        ChatInputBox(
          controller: controller,
          onSend: () {
            if (controller.text.isNotEmpty) {
              final searchedText = controller.text;
              chats.add(
                  Content(role: 'user', parts: [Parts(text: searchedText)]));
              controller.clear();
              loading = true;

              gemini.streamChat(chats).listen((value) {
                print("-------------------------------");
                print(value.output);
                loading = false;
                setState(() {
                  if (chats.isNotEmpty &&
                      chats.last.role == value.content?.role) {
                    chats.last.parts!.last.text =
                    '${chats.last.parts!.last.text}${value.output}';
                  } else {
                    chats.add(Content(
                        role: 'model', parts: [Parts(text: value.output)]));
                  }
                });
              });
            }
          },
        ),
        SizedBox(height: 10),
        Image.asset('assets/image/bottom_line.png'),
        SizedBox(height: height / 25)
      ],
    );
  }

  Widget chatItem(BuildContext context, int index) {
    final Content content = chats[index];

    return Card(
      margin: EdgeInsets.all(15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomRight: content.role == 'model' ? Radius.circular(16) : Radius.circular(0), // 오른쪽 하단 모서리만 각지게 설정
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: content.role == 'model' ? Radius.circular(0) : Radius.circular(16),
        ),
      ),
      elevation: 0,
      color: content.role == 'model' ? Color(0xffEEEEEE) : Color(0xff000000),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Markdown(
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: content.role == 'model' ? Colors.black : Colors.white,
                ),
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              data: content.parts?.lastOrNull?.text ?? 'Gemini가 답장을 못했어요!',
            ),
          ],
        ),
      ),
    );
  }
}
