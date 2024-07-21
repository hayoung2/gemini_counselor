import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:gemini_counselor/section/chat.dart';
import 'package:gemini_counselor/section/embed_batch_contents.dart';
import 'package:gemini_counselor/section/embed_content.dart';
import 'package:gemini_counselor/section/response_widget_stream.dart';
import 'package:gemini_counselor/section/stream.dart';
import 'package:gemini_counselor/section/text_and_image.dart';
import 'package:gemini_counselor/section/text_only.dart';


import 'api.dart';
import 'chat_stream.dart';

void main() {

  Gemini.init(apiKey: Api_().api);

  runApp(const MyApp());


}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Gemini',
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      theme:ThemeData(
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.black), // 앱 전체 폰트 색상을 검은색으로 설정
          bodyText2: TextStyle(color: Colors.black), // 다른 텍스트 스타일도 검은색으로 설정
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,  // 기본 입력 필드 배경색을 하얗게 설정
        ),
      ) ,
      home: const MyHomePage(),
    );
  }
}

class SectionItem {
  final int index;
  final String title;
  final Widget widget;

  SectionItem(this.index, this.title, this.widget);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedItem = 3;

  final _sections = <SectionItem>[
    SectionItem(0, 'Stream text', const SectionTextStreamInput()),
    SectionItem(1, 'textAndImage', const SectionTextAndImageInput()),
    SectionItem(2, 'chat', const SectionChat()),
    SectionItem(3, 'Stream chat', const SectionStreamChat()),
    SectionItem(4, 'text', const SectionTextInput()),
    SectionItem(5, 'embedContent', const SectionEmbedContent()),
    SectionItem(6, 'batchEmbedContents', const SectionBatchEmbedContents()),
    SectionItem(
        7, 'response without setState()', const ResponseWidgetSection()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      body: IndexedStack(
        index: _selectedItem,
        children: _sections.map((e) => e.widget).toList(),
      ),
    );
  }
}