// ignore_for_file: avoid_function_literals_in_foreach_calls, unnecessary_this, unused_element

import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:hive/hive.dart';

import '../data/fav_model.dart';

class HomescreenController extends GetxController {
  HomescreenController() {
    getData();
    createDatabase();
  }

  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
  final FirebaseFirestore cloud = FirebaseFirestore.instance;
  RxBool isLoading = false.obs;
  RxBool isFav = false.obs;
  List<Favorite> favoriteQoutes = [];
  List<Favorite> showFavQoutes = [];
  int dayCount = 0;
  int scroll = 0;

  Future<void> updateTime() async {}

  void getData() async {
    isLoading(!isLoading.value);
    update();
    await getDataFromRemoteConfig();
    isLoading(!isLoading.value);
    update();
  }

  void toggleFav() {
    isFav(!isFav.value);
    update();
  }

  Future<void> getDataFromRemoteConfig() async {
    await createDatabase();
    favoriteQoutes.clear();
    List qoutesMap = [];

    await getDatCount();
    await remoteConfig.ensureInitialized();

    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 20),
      minimumFetchInterval: const Duration(seconds: 50),
    ));

    await remoteConfig.fetchAndActivate();

    final response = remoteConfig.getValue('AllQoutes').asString();
    Map<String, dynamic> jsonData = jsonDecode(response);
    int count;

    jsonData.forEach((key, value) {
      String replacedString = (value as String).replaceAll("'", "\"");
      String replacedData2 = replacedString.replaceAll('/"', "'");
      qoutesMap.add(jsonDecode(replacedData2));
    });


    if ((10 + (dayCount * 5)) < qoutesMap.length) {
      count = (10 + (dayCount * 5));
      if (count > qoutesMap.length) {
        count = qoutesMap.length;
      }
    } else {
      count = 10;
    }

    var scrollCount;

    await Hive.openBox<int>('scrollCount').then((box) {
      scrollCount = (box).get('scrollCount') ?? 0;
      scroll = scrollCount;
    });

    if (scrollCount > qoutesMap.length) {
      await Hive.openBox<int>('scrollCount').then((box) async {
        (box).put('scrollCount', 0);
      });
      scrollCount = 0;
      scroll = 0;
    }
    for (var i = scrollCount + 1; i < qoutesMap.length; i++) {

      favoriteQoutes.add(Favorite.fromJson(qoutesMap[i]));

    }

    for (var i = 0; i <= scrollCount; i++) {
      favoriteQoutes.add(Favorite.fromJson(qoutesMap[i]));
    }
  }

  Future<void> getDatCount() async {
    final resp = await cloud.collection('init').doc('firstTime').get();
    if (resp.exists && resp.data() != null) {
      dayCount = resp.data()!['dayCount'] ?? 0;
    }
  }

  Future<void> checkTime() async {
    final resp = await cloud.collection('init').doc('firstTime').get();
    if (resp.exists && resp.data() != null) {
      DateTime today = DateTime.now().correctTime();
      Duration durationToAdd = const Duration(days: 1);
      DateTime newDateTime = today.add(durationToAdd);
      if (resp.data()!['isFirstDay'] == true) {
        await cloud.collection('init').doc('firstTime').set({
          'dateTime': newDateTime.toString(),
          'dayCount': 0,
          'isFirstDay': false,
        });
      } else {
        if (today.isAfter(DateTime.parse(resp.data()!['dateTime']))) {
          await cloud.collection('init').doc('firstTime').set({
            'dateTime': newDateTime.toString(),
            'dayCount': resp.data()!['dayCount'] + 1,
            'isFirstDay': false,
          });
        }
      }
    }
  }

  Future<void> insertFavInCloud(String email) async {
    await createDatabase();
    List temp = [];
    temp.clear();
    final keys = (box as Box).keys;
    keys.forEach(
      (key) async {
        var x = (box as Box).get(key);
        temp.add(x);
      },
    );
    await cloud.collection('favorite').doc(email).set({'favoriteQoutes': temp});
  }

  Future<void> updateFavoriteInHive(String email) async {
    await createDatabase();
    final keys = (box as Box).keys;
    // log("----> 1111");
    if (keys.isNotEmpty) {
      keys.forEach(
        (key) async {
          await (box as Box).delete(key);
          // log("----> 2222");
        },
      );
    }
    // log("----> 3333");

    final response = await cloud.collection('favorite').doc(email).get();
    if ((response.data()!['favoriteQoutes'] as List).isNotEmpty) {
      // log('Fav: ${response.data()}');
      for (int i = 0;
          i < (response.data()!['favoriteQoutes'] as List).length;
          i++) {
        await (box as Box)
            .put(i, (response.data()!['favoriteQoutes'] as List)[i]);
        // log("----> inside");
      }
    }
    // log("----> 4444");
  }

  ///////////////////////////////////////////////////////
  ///HIVE METHODS//////////////////////////////
  var box;

  //may be change later
  List<Favorite> data = [];

  bool isDeleting = false;

  //STORE IDENTIFIER FOR REELS
   Future<void> keepReelsScroll(int index) async {
    await Hive.openBox<int>('scrollCount').then((box) async {
      int? x = (box).get('scrollCount');

      if (x != null) {
        if (index > x) {
          await (box).put('scrollCount', index);
        }
      }
    });
  }

  void getFavQoutes() {
    showFavQoutes.clear();
    final keys = (box as Box).keys;
    keys.forEach(
      (key) {
        final qoute = (box as Box).get(key);

        showFavQoutes.add(Favorite(
          key: qoute['key'] ?? '',
          auther: qoute['auther'],
          image: qoute['image'],
          isFav: qoute['isFav'],
          qoute: qoute['qoute'],
        ));
      },
    );
  }

  Future<void> createDatabase() async {
    box = await Hive.openBox<Map>('reel_animation');
  }

  Future<void> insertData(String key, Map<String, dynamic> data) async {
    log('keys===>: $key');
    data['isFav'] = true;
    data['key'] = key;
    await (box as Box).put(key, data);
    final test = (box as Box).keys;
    log('keys: $test');
    test.forEach((e) {
      final test1 = (box as Box).get(e);
      log('Test: $test1');
    });
  }

  Future<void> deleteFav(int key) async {
    final k = (box as Box).keyAt(key);
    isDeleting = true;
    update();
    await (box as Box).delete(k);
    getFavQoutes();
    isDeleting = false;
    isFav.value = false;
    update();
  }

  Future<void> deleteData(String key) async {
    await (box as Box).delete(key);
  }

  Future<bool> getFav(String key) async {
    log('key 1-> $key');
    final keys = (box as Box).keys;
    log('keys 1-> $keys');
    if ((box as Box).containsKey(key)) {
      var temp = await (box as Box).get(key);
      log('temp 1-> $temp');
      return temp['isFav'] ?? false;
    } else {
      return false;
    }
  }

  void getDataFromHive() async {
    final keys = (box as Box).keys;
    for (var key in keys) {
      final resp = (box as Box).get(key);
      data.add(Favorite.fromJson(resp));
    }
  }

  Future<void> clearDb() async {
    final keys = (box as Box).keys;
    await (box as Box).deleteAll(keys);
    data.clear();
  }
}

extension on DateTime {
  DateTime correctTime() {
    const x = Duration(days: 1);
    return this.add(x);
  }
}
