# shortcut_sample

Demonstrates how shortcuts, Intents, and Actions can be used to bind mouse and keyboard events to application behavior.

## TODO

- Define shortcuts for the arrow keys which move the selected item. Control and shift modifiers should change the motions incremental x,y delta. If no item is selected, then the up/down arrow keys should scroll.
- Define shortcuts that move the selection to the next/previous item.
- Define an Action that means "addItemAt" and create a shortcut (maybe for space) that adds the Item somewhere that's not too surprising.
- Define an Action that deletes the selected item and create delete and backspace shortcuts for it.
- Define a way to bind mouse gestures to actions, notably "addItemAt" and "selectItemAt".
- Enable moving the focus to items and enable editing their labels.
- Support dragging items with the mouse.
- Support adding resize-handles to items (double click or long tap) and changing their size.
- Enable moving the selected item with the "w a s d" keyboard keys, as in many games.
- Enable multiple selection.
- Z-order: send forward/backwards to-front/to-back.
- Enable changing the selected item's color.
- Shortcuts that rearrange the items' layout in rows/columns (animation!).
