---
name: command-pattern
description: Turn actions into objects for undo/redo, history, queuing, or rebindable controls
---

# Command Pattern

Turn actions into objects you can store, queue, undo, or replay.

## When You Actually Need This

- **Undo/redo** - You need to reverse actions
- **Action history** - You want to replay or log what happened
- **Queuing** - Actions should wait or batch
- **Rebindable controls** - Users customize which keys do what

## The Core Idea

Instead of calling methods directly, wrap each action in an object:

```typescript
// Before: direct call, can't undo
editor.deleteSelection();

// After: action as object
const command = new DeleteSelectionCommand(editor);
command.execute();
history.push(command);  // Now you can undo
```

## Minimal Implementation

```typescript
interface Command {
  execute(): void;
  undo(): void;
}

class DeleteTextCommand implements Command {
  private deletedText: string;

  constructor(private editor: Editor, private start: number, private end: number) {}

  execute() {
    this.deletedText = this.editor.getText(this.start, this.end);
    this.editor.delete(this.start, this.end);
  }

  undo() {
    this.editor.insert(this.start, this.deletedText);
  }
}

// Undo stack
const history: Command[] = [];

function doCommand(cmd: Command) {
  cmd.execute();
  history.push(cmd);
}

function undo() {
  const cmd = history.pop();
  cmd?.undo();
}
```

## When to Skip This

- You don't need undo/redo
- Actions are fire-and-forget
- The "pattern" would just wrap simple function calls with no benefit

If you're adding Command "for flexibility" without a concrete use case, you're probably over-engineering.

## Trade-offs

| You Get | You Pay |
|---------|---------|
| Undo/redo | More objects, more memory |
| Action history | Commands must store enough state to reverse |
| Rebindable input | Indirection between input and action |
| Queueable actions | Slightly more complex execution flow |

## The Simpler Alternative

Often, just saving state snapshots is simpler than implementing undo for every action:

```typescript
// Sometimes this is enough
const snapshots: EditorState[] = [];
function checkpoint() { snapshots.push(editor.getState()); }
function undo() { editor.setState(snapshots.pop()); }
```

Use Command when you need granular action-level control. Use snapshots when you just need to go back.
