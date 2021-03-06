#!/bin/sh -x
NBDIR="${HOME}/notebooks"
PIP_OPTS="${PIP_OPTS}" # ${PIP_OPTS:-'--user'}"
build () {
    apt install -y clang python fftw libzmq freetype libpng pkg-config nodejs
    LDFLAGS=" -lm -lcompiler_rt" python -m pip install cython
    LDFLAGS=" -lm -lcompiler_rt" python -m pip install ${PIP_OPTS:+"${PIP_OPTS}"} numpy matplotlib pandas sympy ipython jupyterlab
}

collectwheels () {
    find ~/.cache/pip/wheels/ -name '.whl'
    tar czvf pipcache.tar.gz ~/.cache/pip/wheels
}

#page="file:///data/data/com.termux/files/home/.local/share/jupyter/runtime/nbserver-20082-open.html"
browser=/data/data/com.termux/files/usr/bin/termux-open-url
browser=termux-open-url
startnb () {
    jupyter notebook --notebook-dir="${NBDIR}" --browser="${browser}"
}

startlab () {
   BROWSER="$browser" jupyter-lab --notebook-dir="${NBDIR}"
}

main () {
    for arg in "${@}"; do
        case "${arg}" in
            build)
                build;
                collectwheels
                ;;
            collectwheels)
                collectwheels
                ;;
            startnb|nb)
                startnb
                ;;
            startlab|lab)
                startlab
                ;;
        esac
    done
}

main "${@}"
