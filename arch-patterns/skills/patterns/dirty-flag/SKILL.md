---
name: dirty-flag-pattern
description: Avoid expensive recalculations by marking data as dirty and only updating when needed
---

# Dirty Flag Pattern

Avoid recalculating things that haven't changed. Mark data as "dirty" when it changes, recalculate only when needed.

## When You Actually Need This

- **Expensive derived calculations** - World transforms, layout, compiled queries
- **Changes happen more often than reads** - User edits frequently, render happens once per frame
- **Cascading updates** - Parent changes affect all children

## The Core Idea

Track whether source data changed. Only recalculate the result when actually needed.

```typescript
// Before: recalculate every time
class Node {
  getWorldTransform(): Matrix {
    // Recalculates entire chain every call, even if nothing changed
    return this.parent
      ? this.parent.getWorldTransform().multiply(this.localTransform)
      : this.localTransform;
  }
}

// After: only recalculate when dirty
class Node {
  private localTransform: Matrix;
  private worldTransform: Matrix | null = null;
  private dirty = true;

  setPosition(x: number, y: number) {
    this.localTransform = Matrix.translate(x, y);
    this.markDirty();
  }

  private markDirty() {
    if (!this.dirty) {
      this.dirty = true;
      this.worldTransform = null;
      for (const child of this.children) {
        child.markDirty();  // Cascade to children
      }
    }
  }

  getWorldTransform(): Matrix {
    if (this.dirty) {
      this.worldTransform = this.parent
        ? this.parent.getWorldTransform().multiply(this.localTransform)
        : this.localTransform;
      this.dirty = false;
    }
    return this.worldTransform!;
  }
}
```

## Minimal Implementation

```typescript
class Computed<T> {
  private value: T | null = null;
  private dirty = true;

  constructor(private compute: () => T) {}

  invalidate() {
    this.dirty = true;
    this.value = null;
  }

  get(): T {
    if (this.dirty) {
      this.value = this.compute();
      this.dirty = false;
    }
    return this.value!;
  }
}

// Usage
const expensiveResult = new Computed(() => {
  // Complex calculation here
  return calculateSomethingExpensive();
});

// Later, when source data changes
expensiveResult.invalidate();

// Only recalculates when actually accessed
const result = expensiveResult.get();
```

## When to Skip This

- **Cheap calculations** - If it's fast, just recalculate
- **Read-heavy workloads** - If you read more than write, caching might be simpler
- **Simple values** - Dirty flags add complexity; make sure it's worth it

## Trade-offs

| You Get | You Pay |
|---------|---------|
| Skip unnecessary work | Must mark dirty on every change |
| Lazy evaluation | Latency spike when finally recalculating |
| Efficient hierarchies | Complexity in tracking what affects what |

## Common Pitfalls

1. **Forgetting to mark dirty** - One missed path = stale data bugs
2. **Over-granular flags** - Sometimes cheaper to just recalculate
3. **Deep hierarchies** - Marking dirty can cascade expensively

## Real-World Examples

**React** - Components re-render only when props/state change (conceptually similar)

**CSS Layout** - Browser only recalculates layout for dirty subtrees

**Scene graphs** - 3D engines cache world transforms until local changes

## The Simpler Alternative

Often, just caching the last input is enough:

```typescript
class CachedCalculation {
  private lastInput: Input | null = null;
  private lastResult: Result | null = null;

  calculate(input: Input): Result {
    if (this.lastInput === input) {
      return this.lastResult!;
    }
    this.lastInput = input;
    this.lastResult = expensiveCalculation(input);
    return this.lastResult;
  }
}
```

Use Dirty Flag when you have hierarchical invalidation or complex dependency chains. Use simple caching for single-input calculations.
