---
AGENT_WS_PARENT: ~/agent-root/
---

# How Agent Workspace Works

A top-level Git directory under `AGENT_WS_PARENT` is called an **agent workspace (agws)**. It is used as durable shared context about different aspects of a topic across agent sessions. An agent workspace may represent a ticket, investigation, or any other topic.

## How to maintain agent workspace

### General guideline

Treat the workspace filesystem as shared memory for all agents spawned in this workspace. Important findings should be persisted here, instead of living only in conversation history.

Assume cwd is the agent workspace root, `~/README.md` is the entry point. Keep it concise: maintain an index of durable knowledge and artifacts with brief descriptions. Agents should read `./README.md` first, then load only the documents or artifacts relevant to their task.

When a session produces useful knowledge:

1. Write or update a focused document under `docs/` or its subfolder.
2. Add or update its short descriptive entry in `README.md` under `## docs` (create one if it does not exist). Each entry maps a document path to a short description.
3. Keep detailed content out of `README.md`, so have progressive disclosure.

If you need to create multiple tightly related documents to persist the knowledge, refer to [Nested README](#nested-readme), and avoid dumping all document descriptions in `README.md`.

When a session creates a substantial code artifact such as a tool, prototype, or experiment:

1. Create an appropriately named subdirectory under `./artifacts/`.
2. Initialize it as its own nested Git repository.
3. Do not track the nested repository in the agent workspace Git repository.
4. Add or update its short descriptive entry in `README.md` under `## artifacts` (create one if it does not exist). Each entry maps an artifact path to a short description of its purpose.

Keep the workspace root clean. In general:

* Put durable written knowledge under `docs/`, and use nested readme if necessary.
* Put substantial code artifacts under `artifacts/<appropriate-name>/` as nested Git repositories.
* Keep temporary and intermediate files under `./tmp/`, and ignore it in `./.gitignore`.
* Workspace-level files such as `.gitignore`, `AGENTS.md`, or tool configuration may live at the root when they apply to the workspace as a whole.

The goal is that a future agent can start with `README.md`, discover the relevant durable context and artifacts, and continue the work without needing previous conversation history.

### Nested README

When we have several tightly related documents generated from a convo, we don't want to store them in root readme as a list of docs, since that will bloat the root readme. Instead, we use Nested README: when the documents form a **cohesive topic** that reads as a whole and benefits from its own index/overview, we should:

1. Put the documents in `docs/<topic>/` with `docs/<topic>/README.md` as the topic's entry point: brief high-level context plus a table of contents linking each document in reading order. It may also carry the topic's overview itself.
2. In the root `README.md`, the topic's `## docs` entry collapses to a **single line** pointing at the folder – not a per-document list. The per-document list lives only in the folder README. That single line in root README should contain a brief description of the folder's topic.
3. Use `README.md` as the index filename at every level, so an agent can open any folder's entry point without listing it first.

Add a folder `README.md` only when it is worth it. Keep nesting shallow. One level of topic folders is usually enough. Edits within a topic update the nearest folder README; the root README changes only when a whole topic is added or removed.

> Note: A `docs/<topic>/README.md` is only an index; it does **not** make the folder a separate workspace. Agent workspace is always defined as the top level git repo under `AGENT_WS_PARENT`

> Note: Grouping and indexing are two separate decisions. A `docs/<folder>/` may simply group loosely related documents under a category – that alone does **not** require a folder README; the root README can still list those documents individually (e.g. `docs/playbooks/restart.md`).

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

Its root `README.md` might contain (flat doc; grouping folder listed per-doc; cohesive topic as one line):

```markdown
# Example Topic

## docs

- `docs/api_walkthrough.md`: Walkthrough of normal API behavior and relevant code locations.
- `docs/playbooks/restart.md`: How to restart the service safely.
- `docs/playbooks/failover.md`: Manual failover steps.
- `docs/root-cause/`: Root-cause investigation – evidence, timeline, ruled-out hypotheses. See its README.

## artifacts

- `artifacts/bug-reproducer/`: Minimal scripts to reproduce the observed API failure.
```

And the nested folder index `docs/root-cause/README.md`:

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

## How to know which agent workspace you are in?

Traverse upward until reaching `AGENT_WS_PARENT`. The top-level Git repository below `AGENT_WS_PARENT` is the agent workspace you are in.
