import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'actions.dart';
import 'model.dart';

class ItemView extends StatelessWidget {
  const ItemView({ Key? key, required this.item }) : super(key: key);

  final Item item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (TapUpDetails details) {
        final Model model = ModelBinding.of<Model>(context);
        ModelBinding.update<Model>(context, model.selectItem(item));
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
        label: 'Item ${model.items.length}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Model model = ModelBinding.of<Model>(context);
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.arrowLeft) : MoveLeftIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowRight) : MoveRightIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowUp) : MoveUpIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowDown) : MoveDownIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft, LogicalKeyboardKey.shift) : MoveLeftIntent(offsetMultiplier: 5.0),
        LogicalKeySet(LogicalKeyboardKey.arrowRight, LogicalKeyboardKey.shift) : MoveRightIntent(offsetMultiplier: 5.0),
        LogicalKeySet(LogicalKeyboardKey.arrowUp, LogicalKeyboardKey.shift) : MoveUpIntent(offsetMultiplier: 5.0),
        LogicalKeySet(LogicalKeyboardKey.arrowDown, LogicalKeyboardKey.shift) : MoveDownIntent(offsetMultiplier: 5.0),
      },
      child: Actions(
        actions: {
          MoveLeftIntent: MoveAction(
            model: model,
            offset: const Offset(-10, 0),
          ),
          MoveRightIntent: MoveAction(
            model: model,
            offset: const Offset(10, 0),
          ),
          MoveUpIntent: MoveAction(
            model: model,
            offset: const Offset(0, -10),
          ),
          MoveDownIntent: MoveAction(
            model: model,
            offset: const Offset(0, 10),
          )
        },
        child: Scaffold(
          body: Scrollbar(
            child: SingleChildScrollView(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (TapUpDetails details) {
                  ModelBinding.update<Model>(context, addItemAt(model, details.localPosition));
                },
                child: Container(
                  color: model.backgroundColor,
                  width: double.infinity,
                  height: model.height,
                  child: Stack(
                    children: model.items.map<Widget>((Item item) {
                      return Positioned.fromRect(
                        key: ValueKey<Item>(item),
                        rect: item.bounds,
                        child: ItemView(item: item),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          // TODO(goderbauer): If I remove the button, shortcuts don't work
          //  anymore, probably because focus is not below the shortcut widget then...
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.cleaning_services),
            onPressed: () {
              ModelBinding.update(context, model.copyWith(items: <Item>[]));
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      title: 'Shortcut Sample',
      theme: ThemeData.from(colorScheme: ColorScheme.light()),
      home: ModelBinding<Model>(
        initialModel: const Model(),
        child: ModelView(),
      ),
    ),
  );
}
