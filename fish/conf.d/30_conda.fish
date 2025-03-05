set condadir ~/.opt/miniconda3
if test -d $condadir
    eval $condadir/bin/conda shell.fish hook | source
else if status is-interactive
    # Bootstrap conda.
    echo "Bootstrapping conda ...\n"
    switch (uname -s)
        case Darwin
            curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh
            bash Miniconda3-latest-MacOSX-arm64.sh -b -p $condadir
            rm Miniconda3-latest-MacOSX-arm64.sh
        case '*'
            wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
            bash Miniconda3-latest-Linux-x86_64.sh -b -p $condadir
            rm Miniconda3-latest-Linux-x86_64.sh
    end
end
