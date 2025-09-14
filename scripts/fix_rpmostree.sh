#!/bin/sh
# # fix_rpmostree.sh
# Install latest rpm-ostree in order to workaround [sysusers] package layering issues
#
# ## References:
# - https://github.com/coreos/rpm-ostree/pull/5403#issuecomment-3046706179
# - https://github.com/coreos/rpm-ostree/pull/5403#issuecomment-3139129186
# - https://packages.fedoraproject.org/pkgs/rpm-ostree/rpm-ostree-libs/
# - https://packages.fedoraproject.org/pkgs/rpm-ostree/rpm-ostree/
# - https://bodhi.fedoraproject.org/updates/?packages=rpm-ostree
# - https://dl.fedoraproject.org/pub/fedora/linux/updates/42/Everything/x86_64/Packages/r/rpm-ostree-2025.9-1.fc42.x86_64.rpm
# - https://dl.fedoraproject.org/pub/fedora/linux/updates/42/Everything/x86_64/Packages/r/rpm-ostree-libs-2025.9-1.fc42.x86_64.rpm


set -x

VERSION="${VERSION:-"2025.9-1"}"
#VERSION="${VERSION:-"2025.10-1"}"
RELEASE="${RELEASE:-"fc42"}"
ARCH="${ARCH:-"x86_64"}"

PACKAGE_SUFFIX="${VERSION}.${RELEASE}.${ARCH}.rpm"
RPMOSTREELIBS_RPM="rpm-ostree-libs-${PACKAGE_SUFFIX}"
RPMOSTREELIBS_RPM_URL="https://dl.fedoraproject.org/pub/fedora/linux/updates/42/Everything/x86_64/Packages/r/${RPMOSTREELIBS_RPM}"
RPMOSTREE_RPM="rpm-ostree-${PACKAGE_SUFFIX}"
RPMOSTREE_RPM_URL="https://dl.fedoraproject.org/pub/fedora/linux/updates/42/Everything/x86_64/Packages/r/${RPMOSTREE_RPM}"


DNF="dnf"
DNF="/usr/bin/python -m dnf.cli.main"

sudo rpm-ostree usroverlay
sudo ${DNF} install -y "${RPMOSTREELIBS_RPM_URL}" "${RPMOSTREE_RPM_URL}"


sudo rpm-ostree status
sudo rpm-ostree status -b -J '$.deployments[*].version'
sudo rpm-ostree status -b -J '$..pending-base-version' | tail -n+2 | head -n1 | sed 's/  "\(.*\)"/\1/'

echo '# Run these commands manually:

sudo rpm-ostree deploy 42.20250706.0  # replace this with the deply version from `rpm-ostree status`
sudo ostree admin finalize-staged -v
'