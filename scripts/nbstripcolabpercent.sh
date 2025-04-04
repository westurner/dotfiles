#!/bin/sh

strip_colab_metadata_from_py_percent_nb() {
    ipynb_path=$1
    sed -i 's/^# %% \(.*\)\(colab\={.*\)/# %% \1/g' "${ipynb_path}"
}

strip_colab_metadata_from_py_percent_nb "${@}"

