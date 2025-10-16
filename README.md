<div align="center">

# social_text

[![pub package](https://img.shields.io/pub/v/social_text.svg)](https://pub.dev/packages/social_text)

Detect, style and interact with social tokens like @mentions, #hashtags, and custom prefixes in Flutter.

</div>

## Features

- Parse tokens for any prefix: `@`, `#`, `$`, `%`, or custom
- Style per-trigger via `styleMap`
- Tappable tokens with `onTap(SocialToken)`
- Optional `onLongPress(SocialToken)`
- Preserves plain text between tokens and line wrapping
- Simple parser helper: `SocialParser.parse()`

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:social_text/social_text.dart';

class Demo extends StatelessWidget {
  const Demo({super.key});
  @override
  Widget build(BuildContext context) {
    return SocialText(
      text: 'Hello @flutterdev! Love #opensource projects.',
      triggers: ['@', '#'],
      style: const TextStyle(fontSize: 16),
      styleMap: const {
        '@': TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        '#': TextStyle(color: Colors.green),
      },
      onTap: (token) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Tapped ${token.full}')));
      },
    );
  }
}
```

## API Overview

```dart
class SocialToken {
  final String prefix; // e.g. '@'
  final String value;  // e.g. 'flutterdev'
  final int start;     // token start index in text
  final int end;       // token end index in text (exclusive)
  const SocialToken(this.prefix, this.value, this.start, this.end);
}

// Parse only
final tokens = SocialParser.parse('Hey @flutterdev check out #flutter!',
  triggers: ['@', '#'],
);

// Build interactive text
SocialText(
  text: 'Hey @flutterdev check out #flutter and \$dart!',
  triggers: ['@', '#', r'$'],
  style: const TextStyle(color: Colors.black87),
  styleMap: const {
    '@': TextStyle(color: Colors.blue),
    '#': TextStyle(color: Colors.purple),
    r'$': TextStyle(color: Colors.teal),
  },
  onTap: (token) => debugPrint('Tapped ${token.full}'),
  onLongPress: (token) => debugPrint('Long-pressed ${token.full}'),
)
```

## Notes

- Uses `RichText` + `TextSpan` under the hood; when both `onTap` and
  `onLongPress` are provided, tokens use `WidgetSpan + GestureDetector` to support both.
- Default token characters are `[A-Za-z0-9_]+`. Override by using your own
  RegExp via `SocialParser.tokenRegExp(triggers: ..., allowedCharsPattern: ...)` if needed.
- Emojis and multi-byte characters are preserved; token indices are Dart string code-unit indices.

## Example App

See `example/lib/main.dart` for a runnable demo that shows:
- Multiple triggers
- Per-trigger styles
- Tap callbacks showing a `SnackBar`

Run it with:

```
cd example
flutter run
```

