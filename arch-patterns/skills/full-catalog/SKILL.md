---
name: full-catalog
description: Comprehensive reference of 20 architectural patterns from Game Programming Patterns for TypeScript/JavaScript projects
---

# Architecture Patterns Skill

This skill provides comprehensive knowledge of 20 proven architectural patterns derived from Game Programming Patterns, adapted for TypeScript/JavaScript projects. It enables Claude to analyze codebases, identify patterns and anti-patterns, and recommend architectural improvements.

## Trigger Conditions

Activate this skill when the user:
- Asks about software architecture patterns or design patterns
- Wants to refactor or improve code architecture
- Mentions "anti-patterns", "coupling", "decoupling", or "code organization"
- Discusses state management, event handling, or component design
- Asks about performance optimization patterns
- Wants to understand when to use specific patterns

## Core Architectural Principles

### Architecture Exists to Facilitate Change
Good architecture minimizes the cognitive load required to make changes. When you can modify a feature by touching one or two files rather than dozens, you've achieved good architecture. The key mechanism is **decoupling**: structuring code so understanding one component doesn't require understanding everything it depends on.

### The Flexibility-Performance Trade-off
Abstractions that enable flexibility carry runtime costs. Maintain flexibility during design and iteration phases, then optimize selectively once requirements stabilize. It's easier to optimize working, well-structured code than to refactor a prematurely-optimized mess.

### Resist Speculative Generalization
Use patterns and abstractions only when genuinely needed. Don't build elaborate plugin architectures "in case" you need them. Find the most direct, simple solution that solves the current problem.

### The Three-Way Trade-off
Every architectural decision balances:
- **Long-term velocity**: How maintainable is this over months and years?
- **Short-term velocity**: How quickly can we ship the next feature?
- **Runtime performance**: How efficiently does this execute?

---

## Pattern Categories

### 1. Design Patterns Revisited

#### Command Pattern
**Problem**: Decouples what action is triggered from how it's executed.

**Use When**:
- Dynamic input remapping (keyboard shortcuts, user preferences)
- Undo/redo functionality
- Action queuing or batching
- Multiple systems triggering identical behaviors

**TypeScript Example**:
```typescript
interface Command {
  execute(): void;
  undo?(): void;
}

class MoveCommand implements Command {
  constructor(private entity: Entity, private dx: number, private dy: number) {}

  execute() {
    this.entity.x += this.dx;
    this.entity.y += this.dy;
  }

  undo() {
    this.entity.x -= this.dx;
    this.entity.y -= this.dy;
  }
}

// Commands become data - can be queued, serialized, replayed
const commandHistory: Command[] = [];
```

**Avoid When**: Actions are tightly bound to specific objects with no variation expected.

---

#### Flyweight Pattern
**Problem**: Memory optimization for thousands of similar objects by sharing intrinsic (immutable) state.

**Use When**:
- Rendering many similar objects (icons, particles, list items)
- Object creation overhead is significant
- Shared state significantly outweighs instance-specific state

**TypeScript Example**:
```typescript
// Intrinsic state - shared across all trees of same type
interface TreeType {
  name: string;
  color: string;
  texture: string;
}

// Extrinsic state - unique per instance
interface Tree {
  x: number;
  y: number;
  type: TreeType; // Reference to shared type
}

// Factory manages shared instances
const treeTypes = new Map<string, TreeType>();
function getTreeType(name: string, color: string, texture: string): TreeType {
  const key = `${name}-${color}-${texture}`;
  if (!treeTypes.has(key)) {
    treeTypes.set(key, { name, color, texture });
  }
  return treeTypes.get(key)!;
}
```

**Avoid When**: Shared state needs to be mutable, or you lack sufficient similar objects to justify complexity.

---

#### Observer Pattern
**Problem**: Enables loose coupling when multiple independent systems must react to events.

**Use When**:
- Communication between distant, unrelated domains
- Adding observers without modifying existing code
- UI updates in response to model changes

**TypeScript Example**:
```typescript
type Observer<T> = (event: T) => void;

class Subject<T> {
  private observers: Set<Observer<T>> = new Set();

  subscribe(observer: Observer<T>): () => void {
    this.observers.add(observer);
    return () => this.observers.delete(observer);
  }

  notify(event: T): void {
    this.observers.forEach(observer => observer(event));
  }
}

// Usage
const achievementUnlocked = new Subject<Achievement>();
achievementUnlocked.subscribe(a => playSound(a.sound));
achievementUnlocked.subscribe(a => showNotification(a.title));
achievementUnlocked.subscribe(a => analytics.track('achievement', a.id));
```

**Avoid When**: Within a single cohesive feature where explicit calls are clearer.

---

#### State Pattern
**Problem**: Manages behavior that changes based on internal conditions, eliminating scattered conditionals.

**Use When**:
- Entity has distinct states with different behaviors
- Combining Boolean flags leads to invalid state combinations
- User input handling, menu navigation, network protocols

**TypeScript Example**:
```typescript
interface PlayerState {
  enter?(player: Player): void;
  exit?(player: Player): void;
  handleInput(player: Player, input: Input): PlayerState | null;
  update(player: Player): void;
}

class StandingState implements PlayerState {
  handleInput(player: Player, input: Input): PlayerState | null {
    if (input === Input.JUMP) return new JumpingState();
    if (input === Input.DUCK) return new DuckingState();
    return null;
  }
  update(player: Player) { /* idle animation */ }
}

class Player {
  private state: PlayerState = new StandingState();

  handleInput(input: Input) {
    const newState = this.state.handleInput(this, input);
    if (newState) {
      this.state.exit?.(this);
      this.state = newState;
      this.state.enter?.(this);
    }
  }
}
```

**Advanced**: Consider hierarchical state machines for shared behavior, or pushdown automata for nested states that need "return to previous."

---

#### Singleton (ANTI-PATTERN)
**Problem**: Singleton disguises global state, creating hidden dependencies, concurrency hazards, and testing difficulties.

**Better Alternatives**:
1. **Pass dependencies explicitly**: Inject what's needed via constructor or function parameters
2. **Use dependency injection containers**: Let a framework manage instances
3. **Service Locator pattern**: If truly global access is needed, at least use an abstract interface
4. **Module-level state**: In JS/TS, a module's top-level variables are already singleton-like

**Signs You Have Singleton Problems**:
- Tests fail when run in parallel
- Mock setup requires global state manipulation
- Hunting through codebase to find what depends on what

---

### 2. Sequencing Patterns

#### Double Buffer Pattern
**Problem**: Prevents external code from observing work-in-progress state during modification.

**Use When**:
- State is modified incrementally while being accessed
- Changes must appear atomic
- Avoiding visual artifacts like screen tearing

**TypeScript Example**:
```typescript
class RenderBuffer {
  private current: FrameBuffer;
  private next: FrameBuffer;

  draw(entity: Entity) {
    // Always draw to "next"
    this.next.draw(entity);
  }

  swap() {
    [this.current, this.next] = [this.next, this.current];
    this.next.clear();
  }

  getDisplayBuffer(): FrameBuffer {
    return this.current;
  }
}
```

**Applicable to**: React's immutable state updates, database MVCC, any scenario requiring atomic visibility.

---

#### Update Method Pattern
**Problem**: Simulates multiple independent entities with concurrent-appearing behavior.

**Use When**:
- Many objects need independent behavior and state
- Dynamic entity management (add/remove at runtime)
- Game loops, animation systems, simulation engines

**TypeScript Example**:
```typescript
interface Entity {
  update(deltaTime: number): void;
  isActive: boolean;
}

class EntityManager {
  private entities: Entity[] = [];

  add(entity: Entity) {
    this.entities.push(entity);
  }

  updateAll(deltaTime: number) {
    // Update all entities
    for (const entity of this.entities) {
      if (entity.isActive) {
        entity.update(deltaTime);
      }
    }
    // Remove inactive entities
    this.entities = this.entities.filter(e => e.isActive);
  }
}
```

---

### 3. Behavioral Patterns

#### Subclass Sandbox Pattern
**Problem**: Many subclasses need access to various systems, but direct access creates coupling explosion.

**Use When**:
- Base class with many derived classes
- Derived classes need similar operations in different combinations
- Want to minimize coupling between derived classes and external systems

**TypeScript Example**:
```typescript
abstract class Spell {
  // Protected "sandbox" methods - the only way subclasses interact with the world
  protected playSound(sound: Sound) { /* ... */ }
  protected spawnParticles(type: ParticleType, x: number, y: number) { /* ... */ }
  protected dealDamage(target: Entity, amount: number) { /* ... */ }
  protected heal(target: Entity, amount: number) { /* ... */ }

  abstract cast(caster: Entity, target: Entity): void;
}

class FireballSpell extends Spell {
  cast(caster: Entity, target: Entity) {
    // Only uses sandbox methods - no direct coupling to audio, particles, combat systems
    this.playSound(Sounds.FIREBALL);
    this.spawnParticles(ParticleType.FIRE, target.x, target.y);
    this.dealDamage(target, 50);
  }
}
```

---

#### Type Object Pattern
**Problem**: Avoid explosion of classes for entity variations by replacing inheritance with data.

**Use When**:
- Many variations that differ primarily in data, not behavior
- Designers need to create variations without code changes
- Want to load entity types from configuration files

**TypeScript Example**:
```typescript
// Type object - defines a category
interface MonsterBreed {
  name: string;
  health: number;
  attack: number;
  resistances: string[];
  parent?: MonsterBreed; // Enables data inheritance
}

// Instance uses the type
class Monster {
  health: number;

  constructor(private breed: MonsterBreed) {
    this.health = breed.health;
  }

  get attack(): number {
    return this.breed.attack;
  }
}

// Load breeds from JSON
const breeds: Record<string, MonsterBreed> = await loadBreeds('monsters.json');
const goblin = new Monster(breeds.goblin);
```

---

### 4. Decoupling Patterns

#### Component Pattern
**Problem**: Monolithic classes accumulating responsibilities across multiple domains.

**Use When**:
- Entity touches multiple domains (rendering, physics, input, networking)
- Need to mix-and-match behaviors
- Testing components in isolation

**TypeScript Example**:
```typescript
interface Component {
  update?(deltaTime: number): void;
}

class GameObject {
  private components = new Map<string, Component>();

  addComponent<T extends Component>(name: string, component: T): T {
    this.components.set(name, component);
    return component;
  }

  getComponent<T extends Component>(name: string): T | undefined {
    return this.components.get(name) as T;
  }

  update(deltaTime: number) {
    for (const component of this.components.values()) {
      component.update?.(deltaTime);
    }
  }
}

// Compose entities from reusable components
const player = new GameObject();
player.addComponent('input', new PlayerInputComponent());
player.addComponent('physics', new PhysicsComponent());
player.addComponent('render', new SpriteComponent(playerSprite));

const enemy = new GameObject();
enemy.addComponent('ai', new AIInputComponent());
enemy.addComponent('physics', new PhysicsComponent());
enemy.addComponent('render', new SpriteComponent(enemySprite));
```

---

#### Event Queue Pattern
**Problem**: Synchronous method calls create tight coupling in timing.

**Use When**:
- Need to aggregate or batch requests
- Timing decoupling is required (fire-and-forget)
- Cross-thread communication
- Request prioritization

**TypeScript Example**:
```typescript
interface Event {
  type: string;
  payload: unknown;
  priority?: number;
}

class EventQueue {
  private queue: Event[] = [];

  emit(event: Event) {
    this.queue.push(event);
    // Sort by priority if needed
    this.queue.sort((a, b) => (b.priority ?? 0) - (a.priority ?? 0));
  }

  process(handler: (event: Event) => void) {
    while (this.queue.length > 0) {
      handler(this.queue.shift()!);
    }
  }
}
```

**Avoid When**: You need responses from the receiver. Observer pattern may be simpler if you don't need timing decoupling.

---

#### Service Locator Pattern
**Problem**: Provide global access to services without Singleton's rigidity.

**Use When**:
- Services are genuinely needed everywhere
- Want to swap implementations at runtime (production vs. testing)
- Need decorator patterns or null object fallbacks

**TypeScript Example**:
```typescript
interface AudioService {
  playSound(sound: Sound): void;
}

class ServiceLocator {
  private static audio: AudioService = new NullAudioService();

  static getAudio(): AudioService {
    return this.audio;
  }

  static provide(audio: AudioService) {
    this.audio = audio;
  }
}

// In production
ServiceLocator.provide(new WebAudioService());

// In tests
ServiceLocator.provide(new NullAudioService());

// Usage - decoupled from concrete implementation
ServiceLocator.getAudio().playSound(Sounds.EXPLOSION);
```

**Prefer**: Explicit parameter passing when threading dependencies through layers isn't gratuitous.

---

### 5. Optimization Patterns

#### Dirty Flag Pattern
**Problem**: Redundant computation when source data changes more frequently than results are read.

**Use When**:
- Derived data is expensive to compute
- Primary data changes more often than derived data is accessed
- Hierarchical transformations (scene graphs, CSS cascading)

**TypeScript Example**:
```typescript
class SceneNode {
  private localTransform: Matrix;
  private worldTransform: Matrix;
  private dirty = true;
  private children: SceneNode[] = [];

  setPosition(x: number, y: number) {
    this.localTransform = Matrix.translate(x, y);
    this.markDirty();
  }

  private markDirty() {
    this.dirty = true;
    for (const child of this.children) {
      child.markDirty();
    }
  }

  getWorldTransform(parentWorld: Matrix): Matrix {
    if (this.dirty) {
      this.worldTransform = parentWorld.multiply(this.localTransform);
      this.dirty = false;
    }
    return this.worldTransform;
  }
}
```

---

#### Object Pool Pattern
**Problem**: Frequent allocation/deallocation causes GC pauses and memory fragmentation.

**Use When**:
- Frequently creating and destroying similar objects
- Objects wrap expensive resources (connections, GPU buffers)
- Predictable object lifetime

**TypeScript Example**:
```typescript
class ObjectPool<T> {
  private available: T[] = [];
  private inUse = new Set<T>();

  constructor(
    private factory: () => T,
    private reset: (obj: T) => void,
    initialSize: number
  ) {
    for (let i = 0; i < initialSize; i++) {
      this.available.push(factory());
    }
  }

  acquire(): T {
    const obj = this.available.pop() ?? this.factory();
    this.inUse.add(obj);
    return obj;
  }

  release(obj: T) {
    if (this.inUse.delete(obj)) {
      this.reset(obj);
      this.available.push(obj);
    }
  }
}

// Usage
const particlePool = new ObjectPool(
  () => new Particle(),
  p => p.reset(),
  1000
);
```

---

## Anti-Pattern Detection Guide

When analyzing code, look for these warning signs:

### Coupling Issues
- Classes that import from many unrelated modules
- Changes in one area requiring changes in many others
- Difficulty testing components in isolation
- "God classes" with too many responsibilities

### State Management Issues
- Boolean flags that can be in invalid combinations
- Scattered conditionals checking the same state
- State changes with unexpected side effects
- Difficulty reasoning about current state

### Performance Issues
- Frequent allocations in hot paths
- Recomputing derived data on every access
- Processing all items when only a subset is relevant
- Cache misses from scattered data access patterns

### Flexibility Issues
- Hard-coded values that should be configurable
- Class hierarchies that are hard to extend
- Behaviors that can't be swapped at runtime
- Tight coupling to specific implementations

---

## Pattern Selection Guide

| Problem | Consider These Patterns |
|---------|------------------------|
| Need undo/redo | Command |
| Many similar objects consuming memory | Flyweight |
| Notifying multiple systems of events | Observer |
| Complex state transitions | State |
| Independent behaviors on entities | Component |
| Deferred/batched operations | Event Queue |
| Expensive derived calculations | Dirty Flag |
| Frequent object churn | Object Pool |
| Data-driven entity variations | Type Object |
| Many subclasses with similar needs | Subclass Sandbox |
| Global service access | Service Locator (carefully) |

---

## References

For detailed pattern implementations and examples, see the reference files:
- `references/design-patterns.md` - Command, Flyweight, Observer, Prototype, State details
- `references/sequencing-patterns.md` - Double Buffer, Game Loop, Update Method details
- `references/behavioral-patterns.md` - Bytecode, Subclass Sandbox, Type Object details
- `references/decoupling-patterns.md` - Component, Event Queue, Service Locator details
- `references/optimization-patterns.md` - Data Locality, Dirty Flag, Object Pool, Spatial Partition details
