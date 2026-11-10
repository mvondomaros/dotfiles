#!/usr/bin/env python3
"""Test real global Python tooling without downloading project dependencies."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

repo = Path(__file__).resolve().parents[1]
for tool in ['nvim', 'ruff', 'ty']:
    if not shutil.which(tool):
        raise SystemExit('Required global tool unavailable: ' + tool)
python = sys.executable
for name in ['python3.11', 'python3.12', 'python3.13', 'python3.14', 'python3.15']:
    candidate = shutil.which(name)
    if candidate:
        python = candidate
        break
with tempfile.TemporaryDirectory(prefix='dotfiles-python-') as temporary:
    root = Path(temporary).resolve()
    environment = root / '.pixi/envs/default'
    subprocess.run([python, '-m', 'venv', '--without-pip', str(environment)], check=True)
    interpreter = environment / 'bin/python'
    site = Path(subprocess.check_output([str(interpreter), '-c', 'import sysconfig; print(sysconfig.get_path("purelib"))'], universal_newlines=True).strip())
    package = site / 'dotfiles_lsp_probe'
    package.mkdir()
    (package / '__init__.py').write_text('def answer() -> int:\n    return 42\n')
    (package / 'py.typed').write_text('')
    (root / 'pyproject.toml').write_text('[project]\nname="dotfiles-test"\nversion="0.0.0"\nrequires-python=">=3.11"\n')
    sample = root / 'sample.py'
    env = os.environ.copy()
    for name in ['VIRTUAL_ENV', 'CONDA_PREFIX', 'CONDA_DEFAULT_ENV', 'PIXI_PROJECT_ROOT', 'PIXI_ENVIRONMENT_NAME']:
        env.pop(name, None)
    env.update(XDG_CACHE_HOME=str(root/'cache'), XDG_STATE_HOME=str(root/'state'), DOTFILES_PYTHON_TEST_FILE=str(sample), DOTFILES_PYTHON_TEST_SCRIPT=str(repo/'tests/check_python.lua'))
    for mode in ['project default', 'activated environment']:
        sample.write_text('from dotfiles_lsp_probe import answer\nnumber: int=answer()\ntext: str=answer()\n')
        if mode == 'activated environment':
            env.update(CONDA_PREFIX=str(environment), CONDA_DEFAULT_ENV='analysis', PIXI_PROJECT_ROOT=str(root), PIXI_ENVIRONMENT_NAME='analysis')
        result = subprocess.run(['nvim', '--headless', '-i', 'NONE', '-c', 'lua dofile(vim.env.DOTFILES_PYTHON_TEST_SCRIPT)'], cwd=str(root), env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True, timeout=35)
        print(mode + ':\n' + result.stdout)
        if result.returncode:
            raise SystemExit(result.returncode)
    lint = root / 'lint.py'
    lint.write_text('import os\n')
    result = subprocess.run(['ruff', 'check', '--output-format', 'json', str(lint)], cwd=str(root), env=env, stdout=subprocess.PIPE, universal_newlines=True)
    assert result.returncode == 1
    assert any(item['code'] == 'F401' for item in json.loads(result.stdout))
    print('PASS: Ruff lint detects unused import')
