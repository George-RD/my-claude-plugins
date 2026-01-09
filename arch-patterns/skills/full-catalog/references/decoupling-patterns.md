# Decoupling Patterns - Detailed Reference

## Component Pattern

### Full Entity-Component System

```typescript
// Component base
abstract class Component {
  entity: Entity | null = null;

  abstract update(deltaTime: number): void;

  // Lifecycle hooks
  onAttach?(entity: Entity): void;
  onDetach?(): void;

  // Get sibling components
  protected getComponent<T extends Component>(type: new (...args: any[]) => T): T | null {
    return this.entity?.getComponent(type) ?? null;
  }
}

// Entity as component container
class Entity {
  private components = new Map<Function, Component>();
  private tags = new Set<string>();

  addComponent<T extends Component>(component: T): T {
    const type = component.constructor;
    this.components.set(type, component);
    component.entity = this;
    component.onAttach?.(this);
    return component;
  }

  removeComponent<T extends Component>(type: new (...args: any[]) => T): boolean {
    const component = this.components.get(type);
    if (component) {
      component.onDetach?.();
      component.entity = null;
      this.components.delete(type);
      return true;
    }
    return false;
  }

  getComponent<T extends Component>(type: new (...args: any[]) => T): T | null {
    return (this.components.get(type) as T) ?? null;
  }

  hasComponent<T extends Component>(type: new (...args: any[]) => T): boolean {
    return this.components.has(type);
  }

  update(deltaTime: number): void {
    for (const component of this.components.values()) {
      component.update(deltaTime);
    }
  }

  // Tags for quick filtering
  addTag(tag: string): void {
    this.tags.add(tag);
  }

  hasTag(tag: string): boolean {
    return this.tags.has(tag);
  }
}

// Example components
class TransformComponent extends Component {
  x = 0;
  y = 0;
  rotation = 0;
  scale = 1;

  update(_deltaTime: number): void {
    // Transform doesn't update itself
  }
}

class PhysicsComponent extends Component {
  velocityX = 0;
  velocityY = 0;
  mass = 1;

  update(deltaTime: number): void {
    const transform = this.getComponent(TransformComponent);
    if (transform) {
      transform.x += this.velocityX * deltaTime;
      transform.y += this.velocityY * deltaTime;
    }
  }
}

class RenderComponent extends Component {
  sprite: Sprite;

  constructor(sprite: Sprite) {
    super();
    this.sprite = sprite;
  }

  update(_deltaTime: number): void {
    const transform = this.getComponent(TransformComponent);
    if (transform) {
      this.sprite.draw(transform.x, transform.y, transform.rotation, transform.scale);
    }
  }
}

// Entity factory
function createPlayer(): Entity {
  const player = new Entity();
  player.addComponent(new TransformComponent());
  player.addComponent(new PhysicsComponent());
  player.addComponent(new RenderComponent(playerSprite));
  player.addComponent(new PlayerInputComponent());
  player.addComponent(new HealthComponent(100));
  player.addTag('player');
  return player;
}

function createEnemy(): Entity {
  const enemy = new Entity();
  enemy.addComponent(new TransformComponent());
  enemy.addComponent(new PhysicsComponent());
  enemy.addComponent(new RenderComponent(enemySprite));
  enemy.addComponent(new AIComponent());
  enemy.addComponent(new HealthComponent(50));
  enemy.addTag('enemy');
  return enemy;
}
```

### Component Communication Patterns

```typescript
// Option 1: Direct component access
class AIComponent extends Component {
  update(deltaTime: number): void {
    const physics = this.getComponent(PhysicsComponent);
    if (physics) {
      physics.velocityX = this.calculateDesiredVelocity();
    }
  }
}

// Option 2: Event-based communication
class HealthComponent extends Component {
  private health: number;
  private maxHealth: number;
  private events = new EventEmitter();

  constructor(maxHealth: number) {
    super();
    this.health = maxHealth;
    this.maxHealth = maxHealth;
  }

  takeDamage(amount: number): void {
    this.health = Math.max(0, this.health - amount);
    this.events.emit('damaged', { current: this.health, amount });

    if (this.health <= 0) {
      this.events.emit('died');
    }
  }

  onDamaged(callback: (data: { current: number; amount: number }) => void): void {
    this.events.on('damaged', callback);
  }

  onDied(callback: () => void): void {
    this.events.on('died', callback);
  }
}

// Components subscribe to each other's events
class DeathEffectComponent extends Component {
  onAttach(entity: Entity): void {
    const health = this.getComponent(HealthComponent);
    health?.onDied(() => {
      this.playDeathAnimation();
      this.spawnParticles();
    });
  }
}
```

---

## Event Queue Pattern

### Priority Event Queue with Ring Buffer

```typescript
interface QueuedEvent<T = unknown> {
  type: string;
  payload: T;
  priority: number;
  timestamp: number;
}

class EventQueue {
  private buffer: (QueuedEvent | null)[];
  private head = 0;
  private tail = 0;
  private count = 0;

  constructor(private capacity: number = 1024) {
    this.buffer = new Array(capacity).fill(null);
  }

  enqueue<T>(type: string, payload: T, priority: number = 0): boolean {
    if (this.count >= this.capacity) {
      console.warn('Event queue full, dropping event:', type);
      return false;
    }

    const event: QueuedEvent<T> = {
      type,
      payload,
      priority,
      timestamp: performance.now()
    };

    // Insert maintaining priority order (higher priority = earlier in queue)
    let insertPos = this.tail;
    while (insertPos !== this.head) {
      const prevPos = (insertPos - 1 + this.capacity) % this.capacity;
      const prevEvent = this.buffer[prevPos];

      if (!prevEvent || prevEvent.priority >= priority) break;

      this.buffer[insertPos] = prevEvent;
      insertPos = prevPos;
    }

    this.buffer[insertPos] = event;
    this.tail = (this.tail + 1) % this.capacity;
    this.count++;
    return true;
  }

  dequeue(): QueuedEvent | null {
    if (this.count === 0) return null;

    const event = this.buffer[this.head];
    this.buffer[this.head] = null;
    this.head = (this.head + 1) % this.capacity;
    this.count--;
    return event;
  }

  process(handler: (event: QueuedEvent) => void, maxEvents: number = Infinity): number {
    let processed = 0;
    while (processed < maxEvents && this.count > 0) {
      const event = this.dequeue();
      if (event) {
        handler(event);
        processed++;
      }
    }
    return processed;
  }

  get length(): number {
    return this.count;
  }

  get isEmpty(): boolean {
    return this.count === 0;
  }
}

// Usage with typed events
type GameEvent =
  | { type: 'SOUND_PLAY'; payload: { sound: string; volume: number } }
  | { type: 'DAMAGE'; payload: { target: string; amount: number } }
  | { type: 'SPAWN'; payload: { entityType: string; x: number; y: number } };

const eventQueue = new EventQueue();

// Fire and forget - decoupled from processing
eventQueue.enqueue('SOUND_PLAY', { sound: 'explosion.wav', volume: 0.8 }, 1);
eventQueue.enqueue('DAMAGE', { target: 'enemy_1', amount: 50 }, 2); // Higher priority

// Process during game loop
function gameLoop() {
  // Process up to 10 events per frame to prevent stalls
  eventQueue.process((event) => {
    switch (event.type) {
      case 'SOUND_PLAY':
        audioSystem.play(event.payload.sound, event.payload.volume);
        break;
      case 'DAMAGE':
        combatSystem.applyDamage(event.payload.target, event.payload.amount);
        break;
      case 'SPAWN':
        entityManager.spawn(event.payload.entityType, event.payload.x, event.payload.y);
        break;
    }
  }, 10);
}
```

### Event Aggregation

```typescript
class SoundEventQueue {
  private pending = new Map<string, { volume: number; count: number }>();

  play(sound: string, volume: number): void {
    const existing = this.pending.get(sound);
    if (existing) {
      // Aggregate: use max volume, track count
      existing.volume = Math.max(existing.volume, volume);
      existing.count++;
    } else {
      this.pending.set(sound, { volume, count: 1 });
    }
  }

  flush(): void {
    for (const [sound, { volume, count }] of this.pending) {
      // Could adjust volume based on count, or just play once
      audioSystem.play(sound, volume);
    }
    this.pending.clear();
  }
}
```

---

## Service Locator Pattern

### Full Implementation with Decorators and Null Objects

```typescript
// Service interfaces
interface IAudioService {
  playSound(id: string, volume?: number): void;
  playMusic(id: string): void;
  stopAll(): void;
}

interface ILogService {
  log(level: 'debug' | 'info' | 'warn' | 'error', message: string, data?: unknown): void;
}

// Null implementations for graceful degradation
class NullAudioService implements IAudioService {
  playSound(_id: string, _volume?: number): void {}
  playMusic(_id: string): void {}
  stopAll(): void {}
}

class NullLogService implements ILogService {
  log(_level: 'debug' | 'info' | 'warn' | 'error', _message: string, _data?: unknown): void {}
}

// Production implementations
class WebAudioService implements IAudioService {
  private context = new AudioContext();
  private sounds = new Map<string, AudioBuffer>();

  async loadSound(id: string, url: string): Promise<void> {
    const response = await fetch(url);
    const buffer = await response.arrayBuffer();
    this.sounds.set(id, await this.context.decodeAudioData(buffer));
  }

  playSound(id: string, volume: number = 1): void {
    const buffer = this.sounds.get(id);
    if (buffer) {
      const source = this.context.createBufferSource();
      const gain = this.context.createGain();
      source.buffer = buffer;
      gain.gain.value = volume;
      source.connect(gain).connect(this.context.destination);
      source.start();
    }
  }

  playMusic(id: string): void {
    // Music implementation
  }

  stopAll(): void {
    this.context.suspend();
  }
}

// Decorator for logging
class LoggingAudioDecorator implements IAudioService {
  constructor(
    private wrapped: IAudioService,
    private logger: ILogService
  ) {}

  playSound(id: string, volume?: number): void {
    this.logger.log('debug', `Playing sound: ${id}`, { volume });
    this.wrapped.playSound(id, volume);
  }

  playMusic(id: string): void {
    this.logger.log('debug', `Playing music: ${id}`);
    this.wrapped.playMusic(id);
  }

  stopAll(): void {
    this.logger.log('debug', 'Stopping all audio');
    this.wrapped.stopAll();
  }
}

// Type-safe service locator
class ServiceLocator {
  private static services = new Map<string, unknown>();

  private static defaults: Record<string, () => unknown> = {
    audio: () => new NullAudioService(),
    log: () => new NullLogService(),
  };

  static provide<T>(key: string, service: T): void {
    this.services.set(key, service);
  }

  static get<T>(key: string): T {
    if (!this.services.has(key)) {
      const defaultFactory = this.defaults[key];
      if (defaultFactory) {
        this.services.set(key, defaultFactory());
      }
    }
    return this.services.get(key) as T;
  }

  // Typed accessors for common services
  static get audio(): IAudioService {
    return this.get<IAudioService>('audio');
  }

  static get log(): ILogService {
    return this.get<ILogService>('log');
  }

  // For testing
  static reset(): void {
    this.services.clear();
  }
}

// Setup in production
async function initializeServices(): Promise<void> {
  const audio = new WebAudioService();
  await audio.loadSound('explosion', '/sounds/explosion.wav');

  const logger = new ConsoleLogService();

  // Wrap with decorator in debug mode
  const audioService = process.env.NODE_ENV === 'development'
    ? new LoggingAudioDecorator(audio, logger)
    : audio;

  ServiceLocator.provide('audio', audioService);
  ServiceLocator.provide('log', logger);
}

// Setup in tests
beforeEach(() => {
  ServiceLocator.reset();
  // Services will use null implementations
});

// Usage anywhere in codebase
function onEnemyDeath(): void {
  ServiceLocator.audio.playSound('explosion', 0.8);
  ServiceLocator.log.log('info', 'Enemy defeated');
}
```

### When to Use vs. Dependency Injection

```typescript
// Prefer DI when dependencies are few and explicit
class Player {
  constructor(
    private audio: IAudioService,
    private input: IInputService
  ) {}
}

// Consider Service Locator when:
// 1. Many different places need the service
// 2. Threading through layers becomes verbose
// 3. Service is truly cross-cutting (logging, analytics)

// BAD: Passing through multiple layers
class GameScene {
  constructor(audio: IAudioService) {
    this.player = new Player(audio);
    this.enemies = enemies.map(e => new Enemy(audio));
    this.particles = new ParticleSystem(audio);
    // etc.
  }
}

// OK: Service Locator for cross-cutting concerns
class Enemy {
  takeDamage(amount: number): void {
    this.health -= amount;
    ServiceLocator.audio.playSound('hit'); // Acceptable
    ServiceLocator.log.log('debug', 'Enemy hit', { damage: amount }); // Acceptable
  }
}
```
