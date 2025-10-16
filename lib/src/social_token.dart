import 'package:flutter/foundation.dart';

/// Represents a detected social token like @mention or #hashtag.
@immutable
class SocialToken {
  final String prefix;
  final String value;
  final int start;
  final int end;

  const SocialToken(this.prefix, this.value, this.start, this.end)
      : assert(prefix.length >= 1),
        assert(start >= 0),
        assert(end >= start);

  String get full => '$prefix$value';

  @override
  String toString() => 'SocialToken(prefix: $prefix, value: $value, start: $start, end: $end)';

  @override
  bool operator ==(Object other) {
    return other is SocialToken &&
        other.prefix == prefix &&
        other.value == value &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(prefix, value, start, end);
}

