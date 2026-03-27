# Universal Agent Guidelines — Claude Code & Kiro

> Source: Anthropic Prompting Best Practices (docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices)
> and Anthropic Frontend Design Skill (github.com/anthropics/claude-code)
> Last updated: 2026-03-26

---

## 1. Clarity and Directness

- Be specific about the desired output format and constraints.
- Provide instructions as sequential numbered steps when order matters.
- Add context or motivation behind instructions — Claude generalizes from explanation.
- Golden rule: if a colleague with minimal context would be confused by the prompt, Claude will be too.
- When intent is ambiguous, ask one focused clarifying question before proceeding.

---

## 2. Action vs. Suggestion

Claude is literal. Match your language to your intent:

- "Can you suggest changes?" → Claude suggests, does not implement.
- "Implement these changes" → Claude acts.

Default behavior: implement changes rather than only suggesting them. If user intent is unclear,
infer the most useful likely action and proceed using tools to discover missing details.

```xml
<default_to_action>
By default, implement changes rather than only suggesting them. If the user's intent is unclear,
infer the most useful likely action and proceed, using tools to discover any missing details
instead of guessing.
</default_to_action>
```

---

## 3. Incremental Development

- Implement in small, focused increments — 50-60 lines maximum per step.
- After each increment, explain what was done and why, then ask before continuing.
- Never dump large blocks of code in a single response.
- Think before coding: break down the problem, identify edge cases, plan the approach.

---

## 4. XML Structure for Complex Prompts

Use XML tags to separate instructions, context, examples, and inputs:

```xml
<instructions>...</instructions>
<context>...</context>
<examples>...</examples>
<input>...</input>
```

Use `<example>` tags (or `<examples>` for multiple) to wrap few-shot examples.
Include 3–5 examples for best results. Place long documents ABOVE the query, not below.

---

## 5. Thinking and Reasoning

- Prefer general instructions ("think thoroughly") over prescriptive step-by-step plans.
- Ask Claude to self-check: "Before you finish, verify your answer against [criteria]."
- For complex multi-step tasks, use structured tags: `<thinking>` and `<answer>`.
- Avoid over-prompting — Claude 4.x models are proactive; aggressive instructions cause overtriggering.

---

## 6. Agentic and Long-Horizon Tasks

- Focus on incremental progress — steady advances on a few things at a time.
- Use git for state tracking across sessions.
- Save progress state before context window refreshes.
- Confirm before irreversible actions: deleting files, force-pushing, dropping tables, posting externally.
- Use parallel tool calls for independent operations; sequential for dependent ones.

---

## 7. Minimize Overengineering

Only make changes that are directly requested or clearly necessary:

```xml
<avoid_overengineering>
Only make changes that are directly requested or clearly necessary. Keep solutions simple and focused.
Do not add features, refactor code, or make "improvements" beyond what was asked.
Do not add docstrings, comments, or type annotations to code you didn't change.
Do not create helpers or abstractions for one-time operations.
The right amount of complexity is the minimum needed for the current task.
</avoid_overengineering>
```

---

## 8. Minimize Hallucinations

```xml
<investigate_before_answering>
Never speculate about code you have not opened. If the user references a specific file,
read the file before answering. Investigate relevant files BEFORE answering questions
about the codebase. Never make claims about code before investigating.
</investigate_before_answering>
```

---

## 9. Frontend Design — Avoid "AI Slop" Aesthetics

> Source: Anthropic Frontend Design Skill SKILL.md (github.com/anthropics/claude-code/blob/main/plugins/frontend-design/skills/frontend-design/SKILL.md)

Before writing any frontend code, commit to a BOLD aesthetic direction:

- **Purpose:** What problem does this interface solve? Who uses it?
- **Tone:** Pick a clear direction — brutally minimal, maximalist, retro-futuristic, organic,
  luxury/refined, playful, editorial, brutalist, art deco, soft/pastel, industrial, etc.
- **Differentiation:** What makes this UNFORGETTABLE? What's the one thing someone will remember?

### Typography
- Choose fonts that are beautiful, unique, and interesting.
- NEVER use: Arial, Inter, Roboto, system fonts as primary choices.
- Pair a distinctive display font with a refined body font.
- Unexpected, characterful font choices elevate the entire design.

### Color & Theme
- Commit to a cohesive aesthetic. Use CSS variables for consistency.
- Dominant colors with sharp accents outperform timid, evenly-distributed palettes.
- NEVER use: purple gradients on white backgrounds (the most clichéd AI output).

### Motion & Interaction
- Use animations for effects and micro-interactions.
- Prioritize CSS-only solutions for HTML; Motion library for React.
- One well-orchestrated page load with staggered reveals creates more delight than scattered micro-interactions.
- Use scroll-triggering and hover states that surprise.

### Spatial Composition
- Unexpected layouts. Asymmetry. Overlap. Diagonal flow. Grid-breaking elements.
- Generous negative space OR controlled density — commit to one.

### Backgrounds & Visual Details
- Create atmosphere and depth — never default to solid colors.
- Apply: gradient meshes, noise textures, geometric patterns, layered transparencies,
  dramatic shadows, decorative borders, grain overlays.

### What to NEVER do
```xml
<no_ai_slop>
NEVER produce generic AI-generated aesthetics:
- Overused fonts: Inter, Roboto, Arial, Space Grotesk, system fonts as primary choices
- Clichéd color schemes: purple gradients on white, generic blue/grey enterprise palettes
- Predictable layouts: standard card grids, generic hero sections, cookie-cutter nav bars
- Cookie-cutter patterns that lack context-specific character
- The same design twice — no two designs should look the same

Interpret creatively. Make unexpected choices that feel genuinely designed for the context.
Vary between light and dark themes, different fonts, different aesthetics across generations.
Claude is capable of extraordinary creative work — commit fully to a distinctive vision.
</no_ai_slop>
```

### Match complexity to vision
- Maximalist designs need elaborate code with extensive animations and effects.
- Minimalist designs need restraint, precision, careful spacing, and subtle details.
- Elegance comes from executing the vision well, not from intensity alone.

---

## 10. Output Format Control

To minimize excessive markdown and bullet points:

```xml
<avoid_excessive_markdown>
Write in clear, flowing prose using complete paragraphs. Reserve markdown for inline code,
code blocks, and simple headings. DO NOT use ordered or unordered lists unless presenting
truly discrete items or the user explicitly requests a list. Incorporate items naturally
into sentences instead.
</avoid_excessive_markdown>
```

---

## 11. Global MCP Configuration — Stitch

**Status:** Configured globally at `~/.kiro/settings/mcp.json` (2026-03-27)

Stitch MCP is now available in all Kiro projects without per-workspace configuration. The global configuration includes:

- **Server:** `stitch` (node-based proxy via `tools/stitch-proxy.mjs`)
- **Status:** Enabled (`disabled: false`)
- **Auto-approved tools:** Read-only operations (list projects, get project, list screens, get screen)
- **Scope:** All workspaces inherit this configuration

To use Stitch MCP in any project:
1. Ensure the workspace has `tools/stitch-proxy.mjs` (or symlink to a shared location)
2. Run `gcloud auth application-default login` once to set up ADC (Application Default Credentials)
3. Stitch MCP tools are immediately available in agent prompts

**Note:** Write operations (generate screen, edit screen, apply design system) still require explicit approval per invocation — they are not auto-approved for safety.
