# Agent Workspace Convention

Agent workspace convention is a set of rules for ai agents to maintain durable shared context about a topic across sessions. An agent workspace may represent a ticket, investigation, or any other topic. For example, to resolve a ticket, I need to read the codebase for background knowledge, triage the bug statically, reproduce the bug, and implement the fix. All these can be organized under one workspace about this ticket, so an agent implementing the fix can know how the bug can be reproduced.

Agent workspace convention provides these features:

- Durable shared context around a topic across sessions

- Progressive disclosure about the shared context, so we don't dilute the agent's context

- Track agent workspace evolution with git

## Getting Started

- Copy `./agent-root` to your file system at `~/agent-root`. It contains

  - a `README.md` file that explains the agent workspace convention to LLM agents

  - a script `init-agent-ws.md` that scaffold a workspace. You can use it by

    ```bash
    cd <parent of workspace>
    ~/agent-root/init-agent-ws.sh <workspace name>
    ```

- Update global AGENTS.md file to point agent to `~/agent-root/README.md` if necessary. For example, I'm using this bullet point in my global AGEMTS.md

  ```markdown
  - Agent workspace convention: If your cwd is under `~/agent-root/` (i.e. `~/agent-root/**/*`), read `~/agent-root/README.md` and follow the agent workspace convention defined there. Otherwise, ignore this bullet point.
  ```

## Details

### How to maintain agent workspace

> Assume `AGENT_WS_PARENT=~/agent-root`, and cwd is the agent workspace root at `$AGENT_WS_PARENT/<some-subfolders>`.

Treat the workspace filesystem as shared memory. Important findings should not live only in conversation history.

`./README.md` is the entry point. Keep it concise: maintain an index of durable knowledge and artifacts with brief descriptions. Agents should read `./README.md` first, then load only the documents or artifacts relevant to their task.

When a session produces useful durable knowledge:

1. Write or update a focused document under `docs/`.
2. Add or update its short descriptive entry in `README.md` under `## docs` (create one if it does not exist). Each entry maps a document path to a short description.
3. Keep detailed content out of `README.md`. We use progressive disclosure for such content.

When a session creates a substantial code artifact such as a tool, prototype, or experiment:

1. Create an appropriately named subdirectory under `./artifacts/`.
2. Initialize it as its own nested Git repository.
3. Do not track the nested repository in the agent workspace Git repository.
4. Add or update its short descriptive entry in `README.md` under `## artifacts` (create one if it does not exist). Each entry maps an artifact path to a short description of its purpose.

Keep the workspace root clean. In general:

- Put durable written knowledge under `docs/`.
- Put substantial code artifacts under `artifacts/<appropriate-name>/` as nested Git repositories.
- Keep temporary and intermediate files under `./tmp/`, and ignore it in `./.gitignore`.
- Workspace-level files such as `.gitignore`, `AGENTS.md`, or tool configuration may live at the root when they apply to the workspace as a whole.

The goal is that a future agent can start with `README.md`, discover the relevant durable context and artifacts, and continue the work without needing previous conversation history.

#### Example

An agent workspace might look like:

```text
~/agent-root/ticket/<ticket-id>/
├── .git/
├── .gitignore
├── README.md
├── docs/
│   ├── context/
│   │   └── api_walkthrough.md
│   └── triage/
│       └── root_cause_analysis.md
├── artifacts/
│   └── bug-reproducer/
│       ├── .git/
│       ├── README.md
│       └── reproduce.py
└── tmp/
```

Its `README.md` might contain:

```markdown
## Example Topic

### docs

- `docs/context/api_walkthrough.md`: Walkthrough of normal API behavior and relevant code locations.
- `docs/triage/root_cause_analysis.md`: Root-cause analysis with evidence and ruled-out hypotheses.

### artifacts

- `artifacts/bug-reproducer/`: Minimal scripts to reproduce the observed API failure.
```

And the git commit history might be

```text
$ git log --oneline

8d312c1 fix: compare candidate approaches
57be842 triage: identify request timeout root cause
314ac90 context: document normal API request flow
cc93a21 init agent workspace
```
