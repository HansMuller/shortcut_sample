import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Model {
  const Model({
    this.backgroundColor = Colors.green,
    this.height = 1000,
    this.items = const <Item>[],
  });

  final Color backgroundColor;
  final double height;
  final List<Item> items;

  Item? get selectedItem => items.cast<Item?>().firstWhere((Item? item) => item!.selected, orElse: () => null);

  Model addItem(Item item) {
    return copyWith(
      backgroundColor: backgroundColor,
      height: height,
      items: items + <Item>[item],
    );
  }

  Model removeItem(Item removedItem) {
    return copyWith(
      items: items.where((Item item) => item != removedItem).toList()
    );
  }

  Model toggleSelectionOfItem(Item selectedItem) {
    return copyWith(
      items: items.map((Item item) {
        if (item == selectedItem) {
          return item.copyWith(selected: !item.selected);
        }
        return item.selected ? item.copyWith(selected: false) : item;
      }).toList(),
    );
  }

  Model moveItem(Item movedItem, Offset offset) {
    return _replaceItem(
      toReplace: movedItem,
      replaceWith: movedItem.copyWith(bounds: movedItem.bounds.shift(offset)),
    );
  }

  Model _replaceItem({required Item toReplace, required Item replaceWith}) {
    return copyWith(
      items: items.map((Item item) {
        return item == toReplace ? replaceWith : item;
      }).toList(),
    );
  }

  Model copyWith({
    Color? backgroundColor,
    double? height,
    List<Item>? items,
  }) {
    return Model(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      height: height ?? this.height,
      items: items ?? this.items,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other))
      return true;
    if (other.runtimeType != runtimeType)
      return false;
    return other is Model
        && other.backgroundColor == backgroundColor
        && other.height == height
        && listEquals<Item>(other.items, items);
  }

  @override
  int get hashCode {
    return hashValues(
      backgroundColor,
      height,
      items,
    );
  }
}

class Item {
  const Item({
    required this.bounds,
    this.selected = false,
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
    this.label = "",
  });

  final Rect bounds;
  final bool selected;
  final Color backgroundColor;
  final Color foregroundColor;
  final String label;

  Item copyWith({
    Rect? bounds,
    bool? selected,
    Color? backgroundColor,
    Color? foregroundColor,
    String? label,
  }) {
    return Item(
      bounds: bounds ?? this.bounds,
      selected: selected ?? this.selected,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      label: label ?? this.label,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other))
      return true;
    if (other.runtimeType != runtimeType)
      return false;
    return other is Item
        && other.bounds == bounds
        && other.selected == selected
        && other.backgroundColor == backgroundColor
        && other.foregroundColor == foregroundColor
        && other.label == label;
  }

  @override
  int get hashCode {
    return hashValues(
      bounds,
      selected,
      backgroundColor,
      foregroundColor,
      label,
    );
  }
}

// The classes below were lifted from
// "Managing Flutter Application State With InheritedWidgets"
// https://medium.com/flutter/managing-flutter-application-state-with-inheritedwidgets-1140452befe1

class _ModelBindingScope<T> extends InheritedWidget {
  const _ModelBindingScope({
    Key? key,
    required this.modelBindingState,
    required Widget child
  }) : super(key: key, child: child);

  final _ModelBindingState<T> modelBindingState;

  @override
  bool updateShouldNotify(_ModelBindingScope oldWidget) => true;
}

class ModelBinding<T> extends StatefulWidget {
  ModelBinding({
    Key? key,
    required this.initialModel,
    required this.child,
  }) : assert(initialModel != null), super(key: key);

  final T initialModel;
  final Widget child;

  _ModelBindingState<T> createState() => _ModelBindingState<T>();

  static T of<T>(BuildContext context) {
    final _ModelBindingScope<T> scope = context.dependOnInheritedWidgetOfExactType<_ModelBindingScope<T>>()!;
    return scope.modelBindingState.currentModel;
  }

  static void update<T>(BuildContext context, T newModel) {
    final _ModelBindingScope<T> scope = context.dependOnInheritedWidgetOfExactType<_ModelBindingScope<T>>()!;
    scope.modelBindingState.updateModel(newModel);
  }
}

class _ModelBindingState<T> extends State<ModelBinding<T>> {
  late T currentModel;

  @override
  void initState() {
    super.initState();
    currentModel = widget.initialModel;
  }

  void updateModel(T newModel) {
    if (newModel != currentModel) {
      setState(() {
        currentModel = newModel;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ModelBindingScope<T>(
      modelBindingState: this,
      child: widget.child,
    );
  }
}
