#!/bin/sh

setup_brew () {
    if ![-f "/usr/local/bin/brew"]; then
        /usr/bin/ruby -e "$(/usr/bin/curl -fsSL https://raw.github.com/mxcl/homebrew/master/Library/Contributions/install_homebrew.rb)"
    fi
}

setup_ipython () {
    brew install readline
    brew install zeromq
    pip install ipython pyzmq tornado pygments

    python -c 'from IPython.external import mathjax; mathjax.install_mathjax()'
}

setup_pandas () {
    brew install gfortran
    brew install pkg-config
    brew tap homebrew/dupes
    brew install homebrew/dupes/freetype

    pip install numpy python-dateutil pytz scipy matplotlib statsmodels
    pip install pandas
}

setup_brew && setup_ipython && setup_pandas && ipython notebook --pylab=inline