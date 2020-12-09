import 'package:flutter/widgets.dart';

import 'model.dart';

class DeleteIntent extends Intent { }
class SelectAllIntent extends Intent { }
class DeselectAllIntent extends Intent { }
class UndoIntent extends Intent { }
class RedoIntent extends Intent { }

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

abstract class SelectedItemsAction<T extends Intent> extends ContextAction<T> {
  @protected
  void invokeAction(T intent, BuildContext context, Model model);

  @override
  Object? invoke(T intent, [BuildContext? context]) {
    final Model model = ModelBinding.of<Model>(context!);
    if (model.items.isNotEmpty) {
      invokeAction(intent, context, model);
    }
    return null;
  }
}

class MoveAction extends SelectedItemsAction<MoveIntent> {
  MoveAction(this.offset);

  final Offset offset;

  @override
  void invokeAction(MoveIntent intent, BuildContext context, Model model) {
    ModelBinding.update<Model>(context, model.moveSelectedItems(offset * intent.multiplier));
  }
}

class DeleteAction extends SelectedItemsAction<DeleteIntent> {
  @override
  void invokeAction(DeleteIntent intent, BuildContext context, Model model) {
    ModelBinding.update<Model>(context, model.removeSelectedItems());
  }
}

class SelectAllAction extends SelectedItemsAction<SelectAllIntent> {
  @override
  void invokeAction(SelectAllIntent intent, BuildContext context, Model model) {
    ModelBinding.update<Model>(context, model.selectAll());
  }
}

class DeselectAllAction extends SelectedItemsAction<DeselectAllIntent> {
  @override
  void invokeAction(DeselectAllIntent intent, BuildContext context, Model model) {
    ModelBinding.update<Model>(context, model.deselectAll());
  }
}

class UndoAction extends ContextAction<UndoIntent> {
  @override
  Object? invoke(UndoIntent intent, [BuildContext? context]) {
    ModelBinding.undo<Model>(context!);
    return null;
  }
}

class RedoAction extends ContextAction<RedoIntent> {
  @override
  Object? invoke(RedoIntent intent, [BuildContext? context]) {
    ModelBinding.redo<Model>(context!);
    return null;
  }
}
