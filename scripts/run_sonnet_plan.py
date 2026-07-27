#!/usr/bin/env python3
import subprocess
from pathlib import Path

root = Path('.')
resources = (root / 'docs/research/platform-resources.md').read_text()
prompt = (root / 'docs/prompts/sonnet-plan-prompt.md').read_text()
full_prompt = f'''You will receive official platform resources and a product-planning task. Use the resources to ground the plan, explicitly cite the relevant frameworks and policy names, and produce only the requested plan in markdown.\n\nOFFICIAL RESOURCES:\n\n{resources}\n\nTASK:\n\n{prompt}\n'''
result = subprocess.run(
    ['npx', 'claude', '-p', full_prompt, '--model', 'sonnet', '--effort', 'high', '--max-turns', '8'],
    cwd=str(root),
    capture_output=True,
    text=True,
    timeout=480,
    check=True,
)
out = root / 'docs/plans/sonnet-root-plan.md'
out.write_text(result.stdout)
print(f'WROTE:{out}')
print(f'BYTES:{len(result.stdout.encode())}')
