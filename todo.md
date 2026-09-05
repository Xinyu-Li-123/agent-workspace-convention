# To-do List

- [ ] Write a cli that do common operations on agws, e.g. create, switch to,

- [ ] Let agent commit with session info (append agws path, session id and optional session name in commit message)

- [ ] In root and subfolder readme, maintain list of references

- [ ] In root readme, maintain session id of all agents spawned in the agws; In commit message, maintain the session id of the agent that make this commit.

  In root readme, we add a dedicated section in the end called `## Sessions`, which maintains a list of convo in the format of
  
  ```
  - agent type: `agent_type`: 

    - session id: `session_id`

    - session title `session_title`
  ```

  And for each commit message append this to the commit message

  ```
  This commit is created by <agent_type> in session `<session_id>` ("<session_name>")
  ```

  This info can be obtained deterministically via a `agws-session-info` tool we defined for each agent separately.

  We can define a mcp server called "agws" that provide these tools

  - `agws_get_session_info_raw`: get the raw session info in the form of a json object (using a helper function).

    ```json
    {
      "agent_type": string,
      "session_id": string,
      "session_title": string | null
    }
    ```

  - `agws_get_session_info_root_readme`: get the session info formatted to be added in root README's "## Sessions" section's unordered list.

    ```markdown
    - agent_type: `session_id` ("session_title")
    ```

    `("session_title")` is omitted if title is null

  - `agws_get_session_info_commit_msg`: get the session info formatted to be appended to a commit message.

    ```markdown
    This commit is created by `agent_type` in session `session_id` ("session_title")
    ```

    `("session_title")` is omitted if title is null

- [ ] Can we make refactoring in agws easier? Example pain points

  - When we move an existing docs, all references to it should be updated somehow

  - When we fix a mistake in a doc, all other docs that depending on this doc should be updated

- [ ] Need to restrain agents from "leaking" agws-specific terms, this refers to things like using a term defined in a specific agws, referring to a doc by its path in the agws

- [ ] Whenever an agent generate a doc under docs/ , prepend a TLDR section. This excludes README.md files, which are only indices.
