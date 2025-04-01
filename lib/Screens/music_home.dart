// import 'dart:html';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:audioplayers/audioplayers.dart';

// class MusicPlayerScreen extends StatefulWidget {
//   @override
//   _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
// }

// class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   List<Map<String, dynamic>> _songs = [];
//   bool _isPlaying = false;
//   String? _currentSongName;

//   // Pick song from local storage (Web)
//   Future<void> _pickSong() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.audio,
//         allowMultiple: true, // Allow selecting multiple files
//         withData: true, // Ensures file bytes are loaded
//       );

//       if (result != null && result.files.isNotEmpty) {
//         setState(() {
//           _songs = result.files
//               .where((file) => file.bytes != null) // Filter out null files
//               .map((file) => {
//                     'name': file.name,
//                     'bytes': file.bytes, // Store file bytes
//                   })
//               .toList();
//         });

//         print("Songs Loaded: ${_songs.length}");
//       } else {
//         print("No file selected");
//       }
//     } catch (e) {
//       print("Error picking file: $e");
//     }
//   }

//   // Play selected song
//   Future<void> _playSong(Uint8List bytes, String songName) async {
//     await _audioPlayer.stop();

//     final blob = Blob([bytes]);
//     final url = Url.createObjectUrlFromBlob(blob);

//     await _audioPlayer.play(UrlSource(url));

//     setState(() {
//       _isPlaying = true;
//       _currentSongName = songName;
//     });
//   }

//   // Stop song
//   Future<void> _stopSong() async {
//     await _audioPlayer.stop();
//     setState(() {
//       _isPlaying = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Flutter Web Music Player")),
//       body: Column(
//         children: [
//           ElevatedButton(
//             onPressed: _pickSong,
//             child: Text("Select Songs from Device"),
//           ),
//           Expanded(
//             child: _songs.isEmpty
//                 ? Center(child: Text("No Songs Selected"))
//                 : ListView.builder(
//                     itemCount: _songs.length,
//                     itemBuilder: (context, index) {
//                       return ListTile(
//                         leading: Icon(Icons.music_note,
//                             size: 40, color: Colors.blue),
//                         title: Text(_songs[index]['name']),
//                         trailing: Icon(Icons.play_arrow, color: Colors.green),
//                         onTap: () => _playSong(
//                             _songs[index]['bytes'], _songs[index]['name']),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: _currentSongName != null
//           ? Container(
//               color: Colors.black87,
//               padding: EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   Icon(Icons.music_note, color: Colors.white, size: 30),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: Text(
//                       _currentSongName!,
//                       style: TextStyle(color: Colors.white),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow,
//                         color: Colors.white),
//                     onPressed: _isPlaying ? _stopSong : null,
//                   ),
//                 ],
//               ),
//             )
//           : SizedBox.shrink(),
//     );
//   }
// }
