import 'package:flutter/widgets.dart';

import 'model.dart';

abstract class MoveIntent extends Intent {
  MoveIntent({this.offsetMultiplier = 1.0});

  final double offsetMultiplier;
}

class MoveUpIntent extends MoveIntent {
  MoveUpIntent({double offsetMultiplier = 1.0}) : super(offsetMultiplier: offsetMultiplier);
}
class MoveDownIntent extends MoveIntent {
  MoveDownIntent({double offsetMultiplier = 1.0}) : super(offsetMultiplier: offsetMultiplier);
}
class MoveLeftIntent extends MoveIntent {
  MoveLeftIntent({double offsetMultiplier = 1.0}) : super(offsetMultiplier: offsetMultiplier);
}
class MoveRightIntent extends MoveIntent {
  MoveRightIntent({double offsetMultiplier = 1.0}) : super(offsetMultiplier: offsetMultiplier);
}

class MoveAction extends ContextAction<MoveIntent> {
  MoveAction({required this.item, required this.offset});

  final Item item;
  final Offset offset;

  @override
  void invoke(MoveIntent intent, [BuildContext? context]) {
    final Model model = ModelBinding.of<Model>(context!);
    ModelBinding.update(context, model.replaceItem(
      oldItem: item,
      newItem: item.copyWith(
        bounds: item.bounds.shift(offset * intent.offsetMultiplier),
      ),
    ));
  }
}
