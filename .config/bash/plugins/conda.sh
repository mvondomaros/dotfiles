if [[ -x ~/.opt/miniconda3/bin/conda-content-trust ]]; then
    eval "$(~/.opt/miniconda3/bin/conda shell.bash hook)"
    eval "$(register-python-argcomplete conda)"
fi
