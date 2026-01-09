---
name: philosophy
description: Helps developers write simpler code by finding the minimal solution that makes changes easy
---

# Architectural Thinking

This skill helps developers write code that's genuinely easier to work with - not by adding patterns, but by finding the simplest solution that makes changes easy.

## When This Applies

Activate this thinking when someone:
- Asks if their code is "well-architected"
- Feels stuck or overwhelmed by complexity
- Wonders whether to add an abstraction
- Is about to refactor something
- Asks "should I use [pattern X] here?"

## The Core Question

Before thinking about patterns or architecture, ask:

> **"How much do I need to hold in my head to make this change?"**

Good architecture minimizes this. Bad architecture - whether too simple OR too complex - maximizes it.

## The Honest Trade-offs

There's no perfect answer. Every choice trades something:

| Choice | You Get | You Pay |
|--------|---------|---------|
| Add abstraction | Flexibility later | Complexity now |
| Keep it simple | Speed now | Maybe harder to change later |
| Optimize early | Performance | Flexibility |
| Stay flexible | Easy changes | Some runtime cost |

The introduction to Game Programming Patterns puts it beautifully:

> *"It's easier to make a fun game fast than it is to make a fast game fun."*

Translation: Get it working simply first. Optimize and abstract only when you feel the pain.

## Signs You Might Be Over-Engineering

- Adding interfaces with only one implementation
- Building "extension points" for changes you're guessing about
- Feeling proud of how clever the architecture is
- Taking longer to trace through abstractions than to understand the actual logic
- Creating patterns because "best practices" rather than felt need

## Signs You Might Be Under-Engineering

- Changing one feature breaks unrelated things
- Copy-pasting similar code in multiple places
- Boolean flags multiplying with invalid combinations
- Dreading touching certain files
- New team members can't understand the flow

## The Simplicity Test

After writing code, ask:

1. **Could someone understand this without me explaining it?**
2. **If I needed to change this in 3 months, how many files would I touch?**
3. **Am I solving today's problem or guessing about tomorrow's?**

## When Patterns Actually Help

Patterns aren't good or bad - they're tools. Reach for them when:

- You feel specific pain that the pattern addresses
- The pattern would make the code *simpler* to understand, not more complex
- You're repeating yourself in ways that cause real bugs
- The abstraction earns its keep immediately, not hypothetically

## When to Just Write the Obvious Thing

Most of the time! The introduction says:

> *"I try very hard to write the cleanest, most direct solution to the problem. The kind of code where after you read it, you understand exactly what it does and can't imagine any other possible solution."*

Three similar lines of code are often better than a premature abstraction.

## The Goal

You want code where:
- Changes feel natural, like the code anticipated them
- You can understand any part without loading the whole system into your head
- New developers can contribute without a week of archaeology
- You're not afraid to touch it

This isn't about following rules. It's about **feeling** when the code is fighting you vs flowing with you.

---

*For specific patterns when you need them, ask about the pattern index or a specific pattern by name.*
