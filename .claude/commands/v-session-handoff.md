---
description: Run the agentic-session-handoff skill to scan conversation history, extract architectural decisions and solved traps, and write a persistent checkpoint for successor agents.
---

# /v-session-handoff

Invoke the `agentic-session-handoff` skill to review the entire dialogue, summarize key accomplishments, document solved edge cases, and pass knowledge cleanly to the next agent session.

## Quick Trigger Guide:
- Use `/v-session-handoff` (or `/v-agent-handoff`) whenever:
  1. The conversation has grown long and you want to prevent AI memory loss or hallucinations.
  2. You want to close the current session and ensure the next agent immediately understands full context.
  3. You completed a major milestone (e.g., MVP or Phase) and need a consolidated persistent checkpoint.
- Produces a persistent knowledge snapshot at `docs/SESSION_HANDOFF.md`.
- Follows the instructions in [agentic-session-handoff](../skills/agentic-session-handoff/SKILL.md).
