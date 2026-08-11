---
AGENT_WS_PARENT: ~/agent-root/
---

# How Agent Workspace Works

A top-level Git directory under `AGENT_WS_PARENT` is called an **agent workspace**. It is used as durable shared context about different aspects of a topic across agent sessions. An agent workspace may represent a ticket, investigation, or any other topic.

## How to maintain agent workspace

> Assume cwd is the agent workspace root

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

* Put durable written knowledge under `docs/`.
* Put substantial code artifacts under `artifacts/<appropriate-name>/` as nested Git repositories.
* Keep temporary and intermediate files under `./tmp/`, and ignore it in `./.gitignore`.
* Workspace-level files such as `.gitignore`, `AGENTS.md`, or tool configuration may live at the root when they apply to the workspace as a whole.

The goal is that a future agent can start with `README.md`, discover the relevant durable context and artifacts, and continue the work without needing previous conversation history.

### Git commits

Use the workspace Git history to record meaningful changes to durable shared context.

Commit when a coherent piece of knowledge is added, corrected, or substantially updated. Do not create commits for every agent action or intermediate edit.

A commit should normally include the relevant `docs/` changes together with any corresponding `README.md` index update.

Before committing, inspect the diff and ensure temporary files and nested repositories are not included.

Use short commit messages that describe the knowledge or workspace change.

Nested repositories under `artifacts/` maintain their own Git histories and should be committed independently.

### Example

An agent workspace might look like:

```text
.
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
# Example Topic

## docs

- `docs/context/api_walkthrough.md`: Walkthrough of normal API behavior and relevant code locations.
- `docs/triage/root_cause_analysis.md`: Root-cause analysis with evidence and ruled-out hypotheses.

## artifacts

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

## How to know which agent workspace you are in?

Traverse upward until reaching `AGENT_WS_PARENT`. The top-level Git repository below `AGENT_WS_PARENT` is the agent workspace you are in.
