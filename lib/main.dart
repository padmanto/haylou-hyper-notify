import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final plugin = FlutterLocalNotificationsPlugin();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await plugin.initialize(const InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  ));
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: Home()));
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override State<Home> createState() => _HomeState();
}
class _HomeState extends State<Home> {
  final title = TextEditingController(text: 'Server Alert');
  final message = TextEditingController(text: 'Replication lag exceeded 30 seconds');
  final emoji = TextEditingController(text: '🚨');
  bool bigText = true, highPriority = true, largeIcon = true;
  String status = 'Ready';
  int sequence = 0;
  static const presets = [
    ('Server Alert', 'Replication lag exceeded 30 seconds', '🚨'),
    ('Hello Watch', 'Sent from Flutter through Haylou Fun!', '💬'),
    ('Daily Activity', '7,645 steps • 3.09 km', '🏃'),
    ('Emoji Test', '😀 ❤️ 🔥 🎉 🚀 ⚡ 🧘', '🎉'),
    ('Long Text Test', 'This deliberately long notification checks truncation, line wrapping and maximum text supported by Haylou Watch Hyper.', '📜')
  ];
  @override void dispose() { title.dispose(); message.dispose(); emoji.dispose(); super.dispose(); }
  Future<void> send() async {
    final android = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    final content = '${emoji.text} ${message.text}';
    try {
      await plugin.show(++sequence, title.text, content,
        NotificationDetails(android: AndroidNotificationDetails(
          'hyper_showcase', 'Hyper Notify Lab',
          channelDescription: 'Notification forwarding tests for Haylou Watch Hyper',
          importance: Importance.max, priority: Priority.high,
          styleInformation: bigText ? BigTextStyleInformation(content) : null,
          largeIcon: largeIcon ? const DrawableResourceAndroidBitmap('ic_large_watch') : null,
          icon: 'ic_stat_watch',
          enableVibration: highPriority, playSound: highPriority,
          visibility: NotificationVisibility.public,
          category: AndroidNotificationCategory.message,
        )));
      setState(() => status = 'Posted to Android. Check Haylou Fun and watch.');
    } catch (e) { setState(() => status = 'Error: $e'); }
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('⌚ Hyper Notify Lab')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Xiaomi → Haylou Fun → Watch Hyper'),
      const SizedBox(height: 16),
      const Text('Showcase presets'),
      Wrap(spacing: 6, children: [
        for (final p in presets) ActionChip(
          label: Text('${p.$3} ${p.$1}'),
          onPressed: () => setState(() {title.text=p.$1;message.text=p.$2;emoji.text=p.$3;}),
        ),
      ]),
      const SizedBox(height: 12),
      TextField(controller: emoji, decoration: const InputDecoration(labelText: 'Emoji', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      TextField(controller: title, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
      const SizedBox(height: 10),
      TextField(controller: message, minLines: 2, maxLines: 5, decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder())),
      SwitchListTile(title: const Text('Expanded big text'), value: bigText, onChanged: (v)=>setState(()=>bigText=v)),
      SwitchListTile(title: const Text('Large Android icon'), value: largeIcon, onChanged: (v)=>setState(()=>largeIcon=v)),
      SwitchListTile(title: const Text('Sound and vibration'), value: highPriority, onChanged: (v)=>setState(()=>highPriority=v)),
      Card(child: ListTile(leading: const Icon(Icons.watch), title: Text('${emoji.text} ${title.text}'), subtitle: Text(message.text))),
      FilledButton.icon(onPressed: send, icon: const Icon(Icons.send), label: const Text('Send notification')),
      OutlinedButton(onPressed: () async {await plugin.cancelAll();setState(()=>status='Cleared');}, child: const Text('Clear notifications')),
      const SizedBox(height: 10),
      Text(status),
      const SizedBox(height: 14),
      const Text('Haylou Fun must have notification access and allow this app. Watch icons, emoji, and long text depend on firmware and Haylou Fun.',style: TextStyle(color: Colors.grey)),
    ]),
  );
}
