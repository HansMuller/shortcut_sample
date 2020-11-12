import 'package:flutter/widgets.dart';

import 'model.dart';

abstract class MoveIntent extends Intent {
  MoveIntent({this.multiplier = 1.0});

  final double multiplier;
}

class MoveUpIntent extends MoveIntent {
  MoveUpIntent({double multiplier = 1.0}) : super(multiplier: multiplier);
}
class MoveDownIntent extends MoveIntent {
  MoveDownIntent({double multiplier = 1.0}) : super(multiplier: multiplier);
}
class MoveLeftIntent extends MoveIntent {
  MoveLeftIntent({double multiplier = 1.0}) : super(multiplier: multiplier);
}
class MoveRightIntent extends MoveIntent {
  MoveRightIntent({double multiplier = 1.0}) : super(multiplier: multiplier);
}

class DeleteIntent extends Intent { }

class MoveAction extends ContextAction<MoveIntent> {
  MoveAction({required this.offset});

  final Offset offset;

  @override
  Object invoke(MoveIntent intent, [BuildContext? context]) {
    final Model model = ModelBinding.of<Model>(context!);
    if (model.selectedItem != null) {
      ModelBinding.update(context, model.moveItem(model.selectedItem!, offset * intent.multiplier));
    }
    // TODO(goderbauer): remove this after https://github.com/flutter/flutter/pull/70397 landed.
    return Object();
  }
}
