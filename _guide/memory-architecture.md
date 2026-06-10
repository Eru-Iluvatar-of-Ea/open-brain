---
title: Memory Architecture — push/pull layers, retrieval model, sizing
chapter: memory-architecture
compiled: 2026-06-11
sources:
  - 2026-06-11--open-brain--memory-layer-sizing-retention--checkpoint--v1.md
---

# Memory Architecture

## The push/pull split

- Layer 1 user-edits (30-slot) is **push**: loaded into context every turn, automatically, zero latency. No model decision involved.
- Open Brain is **pull**: nothing loads automatically. Thoughts reach context only when the model chooses to call a tool, and only the top-k matches (default 10) above the similarity threshold (default 0.5) are returned.
- Tool invocation is a per-turn judgment call, not a reflex — it can be missed on turns where it would have helped. Client-dependent: Claude Desktop auto-selects well; ChatGPT needs explicit prompting initially.
- "Up to 10 results" is a ceiling, not a guarantee. Queries with no matches above threshold return fewer or zero. Limit and threshold are adjustable per call.
- Consequence: anything that must fire on every turn cannot live in Open Brain — it belongs in Layer 1. The division of labor: Layer 1 holds cross-cutting, must-never-miss rules; Open Brain holds everything else, unbounded, at the cost of a tool round-trip. The Amanda/Rivendell in-pocket-latency entry (thought #2) is this line drawn deliberately.

## Sizing

- No meaningful upper bound. Under ~25 entries search feels sparse; ~30 to low thousands is the long-term sweet spot; tens of thousands and beyond remain fine — the HNSW index is built for it.
- There is no target number to manage toward. The layer is designed to grow unbounded; more entries generally improve retrieval discrimination.
- Irrelevant entries are not noise: similarity ranking means they never surface for unrelated queries. Capacity is never the limiting factor — relevance of what goes in is.
- Current state (as of 2026-06-11): 46 thoughts — 45 seeded 5/10–5/11/2026 plus one e2e test row — just past the sparse zone.

## Corrected model

- Supersedes the assumption that Open Brain is queried "every time" with a fixed ten results: retrieval is conditional on the model choosing to call the tool, and 10 is a ceiling above threshold, not a fixed return.

## Open

- none. (The "Peter" vs "Eru/ryslipp" identity question is resolved: confirmed 2026-06-11 that both refer to the same person — Eru is Peter's nickname, ryslipp his business email prefix. First-person queries and "Peter"-subject thoughts target the same identity.)
