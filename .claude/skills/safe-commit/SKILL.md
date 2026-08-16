---
name: safe-commit
description: Commit staged/working-tree changes with a clean, human-only commit message (no AI/Claude attribution), only after the project's tests pass. Use whenever the user asks to commit, or says "safe commit" / "/safe-commit". Aims for high unit test coverage on changed logic but never fabricates tests just to hit a number.
---

# Safe Commit

A stricter alternative to a normal `git commit`. It exists to guarantee two things a default commit doesn't: **no AI attribution ever appears in the message**, and **the commit is never made on top of a red or unverified test suite**.

## Step 1 — Detect the test command

Look for, in order, and use the first that matches:
1. An Xcode project/workspace (`*.xcodeproj` / `*.xcworkspace` in repo root) → run the unit test target via `xcodebuild`, e.g.:
   ```
   env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
     -project "<name>.xcodeproj" -scheme "<scheme>" \
     -sdk iphonesimulator -destination 'platform=iOS Simulator,name=<a booted or available iPhone sim>' \
     -enableCodeCoverage YES test
   ```
   (List available simulators with `xcrun simctl list devices available` if the scheme/destination isn't already known from context.)
2. A Swift package (`Package.swift`) → `swift test --enable-code-coverage`.
3. A `package.json` with a `test` script → `npm test` (or the repo's existing package manager — check for a lockfile: `pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn).
4. A Python project (`pyproject.toml` / `requirements.txt`) → `pytest --cov` if `pytest` is available, else the repo's documented test command.
5. Otherwise, ask the user what the test command is rather than guessing.

If a test command can't be determined and the user hasn't told you, stop and ask — do not commit unverified.

## Step 2 — Run tests, gate on the result

- Run the detected command.
- **If any test fails: stop.** Do not commit. Report the failing test(s) to the user and fix or ask before retrying. Never commit "to save progress" over a red suite.
- If tests were already known-green very recently in this same session (e.g. you just ran them to verify a fix) and nothing has changed since, you may skip re-running — otherwise always re-run before committing.

## Step 3 — Check coverage on what changed (best effort, not a hard gate)

- Pull the coverage report from the run above (`xcrun xccov view --report <.xcresult>` for Xcode, the coverage summary for `swift test`/`pytest --cov`/`npm test --coverage`, etc.).
- Compare against the files touched in this commit (`git diff --stat`, plus untracked new files being added).
- For each changed **logic** file (models, services, pure functions, view models) with meaningful coverage gaps, either add the missing test cases now or, if a gap is intentional (e.g. it calls a real on-device/network API that can't run in CI or a simulator), leave it — do not write a fake/mocked test just to inflate the number.
- Do **not** chase 100% on UI glue that's impractical to unit test (SwiftUI view bodies, `UIViewControllerRepresentable` wrappers, view controllers that just wire other tested pieces together) — that's normal and not a gap worth closing.
- Report the resulting coverage delta to the user in your summary (e.g. "ReturnDatePolicy: 100%, ReceiptListLogic: 100%, ScanView: 0% (UI, not unit-testable)") rather than silently passing or failing on it.

## Step 4 — Stage deliberately

- Review `git status` and `git diff` for what will be included.
- Stage specific files/paths (`git add <path> ...`), never `git add -A` or `git add .` — this avoids accidentally sweeping in unrelated scratch files, secrets, or `.env`-style files.
- If anything unexpected shows up in `git status` (files you didn't create/edit this session), investigate before staging it.

## Step 5 — Write the commit message with zero AI attribution

This is the one place this skill **overrides the default global git commit instructions** (which normally append a `Co-Authored-By: Claude ...` trailer) — for a safe-commit, that trailer must never be added.

Rules for the message:
- No `Co-Authored-By: Claude`, no `Generated with Claude Code`, no mention of Claude, AI, Anthropic, or any assistant/model name anywhere in the subject or body.
- Written as if the human author wrote it themselves — plain, first-person-neutral, no meta-commentary about "an AI made this change."
- Follow the repo's existing commit message style (check `git log --oneline -10` for tone/format: imperative mood, length, whether bodies are used).
- 1-2 sentences focused on *why*, matching this repo's existing single-line style unless the change genuinely needs a body.
- Pass the message via a heredoc so formatting/quoting is exact:
  ```
  git commit -m "$(cat <<'EOF'
  <subject line>

  <optional body>
  EOF
  )"
  ```

## Step 6 — Verify and report

- Run `git status` after committing to confirm a clean result.
- Tell the user: what was committed, that tests passed (and how — command used), and the coverage summary from Step 3. Do not push unless separately asked.
