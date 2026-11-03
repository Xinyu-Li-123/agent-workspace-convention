# Agent Workspace Convention

Agent workspace convention is a set of rules for AI agents to maintain durable shared
context about a topic across sessions. An agent workspace may represent a ticket,
investigation, or any other topic.

For example, to resolve a ticket, I need agents to read the codebase for background
knowledge, triage the bug statically, reproduce the bug, and implement the fix. All of this
can be organized under one workspace about the ticket, so an agent implementing the fix
knows how the bug can be reproduced.

It provides:

- Durable shared context around a topic across sessions.
- Progressive disclosure of that context, so we don't dilute the agent's context.
- Tracking workspace evolution with Git.

## What a workspace looks like

A workspace under `~/agws` might look like this:

```text
tickets/TICKET-123/
├── README.md          # index: what is here, and where to read next
├── docs/
│   ├── api-walkthrough.md
│   └── root-cause/
│       ├── README.md  # topic index: evidence, timeline, ruled out
│       ├── timeline.md
│       └── ruled-out.md
└── artifacts/
    └── reproducer/    # its own repo: code that reproduces the bug
```

Agents start at the workspace README, then read only the documents the task needs. This is
the shape, not the rules: the convention and a full worked example are in
[`agws/README.md`](agws/README.md).

## Getting Started

```bash
mkdir -p ~/agws
cp -r ./agws/. ~/agws/
```

`~/agws` then contains the convention document (`README.md`) that agents read, and
`init-agent-ws.sh`, which scaffolds a new workspace:

```bash
cd <parent of workspace>
~/agws/init-agent-ws.sh <workspace name>
```

Then point agents at the convention from your global `AGENTS.md`:

```markdown
- Agent workspace convention: If your cwd is under `~/agws/` (i.e. `~/agws/**/*`), read
  `~/agws/README.md` and follow the convention defined there. Otherwise, ignore this
  bullet point.
```

## Repository layout

- `agws/`: the convention document and the initialization script. Deploy it by copying the
  directory to `~/agws`.
- `agws-cli/`: a Rust CLI for workspace lifecycle and exploration, under development.
- `todo.md`: the project backlog.

`agws/README.md` is the canonical convention text. This README introduces the project and
does not restate the rules.
