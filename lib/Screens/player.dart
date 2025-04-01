import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imusic/consts/colors.dart';
import 'package:imusic/controllers/playerController.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Player extends StatelessWidget {
  final SongModel data;

  const Player({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    try {
      var controller = Get.find<PlayerController>();
      
      // Start playing the song when the screen opens
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          debugPrint('Starting playback for song: ${data.displayNameWOExt}');
          debugPrint('Song title: ${data.title}');
          debugPrint('Song displayName: ${data.displayName}');
          debugPrint('Song URI: ${data.uri}');
          if (data.uri != null) {
            // Only start playing if the song isn't already playing
            if (!controller.isPlaying.value) {
              controller.playSong(data.uri ?? '', 0);
            }
            controller.currentSongModel.value = data;
            controller.currentSongIndex.value = controller.songs.indexOf(data);
            controller.updateCurrentSongInfo(
              data.title ?? data.displayNameWOExt,
              data.artist ?? "Unknown Artist",
            );
          } else {
            debugPrint('Error: Song URI is null');
          }
        } catch (e) {
          debugPrint('Error in post frame callback: $e');
          debugPrint('Stack trace: ${StackTrace.current}');
        }
      });

      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: const Text('Now Playing'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  // Artwork and song info section
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Song artwork
                          Obx(() => Container(
                            width: constraints.maxWidth * 0.7,
                            height: constraints.maxWidth * 0.7,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: controller.currentSongModel.value != null
                                ? QueryArtworkWidget(
                                    id: controller.currentSongModel.value!.id,
                                    type: ArtworkType.AUDIO,
                                    artworkHeight: double.infinity,
                                    artworkWidth: double.infinity,
                                    nullArtworkWidget: const Icon(Icons.music_note, size: 100),
                                  )
                                : const Icon(Icons.music_note, size: 100),
                          )),
                          const SizedBox(height: 20),
                          
                          // Song title and artist
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Obx(() => Column(
                              children: [
                                Text(
                                  controller.currentSongModel.value?.displayNameWOExt ?? 
                                  controller.currentSong.value,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  controller.currentSongModel.value?.artist ?? "Unknown Artist",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                              ],
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Controls and bookmarks section
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Progress bar
                              Obx(() => Slider(
                                value: controller.value.value,
                                max: controller.max.value,
                                onChanged: (value) {
                                  try {
                                    controller.changeDurationtoSeconds(value.toInt());
                                  } catch (e) {
                                    debugPrint('Error in slider onChanged: $e');
                                  }
                                },
                              )),
                              
                              // Time indicators
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Obx(() => Text(controller.position.value.isEmpty ? "0:00" : controller.position.value)),
                                    Obx(() => Text(controller.duration.value.isEmpty ? "0:00" : controller.duration.value)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Bookmark buttons
                              Obx(() => Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
                                children: [
                                  ...controller.currentBookmarks.entries.map((entry) => 
                                    ElevatedButton.icon(
                                      onPressed: () => controller.jumpToBookmark(entry.key),
                                      icon: const Icon(Icons.bookmark),
                                      label: Text(entry.key),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      controller.isAddingBookmark.value = true;
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Add Bookmark'),
                                          content: TextField(
                                            decoration: const InputDecoration(
                                              hintText: 'Enter bookmark name',
                                            ),
                                            onChanged: (value) => controller.newBookmarkName.value = value,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                controller.isAddingBookmark.value = false;
                                                controller.newBookmarkName.value = '';
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                if (controller.newBookmarkName.value.isNotEmpty) {
                                                  controller.addBookmark(controller.newBookmarkName.value);
                                                  Navigator.pop(context);
                                                }
                                              },
                                              child: const Text('Add'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Bookmark'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ],
                              )),
                              const SizedBox(height: 20),
                              
                              // Playback controls
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.skip_previous, size: 40),
                                      onPressed: controller.playPreviousSong,
                                    ),
                                    Obx(() => IconButton(
                                      icon: Icon(
                                        controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                                        size: 50,
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
                                      icon: const Icon(Icons.skip_next, size: 40),
                                      onPressed: controller.playNextSong,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.stop, size: 40),
                                      onPressed: () => controller.stopSong(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error in Player build: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      return Scaffold(
        body: Center(
          child: Text('Error: $e'),
        ),
      );
    }
  }
}
