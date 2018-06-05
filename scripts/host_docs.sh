

host_docs () {
    #  host_docs    -- build and host documentation in a local directory
    #   param $1: <project_name>
    #   param $2: [<path>]
    #   param $3: [<docs/Makefile>]
    #   param $4: [<docs/conf.py>]
    # * log documentation builds
    # * build a sphinx documentation set with a Makefile and a conf.py
    # * rsync to docs webserver
    # * set permissions

    # this is not readthedocs.org

    # note: you must manually install packages into the
    # local 'docs' virtualenv'
    set -x
    pushd .
    #workon docs

    name=${1}
    #name="host"
    if [ -z "${name}" ]; then
        echo "must specify an application name"
        return 1
    fi

    #path=${2}
    path=${2:-$_WRD}
    #path= -"${__SRC}/${name}"} 
    #path="${WORKON_HOME}/${name}/src/${name}
    #path="${VIRTUAL_ENV}/src/${name}
    #path="${_SRC}/${name}"

    _docs_="docs/"
    _default_docspath="${_wrd}/docs"
    _docs=

    _makefile=${3}
    _confpy=${4}

    _default_makefile="${_wrd}/docs/Makefile"
    _default_confpy="${_wrd}/docs/conf.py"

    _default_builddir="${_wrd}/docs/_build"

    dest="${__DOCSWWW}/${name}"
    group="www-data"

    if [ -z "${_makefile}" ]; then
        if [ -f $_default_makefile ]; then
            _makefile=$_default_makefile;
        else
            echo "404: default_makefile: $_default_makefile" >&2
            __makefiles=$(find "${path}" -maxdepth 2 -type f -name Makefile)
            for __makefile in ${__makefiles[@]}; do
                if [ -n "${__makefile}" ]; then
                    grep -n -H 'sphinx-build' ${__makefile} \
                        && grep -n -H '^html:' ${__makefile}
                    if [ $? -eq 0 ]; then
                        echo 'Found sphinx-build Makefile: $__makefile'
                        # TODO: prompt?
                        _makefile=$__makefile
                        # TODO: find conf.py
                    fi
                fi
            done
        fi

        if [ -f "${_makefile}" ]; then
            _builddir=$(dirname $_makefile)
        fi
    fi

    if [ -z "${_confpy}" ]; then
        if [ -f $_default_confpy ]; then
            _confpy=$_default_confpy;
        else
            echo "404: default_confpy: $_default_confpy" >&2
            confpys=$(find "${path}" -maxdepth 2 -type f -name conf.py)
            for __confpy in ${confpys[@]}; do
                grep -n -H 'sphinx-build' ${__confpy}
                if [ $? -eq 0 ]; then
                    echo 'found conf.py: $__confpy'
                    #TODO: prompt?
                    _confpy=$__confpy
                fi
            done
        fi

        if [ ! -f $_makefile ]; then
            _builddir=$(dirname $__confpy)
        fi

    fi

    _builddir=${_builddir:-${_default_builddir}}
    _buildlog="${_builddir}/build.log"
    _currentbuildlog="${_builddir}/build.current.log"


    cd $path
    rm -f $_currentbuildlog
    html_path=""
    echo '#' $(date) | tee -a $_buildlog | tee $_currentbuildlog

    if [ -n "$_makefile" ]; then
        #TODO
        #>> 'SPHINX_BUILD =    sphinx-build -Dhtml_theme=default -Dother '
        #<< 'SPHINX_BUILD =    sphinx-build -Dhtml_theme=default'
        #sed -i -r 's/(^SPHINXBUILD)( *= *)(sphinx-build)(.*)/\1\2\3 -Dhtml_theme="default"/g' $_makefile

        cd $(dirname $_makefile)
        make \
            SPHINXBUILD="sphinx-build -Dhtml_theme=\"default\"" \
            html | \
            tee -a $_buildlog | tee $_currentbuildlog
        html_path=$(tail -n 1 $_currentbuildlog | \
            sed -r 's/(.*)The HTML pages are in (.*).$/\2/g')
        echo $html_path

    elif [ -n "$_confpy" ]; then
        # >> 'html_theme = "_-_"
        # << 'html_theme = 'default'
        sed -i.bak -r 's/(^ *html_theme)( *= *)(.*)/\1\2"default"' $_confpy
        sourcedir=$(dirname $_confpy)
        html_path="${sourcedir}/_build/html"
        mkdir -p $html_path
        SPHINXBUILD="sphinx-build -Dhtml_theme=\"default\"" \
            sphinx-build \
                -b html \
                -D html_theme="default" \
                -c "${_confpy}" \
                $sourcedir \
                $html_path
    fi

    if [ -n "${html_path}" ]; then
        echo "html-path:" ${html_path}
        echo "dest:" ${dest}
        set -x
        rsync -avr "${html_path}/" "${dest}/" \
            | tee -a $_buildlog \
            | tee $_currentbuildlog
        set +x
        sudo chgrp -R $group "${dest}" \
            | tee -a $_buildlog \
            | tee $_currentbuildlog
    else
        echo "### ${_currentbuildlog}"
        cat $_currentbuildlog
    fi

    popd

    set +x
    deactivate
}


