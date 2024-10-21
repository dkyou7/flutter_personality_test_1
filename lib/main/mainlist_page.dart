import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String welcomeTitle = '';
  bool bannerUse = false;
  int itemHeight = 50;

  Future<String> loadAssets() async {
    return await rootBundle.loadString('res/api/list.json');
  }

  @override
  void initState() {
    super.initState();
    remoteConfigInit();
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
              Map<String, dynamic> list = jsonDecode(snapshot.data!);
              return ListView.builder(
                itemBuilder: (context, value) {
                  return InkWell(
                    child: SizedBox(
                      height: itemHeight.toDouble(),
                      child: Card(
                        child:
                            Text(list['questions'][value]['title'].toString()),
                      ),
                    ),
                    onTap: () async {
                      await FirebaseAnalytics.instance.logEvent(
                        name: 'test_click',
                        parameters: {
                          'test_name':
                              list['questions'][value]['title'].toString(),
                        },
                      ).then(
                        (result) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return QuestionPage(
                                    question: list['questions'][value]['file']
                                        .toString());
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                itemCount: list['count'],
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
    );
  }
}
