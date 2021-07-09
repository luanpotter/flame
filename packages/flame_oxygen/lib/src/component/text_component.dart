part of flame_oxygen.component;

class TextInit {
  final String text;

  TextPaintConfig? config;

  TextInit(
    this.text, {
    this.config,
  });
}

class TextComponent extends Component<TextInit> {
  late String text;

  late TextPaintConfig config;

  @override
  void init([TextInit? initValue]) {
    config = initValue?.config ?? const TextPaintConfig();
    text = initValue?.text ?? '';
  }

  @override
  void reset() {
    config = const TextPaintConfig();
    text = '';
  }
}
