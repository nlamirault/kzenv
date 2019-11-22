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
  || error_and_die "Failed to load test helpers: $(dirname "${0}")/helpers.sh"

echo "### List local versions"
cleanup || error_and_die "Cleanup failed?!"

for v in 1.0.6 1.0.11 2.0.0 2.0.3 3.3.0 3.4.0; do
  kzenv install "${v}" || error_and_proceed "Install of version ${v} failed"
done

result="$(kzenv list)"
expected="$(cat << EOS
* 3.4.0 (set by $(kzenv version-file))
  3.3.0
  2.0.3
  2.0.0
  1.0.11
  1.0.6
EOS
)"

if [ "${expected}" != "${result}" ]; then
  error_and_proceed "List mismatch.\nExpected:\n${expected}\nGot:\n${result}"
fi

if [ "${#errors[@]}" -gt 0 ]; then
  echo -e "\033[0;31m===== The following list tests failed =====\033[0;39m" >&2
  for error in "${errors[@]}"; do
    echo -e "\t${error}"
  done
  exit 1
else
  echo -e "\033[0;32mAll list tests passed.\033[0;39m"
fi;
exit 0