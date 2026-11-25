for prefix in /opt/homebrew /usr/local
    if test -x $prefix/bin/brew
        # Explicit shell name also works when Fish was launched over SSH.
        eval ($prefix/bin/brew shellenv fish)
        break
    end
end
set -q BROWSER; or set -gx BROWSER open
# Workstations query Slurm on the cluster over SSH; clusters use local squeue.
set -q SJOBS_HOST; or set -gx SJOBS_HOST marc3a
