# Optimization Patterns - Detailed Reference

## Dirty Flag Pattern

### Scene Graph with Dirty Flags

```typescript
class Transform {
  private _position = { x: 0, y: 0 };
  private _rotation = 0;
  private _scale = { x: 1, y: 1 };
  private _localMatrix: Matrix4 | null = null;
  private _worldMatrix: Matrix4 | null = null;
  private _dirty = true;

  parent: Transform | null = null;
  children: Transform[] = [];

  get position() {
    return this._position;
  }

  setPosition(x: number, y: number): void {
    if (this._position.x !== x || this._position.y !== y) {
      this._position.x = x;
      this._position.y = y;
      this.markDirty();
    }
  }

  setRotation(radians: number): void {
    if (this._rotation !== radians) {
      this._rotation = radians;
      this.markDirty();
    }
  }

  setScale(x: number, y: number): void {
    if (this._scale.x !== x || this._scale.y !== y) {
      this._scale.x = x;
      this._scale.y = y;
      this.markDirty();
    }
  }

  private markDirty(): void {
    if (!this._dirty) {
      this._dirty = true;
      this._localMatrix = null;
      this._worldMatrix = null;

      // Propagate to children
      for (const child of this.children) {
        child.markDirty();
      }
    }
  }

  getLocalMatrix(): Matrix4 {
    if (!this._localMatrix) {
      this._localMatrix = Matrix4.compose(
        this._position,
        this._rotation,
        this._scale
      );
    }
    return this._localMatrix;
  }

  getWorldMatrix(): Matrix4 {
    if (!this._worldMatrix) {
      const local = this.getLocalMatrix();
      if (this.parent) {
        this._worldMatrix = this.parent.getWorldMatrix().multiply(local);
      } else {
        this._worldMatrix = local;
      }
      this._dirty = false;
    }
    return this._worldMatrix;
  }

  addChild(child: Transform): void {
    child.parent = this;
    this.children.push(child);
    child.markDirty();
  }
}
```

### Computed Property with Dirty Flag

```typescript
class DataGrid<T> {
  private _data: T[] = [];
  private _sortedData: T[] | null = null;
  private _filteredData: T[] | null = null;
  private _sortDirty = true;
  private _filterDirty = true;
  private _sortKey: keyof T | null = null;
  private _filterPredicate: ((item: T) => boolean) | null = null;

  setData(data: T[]): void {
    this._data = data;
    this._sortDirty = true;
    this._filterDirty = true;
    this._sortedData = null;
    this._filteredData = null;
  }

  setSortKey(key: keyof T): void {
    if (this._sortKey !== key) {
      this._sortKey = key;
      this._sortDirty = true;
      this._sortedData = null;
    }
  }

  setFilter(predicate: (item: T) => boolean): void {
    this._filterPredicate = predicate;
    this._filterDirty = true;
    this._filteredData = null;
  }

  getDisplayData(): T[] {
    // Apply filter first
    if (this._filterDirty) {
      this._filteredData = this._filterPredicate
        ? this._data.filter(this._filterPredicate)
        : [...this._data];
      this._filterDirty = false;
      this._sortDirty = true; // Filtered data needs re-sorting
      this._sortedData = null;
    }

    // Then sort
    if (this._sortDirty && this._filteredData) {
      this._sortedData = this._sortKey
        ? [...this._filteredData].sort((a, b) =>
            String(a[this._sortKey!]).localeCompare(String(b[this._sortKey!]))
          )
        : this._filteredData;
      this._sortDirty = false;
    }

    return this._sortedData ?? this._filteredData ?? this._data;
  }
}
```

---

## Object Pool Pattern

### Generic Object Pool with Type Safety

```typescript
interface Poolable {
  reset(): void;
  isActive: boolean;
}

class ObjectPool<T extends Poolable> {
  private available: T[] = [];
  private active = new Set<T>();
  private factory: () => T;
  private maxSize: number;

  constructor(options: {
    factory: () => T;
    initialSize?: number;
    maxSize?: number;
  }) {
    this.factory = options.factory;
    this.maxSize = options.maxSize ?? Infinity;

    // Pre-populate pool
    const initialSize = options.initialSize ?? 0;
    for (let i = 0; i < initialSize; i++) {
      const obj = this.factory();
      obj.isActive = false;
      this.available.push(obj);
    }
  }

  acquire(): T | null {
    let obj: T;

    if (this.available.length > 0) {
      obj = this.available.pop()!;
    } else if (this.active.size < this.maxSize) {
      obj = this.factory();
    } else {
      // Pool exhausted
      return null;
    }

    obj.isActive = true;
    this.active.add(obj);
    return obj;
  }

  release(obj: T): void {
    if (this.active.delete(obj)) {
      obj.reset();
      obj.isActive = false;
      this.available.push(obj);
    }
  }

  releaseAll(): void {
    for (const obj of this.active) {
      obj.reset();
      obj.isActive = false;
      this.available.push(obj);
    }
    this.active.clear();
  }

  // Iterate over active objects only
  forEach(callback: (obj: T) => void): void {
    for (const obj of this.active) {
      callback(obj);
    }
  }

  get activeCount(): number {
    return this.active.size;
  }

  get availableCount(): number {
    return this.available.length;
  }
}

// Particle implementation
class Particle implements Poolable {
  x = 0;
  y = 0;
  vx = 0;
  vy = 0;
  life = 0;
  maxLife = 0;
  color = '#ffffff';
  size = 1;
  isActive = false;

  init(x: number, y: number, vx: number, vy: number, life: number): void {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.life = life;
    this.maxLife = life;
  }

  update(dt: number): void {
    this.x += this.vx * dt;
    this.y += this.vy * dt;
    this.life -= dt;
  }

  reset(): void {
    this.x = 0;
    this.y = 0;
    this.vx = 0;
    this.vy = 0;
    this.life = 0;
    this.maxLife = 0;
    this.color = '#ffffff';
    this.size = 1;
  }
}

// Usage
class ParticleSystem {
  private pool = new ObjectPool({
    factory: () => new Particle(),
    initialSize: 1000,
    maxSize: 5000
  });

  emit(x: number, y: number, count: number): void {
    for (let i = 0; i < count; i++) {
      const particle = this.pool.acquire();
      if (particle) {
        const angle = Math.random() * Math.PI * 2;
        const speed = 50 + Math.random() * 100;
        particle.init(
          x, y,
          Math.cos(angle) * speed,
          Math.sin(angle) * speed,
          1 + Math.random()
        );
      }
    }
  }

  update(dt: number): void {
    const toRelease: Particle[] = [];

    this.pool.forEach(particle => {
      particle.update(dt);
      if (particle.life <= 0) {
        toRelease.push(particle);
      }
    });

    for (const particle of toRelease) {
      this.pool.release(particle);
    }
  }

  draw(ctx: CanvasRenderingContext2D): void {
    this.pool.forEach(particle => {
      const alpha = particle.life / particle.maxLife;
      ctx.globalAlpha = alpha;
      ctx.fillStyle = particle.color;
      ctx.beginPath();
      ctx.arc(particle.x, particle.y, particle.size, 0, Math.PI * 2);
      ctx.fill();
    });
    ctx.globalAlpha = 1;
  }
}
```

---

## Data Locality Pattern

### Structure of Arrays (SoA) vs Array of Structures (AoS)

```typescript
// BAD: Array of Structures (AoS) - scattered memory access
interface ParticleAoS {
  x: number;
  y: number;
  vx: number;
  vy: number;
  life: number;
  color: string;
  size: number;
}

const particlesAoS: ParticleAoS[] = new Array(10000).fill(null).map(() => ({
  x: 0, y: 0, vx: 0, vy: 0, life: 1, color: '#fff', size: 1
}));

// Updating positions touches memory scattered across the heap
function updateAoS(dt: number) {
  for (const p of particlesAoS) {
    p.x += p.vx * dt;
    p.y += p.vy * dt;
  }
}


// GOOD: Structure of Arrays (SoA) - contiguous memory access
class ParticlesSoA {
  private count = 0;
  private capacity: number;

  // Contiguous typed arrays - cache friendly
  x: Float32Array;
  y: Float32Array;
  vx: Float32Array;
  vy: Float32Array;
  life: Float32Array;

  constructor(capacity: number) {
    this.capacity = capacity;
    this.x = new Float32Array(capacity);
    this.y = new Float32Array(capacity);
    this.vx = new Float32Array(capacity);
    this.vy = new Float32Array(capacity);
    this.life = new Float32Array(capacity);
  }

  add(x: number, y: number, vx: number, vy: number, life: number): number {
    if (this.count >= this.capacity) return -1;
    const i = this.count++;
    this.x[i] = x;
    this.y[i] = y;
    this.vx[i] = vx;
    this.vy[i] = vy;
    this.life[i] = life;
    return i;
  }

  update(dt: number): void {
    // Each loop accesses contiguous memory - excellent cache utilization
    const count = this.count;

    // Update positions
    for (let i = 0; i < count; i++) {
      this.x[i] += this.vx[i] * dt;
    }
    for (let i = 0; i < count; i++) {
      this.y[i] += this.vy[i] * dt;
    }

    // Update life
    for (let i = 0; i < count; i++) {
      this.life[i] -= dt;
    }

    // Remove dead particles (swap with last)
    for (let i = count - 1; i >= 0; i--) {
      if (this.life[i] <= 0) {
        this.removeAt(i);
      }
    }
  }

  private removeAt(index: number): void {
    const last = --this.count;
    if (index !== last) {
      this.x[index] = this.x[last];
      this.y[index] = this.y[last];
      this.vx[index] = this.vx[last];
      this.vy[index] = this.vy[last];
      this.life[index] = this.life[last];
    }
  }
}
```

### Hot/Cold Data Splitting

```typescript
// Split frequently accessed "hot" data from rarely accessed "cold" data
class EntityManager {
  // HOT data - accessed every frame
  private positions: Float32Array;
  private velocities: Float32Array;
  private active: Uint8Array;

  // COLD data - accessed rarely
  private metadata: Map<number, {
    name: string;
    createdAt: number;
    debugInfo: string;
  }>;

  constructor(capacity: number) {
    this.positions = new Float32Array(capacity * 2);
    this.velocities = new Float32Array(capacity * 2);
    this.active = new Uint8Array(capacity);
    this.metadata = new Map();
  }

  // Hot path - tight loop over contiguous data
  updatePhysics(dt: number): void {
    const count = this.active.length;
    for (let i = 0; i < count; i++) {
      if (this.active[i]) {
        const idx = i * 2;
        this.positions[idx] += this.velocities[idx] * dt;
        this.positions[idx + 1] += this.velocities[idx + 1] * dt;
      }
    }
  }

  // Cold path - fine to use Map lookup
  getDebugInfo(id: number): string | undefined {
    return this.metadata.get(id)?.debugInfo;
  }
}
```

---

## Spatial Partition Pattern

### Spatial Hash Grid

```typescript
interface Spatial {
  x: number;
  y: number;
  width: number;
  height: number;
}

class SpatialHashGrid<T extends Spatial> {
  private cellSize: number;
  private cells = new Map<string, Set<T>>();
  private entityCells = new Map<T, Set<string>>();

  constructor(cellSize: number) {
    this.cellSize = cellSize;
  }

  private getKey(cellX: number, cellY: number): string {
    return `${cellX},${cellY}`;
  }

  private getCellsForEntity(entity: T): string[] {
    const keys: string[] = [];
    const startX = Math.floor(entity.x / this.cellSize);
    const startY = Math.floor(entity.y / this.cellSize);
    const endX = Math.floor((entity.x + entity.width) / this.cellSize);
    const endY = Math.floor((entity.y + entity.height) / this.cellSize);

    for (let x = startX; x <= endX; x++) {
      for (let y = startY; y <= endY; y++) {
        keys.push(this.getKey(x, y));
      }
    }
    return keys;
  }

  insert(entity: T): void {
    const cellKeys = this.getCellsForEntity(entity);
    const entityCellSet = new Set<string>();

    for (const key of cellKeys) {
      if (!this.cells.has(key)) {
        this.cells.set(key, new Set());
      }
      this.cells.get(key)!.add(entity);
      entityCellSet.add(key);
    }

    this.entityCells.set(entity, entityCellSet);
  }

  remove(entity: T): void {
    const cellKeys = this.entityCells.get(entity);
    if (cellKeys) {
      for (const key of cellKeys) {
        this.cells.get(key)?.delete(entity);
      }
      this.entityCells.delete(entity);
    }
  }

  update(entity: T): void {
    this.remove(entity);
    this.insert(entity);
  }

  queryRect(x: number, y: number, width: number, height: number): Set<T> {
    const result = new Set<T>();
    const startX = Math.floor(x / this.cellSize);
    const startY = Math.floor(y / this.cellSize);
    const endX = Math.floor((x + width) / this.cellSize);
    const endY = Math.floor((y + height) / this.cellSize);

    for (let cx = startX; cx <= endX; cx++) {
      for (let cy = startY; cy <= endY; cy++) {
        const cell = this.cells.get(this.getKey(cx, cy));
        if (cell) {
          for (const entity of cell) {
            // Precise bounds check
            if (this.intersects(entity, x, y, width, height)) {
              result.add(entity);
            }
          }
        }
      }
    }

    return result;
  }

  queryRadius(centerX: number, centerY: number, radius: number): Set<T> {
    const result = new Set<T>();
    const radiusSq = radius * radius;

    // Query bounding box
    const candidates = this.queryRect(
      centerX - radius,
      centerY - radius,
      radius * 2,
      radius * 2
    );

    for (const entity of candidates) {
      const dx = entity.x + entity.width / 2 - centerX;
      const dy = entity.y + entity.height / 2 - centerY;
      if (dx * dx + dy * dy <= radiusSq) {
        result.add(entity);
      }
    }

    return result;
  }

  private intersects(entity: T, x: number, y: number, width: number, height: number): boolean {
    return !(
      entity.x + entity.width < x ||
      entity.x > x + width ||
      entity.y + entity.height < y ||
      entity.y > y + height
    );
  }

  clear(): void {
    this.cells.clear();
    this.entityCells.clear();
  }
}

// Usage
const grid = new SpatialHashGrid<Enemy>(100); // 100px cells

// Insert all enemies
for (const enemy of enemies) {
  grid.insert(enemy);
}

// Find nearby enemies (O(1) average instead of O(n))
const nearPlayer = grid.queryRadius(player.x, player.y, 200);
for (const enemy of nearPlayer) {
  checkCollision(player, enemy);
}
```

### Quadtree for Dynamic Scenes

```typescript
interface QuadTreeItem {
  x: number;
  y: number;
  width: number;
  height: number;
}

class QuadTree<T extends QuadTreeItem> {
  private items: T[] = [];
  private children: QuadTree<T>[] | null = null;
  private depth: number;

  constructor(
    private bounds: { x: number; y: number; width: number; height: number },
    private maxItems: number = 8,
    private maxDepth: number = 8,
    depth: number = 0
  ) {
    this.depth = depth;
  }

  insert(item: T): boolean {
    // Check if item intersects this node
    if (!this.intersects(item)) return false;

    // If we have children, insert into them
    if (this.children) {
      for (const child of this.children) {
        child.insert(item);
      }
      return true;
    }

    // Add to this node
    this.items.push(item);

    // Subdivide if needed
    if (this.items.length > this.maxItems && this.depth < this.maxDepth) {
      this.subdivide();
    }

    return true;
  }

  private subdivide(): void {
    const { x, y, width, height } = this.bounds;
    const halfW = width / 2;
    const halfH = height / 2;

    this.children = [
      new QuadTree({ x, y, width: halfW, height: halfH }, this.maxItems, this.maxDepth, this.depth + 1),
      new QuadTree({ x: x + halfW, y, width: halfW, height: halfH }, this.maxItems, this.maxDepth, this.depth + 1),
      new QuadTree({ x, y: y + halfH, width: halfW, height: halfH }, this.maxItems, this.maxDepth, this.depth + 1),
      new QuadTree({ x: x + halfW, y: y + halfH, width: halfW, height: halfH }, this.maxItems, this.maxDepth, this.depth + 1),
    ];

    // Redistribute items
    for (const item of this.items) {
      for (const child of this.children) {
        child.insert(item);
      }
    }
    this.items = [];
  }

  query(rect: { x: number; y: number; width: number; height: number }): T[] {
    const result: T[] = [];

    if (!this.intersectsRect(rect)) return result;

    for (const item of this.items) {
      if (this.itemIntersectsRect(item, rect)) {
        result.push(item);
      }
    }

    if (this.children) {
      for (const child of this.children) {
        result.push(...child.query(rect));
      }
    }

    return result;
  }

  private intersects(item: T): boolean {
    return this.intersectsRect(item);
  }

  private intersectsRect(rect: { x: number; y: number; width: number; height: number }): boolean {
    return !(
      rect.x > this.bounds.x + this.bounds.width ||
      rect.x + rect.width < this.bounds.x ||
      rect.y > this.bounds.y + this.bounds.height ||
      rect.y + rect.height < this.bounds.y
    );
  }

  private itemIntersectsRect(item: T, rect: { x: number; y: number; width: number; height: number }): boolean {
    return !(
      item.x > rect.x + rect.width ||
      item.x + item.width < rect.x ||
      item.y > rect.y + rect.height ||
      item.y + item.height < rect.y
    );
  }

  clear(): void {
    this.items = [];
    this.children = null;
  }
}
```
