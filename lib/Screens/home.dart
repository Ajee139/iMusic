import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imusic/Screens/player.dart';
import 'package:imusic/consts/colors.dart';
import 'package:imusic/controllers/playerController.dart';
import 'package:imusic/widgets/bottom_player.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<PlayerController>();
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Music'),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => controller.refreshSongs(),
            child: FutureBuilder<List<SongModel>>(
              future: controller.audioQuery.querySongs(
                sortType: null,
                orderType: OrderType.ASC_OR_SMALLER,
                uriType: UriType.EXTERNAL,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Obx(() => ElevatedButton.icon(
                          onPressed: controller.isLoading.value 
                            ? null 
                            : () => controller.refreshSongs(),
                          icon: controller.isLoading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.refresh),
                          label: Text(
                            controller.isLoading.value ? 'Refreshing...' : 'Try Again',
                          ),
                        )),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.music_off,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No songs found',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Pull down to refresh',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(() => ElevatedButton.icon(
                          onPressed: controller.isLoading.value 
                            ? null 
                            : () => controller.refreshSongs(),
                          icon: controller.isLoading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(bgColor),
                                ),
                              )
                            : const Icon(Icons.refresh),
                          label: Text(
                            controller.isLoading.value ? 'Refreshing...' : 'Refresh',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: bgColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        )),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data![index];
                    return ListTile(
                      leading: QueryArtworkWidget(
                        id: data.id,
                        type: ArtworkType.AUDIO,
                        nullArtworkWidget: const Icon(Icons.music_note),
                      ),
                      title: Text(
                        data.displayNameWOExt,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        data.artist ?? "Unknown Artist",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () {
                        controller.updateCurrentSongInfo(
                          data.displayNameWOExt,
                          data.artist ?? "Unknown Artist",
                        );
                        Get.to(() => Player(data: data));
                      },
                    );
                  },
                );
              },
            ),
          ),
          // Bottom player
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomPlayer(),
          ),
        ],
      ),
    );
  }
}
