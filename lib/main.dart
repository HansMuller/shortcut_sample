import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'actions.dart';
import 'model.dart';

int nextItemIndex = 0;

class ItemView extends StatelessWidget {
  const ItemView({ Key? key, required this.item }) : super(key: key);

  final Item item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (TapUpDetails details) {
        final Set<LogicalKeyboardKey> modifiers = LogicalKeyboardKey.collapseSynonyms(RawKeyboard.instance.keysPressed);
        final Model model = ModelBinding.of<Model>(context);
        late final Model updatedModel;
        if (modifiers.contains(LogicalKeyboardKey.shift)) {
          updatedModel = model.selectItem(item, SelectionMode.add);
        } else if (modifiers.contains(LogicalKeyboardKey.control)) {
          updatedModel = model.selectItem(item, SelectionMode.remove);
        } else if (modifiers.contains(LogicalKeyboardKey.alt)) {
          updatedModel = model.selectItem(item, SelectionMode.set);
        } else {
          updatedModel = model.selectItem(item, SelectionMode.toggle);
        }
        ModelBinding.update<Model>(context,updatedModel);
      },
      child: Material(
        color: item.backgroundColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: item.selected ? BorderSide(width: 2, color: Colors.blue) : BorderSide.none,
        ),
        child: Center(
          child: Text(item.label),
        ),
      ),
    );
  }
}

class ModelView extends StatelessWidget {
  Model addItemAt(Model model, Offset offset) {
    return model.addItem(
      Item(
        bounds: offset & Size(96, 32),
        label: 'Item ${nextItemIndex++}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Model model = ModelBinding.of<Model>(context);
    return Scaffold(
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Actions(
            actions: {
              MoveLeftIntent: MoveAction(const Offset(-10, 0)),
              MoveRightIntent: MoveAction(const Offset(10, 0)),
              MoveUpIntent: MoveAction(const Offset(0, -10)),
              MoveDownIntent: MoveAction(const Offset(0, 10)),
              DeleteIntent: DeleteAction(),
              SelectAllIntent: SelectAllAction(),
              DeselectAllIntent: DeselectAllAction(),
              UndoIntent: UndoAction(),
              RedoIntent: RedoAction(),
            },
            child: Focus(
              child: Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (TapUpDetails details) {
                      ModelBinding.update<Model>(context, addItemAt(model, details.localPosition));
                      Focus.of(context).requestFocus();
                    },
                    child: Container(
                      color: model.backgroundColor,
                      width: double.infinity,
                      height: model.height,
                      child: Stack(
                        children: model.items.map<Widget>((Item item) {
                          return Positioned.fromRect(
                            rect: item.bounds,
                            child: ItemView(item: item),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.arrowLeft) : MoveLeftIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowRight) : MoveRightIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowUp) : MoveUpIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowDown) : MoveDownIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft, LogicalKeyboardKey.shift) : MoveLeftIntent(multiplier: 5.0),
        LogicalKeySet(LogicalKeyboardKey.arrowRight, LogicalKeyboardKey.shift) : MoveRightIntent(multiplier: 5.0),
        LogicalKeySet(LogicalKeyboardKey.arrowUp, LogicalKeyboardKey.shift) : MoveUpIntent(multiplier: 5.0),
        LogicalKeySet(LogicalKeyboardKey.arrowDown, LogicalKeyboardKey.shift) : MoveDownIntent(multiplier: 5.0),
        LogicalKeySet(LogicalKeyboardKey.keyD) : DeleteIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyA, LogicalKeyboardKey.shift, LogicalKeyboardKey.control) : DeselectAllIntent(), // FAILS
        LogicalKeySet(LogicalKeyboardKey.keyA, LogicalKeyboardKey.control) : SelectAllIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyZ, LogicalKeyboardKey.control) : UndoIntent(),
        LogicalKeySet(LogicalKeyboardKey.keyY, LogicalKeyboardKey.control) : RedoIntent(),
      },
      title: 'Shortcut Sample',
      theme: ThemeData.from(colorScheme: ColorScheme.light()),
      home: ModelBinding<Model>(
        initialModel: const Model(),
        child: ModelView(),
      ),
    ),
  );
}
