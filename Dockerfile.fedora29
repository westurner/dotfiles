
# westurner/dotfiles fedora:29 Dockerfile

FROM fedora:29

## Install system packages
RUN dnf install -y which \
    python \
    python3 \
    bash-completion \
    zsh \
    git \
    mercurial \
    python2-pip \
    python3-pip \
    python-devel \
    python3-devel \
    gcc
#RUN pip install -U pip
## Install latest pip
#RUN curl -SL https://bootstrap.pypa.io/get-pip.py > get-pip.py
#RUN python ./get-pip.py

## Install dotfiles
#ADD $__DOTFILES/scripts/bootstrap_dotfiles.sh /usr/local/bin/bootstrap_dotfiles.sh
#RUN curl -SL https://raw.githubusercontent.com/westurner/dotfiles/develop/scripts/bootstrap_dotfiles.sh > bootstrap_dotfiles.sh
COPY ./scripts/bootstrap_dotfiles.sh ./bootstrap_dotfiles.sh
RUN DOTFILES_REPO_REV="develop" bash ./bootstrap_dotfiles.sh -I
RUN pip3 install --user virtualenv virtualenvwrapper
#RUN DOTFILES_REPO_REV="develop" bash ./bootstrap_dotfiles.sh -R
#RUN DOTFILES_REPO_REV="develop" ./bootstrap_dotfiles.sh -U -R

