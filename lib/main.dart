import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Settings.init();
  runApp(const UminekoReaderApp());
}

class UminekoReaderApp extends StatelessWidget {
  const UminekoReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Umineko Reader',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
        ),
      ),
      home: const EpisodeSelectionScreen(),
    );
  }
}

class Settings {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String get folderPath =>
      _prefs.getString('folder_path') ?? 'C:/Users/Derkein/Desktop/umineko';
  static set folderPath(String value) => _prefs.setString('folder_path', value);

  static double get bgmVolume => _prefs.getDouble('bgm_volume') ?? 0.7;
  static set bgmVolume(double value) => _prefs.setDouble('bgm_volume', value);

  static double get seVolume => _prefs.getDouble('se_volume') ?? 1.0;
  static set seVolume(double value) => _prefs.setDouble('se_volume', value);

  static String? get lastEpisodePath => _prefs.getString('last_episode_path');
  static set lastEpisodePath(String? value) {
    if (value != null) {
      _prefs.setString('last_episode_path', value);
    } else {
      _prefs.remove('last_episode_path');
    }
  }

  static String? get lastEpisodeName => _prefs.getString('last_episode_name');
  static set lastEpisodeName(String? value) {
    if (value != null) {
      _prefs.setString('last_episode_name', value);
    } else {
      _prefs.remove('last_episode_name');
    }
  }

  static String? get lastChapter => _prefs.getString('last_chapter');
  static set lastChapter(String? value) {
    if (value != null) {
      _prefs.setString('last_chapter', value);
    } else {
      _prefs.remove('last_chapter');
    }
  }

  static int get lastPageIndex => _prefs.getInt('last_page_index') ?? 0;
  static set lastPageIndex(int value) =>
      _prefs.setInt('last_page_index', value);

  static bool get hasLastReading =>
      lastEpisodePath != null && lastEpisodeName != null && lastChapter != null;
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double bgmVolume = Settings.bgmVolume;
  double seVolume = Settings.seVolume;
  String folderPath = Settings.folderPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.grey[900],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Audio Settings',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Icon(Icons.music_note, color: Colors.amber),
                      const SizedBox(width: 12),
                      const Text(
                        'BGM Volume',
                        style: TextStyle(color: Colors.white),
                      ),
                      const Spacer(),
                      Text(
                        '${(bgmVolume * 100).round()}%',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  Slider(
                    value: bgmVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    activeColor: Colors.amber,
                    inactiveColor: Colors.grey[700],
                    onChanged: (value) {
                      setState(() {
                        bgmVolume = value;
                      });
                      Settings.bgmVolume = value;
                    },
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.volume_up, color: Colors.amber),
                      const SizedBox(width: 12),
                      const Text(
                        'Sound Effects Volume',
                        style: TextStyle(color: Colors.white),
                      ),
                      const Spacer(),
                      Text(
                        '${(seVolume * 100).round()}%',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  Slider(
                    value: seVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    activeColor: Colors.amber,
                    inactiveColor: Colors.grey[700],
                    onChanged: (value) {
                      setState(() {
                        seVolume = value;
                      });
                      Settings.seVolume = value;
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            color: Colors.grey[900],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'File Settings',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.folder, color: Colors.amber),
                      SizedBox(width: 12),
                      Text(
                        'Umineko Folder Path',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      folderPath,
                      style: const TextStyle(color: Colors.white70),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      String? selectedDirectory =
                          await FilePicker.platform.getDirectoryPath();
                      if (selectedDirectory != null) {
                        setState(() {
                          folderPath = selectedDirectory;
                        });
                        Settings.folderPath = selectedDirectory;

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Folder path updated! Please restart the app to see changes.'),
                              backgroundColor: Colors.amber,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Browse Folder'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EpisodeSelectionScreen extends StatefulWidget {
  const EpisodeSelectionScreen({super.key});

  @override
  State<EpisodeSelectionScreen> createState() => _EpisodeSelectionScreenState();
}

class _EpisodeSelectionScreenState extends State<EpisodeSelectionScreen> {
  List<String> episodes = [];
  String basePath = '';

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
  }

  Future<void> _loadEpisodes() async {
    try {
      final directory = Directory(Settings.folderPath);

      if (await directory.exists()) {
        final entities = await directory.list().toList();
        final episodeFolders = entities
            .whereType<Directory>()
            .where((dir) => path.basename(dir.path).startsWith('umineko-ep-'))
            .map((dir) => path.basename(dir.path))
            .toList();

        episodeFolders.sort((a, b) {
          final aNum = int.tryParse(a.split('-').last) ?? 0;
          final bNum = int.tryParse(b.split('-').last) ?? 0;
          return aNum.compareTo(bNum);
        });

        setState(() {
          episodes = episodeFolders;
          basePath = directory.path;
        });
      }
    } catch (e) {
      print('Error loading episodes: $e');
    }
  }

  void _resumeLastReading() {
    if (Settings.hasLastReading) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UminekoReaderScreen(
            episodePath: Settings.lastEpisodePath!,
            episodeName: Settings.lastEpisodeName!,
            startChapter: Settings.lastChapter!,
            startPageIndex: Settings.lastPageIndex,
          ),
        ),
      ).then((_) {
        setState(() {});
      });
    }
  }

  String _getEpisodeDisplayNameFromEpisodeName(String episodeName) {
    final episodeNumber = episodeName.split('-').last;
    switch (episodeNumber) {
      case '1':
        return 'Episode 1';
      case '2':
        return 'Episode 2';
      case '3':
        return 'Episode 3';
      case '4':
        return 'Episode 4';
      case '5':
        return 'Episode 5';
      case '6':
        return 'Episode 6';
      case '7':
        return 'Episode 7';
      case '8':
        return 'Episode 8';
      default:
        return episodeName.replaceAll('-', ' ').toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Umineko Episodes'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          if (!episodes.isEmpty && Settings.hasLastReading)
            Container(
              margin: const EdgeInsets.all(16),
              child: Card(
                color: Colors.amber[800],
                child: ListTile(
                  leading: const Icon(Icons.bookmark, color: Colors.black),
                  title: const Text(
                    'Resume Reading',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Continue from ${_getEpisodeDisplayNameFromEpisodeName(Settings.lastEpisodeName!)}, Chapter ${Settings.lastChapter}, Page ${Settings.lastPageIndex + 1}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                  trailing: const Icon(Icons.play_arrow, color: Colors.black),
                  onTap: _resumeLastReading,
                ),
              ),
            ),

          Expanded(
            child: episodes.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.amber),
                        SizedBox(height: 16),
                        Text(
                          'Loading episodes...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: episodes.length,
                    itemBuilder: (context, index) {
                      final episode = episodes[index];
                      return Card(
                        color: Colors.grey[900],
                        child: ListTile(
                          leading: const Icon(Icons.book, color: Colors.amber),
                          title: Text(
                            _getEpisodeDisplayName(episode),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            _getEpisodeSubtitle(episode),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              color: Colors.amber),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChapterSelectionScreen(
                                  episodePath: path.join(basePath, episode),
                                  episodeName: episode,
                                ),
                              ),
                            ).then((_) {
                              setState(() {});
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _getEpisodeDisplayName(String episode) {
    final episodeNumber = episode.split('-').last;
    switch (episodeNumber) {
      case '1':
        return 'Episode 1 - Legend of the Golden Witch';
      case '2':
        return 'Episode 2 - Turn of the Golden Witch';
      case '3':
        return 'Episode 3 - Banquet of the Golden Witch';
      case '4':
        return 'Episode 4 - Alliance of the Golden Witch';
      case '5':
        return 'Episode 5 - End of the Golden Witch';
      case '6':
        return 'Episode 6 - Dawn of the Golden Witch';
      case '7':
        return 'Episode 7 - Requiem of the Golden Witch';
      case '8':
        return 'Episode 8 - Twilight of the Golden Witch';
      default:
        return episode.replaceAll('-', ' ').toUpperCase();
    }
  }

  String _getEpisodeSubtitle(String episode) {
    final episodeNumber = episode.split('-').last;
    final episodeNum = int.tryParse(episodeNumber) ?? 0;
    if (episodeNum <= 4) {
      return 'Question Arc - Tap to select chapter';
    } else {
      return 'Answer Arc - Tap to select chapter';
    }
  }
}

class ChapterSelectionScreen extends StatefulWidget {
  final String episodePath;
  final String episodeName;

  const ChapterSelectionScreen({
    super.key,
    required this.episodePath,
    required this.episodeName,
  });

  @override
  State<ChapterSelectionScreen> createState() => _ChapterSelectionScreenState();
}

class _ChapterSelectionScreenState extends State<ChapterSelectionScreen> {
  List<String> chapters = [];
  Map<String, dynamic> scriptData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    try {
      final scriptFile = File(path.join(widget.episodePath, 'script.json'));
      if (await scriptFile.exists()) {
        final scriptContent = await scriptFile.readAsString();
        final data = jsonDecode(scriptContent);
        scriptData = data;

        if (data['chapters'] != null) {
          final chapterKeys = data['chapters'].keys.toList();
          chapterKeys.sort((a, b) {
            final aNum = int.tryParse(a) ?? 0;
            final bNum = int.tryParse(b) ?? 0;
            return aNum.compareTo(bNum);
          });
          setState(() {
            chapters = chapterKeys;
          });
        }
      } else {
        final imgDir = Directory(path.join(widget.episodePath, 'img'));
        if (await imgDir.exists()) {
          final entities = await imgDir.list().toList();
          final chapterFolders = entities
              .whereType<Directory>()
              .where((dir) => path.basename(dir.path).startsWith('ch-'))
              .map((dir) =>
                  path.basename(dir.path).substring(3)) 
              .toList();

          chapterFolders.sort((a, b) {
            final aNum = int.tryParse(a) ?? 0;
            final bNum = int.tryParse(b) ?? 0;
            return aNum.compareTo(bNum);
          });

          setState(() {
            chapters = chapterFolders;
          });
        }
      }
    } catch (e) {
      print('Error loading chapters: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getChapterDisplayName(String chapter) {
    if (scriptData['chapters'] != null &&
        scriptData['chapters'][chapter] != null) {
      final chapterData = scriptData['chapters'][chapter];
      String? title;

      if (chapterData['title_en'] != null) {
        title = chapterData['title_en'];
      } else if (chapterData['title'] != null && chapterData['title'] is Map) {
        final titleMap = chapterData['title'] as Map<String, dynamic>;
        title = titleMap['en'] ?? titleMap['english'];
      } else if (chapterData['title'] != null &&
          chapterData['title'] is String) {
        title = chapterData['title'];
      }

      if (title != null && title.isNotEmpty) {
        return 'Chapter $chapter - $title';
      }
    }

    return 'Chapter $chapter';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.episodeName} - Chapters'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.amber),
                  SizedBox(height: 16),
                  Text(
                    'Loading chapters...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
          : chapters.isEmpty
              ? const Center(
                  child: Text(
                    'No chapters found',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    return Card(
                      color: Colors.grey[900],
                      child: ListTile(
                        leading:
                            const Icon(Icons.play_circle, color: Colors.amber),
                        title: Text(
                          _getChapterDisplayName(chapter),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'Tap to start reading',
                          style: TextStyle(color: Colors.grey),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.amber),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UminekoReaderScreen(
                                episodePath: widget.episodePath,
                                episodeName: widget.episodeName,
                                startChapter: chapter,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class UminekoReaderScreen extends StatefulWidget {
  final String episodePath;
  final String episodeName;
  final String? startChapter;
  final int? startPageIndex;

  const UminekoReaderScreen({
    super.key,
    required this.episodePath,
    required this.episodeName,
    this.startChapter,
    this.startPageIndex,
  });

  @override
  State<UminekoReaderScreen> createState() => _UminekoReaderScreenState();
}

class _UminekoReaderScreenState extends State<UminekoReaderScreen> {
  Map<String, dynamic> scriptData = {};
  String currentChapter = '';
  int currentPageIndex = 0;
  List<Map<String, dynamic>> currentPages = [];

  late final AudioPlayer bgmPlayer;
  late final List<AudioPlayer> sePlayers;

  bool isLoading = true;
  bool isFullscreen = false;
  String? currentImagePath;
  bool audioEnabled = true;

  String? currentlyPlayingBGM;
  List<String> currentlyPlayingSEs = [];

  PlayerState bgmState = PlayerState.stopped;
  PlayerState seState = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    _initializeAudioPlayers();
    _loadScript();
  }

  void _initializeAudioPlayers() {
    bgmPlayer = AudioPlayer();
    sePlayers = List.generate(5, (index) => AudioPlayer());

    bgmPlayer.onPlayerStateChanged.listen((state) {
      bgmState = state;
      print('BGM State changed to: $state');
      if (state == PlayerState.stopped || state == PlayerState.completed) {
        if (state == PlayerState.completed) {
          currentlyPlayingBGM = null;
        }
      }
    });

    for (int i = 0; i < sePlayers.length; i++) {
      sePlayers[i].onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed || state == PlayerState.stopped) {
        }
      });
    }
  }

  @override
  void dispose() {
    bgmPlayer.dispose();
    for (final player in sePlayers) {
      player.dispose();
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _loadScript() async {
    try {
      final scriptFile = File(path.join(widget.episodePath, 'script.json'));
      if (await scriptFile.exists()) {
        final scriptContent = await scriptFile.readAsString();
        final data = jsonDecode(scriptContent);

        setState(() {
          scriptData = data;
          if (data['chapters'] != null && data['chapters'].isNotEmpty) {
            if (widget.startChapter != null &&
                data['chapters'].containsKey(widget.startChapter)) {
              currentChapter = widget.startChapter!;
              currentPageIndex = widget.startPageIndex ?? 0;
            } else {
              currentChapter = data['chapters'].keys.first;
            }
            currentPages = List<Map<String, dynamic>>.from(
                data['chapters'][currentChapter]['pages'] ?? []);
            _loadCurrentPage();
          }
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading script: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadCurrentPage() async {
    if (currentPages.isEmpty || currentPageIndex >= currentPages.length) return;

    final currentPage = currentPages[currentPageIndex];
    final pageName = currentPage['page'];

    final imagePath = path.join(
        widget.episodePath, 'img', 'ch-$currentChapter', '$pageName.jpg');

    final imageFile = File(imagePath);
    if (await imageFile.exists()) {
      setState(() {
        currentImagePath = imagePath;
      });
    }

    if (!audioEnabled) return;

    await _handleBGM(currentPage['bgm'] as String?);

    await _handleSE(currentPage['se']);
  }

  Future<void> _handleBGM(String? pageBGM) async {
    final normalizedBGM =
        (pageBGM?.trim().isEmpty ?? true) ? null : pageBGM?.trim();

    print(
        'Handling BGM: current="$currentlyPlayingBGM", requested="$normalizedBGM", state=$bgmState');

    if (normalizedBGM == null) {
      if (currentlyPlayingBGM != null) {
        print('Stopping BGM as page has no BGM requirement');
        currentlyPlayingBGM = null;
        await bgmPlayer.stop();
      }
      return;
    }

    if (currentlyPlayingBGM == normalizedBGM &&
        (bgmState == PlayerState.playing || bgmState == PlayerState.paused)) {
      print('BGM "$normalizedBGM" is already playing, not restarting');
      return;
    }

    print('Starting new BGM: "$normalizedBGM"');
    currentlyPlayingBGM = normalizedBGM;
    await _playBGM(normalizedBGM);
  }

  Future<void> _handleSE(dynamic pageSE) async {
    List<String> requestedSEs = [];

    if (pageSE is List) {
      requestedSEs = pageSE
          .where((se) => se != null && se.toString().trim().isNotEmpty)
          .map((se) => se.toString().trim())
          .toList();
    } else if (pageSE is String && pageSE.trim().isNotEmpty) {
      requestedSEs = [pageSE.trim()];
    }

    print(
        'Handling SE: current=${currentlyPlayingSEs}, requested=$requestedSEs');

    if (requestedSEs.isEmpty) {
      if (currentlyPlayingSEs.isNotEmpty) {
        print('Stopping all SEs as page has empty SE array');
        await _stopAllSEs();
        setState(() {
          currentlyPlayingSEs.clear();
        });
      }
      return;
    }

    bool needsUpdate = !_listsEqual(currentlyPlayingSEs, requestedSEs);

    if (!needsUpdate) {
      print('Same SEs already playing, not restarting');
      return;
    }

    print('Updating SEs from $currentlyPlayingSEs to $requestedSEs');

    List<String> sesToStop =
        currentlyPlayingSEs.where((se) => !requestedSEs.contains(se)).toList();

    List<String> sesToStart =
        requestedSEs.where((se) => !currentlyPlayingSEs.contains(se)).toList();

    for (String seToStop in sesToStop) {
      int index = currentlyPlayingSEs.indexOf(seToStop);
      if (index >= 0 && index < sePlayers.length) {
        print('Stopping SE: $seToStop at player index $index');
        await sePlayers[index].stop();
      }
    }

    for (String seToStart in sesToStart) {
      int targetIndex = requestedSEs.indexOf(seToStart);

      if (targetIndex >= 0 && targetIndex < sePlayers.length) {
        print('Starting SE: $seToStart at player index $targetIndex');
        await _playSE(seToStart, sePlayers[targetIndex]);
      }
    }

    setState(() {
      currentlyPlayingSEs = List<String>.from(requestedSEs);
    });
  }

  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  Future<void> _stopAllSEs() async {
    for (final player in sePlayers) {
      try {
        await player.stop();
      } catch (e) {
        print('Error stopping SE player: $e');
      }
    }
  }

  Future<void> _playBGM(String bgmId) async {
    try {
      final soundDir = scriptData['soundDir'] ?? 'umineko-sound';

      final extensions = ['mp3', 'wav', 'm4a', 'ogg'];
      String? workingPath;

      for (final ext in extensions) {
        final testPath = path.join(
            path.dirname(widget.episodePath), soundDir, 'bgm', '$bgmId.$ext');

        final testFile = File(testPath);
        if (await testFile.exists()) {
          workingPath = testPath;
          break;
        }
      }

      if (workingPath != null) {
        await bgmPlayer.stop();
        await bgmPlayer.play(DeviceFileSource(workingPath));
        await bgmPlayer.setVolume(Settings.bgmVolume);
        await bgmPlayer.setReleaseMode(ReleaseMode.loop);
        print('Successfully playing BGM: $workingPath');
      } else {
        print(
            'BGM file not found for ID: $bgmId (tried extensions: ${extensions.join(', ')})');
        currentlyPlayingBGM = null; 
      }
    } catch (e) {
      print('Error playing BGM: $e');
      currentlyPlayingBGM = null; 
    }
  }

  Future<void> _playSE(String seId, AudioPlayer player) async {
    try {
      final soundDir = scriptData['soundDir'] ?? 'umineko-sound';

      final extensions = ['mp3', 'wav', 'm4a', 'ogg'];
      String? workingPath;

      for (final ext in extensions) {
        final testPath = path.join(
            path.dirname(widget.episodePath), soundDir, 'se', '$seId.$ext');

        final testFile = File(testPath);
        if (await testFile.exists()) {
          workingPath = testPath;
          break;
        }
      }

      if (workingPath != null) {
        await player.stop();
        await player.play(DeviceFileSource(workingPath));
        await player.setVolume(Settings.seVolume);
        print('Successfully playing SE: $workingPath');
      } else {
        print(
            'SE file not found for ID: $seId (tried extensions: ${extensions.join(', ')})');
      }
    } catch (e) {
      print('Error playing SE: $e');
    }
  }

  void _handleTap(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapX = details.globalPosition.dx;

    if (tapX < screenWidth * 0.3) {
      _previousPage();
    } else if (tapX > screenWidth * 0.7) {
      _nextPage();
    } else {
      _toggleFullscreen();
    }
  }

  void _saveReadingProgress() {
    Settings.lastEpisodePath = widget.episodePath;
    Settings.lastEpisodeName = widget.episodeName;
    Settings.lastChapter = currentChapter;
    Settings.lastPageIndex = currentPageIndex;
  }

  void _toggleFullscreen() {
    setState(() {
      isFullscreen = !isFullscreen;
    });

    if (isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _previousPage() {
    if (currentPageIndex > 0) {
      setState(() {
        currentPageIndex--;
      });
      _saveReadingProgress();
      _loadCurrentPage();
    } else {
      _previousChapter();
    }
  }

  void _nextPage() {
    if (currentPageIndex < currentPages.length - 1) {
      setState(() {
        currentPageIndex++;
      });
      _saveReadingProgress();
      _loadCurrentPage();
    } else {
      _nextChapter();
    }
  }

  void _nextChapter() {
    final chapters = scriptData['chapters']?.keys.toList() ?? [];
    final currentIndex = chapters.indexOf(currentChapter);

    if (currentIndex < chapters.length - 1) {
      final nextChapter = chapters[currentIndex + 1];
      setState(() {
        currentChapter = nextChapter;
        currentPageIndex = 0;
        currentPages = List<Map<String, dynamic>>.from(
            scriptData['chapters'][nextChapter]['pages'] ?? []);
      });
      _saveReadingProgress(); 
      _loadCurrentPage();
    }
  }

  void _previousChapter() {
    final chapters = scriptData['chapters']?.keys.toList() ?? [];
    final currentIndex = chapters.indexOf(currentChapter);

    if (currentIndex > 0) {
      final prevChapter = chapters[currentIndex - 1];
      final prevPages = List<Map<String, dynamic>>.from(
          scriptData['chapters'][prevChapter]['pages'] ?? []);

      setState(() {
        currentChapter = prevChapter;
        currentPageIndex = prevPages.length - 1;
        currentPages = prevPages;
      });
      _saveReadingProgress(); 
      _loadCurrentPage();
    }
  }

  void _toggleAudio() {
    setState(() {
      audioEnabled = !audioEnabled;
    });

    if (!audioEnabled) {
      bgmPlayer.stop();
      _stopAllSEs();
      currentlyPlayingBGM = null;
      currentlyPlayingSEs.clear();
    } else {
      _loadCurrentPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.episodeName),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.amber),
        ),
      );
    }

    final currentPage =
        currentPages.isNotEmpty && currentPageIndex < currentPages.length
            ? currentPages[currentPageIndex]
            : null;

    if (isFullscreen) {
      return Scaffold(
        body: GestureDetector(
          onTapDown: _handleTap,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
            child: currentImagePath != null
                ? Image.file(
                    File(currentImagePath!),
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 48),
                            Text(
                              'Image not found',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      'No image available',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(scriptData['title'] ?? widget.episodeName),
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: _toggleFullscreen,
            tooltip: 'Fullscreen',
          ),
          IconButton(
            icon: Icon(
              audioEnabled ? Icons.volume_up : Icons.volume_off,
              color: audioEnabled ? Colors.amber : Colors.grey,
            ),
            onPressed: _toggleAudio,
            tooltip: audioEnabled ? 'Disable Audio' : 'Enable Audio',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 4,
            child: LinearProgressIndicator(
              value: currentPages.isNotEmpty
                  ? (currentPageIndex + 1) / currentPages.length
                  : 0,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[900],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Chapter $currentChapter',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Page ${currentPageIndex + 1}/${currentPages.length}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            color: Colors.grey[850],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tap: Left=Back • Center=Fullscreen • Right=Next',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (audioEnabled)
                  Text(
                    'BGM: ${currentlyPlayingBGM ?? 'None'} | SE: ${currentlyPlayingSEs.isEmpty ? 'None' : currentlyPlayingSEs.join(', ')}',
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
              ],
            ),
          ),

          Expanded(
            child: GestureDetector(
              onTapDown: _handleTap,
              child: Container(
                width: double.infinity,
                child: currentImagePath != null
                    ? Image.file(
                        File(currentImagePath!),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, color: Colors.red, size: 48),
                                Text(
                                  'Image not found',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          'No image available',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[900],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, color: Colors.amber),
                  onPressed: _previousChapter,
                  tooltip: 'Previous Chapter',
                ),
                IconButton(
                  icon: const Icon(Icons.navigate_before, color: Colors.amber),
                  onPressed: _previousPage,
                  tooltip: 'Previous Page',
                ),
                IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.amber),
                  onPressed: () {
                    if (currentPage != null && audioEnabled) {
                      _loadCurrentPage(); 
                    }
                  },
                  tooltip: 'Replay Audio',
                ),
                IconButton(
                  icon: const Icon(Icons.navigate_next, color: Colors.amber),
                  onPressed: _nextPage,
                  tooltip: 'Next Page',
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, color: Colors.amber),
                  onPressed: _nextChapter,
                  tooltip: 'Next Chapter',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
