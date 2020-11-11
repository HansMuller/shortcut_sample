
import 'package:flutter/material.dart';

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
