import 'social_token.dart';

/// A simple RegExp-based parser that extracts social tokens
/// like @mentions and #hashtags from a given text.
class SocialParser {
  /// Parses [text] and returns a list of [SocialToken]s for the given [triggers].
  ///
  /// - [triggers] is a list of prefixes to detect (e.g. ['@', '#', '$']).
  /// - [allowedCharsPattern] controls the characters after the prefix. Defaults to `[A-Za-z0-9_]+`.
  ///   Change only if you need a different set of valid token characters.
  static List<SocialToken> parse(
    String text, {
    List<String> triggers = const ['@', '#'],
    String allowedCharsPattern = r"[A-Za-z0-9_]+",
  }) {
    if (text.isEmpty) return const [];
    _validateTriggers(triggers);

    final regExp = tokenRegExp(
      triggers: triggers,
      allowedCharsPattern: allowedCharsPattern,
    );

    final result = <SocialToken>[];
    for (final match in regExp.allMatches(text)) {
      final prefix = match.group(1)!;
      final value = match.group(2)!;
      result.add(SocialToken(prefix, value, match.start, match.end));
    }
    return result;
  }

  /// Builds the [RegExp] used to find tokens for the given [triggers].
  ///
  /// The expression uses a negative lookbehind to ensure the prefix is not
  /// immediately preceded by a token character, which helps avoid matching
  /// inside emails and similar contexts (e.g. `test@example.com`).
  static RegExp tokenRegExp({
    required List<String> triggers,
    String allowedCharsPattern = r"[A-Za-z0-9_]+",
  }) {
    _validateTriggers(triggers);

    // Escape each trigger for regex usage.
    final escaped = triggers.map(RegExp.escape).join('');
    // Negative lookbehind to avoid mid-word matches, then capture prefix and token value.
    final pattern = '(?<![A-Za-z0-9_])([$escaped])($allowedCharsPattern)';

    // Use unicode: true for better handling of extended characters; the pattern itself
    // is ASCII-oriented by default but this ensures the engine is Unicode-aware.
    return RegExp(pattern, multiLine: true, unicode: true);
  }

  static void _validateTriggers(List<String> triggers) {
    assert(triggers.isNotEmpty, 'triggers cannot be empty');
    assert(
      triggers.every((t) => t.isNotEmpty),
      'Each trigger must be a non-empty string.',
    );
  }
}
