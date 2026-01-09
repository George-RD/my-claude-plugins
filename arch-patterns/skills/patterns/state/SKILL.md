---
name: state-pattern
description: Replace tangled conditionals with state objects where each state handles its own behavior
---

# State Pattern

Replace tangled conditionals with state objects. Each state handles its own behavior.

## When You Actually Need This

- **Multiple booleans getting tangled** - `isJumping && !isCrouching && !isDead`...
- **Invalid state combinations** - Flags can be set in ways that don't make sense
- **Behavior varies by state** - Same input does different things depending on mode

## The Core Idea

Instead of checking state everywhere, each state is an object that handles its own behavior.

```typescript
// Before: scattered conditionals
class Player {
  isJumping = false;
  isCrouching = false;
  isDead = false;

  handleInput(input: Input) {
    if (this.isDead) return;

    if (input === 'JUMP') {
      if (!this.isJumping && !this.isCrouching) {
        this.isJumping = true;
        // jump logic...
      }
    } else if (input === 'CROUCH') {
      if (!this.isJumping) {
        this.isCrouching = true;
        // crouch logic...
      }
    }
    // More tangled conditions...
  }
}

// After: state objects
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

class StandingState implements PlayerState {
  handleInput(player: Player, input: Input): PlayerState | null {
    if (input === 'JUMP') return new JumpingState();
    if (input === 'CROUCH') return new CrouchingState();
    return null;
  }
}

class JumpingState implements PlayerState {
  handleInput(player: Player, input: Input): PlayerState | null {
    // Can't crouch while jumping - no check needed, state handles it
    return null;
  }
}
```

## Minimal Implementation

```typescript
interface State {
  enter?(context: any): void;
  exit?(context: any): void;
  update(context: any, dt: number): void;
  handleInput(context: any, input: Input): State | null;
}

class StateMachine {
  constructor(private state: State, private context: any) {
    this.state.enter?.(this.context);
  }

  update(dt: number) {
    this.state.update(this.context, dt);
  }

  handleInput(input: Input) {
    const newState = this.state.handleInput(this.context, input);
    if (newState) {
      this.state.exit?.(this.context);
      this.state = newState;
      this.state.enter?.(this.context);
    }
  }
}
```

## When to Skip This

- **Simple on/off toggle** - A boolean is fine
- **Two or three states** - A switch statement is clearer
- **States don't have behavior** - Pattern is for behavior that varies by state

## Trade-offs

| You Get | You Pay |
|---------|---------|
| Invalid states become impossible | More classes/objects |
| State-specific behavior is focused | Need to trace through state transitions |
| Easy to add new states | Slightly more ceremony for simple cases |

## Variations

**Entry/exit actions** - Do something when entering or leaving a state:
```typescript
class JumpingState {
  enter(player: Player) { player.playSound('jump'); }
  exit(player: Player) { player.playSound('land'); }
}
```

**Pushdown automata** - Remember previous state to return to:
```typescript
class StateMachine {
  private stack: State[] = [];

  push(state: State) {
    this.stack.push(this.state);
    this.transition(state);
  }

  pop() {
    const previous = this.stack.pop();
    if (previous) this.transition(previous);
  }
}
```

## The Simpler Alternative

For simple cases, a discriminated union works well:

```typescript
type PlayerState =
  | { type: 'standing' }
  | { type: 'jumping'; startTime: number }
  | { type: 'crouching' };

function handleInput(state: PlayerState, input: Input): PlayerState {
  switch (state.type) {
    case 'standing':
      if (input === 'JUMP') return { type: 'jumping', startTime: Date.now() };
      if (input === 'CROUCH') return { type: 'crouching' };
      return state;
    case 'jumping':
      return state;  // Can't change state while jumping
    // ...
  }
}
```

Use full State pattern when states have complex behavior. Use discriminated unions when states are mostly data.
