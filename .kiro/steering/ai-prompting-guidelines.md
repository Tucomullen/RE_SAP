---
inclusion: auto
description: Anthropic prompting best practices and frontend design anti-AI-slop guidelines for all agents in this workspace.
---

# AI Prompting Guidelines — RE-SAP IFRS 16 Addon

> Source: Anthropic Prompting Best Practices
> (docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices)
> and Anthropic Frontend Design Skill SKILL.md
> (github.com/anthropics/claude-code/blob/main/plugins/frontend-design/skills/frontend-design/SKILL.md)
> Last updated: 2026-03-26

These guidelines apply to all agents in this workspace and complement the behavioral rules
in `AGENTS.md`. They govern how agents communicate, structure outputs, and approach
frontend design work.

---

## Clarity and Instruction Structure

- Be specific about desired output format and constraints in every prompt.
- Provide instructions as sequential numbered steps when order or completeness matters.
- Add context or motivation behind instructions — Claude generalizes from explanation.
- Use XML tags to separate instructions, context, examples, and variable inputs:

```xml
<instructions>...</instructions>
<context>...</context>
<examples>...</examples>
<input>...</input>
```

- Wrap few-shot examples in `<example>` or `<examples>` tags. Include 3–5 examples for best results.
- Place long documents ABOVE the query in the prompt, not below.

---

## Action vs. Suggestion

Claude is literal. Language must match intent:

- "Can you suggest changes?" → Claude suggests only.
- "Implement these changes" → Claude acts.

When user intent is ambiguous, infer the most useful likely action and proceed using tools
to discover missing details rather than guessing or asking unnecessarily.

---

## Incremental Development

- Implement in small, focused increments — 50-60 lines maximum per step.
- Think before coding: break down the problem, identify edge cases, plan the approach.
- Never dump large blocks of code in a single response.
- After each increment, explain what was done and why, then confirm before continuing.

---

## Avoid Overengineering

Only make changes that are directly requested or clearly necessary:

- Do not add features, refactor code, or make "improvements" beyond what was asked.
- Do not add docstrings or comments to code you did not change.
- Do not create helpers or abstractions for one-time operations.
- The right amount of complexity is the minimum needed for the current task.

---

## Minimize Hallucinations

Never speculate about code or files you have not read. If the user references a specific file,
read it before answering. Investigate relevant files BEFORE answering questions about the
codebase. Never make claims about code before investigating.

---

## Agentic and Long-Horizon Tasks

- Focus on incremental progress — steady advances on a few things at a time.
- Use git for state tracking across sessions.
- Save progress state before context window refreshes.
- Confirm before irreversible actions: deleting files, force-pushing, dropping tables, posting externally.
- Use parallel tool calls for independent operations; sequential for dependent ones.

---

## Frontend Design — Avoid "AI Slop" Aesthetics

This section is mandatory for any UI or UX work in this project, including Stitch screen
generation, UI5 component design, and any HTML/CSS prototype.

### Before writing any frontend code

Commit to a BOLD aesthetic direction by answering:

1. **Purpose:** What problem does this interface solve? Who uses it?
2. **Tone:** Pick a clear direction — brutally minimal, maximalist, retro-futuristic, organic,
   luxury/refined, editorial, brutalist, art deco, soft/pastel, industrial, etc.
3. **Differentiation:** What makes this UNFORGETTABLE? What is the one thing a user will remember?

### Typography rules
- Choose fonts that are beautiful, unique, and interesting.
- NEVER use Arial, Inter, Roboto, Space Grotesk, or system fonts as primary choices.
- Pair a distinctive display font with a refined body font.

### Color rules
- Commit to a cohesive aesthetic. Use CSS variables for consistency.
- Dominant colors with sharp accents outperform timid, evenly-distributed palettes.
- NEVER use purple gradients on white backgrounds — the most clichéd AI output.

### Motion and interaction
- Use animations for effects and micro-interactions.
- One well-orchestrated page load with staggered reveals creates more delight than scattered micro-interactions.
- Use scroll-triggering and hover states that surprise.

### Spatial composition
- Unexpected layouts. Asymmetry. Overlap. Diagonal flow. Grid-breaking elements.
- Generous negative space OR controlled density — commit to one, do not mix timidly.

### Backgrounds and visual details
- Create atmosphere and depth — never default to solid colors.
- Apply: gradient meshes, noise textures, geometric patterns, layered transparencies,
  dramatic shadows, decorative borders, grain overlays.

### What to NEVER produce

```xml
<no_ai_slop>
NEVER produce generic AI-generated aesthetics:
- Overused fonts: Inter, Roboto, Arial, Space Grotesk, system fonts as primary choices
- Clichéd color schemes: purple gradients on white, generic blue/grey enterprise palettes
- Predictable layouts: standard card grids, generic hero sections, cookie-cutter nav bars
- Cookie-cutter patterns that lack context-specific character
- The same design twice — no two designs should look the same

Interpret creatively. Make unexpected choices that feel genuinely designed for the context.
Vary between light and dark themes, different fonts, different aesthetics.
Claude is capable of extraordinary creative work — commit fully to a distinctive vision.
</no_ai_slop>
```

### Match complexity to vision
- Maximalist designs need elaborate code with extensive animations and effects.
- Minimalist designs need restraint, precision, careful spacing, and subtle details.
- Elegance comes from executing the vision well, not from intensity alone.

---

## Output Format Control

Write in clear, flowing prose using complete paragraphs. Reserve markdown for inline code,
code blocks, and simple headings. Do not use ordered or unordered lists unless presenting
truly discrete items or the user explicitly requests a list.
