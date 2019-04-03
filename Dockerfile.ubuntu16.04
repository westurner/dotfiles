
# westurner/dotfiles ubuntu:16.04 Dockerfile

FROM ubuntu:16.04

## Install system packages
RUN apt-get update
RUN apt-get install -y \
    python \
    bash-completion \
    mercurial \
    zsh \
    git \
    python-pip \
    python-dev \
    gcc
RUN pip install -U pip

## Install latest pip
#RUN curl -SL https://bootstrap.pypa.io/get-pip.py > get-pip.py
#RUN python ./get-pip.py

## Install dotfiles
#ADD $__DOTFILES/scripts/bootstrap_dotfiles.sh /usr/local/bin/bootstrap_dotfiles.sh
#RUN curl -SL https://raw.githubusercontent.com/westurner/dotfiles/develop/scripts/bootstrap_dotfiles.sh > bootstrap_dotfiles.sh
ADD ./bootstrap_dotfiles.sh ./bootstrap_dotfiles.sh
RUN DOTFILES_REPO_REV="develop" bash ./bootstrap_dotfiles.sh -I
RUN DOTFILES_REPO_REV="develop" bash ./bootstrap_dotfiles.sh -R
#RUN DOTFILES_REPO_REV="develop" ./bootstrap_dotfiles.sh -U -R

