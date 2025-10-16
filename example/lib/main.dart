import 'package:flutter/material.dart';
import 'package:social_text/social_text.dart';

void main() => runApp(const SocialTextDemoApp());

class SocialTextDemoApp extends StatelessWidget {
  const SocialTextDemoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'social_text demo',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const DemoScreen(),
    );
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});
  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  final _controller = TextEditingController(
    text: 'Hey @flutterdev, check out #flutter and \\$dart!\\nAdd more: @dartlang #mobile \\$dev',
  );

  final triggers = ['@', '#', r'$'];

  bool _useLongPress = false;

  Map<String, TextStyle> get _styleMap => {
        '@': const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
        '#': const TextStyle(color: Colors.purple),
        r'$': const TextStyle(color: Colors.teal),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('social_text example')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Type text with @, #, \\$ tokens',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  FilterChip(
                    label: const Text('Long-press on'),
                    selected: _useLongPress,
                    onSelected: (v) => setState(() => _useLongPress = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Parsed tokens:'),
              const SizedBox(height: 6),
              Builder(builder: (context) {
                final tokens = SocialParser.parse(_controller.text, triggers: triggers);
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in tokens)
                      Chip(
                        label: Text('${t.prefix}${t.value}'),
                      ),
                  ],
                );
              }),
              const Divider(height: 24),
              const Text('Rendered SocialText:'),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SocialText(
                    text: _controller.text,
                    style: Theme.of(context).textTheme.bodyLarge,
                    styleMap: _styleMap,
                    triggers: triggers,
                    onTap: (token) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tapped ${token.full}')),
                      );
                    },
                    onLongPress: _useLongPress
                        ? (token) => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Long-pressed ${token.full}')),
                            )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

