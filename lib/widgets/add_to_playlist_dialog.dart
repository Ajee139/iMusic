import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imusic/controllers/playerController.dart';

class AddToPlaylistDialog extends StatelessWidget {
  final String songId;
  final String songTitle;

  const AddToPlaylistDialog({
    super.key,
    required this.songId,
    required this.songTitle,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlayerController>();

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add to Playlist',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Add "$songTitle" to:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Obx(() => ListView.builder(
              shrinkWrap: true,
              itemCount: controller.playlists.length + 1,
              itemBuilder: (context, index) {
                if (index == controller.playlists.length) {
                  return ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Create New Playlist'),
                    onTap: () {
                      Navigator.pop(context);
                      _showCreatePlaylistDialog(context, controller);
                    },
                  );
                }

                final playlist = controller.playlists[index];
                final isInPlaylist = playlist.songIds.contains(songId);

                return ListTile(
                  leading: Icon(
                    isInPlaylist ? Icons.check_box : Icons.check_box_outline_blank,
                    color: isInPlaylist ? Colors.blue : null,
                  ),
                  title: Text(playlist.name),
                  onTap: () async {
                    if (isInPlaylist) {
                      await controller.removeSongFromPlaylist(songId, playlist.name);
                    } else {
                      await controller.addSongToPlaylist(songId, playlist.name);
                    }
                  },
                );
              },
            )),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
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
                // Show the add to playlist dialog again
                showDialog(
                  context: context,
                  builder: (context) => AddToPlaylistDialog(
                    songId: songId,
                    songTitle: songTitle,
                  ),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
} 