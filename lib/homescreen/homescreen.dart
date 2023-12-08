// ignore_for_file: unrelated_type_equality_checks

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:reel_animation2/homescreen/favoritescreen.dart';
import 'package:reel_animation2/homescreen/share_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../data/fav_model.dart';
import 'controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  PageController pageController =
      PageController(initialPage: 0, keepPage: true);
  int currentBackgroundColor = 0;

  final controller = Get.put(HomescreenController());

  bool tempFav = false;

  @override
  void initState() {
    updatetime();
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void updatetime() async {
    await controller.checkTime();
    await controller.insertFavInCloud('sikandarkhan1@gmail.com');
    await controller.updateFavoriteInHive('sikandarkhan1@gmail.com');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => controller.isLoading.value == true
            ///When data is loading from remote config so this indicator will be shown.
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: [
                  Hero(
                    tag: 'animatedHero',
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(milliseconds: 250),
                          useOldImageOnUrlChange: true,
                          imageUrl: controller
                              .favoriteQoutes[currentBackgroundColor].image,
                        ),
                        PageView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Material(
                                color: Colors.transparent,
                                child: ReelText(
                                    data: controller.favoriteQoutes[index]));
                          },
                          controller: pageController,
                          scrollDirection: Axis.vertical,
                          onPageChanged: (value) async {
                            currentBackgroundColor = value;
                            await controller
                                .keepReelsScroll(value + controller.scroll);

                            controller.isFav.value = await controller
                                .getFav(controller.favoriteQoutes[value].key);

                            setState(
                              () {},
                            );
                          },
                          itemCount: controller.favoriteQoutes.length,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 25,
                    left: 15,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const FavoriteScreen()));
                          },
                          child: Container(
                            height: 50,
                            width: 80,
                            decoration: BoxDecoration(
                                color: Colors.grey[200]!.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10)),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(Icons.browse_gallery_outlined),
                                Text('Favorite')
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 145,
                        ),
                        SizedBox(
                          width: 150,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Obx(
                                () => InkWell(
                                  onTap: () async {
                                    log('Fav: ${controller.favoriteQoutes[currentBackgroundColor].toJson()}');
                                    controller.toggleFav();
                                    if (controller.isFav.value == true) {
                                      await controller.insertData(
                                          controller
                                              .favoriteQoutes[
                                                  currentBackgroundColor]
                                              .key,
                                          controller.favoriteQoutes[
                                                  currentBackgroundColor]
                                              .toJson());
                                    } else {
                                      controller.deleteData(controller
                                          .favoriteQoutes[
                                              currentBackgroundColor]
                                          .key);
                                    }
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                        color:
                                            Colors.grey[200]!.withOpacity(0.3),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Icon(
                                      controller.isFav == false
                                          ? Bootstrap.heart
                                          : Bootstrap.heart_fill,
                                      color: controller.isFav.value
                                          ? Colors.red
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ShareScreen(
                                        data: controller.favoriteQoutes[
                                            currentBackgroundColor],
                                      ),
                                    ),
                                  );

                                  currentBackgroundColor = 0;
                                  setState(() {});
                                },
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                      color: Colors.grey[200]!.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Icon(Bootstrap.share_fill),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }
}

class ReelText extends StatelessWidget {
  ReelText({super.key, required this.data});
  Favorite data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Align(
            alignment: const Alignment(-0.9, -0.1),
            child: SizedBox(
              width: 100,
              height: 70,
              child: Image.asset(
                'assets/quote.png',
                color: Colors.grey[300]!.withOpacity(0.5),
              ),
            ),
          ),
          SizedBox(
            height: 100,
            width: 300,
            child: Text(
              data.qoute,
              style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255)),
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 100,
                  height: 2,
                  color: Colors.white,
                ),
                Text(
                  data.auther,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                Container(
                  width: 100,
                  height: 2,
                  color: Colors.white,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
