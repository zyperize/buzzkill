#!/bin/bash
set -euo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"
cat docs/research/platform-resources.md docs/prompts/sonnet-plan-prompt.md | npx claude -p 'The first section of stdin contains official platform resources and policy notes. The second section contains the task. Use the official sources to ground the plan, explicitly cite the relevant frameworks/policies by name, and produce only the requested plan in markdown.' --model sonnet --effort high --max-turns 8 > docs/plans/sonnet-root-plan.md
