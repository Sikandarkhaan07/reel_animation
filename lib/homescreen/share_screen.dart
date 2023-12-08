import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reel_animation2/data/fav_model.dart';
import 'package:screenshot/screenshot.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key, required this.data});
  final Favorite data;

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final ScreenshotController controller = ScreenshotController();
  File? xFile;

  @override
  Widget build(BuildContext context) {
    print('share screen.....');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
              padding: const EdgeInsets.symmetric( horizontal: 30),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(height: 90,),
                    Hero(
                      tag: 'animatedHero',
                      child: Screenshot(
                        controller: controller,
                        child: Container(
                          width: 330,
                          height: 420,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: CachedNetworkImage(
                
                                    fit: BoxFit.cover,
                                    fadeInDuration:
                                        const Duration(milliseconds: 1000),
                                    useOldImageOnUrlChange: true,
                                    imageUrl: widget.data.image),
                              ),
                              Align(
                                alignment: const Alignment(-0.9, -0.2),
                                child: SizedBox(
                                  width: 60,
                                  height: 50,
                                  child: Image.asset(
                                    'assets/quote.png',
                                    color: Colors.grey[300]!.withOpacity(0.5),
                                  ),
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: Align(
                                  alignment: const Alignment(0.6, 0),
                                  child: SizedBox(
                                    height: 100,
                                    width: 280,
                                    child: Text(
                                      widget.data.qoute,
                                      style: const TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Color.fromARGB(255, 255, 255, 255)),
                                    ),
                                  ),
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: Align(
                                  alignment: const Alignment(0, 0.35),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          
                                          width: double.infinity,
                                          height: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        widget.data.auther,
                                        style: const TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      ),
                                      Expanded(child: Container(
                                        width: double.infinity,
                                        height: 2,
                                        color: Colors.white,
                                      ), ),
                
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      // color: Colors.amber,
                      width: double.infinity,
                      height: 190,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: SizedBox(
                              // color: Colors.red,
                              height: 180,
                              width: 150,
                              child: Stack(
                                children: [
                                  Text(
                                    'Share',
                                    style: TextStyle(
                                        fontSize: 45,
                                        color: Colors.grey[300],
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Positioned(
                                    top: 48,
                                    child: Container(
                                      width: 140,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        color: Colors.purple,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: const Icon(
                                        Bootstrap.instagram,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final path =
                                  await getApplicationDocumentsDirectory();
                
                              final response = await controller.capture();
                              if (response != null) {
                                final imagePath =
                                    await File('${path.path}/test.png').create();
                
                                final savedToGallery =
                                    await GallerySaver.saveImage(imagePath.path);
                                log('savedToGallery: $savedToGallery');
                                log("path: $imagePath");
                                // xFile = await imagePath.writeAsBytes(response);
                                // setState(() {});
                              }
                            },
                            child: SizedBox(
                              // color: Colors.red,
                              height: 180,
                              width: 150,
                              child: Stack(
                                children: [
                                  Text(
                                    'to',
                                    style: TextStyle(
                                        fontSize: 45,
                                        color: Colors.grey[300],
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Positioned(
                                    top: 48,
                                    child: Container(
                                      width: 140,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        color: Colors.purple,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: const Icon(
                                        Bootstrap.download,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'CANCEL',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[300],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
