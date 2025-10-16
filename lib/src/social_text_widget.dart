import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'social_parser.dart';
import 'social_token.dart';

typedef SocialTokenTap = void Function(SocialToken token);

/// Displays text with social tokens (e.g., @mentions, #hashtags) parsed and
/// stylable per trigger. Tokens are optionally tappable and long-pressable.
class SocialText extends StatefulWidget {
  final String text;
  final List<String> triggers;
  final Map<String, TextStyle> styleMap;
  final TextStyle? style;
  final TextStyle? defaultTokenStyle;
  final SocialTokenTap? onTap;
  final SocialTokenTap? onLongPress;

  // RichText pass-throughs
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final int? maxLines;
  final StrutStyle? strutStyle;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final TextScaler? textScaler;

  const SocialText({
    super.key,
    required this.text,
    this.triggers = const ['@', '#'],
    this.styleMap = const {},
    this.style,
    this.defaultTokenStyle,
    this.onTap,
    this.onLongPress,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.maxLines,
    this.strutStyle,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.textScaler,
  });

  @override
  State<SocialText> createState() => _SocialTextState();
}

class _SocialTextState extends State<SocialText> {
  final List<GestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    _clearRecognizers();
    super.dispose();
  }

  void _clearRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  TextStyle _composeTokenStyle(String prefix) {
    TextStyle style = widget.style ?? const TextStyle();
    if (widget.defaultTokenStyle != null) {
      style = style.merge(widget.defaultTokenStyle);
    }
    final perTrigger = widget.styleMap[prefix];
    if (perTrigger != null) {
      style = style.merge(perTrigger);
    }
    return style;
  }

  InlineSpan _buildTokenSpan(SocialToken token) {
    final tokenText = token.full;
    final style = _composeTokenStyle(token.prefix);

    final hasTap = widget.onTap != null;
    final hasLong = widget.onLongPress != null;

    if (!hasTap && !hasLong) {
      return TextSpan(text: tokenText, style: style);
    }

    if (hasTap && hasLong) {
      // Use a WidgetSpan to support both tap and long-press simultaneously.
      return WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => widget.onTap?.call(token),
          onLongPress: () => widget.onLongPress?.call(token),
          child: Text(tokenText, style: style),
        ),
      );
    }

    // Only one recognizer needed; manage lifecycle explicitly.
    if (hasTap) {
      final recognizer = TapGestureRecognizer()
        ..onTap = () => widget.onTap?.call(token);
      _recognizers.add(recognizer);
      return TextSpan(text: tokenText, style: style, recognizer: recognizer);
    } else {
      final recognizer = LongPressGestureRecognizer()
        ..onLongPress = () => widget.onLongPress?.call(token);
      _recognizers.add(recognizer);
      return TextSpan(text: tokenText, style: style, recognizer: recognizer);
    }
  }

  List<InlineSpan> _buildSpans() {
    _clearRecognizers();

    final tokens = SocialParser.parse(widget.text, triggers: widget.triggers);
    final spans = <InlineSpan>[];

    int cursor = 0;
    for (final t in tokens) {
      if (t.start > cursor) {
        spans.add(TextSpan(
          text: widget.text.substring(cursor, t.start),
          style: widget.style,
        ));
      }
      spans.add(_buildTokenSpan(t));
      cursor = t.end;
    }

    if (cursor < widget.text.length) {
      spans.add(TextSpan(
        text: widget.text.substring(cursor),
        style: widget.style,
      ));
    }

    // Handle empty string case to preserve layout.
    if (spans.isEmpty) {
      spans.add(TextSpan(text: '', style: widget.style));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = widget.textDirection ?? Directionality.maybeOf(context);
    return RichText(
      textAlign: widget.textAlign ?? TextAlign.start,
      textDirection: textDirection,
      locale: widget.locale,
      softWrap: widget.softWrap ?? true,
      overflow: widget.overflow ?? TextOverflow.clip,
      maxLines: widget.maxLines,
      textScaler: widget.textScaler ?? MediaQuery.textScalerOf(context),
      textWidthBasis: widget.textWidthBasis ?? TextWidthBasis.parent,
      textHeightBehavior: widget.textHeightBehavior,
      strutStyle: widget.strutStyle,
      text: TextSpan(children: _buildSpans(), style: widget.style),
    );
  }
}
