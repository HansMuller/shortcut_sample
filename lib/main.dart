import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'actions.dart';
import 'model.dart';

class ItemView extends StatelessWidget {
  const ItemView({ Key? key, required this.item }) : super(key: key);

  final Item item;

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: {
        MoveLeftIntent: MoveAction(
          item: item,
          offset: const Offset(-10, 0),
        ),
        MoveRightIntent: MoveAction(
          item: item,
          offset: const Offset(10, 0),
        ),
        MoveUpIntent: MoveAction(
          item: item,
          offset: const Offset(0, -10),
        ),
        MoveDownIntent: MoveAction(
          item: item,
          offset: const Offset(0, 10),
        )
      },
      child: Focus(
        child: Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (Focus.of(context).hasFocus) {
                  Focus.of(context).unfocus();
                } else {
                  Focus.of(context).requestFocus();
                }
              },
              child: Material(
                color: item.backgroundColor,
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: Focus.of(context).hasFocus ? BorderSide(width: 2, color: Colors.blue) : BorderSide.none,
                ),
                child: Center(
                  child: Text(item.label),
                ),
              ),
            );
          },
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
    return Scaffold(
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
                    rect: item.bounds,
                    child: ItemView(item: item),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.cleaning_services),
        onPressed: () {
          ModelBinding.update(context, model.copyWith(items: <Item>[]));
        },
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      // TODO(goderbauer): Is this the right place to define the shortcuts? What about the defaults?
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
      title: 'Shortcut Sample',
      theme: ThemeData.from(colorScheme: ColorScheme.light()),
      home: ModelBinding<Model>(
        initialModel: const Model(),
        child: ModelView(),
      ),
    ),
  );
}
