# Agent Workspace Convention

Agent workspace convention is a set of rules for ai agents to maintain durable shared context about a topic across sessions. An agent workspace may represent a ticket, investigation, or any other topic.

For example, to resolve a ticket, I need to let agents read the codebase for background knowledge, triage the bug statically, reproduce the bug, and implement the fix. All these can be organized under one workspace about this ticket, so an agent implementing the fix can know how the bug can be reproduced.

Agent workspace convention provides these features:

- Durable shared context around a topic across sessions

- Progressive disclosure about the shared context, so we don't dilute the agent's context

- Tracking agent workspace evolution with git

## Getting Started

- Copy `./agent-root` to your file system at `~/agent-root`. It contains

  - a `README.md` file that explains the agent workspace convention to LLM agents

  - a script `init-agent-ws.md` that scaffold a workspace. You can use it by

    ```bash
    cd <parent of workspace>
    ~/agent-root/init-agent-ws.sh <workspace name>
    ```

- Update global `AGENTS.md` file to point agents to `~/agent-root/README.md` if necessary. For example, I'm using this bullet point in my global `AGENTS.md`

  ```markdown
  - Agent workspace convention: If your cwd is under `~/agent-root/` (i.e. `~/agent-root/**/*`), read `~/agent-root/README.md` and follow the agent workspace convention defined there. Otherwise, ignore this bullet point.
  ```

## Example

Assume you have set up agws as is described in [Getting Started](#getting-started).

Let's say you are working on a bug in an API service that causes infinite retries. The ticket is called `TICKET_123`.

As a user, you will first use the `./agent-root/init-agent-ws.sh` script in this repo to create an agws about this topic:

```bash
mkdir -p ~/agent-root/tickets
cd ~/agent-root/tickets/
~/agent-root/init-agent-ws.sh ticket_123
cd ticket_123/
```

Then, you will spawn agents in the agws to work on different aspects of this bug, such as

- Generate a walkthrough of the API service
- Reproduce the bug
- Analyze the root cause of the bug
- provide some playbooks to play around with the API service yourself

The agents will pick up the agws convention from their global `AGENT.md` (per our setup in [Getting Started](#getting-started)), and persist their knowledge in the agws as docs and artifacts. After several sessions, the agws may evolve into a folder like this:

```text
~/agent-root/tickets/ticket_123
├── .git/
├── .gitignore
├── README.md
├── docs/
│   ├── api_walkthrough.md          # single doc (flat)
│   ├── playbooks/                  # loose grouping – no folder README
│   │   ├── restart.md
│   │   └── failover.md
│   └── root-cause/                 # cohesive topic – has a folder README
│       ├── README.md
│       ├── timeline.md
│       └── ruled_out.md
├── artifacts/
│   └── bug-reproducer/
│       ├── .git/
│       ├── README.md
│       └── reproduce.py
└── tmp/
```

Its root `README.md` might become

```markdown
# Example Topic

This agws is about the bug in TICKET_123, where our API service retries indefinitely.

## docs

- `docs/api_walkthrough.md`: Walkthrough of normal API behavior and relevant code locations.
- `docs/playbooks/restart.md`: How to restart the service safely.
- `docs/playbooks/failover.md`: Manual failover steps.
- `docs/root-cause/`: Root-cause investigation – evidence, timeline, ruled-out hypotheses. See its README.

## artifacts

- `artifacts/bug-reproducer/`: Minimal scripts to reproduce the observed API failure.
```

The folder-level readme at `docs/root-cause/README.md` might be:

```markdown
# Root-cause investigation

What we were chasing and the current conclusion, in a few lines.

- `timeline.md`: Reconstructed sequence of events with evidence.
- `ruled_out.md`: Hypotheses considered and why they were rejected.
```

And the git commit history might be

```text
$ git log --oneline

8d312c1 fix: compare candidate approaches
57be842 triage: identify request timeout root cause
314ac90 context: document normal API request flow
cc93a21 init agent workspace
```

## How the convention works

See `./agent-root/README.md` for the full convention. In short:

- Each workspace is a Git repository for one topic. The root `README.md` contains a table of content that a summary of each doc, so the agent can have an overview of the context, and read into the details if needed.

- Useful knowledge is stored as markdown files in `docs/`, substantial code is stored in `artifacts/` as nested git repo.

- When an agent persist some knowledge, it will update both `docs/` with the knowledge as markdown and add an entry in root README for reference.
