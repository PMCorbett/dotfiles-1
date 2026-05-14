---
name: create-mr
description: >-
  Creates a GitLab merge request for the current branch using Gary MCP, after
  resolving the JIRA key from the branch name and loading the issue from
  Atlassian MCP. Use when the user asks to create an MR, merge request, open a
  merge request, or raise a merge request for the current branch.
---

# Create merge request

Create a merge request for the **current** Git branch: infer intent from the
conversation, gather JIRA and git context, then call GitLab via **Gary MCP**
(`user-remote-gary`). Use **Atlassian MCP** (`user-Atlassian-MCP-Server`) for
the ticket.

## Before you call any MCP tool

Read each tool’s JSON schema under the MCP descriptors folder (same rule as
elsewhere in this workspace): confirm required fields and types, then call.

## 1. Branch and JIRA key

1. Current branch: `git branch --show-current` (or equivalent).
2. **Expected branch shape:** `worktype/ticket-number`, e.g. `feat/GT-1234`,
   where `GT-1234` is the JIRA issue key.
3. Extract the key with a pattern such as: last path segment after `/` must
   match a JIRA-style key (typically `LETTERS-NUMBER`, e.g. `GT-1234`).
4. If the branch does **not** match or no key is found: tell the user, ask for
   the issue key (or an amended branch name), and **do not** guess a key from
   unrelated text.

## 2. Resolve Atlassian `cloudId`

1. Call `getAccessibleAtlassianResources` on **user-Atlassian-MCP-Server** when
   you need a `cloudId`, or when passing a site hostname as `cloudId` fails.
2. Use the returned `cloudId` with `getJiraIssue`.

## 3. Load the JIRA issue

1. On **user-Atlassian-MCP-Server**, call `getJiraIssue` with:
   - `cloudId` from step 2
   - `issueIdOrKey` = key from step 1
2. Prefer `responseContentFormat: "markdown"` when you want readable summary
   fields in the model context.
3. Use the issue **summary**, **description**, acceptance criteria, and any
   other returned fields to anchor what the ticket is meant to deliver.

## 4. What changed on this branch (and why)

Synthesise a short, accurate narrative from:

| Source | What to use |
|--------|----------------|
| **JIRA issue** | Summary, description, intent, acceptance criteria |
| **Git** | Commits on this branch not on the target branch (see below), one-line subjects, authors if helpful |
| **Chat** | User-stated goals, constraints, or ticket references from this conversation |

**Git commands (adapt default branch if needed):**

- Discover default branch, e.g.  
  `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'`  
  or use `main` if that is clearly the repo default.
- Commit range (example):  
  `git log --oneline origin/<default-branch>..HEAD`

If the user gave extra context in chat that git/JIRA do not show, include it
briefly under a **Notes** or **Context** subsection.

## 5. GitLab project and duplicate MRs

1. **Project path:** parse `git remote get-url origin` (e.g. SSH  
   `git@gitlab.com:wealthwizards/guidance/monorepo-faramir.git` →  
   `wealthwizards/guidance/monorepo-faramir`). Use that string as `project_id`
   for Gary unless the user specifies another project.
2. Optionally call `list_merge_requests` on **user-remote-gary** with the same
   `project_id`, `source_branch` = current branch, `state` = `opened`, to avoid
   creating a duplicate MR. If one exists, share the link instead of creating
   another.

## 6. Create the MR (Gary MCP)

On **user-remote-gary**, call `create_merge_request` with:

- `project_id` — from step 5
- `source_branch` — current branch name
- `target_branch` — default branch (from step 4) unless the user asked for a
  different base
- `title` — concise; usually include the JIRA key and mirror or shorten the
  issue summary (e.g. `GT-1234: …`).
- `description` — markdown body built from step 4 (what / why / how to review),
  then **exactly** the following lines for GitLab quick actions (verbatim,
  including line breaks):

```
/assign-me

/assign_reviewer @wealthwizards/guidance
```

Place those two lines **at the end** of the description so assignment runs
after the narrative.

## 7. After creation

Reply with the MR URL (from the tool response) and a one-sentence recap of what
the MR does. If JIRA or Gary returns an auth or permission error, report it and
stop; do not fabricate an MR link.

## Failure modes

- **No JIRA key on branch:** stop and ask the user for the key or branch rename.
- **Multiple possible keys:** prefer the segment after the final `/` that matches
  `PROJECT-123` style; if still ambiguous, ask the user.
- **Ticket not found:** confirm key and `cloudId`; report the API error.
- **Branch not pushed:** GitLab may reject or show no commits; suggest  
  `git push -u origin <branch>` and retry after push.
