# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

This is a third-party Homebrew tap (`novacore-cc/tap`, hosted at `github.com/novacore-cc/homebrew-tap`) that distributes macOS Casks. End users install via `brew install --cask novacore-cc/tap/<cask>`. Each `.rb` file under `Casks/` is a Cask DSL definition consumed by Homebrew — there is no application code to build here.

## Common commands

Run from the tap root. `brew` must be installed and the tap must be discoverable (either tapped via `brew tap novacore-cc/tap` or symlinked into `$(brew --repo)/Library/Taps/novacore-cc/homebrew-tap`).

- Lint Cask syntax/style: `brew style ./Casks/<cask>.rb` (or `brew style .` for the whole tap)
- Audit a Cask (download, signature, livecheck): `brew audit --cask --new --online ./Casks/<cask>.rb` — drop `--new` after the cask is published
- Install locally to verify: `brew install --cask ./Casks/<cask>.rb`
- Verify upstream version detection: `brew livecheck --cask ./Casks/<cask>.rb`
- Run the same checks CI runs: `brew test-bot --only-tap-syntax` and `brew test-bot --only-formulae` (the latter only meaningful on a PR branch)
- Recompute `sha256` after bumping `version`: `shasum -a 256 <downloaded-zip>` — the SHA must match the asset at the templated `url`

## Release / PR flow

CI is split across two workflows:

- `.github/workflows/tests.yml` — runs `brew test-bot` on every push and PR across `ubuntu-22.04`, `macos-15-intel`, `macos-26`. PRs additionally upload built bottles as artifacts.
- `.github/workflows/publish.yml` — triggered when a maintainer adds the `pr-pull` label to a PR. It runs `brew pr-pull` to consume the bottle artifacts from the test workflow, pushes the resulting commits to `main`, and deletes the PR branch.

Practical implications:
- Cask updates land via PR, not direct pushes to `main`. The merge happens through the `pr-pull` label, not the GitHub merge button — do not squash/rebase-merge from the UI.
- A PR's bottle artifacts must succeed on the `tests.yml` run before `pr-pull` can find and pull them, so a red `tests.yml` blocks publish.
- `pull_request_target` is used in `publish.yml`; only edit that workflow with care, since it runs against the base branch with write permissions.

## Cask conventions in this tap

- Versioned GitHub release downloads: `url "https://github.com/<owner>/<repo>/releases/download/v#{version}/<Asset>-#{version}.zip"` paired with `livecheck { url :url; strategy :github_latest }`. Bumping a Cask = update `version`, update `sha256`, leave the URL template alone.
- `zap` blocks list user-data paths to remove on `brew uninstall --zap`. When adding a new Cask, include both `~/.config/<app>` and `~/Library/Application Support/<App>` style paths if the app writes to either.
- `depends_on macos:` should reflect the app's actual minimum, not a default.
