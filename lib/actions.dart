import 'package:flutter/widgets.dart';

import 'model.dart';

class DeleteIntent extends Intent { }
class SelectAllIntent extends Intent { }
class DeselectAllIntent extends Intent { }

abstract class MoveIntent extends Intent {
  MoveIntent({ this.multiplier = 1.0 });

  final double multiplier;
}

class MoveUpIntent extends MoveIntent {
  MoveUpIntent({ double multiplier = 1.0 }) : super(multiplier: multiplier);
}
class MoveDownIntent extends MoveIntent {
  MoveDownIntent({ double multiplier = 1.0 }) : super(multiplier: multiplier);
}
class MoveLeftIntent extends MoveIntent {
  MoveLeftIntent({ double multiplier = 1.0 }) : super(multiplier: multiplier);
}
class MoveRightIntent extends MoveIntent {
  MoveRightIntent({ double multiplier = 1.0 }) : super(multiplier: multiplier);
}

class MoveAction extends ContextAction<MoveIntent> {
  MoveAction({ required this.offset });

  final Offset offset;

  @override
  Object? invoke(MoveIntent intent, [BuildContext? context]) {
    final Model model = ModelBinding.of<Model>(context!);
    ModelBinding.update(context, model.moveSelectedItems(offset * intent.multiplier));
    return null;
  }
}
