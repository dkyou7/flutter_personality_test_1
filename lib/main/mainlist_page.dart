import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:personality_test/question/question_page.dart';

final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  FirebaseDatabase database = FirebaseDatabase.instance;
  late DatabaseReference _testRef;
  late List<String> testList = List.empty(growable: true);

  String welcomeTitle = '';
  bool bannerUse = false;
  int itemHeight = 50;

  Future<List<String>> loadAssets() async {
    await _testRef.get().then((value) => value.children.forEach((element) {
          testList.add(element.value.toString());
        }));
    print(testList.length);
    return testList;
  }

  @override
  void initState() {
    super.initState();
    remoteConfigInit();
    _testRef = database.ref('test');
  }

  void remoteConfigInit() async {
    await remoteConfig.fetchAndActivate();
    welcomeTitle = remoteConfig.getString('welcome');
    bannerUse = remoteConfig.getBool('banner');
    itemHeight = remoteConfig.getInt('item_height');
    print('ssss : $welcomeTitle & $bannerUse & $itemHeight');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: bannerUse ? AppBar(title: Text(welcomeTitle)) : null,
      body: FutureBuilder(
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              return ListView.builder(
                itemBuilder: (context, value) {
                  Map<String, dynamic> item = jsonDecode(snapshot.data![value]);
                  print(item.length);
                  return InkWell(
                    child: SizedBox(
                      height: itemHeight.toDouble(),
                      child: Card(
                        color: Colors.amber,
                        child: Text(item['title'].toString()),
                      ),
                    ),
                    onTap: () async {
                      await FirebaseAnalytics.instance.logEvent(
                        name: 'test_click',
                        parameters: {
                          'test_name': item['title'].toString(),
                        },
                      ).then(
                        (result) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return QuestionPage(question: item);
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                itemCount: snapshot.data!.length,
              );
            case ConnectionState.none:
              return const Center(
                child: Text('No data'),
              );
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
        future: loadAssets(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FirebaseDatabase database = FirebaseDatabase.instance;
          DatabaseReference _testRef = database.ref('test');
          _testRef.push().set("""
{
  "title": "5초 MBTI I/E 편",
  "question": "친구와 함께 간 미술관 당신이라면",
  "selects": [
    "말이 많아짐",
    "생각이 많아짐"
  ],
  "answer": [
    "당신의 성향은 E",
    "당신의 성향은 I"
  ]
}
        """);
          _testRef.push().set("""
        {
  "title": "당신이 좋아하는 애완동물은",
  "question": "당신이 무인도에 도착했는데 마침 떠내려온 상자를 열었을때 보이는 이것은",
  "selects": [
    "생존키트",
    "휴대폰",
    "텐트",
    "무인도에서 살아남기"
  ],
  "answer": [
    "당신은 현실주의 동물은 안키운다!!",
    "당신은 늘 함께 있는 걸 좋아하는 강아지가 딱입니다",
    "당신은 같은 공간을 공유하는 고양이",
    "당신은 낭만을 좋아하는 앵무새"
  ]
}
        """);
          _testRef.push().set("""
{
  "title": "당신은 어떤 사랑을 하고 싶나요",
  "question": "목욕을 할때 가장 먼저 비누칠을 하는 곳은",
  "selects": [
    "머리",
    "상체",
    "하체"
  ],
  "answer": [
    "당신은 자만추를 추천해요",
    "당신은 소개팅을 통한 새로운 사람의 소개를 좋아합니다",
    "당신은 길가다가 우연히 지나친 그런 인연을 좋아합니다"
  ]
}
        """);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
