import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:imusic/controllers/playerController.dart';
import 'package:imusic/Screens/player.dart';

class RecentlyAdded extends StatelessWidget {
  const RecentlyAdded({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Added'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<SongModel>>(
        future: OnAudioQuery().querySongs(
          sortType: SongSortType.DATE_ADDED,
          orderType: OrderType.ASC_OR_SMALLER,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final songs = snapshot.data!;
          if (songs.isEmpty) {
            return const Center(child: Text('No songs found'));
          }

          // Reverse the list to show recently added first
          final reversedSongs = songs.reversed.toList();

          return ListView.builder(
            itemCount: reversedSongs.length,
            itemBuilder: (context, index) {
              final song = reversedSongs[index];
              return ListTile(
                leading: QueryArtworkWidget(
                  id: song.id,
                  type: ArtworkType.AUDIO,
                  artworkHeight: 50,
                  artworkWidth: 50,
                  nullArtworkWidget: const Icon(Icons.music_note),
                ),
                title: Text(
                  song.displayNameWOExt,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  song.artist ?? 'Unknown Artist',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  final controller = Get.find<PlayerController>();
                  controller.playSong(song.uri!, 0);
                  controller.currentSongModel.value = song;
                  controller.currentSongIndex.value = index;
                  Get.to(() => Player(data: song));
                },
              );
            },
          );
        },
      ),
    );
  }
} 