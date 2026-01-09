---
name: observer-pattern
description: Let objects react to changes without tight coupling between sender and receivers
---

# Observer Pattern

Let objects react to changes without the changing code knowing about them.

## When You Actually Need This

- **Cross-module communication** - UI needs to update when data changes, but data shouldn't know about UI
- **Plugin systems** - Core code emits events, plugins subscribe
- **Avoiding circular dependencies** - A and B need to communicate but shouldn't import each other

## The Core Idea

The thing that changes (Subject) doesn't know who's listening. Listeners (Observers) subscribe and react.

```typescript
// Without Observer: tight coupling
class Player {
  takeDamage(amount: number) {
    this.health -= amount;
    ui.updateHealthBar(this.health);     // Player knows about UI
    audio.playSound('hurt');              // Player knows about audio
    achievements.check('took_damage');    // Player knows about achievements
  }
}

// With Observer: decoupled
class Player {
  readonly onDamaged = new EventEmitter<{ health: number, amount: number }>();

  takeDamage(amount: number) {
    this.health -= amount;
    this.onDamaged.emit({ health: this.health, amount });
  }
}

// Elsewhere, independently:
player.onDamaged.subscribe(e => ui.updateHealthBar(e.health));
player.onDamaged.subscribe(e => audio.playSound('hurt'));
player.onDamaged.subscribe(e => achievements.check('took_damage'));
```

## Minimal Implementation

```typescript
type Listener<T> = (event: T) => void;

class EventEmitter<T> {
  private listeners = new Set<Listener<T>>();

  subscribe(listener: Listener<T>): () => void {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);  // Unsubscribe function
  }

  emit(event: T) {
    this.listeners.forEach(listener => listener(event));
  }
}
```

## When to Skip This

- **Within a single module** - Just call the function directly
- **One-to-one communication** - Observer is for one-to-many
- **When you need to trace what happens** - Observer makes flow harder to follow

The introduction warns:
> *"It takes you forever to trace through all of that scaffolding to find some real code that does something."*

Only use Observer across module boundaries where decoupling genuinely helps.

## Trade-offs

| You Get | You Pay |
|---------|---------|
| Loose coupling | Harder to trace execution flow |
| Easy to add new listeners | Memory leaks if you forget to unsubscribe |
| Sender doesn't know receivers | Debugging "why did X happen?" is harder |

## Common Pitfalls

1. **Forgetting to unsubscribe** - Causes memory leaks
2. **Observer doing too much** - Keep handlers simple
3. **Circular notifications** - A notifies B notifies A...
4. **Using it everywhere** - Reserve for module boundaries

## The Simpler Alternative

Sometimes a callback is enough:

```typescript
// If there's only one listener, just use a callback
class DataLoader {
  onComplete?: (data: Data) => void;

  load() {
    // ...
    this.onComplete?.(data);
  }
}
```

Use Observer when you have multiple independent listeners. Use callbacks for single handlers.
