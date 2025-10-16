import 'package:flutter_test/flutter_test.dart';
import 'package:social_text/social_text.dart';

void main() {
  test('parses tokens with multiple triggers', () {
    const text = 'Hey @chandra check out #flutter and \$dart';
    final tokens = SocialParser.parse(text, triggers: ['@', '#', r'$']);

    expect(tokens.length, 3);
    expect(tokens[0].full, '@chandra');
    expect(tokens[1].full, '#flutter');
    final dollar = tokens.firstWhere((t) => t.prefix == r'$');
    expect(dollar.value, 'dart');
  });
}

