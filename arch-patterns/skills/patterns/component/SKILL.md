---
name: component-pattern
description: Split large classes into focused pieces and compose entities from reusable parts
---

# Component Pattern

Split a big class into focused pieces. Compose entities from reusable parts.

## When You Actually Need This

- **God class** - One class handles rendering, physics, input, networking...
- **Behavior reuse** - Player and Enemy share some behaviors but not others
- **Mix-and-match** - Different entity types need different combinations

## The Core Idea

Instead of one class doing everything, split by domain. An entity becomes a container of components.

```typescript
// Before: everything in one class
class Player {
  // Physics stuff
  x: number; y: number; velocity: Vector2;
  applyGravity() { ... }
  checkCollisions() { ... }

  // Rendering stuff
  sprite: Sprite;
  draw() { ... }

  // Input stuff
  handleInput() { ... }

  // Combat stuff
  health: number;
  takeDamage() { ... }
}

// After: focused components
class Entity {
  components = new Map<string, Component>();
  add<T extends Component>(c: T): T { ... }
  get<T extends Component>(type: string): T { ... }
}

// Each component owns one concern
const player = new Entity();
player.add(new Transform(100, 100));
player.add(new Physics({ gravity: true }));
player.add(new Sprite('player.png'));
player.add(new PlayerInput());
player.add(new Health(100));
```

## Minimal Implementation

```typescript
abstract class Component {
  entity: Entity | null = null;
  update?(dt: number): void;
}

class Entity {
  private components = new Map<Function, Component>();

  add<T extends Component>(component: T): T {
    this.components.set(component.constructor, component);
    component.entity = this;
    return component;
  }

  get<T extends Component>(type: new (...args: any[]) => T): T | undefined {
    return this.components.get(type) as T;
  }

  update(dt: number) {
    for (const c of this.components.values()) {
      c.update?.(dt);
    }
  }
}

// Reusable components
class Health extends Component {
  constructor(public current: number, public max: number = current) {}
  takeDamage(amount: number) { this.current -= amount; }
}

// Compose different entities
const player = new Entity();
player.add(new Transform(0, 0));
player.add(new Health(100));
player.add(new PlayerInput());

const enemy = new Entity();
enemy.add(new Transform(50, 50));
enemy.add(new Health(30));
enemy.add(new AIBehavior());
// Note: same Health component, different input
```

## When to Skip This

- **Small, focused classes** - If your class is already simple, don't split it
- **One-off entities** - Component overhead isn't worth it for unique things
- **Tight integration needed** - Sometimes things belong together

## Trade-offs

| You Get | You Pay |
|---------|---------|
| Focused, reusable pieces | More indirection |
| Easy to add/remove behaviors | Component communication is less direct |
| No deep inheritance hierarchies | Entity is just a bag, less clear structure |

## Component Communication

Components sometimes need to talk to each other:

```typescript
class Physics extends Component {
  update(dt: number) {
    // Get sibling component
    const transform = this.entity?.get(Transform);
    if (transform) {
      transform.x += this.velocity.x * dt;
    }
  }
}
```

Keep this communication simple. If components have complex interactions, maybe they should be one component.

## The Simpler Alternative

Sometimes inheritance or simple composition is fine:

```typescript
// If you only have a few entity types
class Player {
  transform = new Transform();
  health = new Health(100);
  input = new PlayerInput();

  update(dt: number) {
    this.input.update(dt);
    this.transform.update(dt);
  }
}
```

Use the full Component pattern when you need runtime flexibility (add/remove components) or many entity variations. Use simple composition when your entities are fixed.
