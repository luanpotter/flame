part of flame_oxygen.component;

class AnchorComponent extends Component<Anchor> {
  late Anchor anchor;

  @override
  void init([Anchor? anchor]) => this.anchor = anchor ?? Anchor.topLeft;

  @override
  void reset() => anchor = Anchor.topLeft;
}
