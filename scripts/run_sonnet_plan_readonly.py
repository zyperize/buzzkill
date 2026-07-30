#!/usr/bin/env python3
import subprocess
from pathlib import Path

root = Path(__file__).resolve().parents[1]
cmd = [
    'npx','claude','-p',
    'Read docs/research/platform-resources.md and docs/prompts/sonnet-plan-prompt.md from this repo. Use the official platform resources and policy notes to ground the answer. Explicitly cite relevant framework and policy names like AccessibilityService, UsageStatsManager, Family Controls, Device Activity, Managed Settings, and the Google Play AccessibilityService policy when relevant. Then produce only the requested plan in markdown.',
    '--model','sonnet',
    '--max-turns','6',
    '--allowedTools','Read'
]
result = subprocess.run(cmd, cwd=str(root), capture_output=True, text=True, timeout=480, check=True)
(root / 'docs/plans/sonnet-root-plan.md').write_text(result.stdout)
print('OK')
print(len(result.stdout))
