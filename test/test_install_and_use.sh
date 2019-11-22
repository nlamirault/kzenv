#!/usr/bin/env bash

declare -a errors

function error_and_proceed() {
  errors+=("${1}")
  echo -e "kzenv: ${0}: Test Failed: ${1}" >&2
}

function error_and_die() {
  echo -e "kzenv: ${0}: ${1}" >&2
  exit 1
}

[ -n "${KZENV_DEBUG}" ] && set -x
source "$(dirname "${0}")/helpers.sh" \
  || error_and_die "Failed to load test helpers: $(dirname ${0})/helpers.sh"

# echo "### Install latest version"
# cleanup || error_and_die "Cleanup failed?!"

# v="$(kzenv list-remote | grep -e "^[0-9]\+\.[0-9]\+\.[0-9]\+$" | head -n 1)"
# (
#   kzenv install latest || exit 1
#   check_version "${v}" || exit 1
# ) || error_and_proceed "Installing latest version ${v}"


# echo "### Install latest version with Regex"
# cleanup || error_and_die "Cleanup failed?!"

# v="3.4.0"
# (
#   kzenv install latest:^0.8 || exit 1
#   check_version "${v}" || exit 1
# ) || error_and_proceed "Installing latest version ${v} with Regex"

echo "### Install specific version 3.x"
cleanup || error_and_die "Cleanup failed?!"

v="3.3.0"
(
  kzenv install "${v}" || exit 1
  check_version "${v}" || exit 1
) || error_and_proceed "Installing specific version ${v}"

echo "### Install specific .kustomize-version"
cleanup || error_and_die "Cleanup failed?!"

v="3.2.0"
echo "${v}" > ./.kustomize-version
(
  kzenv install || exit 1
  check_version "${v}" || exit 1
) || error_and_proceed "Installing .kustomize-version ${v}"

# echo "### Install latest:<regex> .kustomize-version"
# cleanup || error_and_die "Cleanup failed?!"

# v="$(kzenv list-remote | grep -e '^0.8' | head -n 1)"
# echo "latest:^0.8" > ./.kustomize-version
# (
#   kzenv install || exit 1
#   check_version "${v}" || exit 1
# ) || error_and_proceed "Installing .kustomize-version ${v}"

echo "### Install with ${HOME}/.kustomize-version"
cleanup || error_and_die "Cleanup failed?!"

if [ -f "${HOME}/.kustomize-version" ]; then
  mv "${HOME}/.kustomize-version" "${HOME}/.kustomize-version.bup"
fi
v="$(kzenv list-remote | grep -e "^[0-9]\+\.[0-9]\+\.[0-9]\+$" | head -n 2 | tail -n 1)"
echo "${v}" > "${HOME}/.kustomize-version"
(
  kzenv install || exit 1
  check_version "${v}" || exit 1
) || error_and_proceed "Installing ${HOME}/.kustomize-version ${v}"

echo "### Install with parameter and use ~/.kustomize-version"
v="$(kzenv list-remote | grep -e "^[0-9]\+\.[0-9]\+\.[0-9]\+$" | head -n 1)"
(
  kzenv install "${v}" || exit 1
  check_version "${v}" || exit 1
) || error_and_proceed "Use ${HOME}/.kustomize-version ${v}"

echo "### Use with parameter and  ~/.kustomize-version"
v="$(kzenv list-remote | grep -e "^[0-9]\+\.[0-9]\+\.[0-9]\+$" | head -n 2 | tail -n 1)"
(
  kzenv use "${v}" || exit 1
  check_version "${v}" || exit 1
) || error_and_proceed "Use ${HOME}/.kustomize-version ${v}"

rm "${HOME}/.kustomize-version"
if [ -f "${HOME}/.kustomize-version.bup" ]; then
  mv "${HOME}/.kustomize-version.bup" "${HOME}/.kustomize-version"
fi

echo "### Install invalid specific version"
cleanup || error_and_die "Cleanup failed?!"

v="0.1.0"
expected_error_message="No versions matching '${v}' found in remote"
[ -z "$(kzenv install "${v}" 2>&1 | grep "${expected_error_message}")" ] \
  && error_and_proceed "Installing invalid version ${v}"

# echo "### Install invalid latest:<regex> version"
# cleanup || error_and_die "Cleanup failed?!"

# v="latest:word"
# expected_error_message="No versions matching '${v}' found in remote"
# [ -z "$(kzenv install "${v}" 2>&1 | grep "${expected_error_message}")" ] \
#   && error_and_proceed "Installing invalid version ${v}"

if [ "${#errors[@]}" -gt 0 ]; then
  echo -e "\033[0;31m===== The following install_and_use tests failed =====\033[0;39m" >&2
  for error in "${errors[@]}"; do
    echo -e "\t${error}"
  done
  exit 1
else
  echo -e "\033[0;32mAll install_and_use tests passed.\033[0;39m"
fi;
exit 0