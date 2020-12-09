import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum SelectionMode {
  set, // select an item, deselect all others
  add, // select an item if it's not selected already
  remove, // deselect an item if it's not selected already
  toggle, // toggle an item's selected flag
}

class Model {
  const Model({
    this.backgroundColor = Colors.green,
    this.height = 1000,
    this.items = const <Item>[],
  });

  final Color backgroundColor;
  final double height;
  final Iterable<Item> items;

  Iterable<Item> get selectedItems => items.where((Item item) => item.selected);

  Model addItem(Item item) {
    return copyWith(
      backgroundColor: backgroundColor,
      height: height,
      items: items.toList() + <Item>[item],
    );
  }

  Model selectItem(Item selectedItem, SelectionMode mode) {
    return copyWith(
      items: items.map((Item item) {
        late bool selected;
        if (item == selectedItem) {
          switch (mode) {
            case SelectionMode.set:
            case SelectionMode.add:
              selected = true;
              break;
            case SelectionMode.remove:
              selected = false;
              break;
            case SelectionMode.toggle:
              selected = !item.selected;
              break;
          }
        } else {
          switch (mode) {
            case SelectionMode.set:
              selected = false;
              break;
            case SelectionMode.add:
            case SelectionMode.remove:
            case SelectionMode.toggle:
              selected = item.selected;
              break;
          }
        }
        return item.selected == selected ? item : item.copyWith(selected: selected);
      }),
    );
  }

  Model _selectAll(bool selected) {
    return copyWith(
      items: items.map((Item item) {
        return item.selected == selected ? item : item.copyWith(selected: selected);
      }),
    );
  }
  Model selectAll() => _selectAll(true);
  Model deselectAll() => _selectAll(false);

  Model removeSelectedItems() {
    return copyWith(
      items: items.where((Item item) => !item.selected),
    );
  }

  Model moveSelectedItems(Offset offset) {
    return copyWith(
      items: items.map((Item item) {
        return item.selected ? item.copyWith(bounds: item.bounds.shift(offset)) : item;
      }),
    );
  }

  Model copyWith({
    Color? backgroundColor,
    double? height,
    Iterable<Item>? items,
  }) {
    return Model(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      height: height ?? this.height,
      items: items ?? this.items,
    );
  }

  bool _itemsEquals(Iterable<Item> a, Iterable<Item>b) {
    if (identical(a, b))
      return true;
    final Iterator<Item> iteratorA = a.iterator;
    final Iterator<Item> iteratorB = b.iterator;
    while(true) {
      final bool nextA = iteratorA.moveNext();
      final bool nextB = iteratorB.moveNext();
      if (nextA != nextB)
        return false;
      if (nextA && nextB && iteratorA.current != iteratorB.current)
        return false;
      if (!nextA && !nextB)
        return true;
    }
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
        && _itemsEquals(other.items, items);
  }

  @override
  int get hashCode {
    return hashValues(
      backgroundColor,
      height,
      items,
    );
  }

  @override
  String toString() => 'Model($items)';
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

  @override
  String toString() => 'Item("$label", selected=$selected)';
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

  static void undo<T>(BuildContext context) {
    final _ModelBindingScope<T> scope = context.dependOnInheritedWidgetOfExactType<_ModelBindingScope<T>>()!;
    return scope.modelBindingState.undo();
  }

  static void redo<T>(BuildContext context) {
    final _ModelBindingScope<T> scope = context.dependOnInheritedWidgetOfExactType<_ModelBindingScope<T>>()!;
    return scope.modelBindingState.redo();
  }
}

class _ModelBindingState<T> extends State<ModelBinding<T>> {
  late final List<T> models;
  int modelIndex = 0;

  T get currentModel => models[modelIndex];

  @override
  void initState() {
    super.initState();
    models = List<T>.from(<T>[widget.initialModel]);
  }

  void updateModel(T newModel) {
    if (newModel != models.last) {
      setState(() {
        assert(modelIndex + 1 <= models.length);
        modelIndex += 1;
        if (modelIndex == models.length) {
          models.add(newModel);
        } else {
          models[modelIndex] = newModel;
        }
      });
    }
  }

  void undo() {
    assert(modelIndex >= 0 && modelIndex < models.length);
    if (modelIndex > 0) {
      setState(() {
        modelIndex -= 1;
      });
    }
  }

  void redo() {
    assert(modelIndex >= 0 && modelIndex < models.length);
    if (modelIndex + 1 < models.length) {
      setState(() {
        modelIndex += 1;
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
