# Decisions — git-plugin

Architectural decisions for the git-plugin, in lightweight ADR format.

---

## Decision 001 — Adopted agentic scaffold (2026-04-21)

**Context:** The plugin had a README but no CLAUDE.md, no decision log, no changelog, and future skill ideas were buried in a README section. As the plugin considers new skills (review, branch, sync, release, diff), conventions need to be explicit.

**Decision:** Add the standard agentic scaffold (CLAUDE.md, CHANGELOG.md, DECISIONS.md, ROADMAP.md). Migrate the README's "Roadmap" section into ROADMAP.md proper so future directions have a structured home with the ROADMAP → DECISIONS pipeline.

**Consequences:**
- Agent sessions have explicit safety principles and conventions documented in CLAUDE.md
- Future skills are tracked with statuses rather than a flat bullet list in the README
- Pre-scaffold version history is reconstructed in CHANGELOG from git log
- Adds four small files; README's roadmap section can be simplified to a pointer

**Alternatives Considered:**
- *Leave as-is* — workable at four skills, but would become unwieldy as the roadmap grows
- *Just add CLAUDE.md* — misses the opportunity to establish the full decision/roadmap pipeline
