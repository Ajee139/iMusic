import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imusic/consts/colors.dart';
import 'package:imusic/Screens/home.dart';
import 'package:imusic/Screens/library.dart';
import 'package:imusic/Screens/player.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../controllers/playerController.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final controller = Get.find<PlayerController>();
        return Stack(
          children: [
            // Main content
            IndexedStack(
              index: controller.currentIndex.value,
              children: const [
                Home(),
                Library(),
              ],
            ),
            
            // Bottom player widget
            if (controller.currentSongModel.value != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: QueryArtworkWidget(
                      id: controller.currentSongModel.value!.id,
                      type: ArtworkType.AUDIO,
                      artworkHeight: 50,
                      artworkWidth: 50,
                      nullArtworkWidget: const Icon(Icons.music_note),
                    ),
                    title: Text(
                      controller.currentSongModel.value!.displayNameWOExt,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      controller.currentSongModel.value!.artist ?? "Unknown Artist",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() => IconButton(
                          icon: Icon(
                            controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                          ),
                          onPressed: () {
                            if (controller.isPlaying.value) {
                              controller.pauseSong();
                            } else {
                              controller.resumeSong();
                            }
                          },
                        )),
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          onPressed: controller.playNextSong,
                        ),
                      ],
                    ),
                    onTap: () {
                      Get.to(() => Player(data: controller.currentSongModel.value!));
                    },
                  ),
                ),
              ),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final controller = Get.find<PlayerController>();
        return BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: (index) => controller.currentIndex.value = index,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_music),
              label: 'Library',
            ),
          ],
        );
      }),
    );
  }
} 