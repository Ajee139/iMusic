import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:imusic/controllers/playerController.dart';
import 'package:imusic/Screens/player.dart';
import 'package:imusic/widgets/add_to_playlist_dialog.dart';
import 'package:imusic/models/playlist.dart';

class Playlists extends StatelessWidget {
  const Playlists({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlists'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GetBuilder<PlayerController>(
        builder: (controller) {
          if (controller.playlists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.playlist_play, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No playlists yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showCreatePlaylistDialog(context, controller),
                    child: const Text('Create Playlist'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: controller.playlists.length,
            itemBuilder: (context, index) {
              final playlist = controller.playlists[index];
              return Dismissible(
                key: Key(playlist.name),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  controller.deletePlaylist(playlist.name);
                },
                child: ListTile(
                  leading: const Icon(Icons.playlist_play),
                  title: Text(playlist.name),
                  subtitle: Text('${playlist.songIds.length} songs'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AddToPlaylistDialog(
                          songId: '',  // This will be handled in the playlist detail screen
                          songTitle: playlist.name,
                        ),
                      );
                    },
                  ),
                  onTap: () => _showPlaylistDetail(context, playlist),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePlaylistDialog(context, Get.find<PlayerController>()),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, PlayerController controller) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Playlist'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Enter playlist name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                controller.createPlaylist(nameController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showPlaylistDetail(BuildContext context, Playlist playlist) {
    final controller = Get.find<PlayerController>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      playlist.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${playlist.songIds.length} songs',
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<SongModel>>(
                  future: OnAudioQuery().querySongs(
                    sortType: SongSortType.TITLE,
                    orderType: OrderType.ASC_OR_SMALLER,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final allSongs = snapshot.data!;
                    final playlistSongs = allSongs
                        .where((song) => playlist.songIds.contains(song.id.toString()))
                        .toList();

                    if (playlistSongs.isEmpty) {
                      return const Center(
                        child: Text('No songs in this playlist'),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      itemCount: playlistSongs.length,
                      itemBuilder: (context, index) {
                        final song = playlistSongs[index];
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
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              controller.removeSongFromPlaylist(
                                song.id.toString(),
                                playlist.name,
                              );
                            },
                          ),
                          onTap: () {
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
              ),
            ],
          );
        },
      ),
    );
  }
} 