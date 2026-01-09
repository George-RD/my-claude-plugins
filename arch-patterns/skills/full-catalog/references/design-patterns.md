# Design Patterns Revisited - Detailed Reference

## Command Pattern

### Full Implementation with Undo Stack

```typescript
interface Command {
  execute(): void;
  undo(): void;
  getDescription(): string;
}

class CommandManager {
  private undoStack: Command[] = [];
  private redoStack: Command[] = [];
  private maxHistory = 100;

  execute(command: Command): void {
    command.execute();
    this.undoStack.push(command);
    this.redoStack = []; // Clear redo stack on new command

    if (this.undoStack.length > this.maxHistory) {
      this.undoStack.shift();
    }
  }

  undo(): boolean {
    const command = this.undoStack.pop();
    if (command) {
      command.undo();
      this.redoStack.push(command);
      return true;
    }
    return false;
  }

  redo(): boolean {
    const command = this.redoStack.pop();
    if (command) {
      command.execute();
      this.undoStack.push(command);
      return true;
    }
    return false;
  }

  canUndo(): boolean {
    return this.undoStack.length > 0;
  }

  canRedo(): boolean {
    return this.redoStack.length > 0;
  }
}

// Composite command for batching
class CompositeCommand implements Command {
  constructor(private commands: Command[]) {}

  execute(): void {
    for (const command of this.commands) {
      command.execute();
    }
  }

  undo(): void {
    // Undo in reverse order
    for (let i = this.commands.length - 1; i >= 0; i--) {
      this.commands[i].undo();
    }
  }

  getDescription(): string {
    return `Batch: ${this.commands.map(c => c.getDescription()).join(', ')}`;
  }
}
```

### Input Binding Example

```typescript
type InputAction = 'JUMP' | 'FIRE' | 'CROUCH' | 'MOVE_LEFT' | 'MOVE_RIGHT';

class InputHandler {
  private bindings = new Map<string, Command>();

  bind(key: string, command: Command): void {
    this.bindings.set(key, command);
  }

  handleKeyPress(key: string): Command | null {
    return this.bindings.get(key) ?? null;
  }

  // Rebindable controls
  rebind(oldKey: string, newKey: string): void {
    const command = this.bindings.get(oldKey);
    if (command) {
      this.bindings.delete(oldKey);
      this.bindings.set(newKey, command);
    }
  }
}
```

---

## Flyweight Pattern

### Full Implementation with Factory

```typescript
// Intrinsic state - immutable, shared
class TileType {
  constructor(
    public readonly name: string,
    public readonly texture: string,
    public readonly isWalkable: boolean,
    public readonly movementCost: number
  ) {
    Object.freeze(this); // Ensure immutability
  }
}

// Flyweight factory
class TileTypeFactory {
  private types = new Map<string, TileType>();

  getType(name: string, texture: string, isWalkable: boolean, movementCost: number): TileType {
    const key = `${name}:${texture}:${isWalkable}:${movementCost}`;

    if (!this.types.has(key)) {
      this.types.set(key, new TileType(name, texture, isWalkable, movementCost));
    }

    return this.types.get(key)!;
  }

  get typeCount(): number {
    return this.types.size;
  }
}

// Context with extrinsic state
class Tile {
  constructor(
    public x: number,
    public y: number,
    public type: TileType // Reference to shared flyweight
  ) {}
}

// Usage
const factory = new TileTypeFactory();
const tiles: Tile[] = [];

// Create 1000 grass tiles - only ONE TileType instance created
for (let i = 0; i < 1000; i++) {
  tiles.push(new Tile(
    i % 100,
    Math.floor(i / 100),
    factory.getType('grass', 'grass.png', true, 1)
  ));
}

console.log(`Tiles: ${tiles.length}, Types: ${factory.typeCount}`); // Tiles: 1000, Types: 1
```

---

## Observer Pattern

### Type-Safe Event Emitter

```typescript
type EventMap = {
  playerDied: { playerId: string; position: Position };
  levelComplete: { level: number; score: number; time: number };
  itemCollected: { item: Item; collector: Entity };
};

class TypedEventEmitter<T extends Record<string, unknown>> {
  private listeners = new Map<keyof T, Set<(payload: any) => void>>();

  on<K extends keyof T>(event: K, listener: (payload: T[K]) => void): () => void {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, new Set());
    }
    this.listeners.get(event)!.add(listener);

    // Return unsubscribe function
    return () => this.listeners.get(event)?.delete(listener);
  }

  emit<K extends keyof T>(event: K, payload: T[K]): void {
    this.listeners.get(event)?.forEach(listener => listener(payload));
  }

  once<K extends keyof T>(event: K, listener: (payload: T[K]) => void): () => void {
    const unsubscribe = this.on(event, (payload) => {
      unsubscribe();
      listener(payload);
    });
    return unsubscribe;
  }
}

// Usage
const events = new TypedEventEmitter<EventMap>();

events.on('playerDied', ({ playerId, position }) => {
  console.log(`Player ${playerId} died at ${position.x}, ${position.y}`);
});

events.emit('playerDied', { playerId: 'player1', position: { x: 10, y: 20 } });
```

---

## State Pattern

### Hierarchical State Machine

```typescript
interface State {
  enter?(context: StateMachine): void;
  exit?(context: StateMachine): void;
  update(context: StateMachine, deltaTime: number): void;
  handleInput(context: StateMachine, input: Input): State | null;

  // For hierarchical states
  parent?: State;
}

class StateMachine {
  private currentState: State;
  private stateStack: State[] = []; // For pushdown automata

  constructor(initialState: State) {
    this.currentState = initialState;
    this.currentState.enter?.(this);
  }

  transition(newState: State): void {
    this.currentState.exit?.(this);
    this.currentState = newState;
    this.currentState.enter?.(this);
  }

  // Pushdown automata - remember previous state
  push(newState: State): void {
    this.stateStack.push(this.currentState);
    this.currentState.exit?.(this);
    this.currentState = newState;
    this.currentState.enter?.(this);
  }

  pop(): boolean {
    const previousState = this.stateStack.pop();
    if (previousState) {
      this.currentState.exit?.(this);
      this.currentState = previousState;
      this.currentState.enter?.(this);
      return true;
    }
    return false;
  }

  update(deltaTime: number): void {
    this.currentState.update(this, deltaTime);
  }

  handleInput(input: Input): void {
    let state: State | null = this.currentState;

    // Walk up hierarchy until someone handles the input
    while (state) {
      const newState = state.handleInput(this, input);
      if (newState) {
        this.transition(newState);
        return;
      }
      state = state.parent ?? null;
    }
  }
}

// Example: Character states
class OnGroundState implements State {
  update(context: StateMachine, deltaTime: number): void {
    // Shared ground behavior
  }

  handleInput(context: StateMachine, input: Input): State | null {
    if (input === Input.JUMP) return new JumpingState();
    return null;
  }
}

class StandingState extends OnGroundState {
  handleInput(context: StateMachine, input: Input): State | null {
    if (input === Input.CROUCH) return new CrouchingState();
    if (input === Input.WALK) return new WalkingState();
    return super.handleInput(context, input); // Defer to parent
  }
}

class CrouchingState extends OnGroundState {
  handleInput(context: StateMachine, input: Input): State | null {
    if (input === Input.STAND) return new StandingState();
    return super.handleInput(context, input);
  }
}
```

---

## Singleton Alternatives

### Dependency Injection Container

```typescript
class Container {
  private instances = new Map<string, unknown>();
  private factories = new Map<string, () => unknown>();

  register<T>(key: string, factory: () => T): void {
    this.factories.set(key, factory);
  }

  registerSingleton<T>(key: string, factory: () => T): void {
    this.factories.set(key, () => {
      if (!this.instances.has(key)) {
        this.instances.set(key, factory());
      }
      return this.instances.get(key);
    });
  }

  resolve<T>(key: string): T {
    const factory = this.factories.get(key);
    if (!factory) {
      throw new Error(`No registration for ${key}`);
    }
    return factory() as T;
  }
}

// Usage
const container = new Container();
container.registerSingleton('audio', () => new AudioService());
container.registerSingleton('logger', () => new Logger());
container.register('player', () => new Player(
  container.resolve('audio'),
  container.resolve('logger')
));

const player = container.resolve<Player>('player');
```

### Module-Level "Singleton" (Simpler Alternative)

```typescript
// audio.ts - Module is naturally singleton-like
let audioContext: AudioContext | null = null;

export function getAudioContext(): AudioContext {
  if (!audioContext) {
    audioContext = new AudioContext();
  }
  return audioContext;
}

// For testing
export function resetAudioContext(): void {
  audioContext?.close();
  audioContext = null;
}
```
