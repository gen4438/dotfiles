Create a git commit for changes made during this conversation.

Follow this process:

1. **Identify files changed in this conversation**:
   - Track which files were modified using Edit, Write, or NotebookEdit tools during this conversation
   - Do NOT include files that were already modified before this conversation started
   - If no files were changed in this conversation, inform the user and stop

2. **Stage the changes**:
   - Run `git status` to see the current state
   - Use `git add <file>` to stage only the files that were changed in this conversation
   - Run `git diff --staged` to show what will be committed

3. **Create commit message**:
   - Analyze the staged changes
   - Draft a concise commit message following the repository's existing commit style
   - Focus on "what" and "why" rather than implementation details
   - **IMPORTANT**: Do NOT include Claude Code attribution or generation notices
   - Do NOT add "🤖 Generated with Claude Code" or "Co-Authored-By: Claude"
   - Keep it simple and follow conventional commit style when appropriate

4. **Confirm with user**:
   - Present the proposed commit message to the user
   - Ask if they want to proceed, edit the message, or cancel
   - Wait for user approval before committing

5. **Execute commit**:
   - Run `git commit -m "message"` with the approved message
   - Run `git status` to verify the commit succeeded
   - Report the result to the user

Important notes:
- Only commit files that Claude Code changed in THIS conversation
- Exclude any unrelated changes that existed before
- If unsure which files to commit, ask the user
- Follow CLAUDE.md guidelines: no Claude Code attribution in commits
