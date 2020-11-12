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
  MoveAction({required this.model, required this.offset});

  final Model model;
  final Offset offset;

  @override
  bool isEnabled(MoveIntent intent) => model.selectedItem != null;

  @override
  void invoke(MoveIntent intent, [BuildContext? context]) {
    final Item selectedItem = model.selectedItem!;
    ModelBinding.update(context!, model.replaceItem(
      oldItem: selectedItem,
      newItem: selectedItem.copyWith(
        bounds: selectedItem.bounds.shift(offset * intent.offsetMultiplier),
      ),
    ));
  }
}
