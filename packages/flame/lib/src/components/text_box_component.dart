import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/widgets.dart' hide Image;

import '../extensions/vector2.dart';
import '../palette.dart';
import '../text.dart';
import 'position_component.dart';

/// A set of configurations for the [TextBoxComponent] itself (as opposed to
/// the [TextRenderer], that contains the configuration for how to render the
/// text only (font size, color, family, etc)).
class TextBoxConfig {
  /// Max width this paragraph can take. Lines will be broken trying to respect
  /// word boundaries in as many lines as necessary.
  final double maxWidth;

  /// Margins of the text box w.r.t the [TextBoxComponent.size].
  final EdgeInsets margins;

  /// Defaults to 0. If not zero the characters will appear one by one giving
  /// a typying effect to the text box, and this will be the delay in seconds
  /// between each char.
  final double timePerChar;

  /// Defaults to 9. If not zero, this component will disapear this amount of
  /// seconds after being completed (if [timePerChar] is set) or after first
  /// appearing (otherwise).
  final double dismissDelay;

  /// Only relevant if [timePerChar] is set. If true, the box will start with
  /// the size to fit the first character and grow as more lines are typed.
  /// If false, the box will start with the full necessary size from the
  /// beginning (both width and height).
  final bool growingBox;

  TextBoxConfig({
    this.maxWidth = 200.0,
    this.margins = const EdgeInsets.all(8.0),
    this.timePerChar = 0.0,
    this.dismissDelay = 0.0,
    this.growingBox = false,
  });
}

class TextBoxComponent<T extends TextRenderer> extends PositionComponent {
  static final Paint _imagePaint = BasicPalette.white.paint()
    ..filterQuality = FilterQuality.high;

  final String _text;
  final T _textRenderer;
  final TextBoxConfig _boxConfig;

  late List<String> _lines;
  double _maxLineWidth = 0.0;
  late double _lineHeight;
  late int _totalLines;

  double _lifeTime = 0.0;
  Image? _cache;
  int? _previousChar;

  String get text => _text;

  TextRenderer get renderer => _textRenderer;

  TextBoxConfig get boxConfig => _boxConfig;

  TextBoxComponent(
    String text, {
    T? textRenderer,
    TextBoxConfig? boxConfig,
    Vector2? position,
    Vector2? size,
    int? priority,
  })  : _text = text,
        _boxConfig = boxConfig ?? TextBoxConfig(),
        _textRenderer = textRenderer ?? TextRenderer.createDefault<T>(),
        super(position: position, size: size, priority: priority) {
    _lines = [];
    double? lineHeight;
    text.split(' ').forEach((word) {
      final possibleLine = _lines.isEmpty ? word : '${_lines.last} $word';
      lineHeight ??= _textRenderer.measureTextHeight(possibleLine);

      final textWidth = _textRenderer.measureTextWidth(possibleLine);
      if (textWidth <= _boxConfig.maxWidth - _boxConfig.margins.horizontal) {
        if (_lines.isNotEmpty) {
          _lines.last = possibleLine;
        } else {
          _lines.add(possibleLine);
        }
        _updateMaxWidth(textWidth);
      } else {
        _lines.add(word);
        _updateMaxWidth(textWidth);
      }
    });
    _totalLines = _lines.length;
    _lineHeight = lineHeight ?? 0.0;
  }

  void _updateMaxWidth(double w) {
    if (w > _maxLineWidth) {
      _maxLineWidth = w;
    }
  }

  double get totalCharTime => _text.length * _boxConfig.timePerChar;

  bool get finished => _lifeTime > totalCharTime + _boxConfig.dismissDelay;

  int get _actualTextLength {
    return _lines.map((e) => e.length).fold(0, (p, c) => p + c);
  }

  int get currentChar => _boxConfig.timePerChar == 0.0
      ? _actualTextLength
      : math.min(_lifeTime ~/ _boxConfig.timePerChar, _actualTextLength);

  int get currentLine {
    var totalCharCount = 0;
    final _currentChar = currentChar;
    for (var i = 0; i < _lines.length; i++) {
      totalCharCount += _lines[i].length;
      if (totalCharCount > _currentChar) {
        return i;
      }
    }
    return _lines.length - 1;
  }

  @override
  Vector2 get size => Vector2(width, height);

  double getLineWidth(String line, int charCount) {
    return _textRenderer.measureTextWidth(
      line.substring(0, math.min(charCount, line.length)),
    );
  }

  double? _cachedWidth;

  @override
  double get width {
    if (_cachedWidth != null) {
      return _cachedWidth!;
    }
    if (_boxConfig.growingBox) {
      var i = 0;
      var totalCharCount = 0;
      final _currentChar = currentChar;
      final _currentLine = currentLine;
      final textWidth = _lines.sublist(0, _currentLine + 1).map((line) {
        final charCount =
            (i < _currentLine) ? line.length : (_currentChar - totalCharCount);
        totalCharCount += line.length;
        i++;
        return getLineWidth(line, charCount);
      }).reduce(math.max);
      _cachedWidth = textWidth + _boxConfig.margins.horizontal;
    } else {
      _cachedWidth = _boxConfig.maxWidth + _boxConfig.margins.horizontal;
    }
    return _cachedWidth!;
  }

  @override
  double get height {
    if (_boxConfig.growingBox) {
      return _lineHeight * _lines.length + _boxConfig.margins.vertical;
    } else {
      return _lineHeight * _totalLines + _boxConfig.margins.vertical;
    }
  }

  @override
  void render(Canvas c) {
    if (_cache == null) {
      return;
    }
    super.render(c);
    final devicePixelRatio = window.devicePixelRatio;
    c.save();
    c.scale(1 / devicePixelRatio);
    c.drawImage(_cache!, Offset.zero, _imagePaint);
    c.restore();
  }

  Future<Image> _redrawCache() {
    final devicePixelRatio = window.devicePixelRatio;
    final recorder = PictureRecorder();
    final c = Canvas(recorder, size.toRect());
    c.scale(devicePixelRatio);
    _fullRender(c);
    return recorder.endRecording().toImage(
          (width * devicePixelRatio).ceil(),
          (height * devicePixelRatio).ceil(),
        );
  }

  /// Override this method to provide a custom background to the text box.
  void drawBackground(Canvas c) {}

  void _fullRender(Canvas c) {
    drawBackground(c);

    final _currentLine = currentLine;
    var charCount = 0;
    var dy = _boxConfig.margins.top;
    for (var line = 0; line < _currentLine; line++) {
      charCount += _lines[line].length;
      _drawLine(c, _lines[line], dy);
      dy += _lineHeight;
    }
    final max = math.min(currentChar - charCount, _lines[_currentLine].length);
    _drawLine(c, _lines[_currentLine].substring(0, max), dy);
  }

  void _drawLine(Canvas c, String line, double dy) {
    _textRenderer.render(c, line, Vector2(_boxConfig.margins.left, dy));
  }

  void redrawLater() async {
    _cache = await _redrawCache();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifeTime += dt;
    if (_previousChar != currentChar) {
      _cachedWidth = null;
      redrawLater();
    }
    _previousChar = currentChar;
  }
}
