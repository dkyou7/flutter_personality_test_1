import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personality_test/detail/detail_page.dart';

class QuestionPage extends StatefulWidget {
  final String question;

  const QuestionPage({
    super.key,
    required this.question,
  });

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  String title = '';
  int selectNumber = -1;

  Future<String> loadAssets(String filename) async {
    return await rootBundle.loadString('res/api/$filename.json');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadAssets(widget.question),
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Error : ${snapshot.error}',
                  style: const TextStyle(fontSize: 15.0),
                ),
              ),
            );
          } else {
            Map<String, dynamic> questions = jsonDecode(snapshot.data!);
            title = questions['title'].toString();
            List<Widget> widgets;

            widgets = List<Widget>.generate(
                (questions['selects'] as List<dynamic>).length,
                (int index) => SizedBox(
                      height: 100,
                      child: Column(
                        children: [
                          Text(questions['selects'][index]),
                          Radio(
                            value: index,
                            groupValue: selectNumber,
                            onChanged: (value) {
                              setState(() {
                                selectNumber = index;
                              });
                            },
                          ),
                        ],
                      ),
                    ));
            return Scaffold(
              appBar: AppBar(
                title: Text(title),
              ),
              body: Column(
                children: [
                  Text(
                    questions['question'].toString(),
                    style: TextStyle(fontSize: 20,),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widgets.length,
                      itemBuilder: (context, index) {
                        final item = widgets[index];
                        return item;
                      },
                    ),
                  ),
                  selectNumber == -1
                      ? Container()
                      : ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacement(MaterialPageRoute(builder: (context) {
                        return DetailPage(
                          question: questions['question'],
                          answer: questions['answer'][selectNumber],
                        );
                      }));
                    },
                          child: const Text('결과 보기'),
                        ),
                ],
              ),
            );
          }
        });
  }
}
