#!/bin/sh -x
# Setup IPython Notebook and Pandas for Ubuntu

IPYTHONDIR="${VIRTUAL_ENV}/src/.ipython"
IPYTHON_NOTEBOOK_DIR="${VIRTUAL_ENV}/src/notebooks"
IPYTHON_NOTEBOOK_SH="${VIRTUAL_ENV}/bin/ipython_notebook.sh"

setup_python_dev () {
  sudo apt-get install -y build-essential python-dev python-setuptools \
    python-pip python-virtualenv virtualenvwrapper
}

setup_virtualenvwrapper () {
  #sudo apt-get install -y virtualenvwrapper

  _VENVW='/usr/local/bin/virtualenvwrapper.sh'
  if [ -f "${_VENVW}" ]; then
    grep "${_VENVW}" ~/.bashrc || \ 
      echo "source ${_VENVW}" >> ~/.bashrc && \
      export _VENVW &&
      source ${_VENVW}
  fi
}

create_virtual_env () {
  echo "VIRTUAL_ENV: ${VIRTUAL_ENV}"
  if [ -d "${VIRTUAL_ENV}" ]; then
    echo "already in a VIRTUAL_ENV: ${VIRTUAL_ENV}"
  else
    #sudo apt-get install -y python-virtualenv
    NAME="${1:-'ipynb'}"
    if [ "${_VENVW}" -ne "" ]; then
      mkvirtualenv ${NAME}
      workon ${NAME}
    else
      export VIRTUAL_ENV="${HOME}/${NAME}"
      virtualenv --no-site-packages "${VIRTUAL_ENV}"
      source "${VIRTUAL_ENV}/bin/activate"
    fi
  fi
  echo "VIRTUAL_ENV: ${VIRTUAL_ENV}"
  IPYTHONDIR="${VIRTUAL_ENV}/src/.ipython"
  IPYTHON_NOTEBOOK_DIR="${VIRTUAL_ENV}/src/notebooks"
  IPYTHON_NOTEBOOK_SH="${VIRTUAL_ENV}/bin/ipython_notebook.sh"
}

setup_ipython_profile () {
  export IPYTHONDIR
  ipython profile create #<default>
  # ipython profile list
  # ipython --profile <default>
}

setup_ipython_sh_script () {
  scriptname=${1:-"${IPYTHON_NOTEBOOK_SH}"}
  echo "Wrting startup script to: $scriptname"

  cat > "${scriptname}" << EOF
#!/bin/sh
IPYTHONDIR="${IPYTHONDIR}"
IPYTHON_NOTEBOOK_DIR="${IPYTHON_NOTEBOOK_DIR}"
mkdir -p "${IPYTHON_NOTEBOOK_DIR}"
ipython notebook \
   --pylab=inline \
   --ipython-dir="\${IPYTHONDIR}" \
   --notebook-dir="\${IPYTHON_NOTEBOOK_DIR}" \
   --secure 
EOF
  chmod -v +x ${scriptname}
}

setup_ipython () {
  #apt-get readline
  sudo apt-get install libzmq1 libzmq-dev
  pip install ipython pyzmq tornado pygments

  python -c 'map(__import__,"IPython zmq tornado pygments".split())'
  python -c 'from IPython.external import mathjax; mathjax.install_mathjax()'
  mkdir -v -p "${IPYTHONDIR}" "${IPYTHON_NOTEBOOK_DIR}"
  setup_ipython_profile
  setup_ipython_sh_script
}

setup_pandas () {
  # apt-cache show pandas
  sudo apt-get install -y \
    python-numpy \
    python-scipy \
    python-matplotlib \
    python-dateutil \
    gfortran \
    cython \
    libfreetype6-dev \
    libpng12-dev

  sys_shared="/usr/share/pyshared"
  sys_pkgs="/usr/lib/python2.7/dist-packages"
  site_pkgs="$VIRTUAL_ENV/lib/python2.7/site-packages"
  for pkg in numpy scipy dateutil; do
    from="${sys_pkgs}/${pkg}"
    to="${site_pkgs}/${pkg}"
    rm -fv "${to}"
    ln -s -v "${from}" "${to}"
  done

  pip install matplotlib
  pip install pytz
  pip install statsmodels
  pip install --no-deps pandas
  python -c 'map(__import__,"numpy scipy matplotlib pylab pandas".split())'
}

setup_python_dev && \
  create_virtual_env && \
  setup_ipython && \
  setup_pandas && \
  $IPYTHON_NOTEBOOK_SH