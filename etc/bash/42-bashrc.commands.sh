
### bashrc.commands.sh
# usage: bash -c 'source bashrc.commands.sh; funcname <args>'

chown-me () {
    # chown-me()        -- chown -Rv user
    (set -x; \
    chown -Rv $(id -un) $@ )
}

chown-me-mine () {
    # chown-me-mine()   -- chown -Rv user:user && chmod -Rv go-rwx
    (set -x; \
    chown -Rv $(id -un):$(id -un) $@ ; \
    chmod -Rv go-rwx $@ )
}

chown-sme () {
    # chown-sme()       -- sudo chown -Rv user
    (set -x; \
    sudo chown -Rv $(id -un) $@ )
}

chown-sme-mine () {
    # chown-sme-mine()  -- sudo chown -Rv user:user && chmod -Rv go-rwx
    (set -x; \
    sudo chown -Rv $(id -un):$(id -un) $@ ; \
    sudo chmod -Rv go-rwx $@ )
}

chmod-unumask () {
    # chmod-unumask()   -- recursively add other+r (files) and other+rx (dirs)
    path=$1
    sudo find "${path}" -type f -exec chmod -v o+r {} \;
    sudo find "${path}" -type d -exec chmod -v o+rx {} \;
}

