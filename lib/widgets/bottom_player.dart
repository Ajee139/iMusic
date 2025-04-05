import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imusic/consts/colors.dart';
import 'package:imusic/controllers/playerController.dart';
import 'package:imusic/Screens/player.dart';
import 'package:on_audio_query/on_audio_query.dart';

class BottomPlayer extends StatelessWidget {
  const BottomPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<PlayerController>();
    
    return Obx(() {
      if (!controller.isPlaying.value) return const SizedBox.shrink();
      
      return GestureDetector(
        onTap: () {
          Get.to(() => Player(data: SongModel({
            'id': controller.playIndex.value,
            'title': controller.currentSong.value,
            'artist': controller.currentArtist.value,
            'uri': controller.currentUri.value,
          })));
        },
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: bgDarkColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: QueryArtworkWidget(
                  id: controller.playIndex.value,
                  type: ArtworkType.AUDIO,
                  nullArtworkWidget: const Icon(
                    Icons.music_note,
                    color: whiteColor,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.currentSong.value,
                      style: const TextStyle(
                        color: whiteColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      controller.currentArtist.value,
                      style: TextStyle(
                        color: whiteColor.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (controller.isPlaying.value) {
                        controller.pauseSong();
                      } else {
                        controller.resumeSong();
                      }
                    },
                    icon: Icon(
                      controller.isPlaying.value
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: whiteColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      controller.stopSong();
                    },
                    icon: const Icon(
                      Icons.close,
                      color: whiteColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
} 