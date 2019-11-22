#!/bin/sh

# Be strict
set -e
set -u

###
### Inputs
###
_list="${1}"
_write="${2}"
_diff="${3}"
_check="${4}"
_file="${5}"
# shellcheck disable=SC2155
_temp="/tmp/$(basename "${_file}").tf"
_ret=0


###
### Build command (only append if default values are overwritten)
###
_cmd="terraform fmt"
if [ "${_list}" = "0" ]; then
	_cmd="${_cmd} -list=false"
else
	_cmd="${_cmd} -list=true"
fi
if [ "${_write}" = "1" ]; then
	_cmd="${_cmd} -write=true"
else
	_cmd="${_cmd} -write=false"
fi
if [ "${_diff}" = "1" ]; then
	_cmd="${_cmd} -diff"
fi
if [ "${_check}" = "1" ]; then
	_cmd="${_cmd} -check"
fi

###
### Output and execute command
###
echo "${_cmd} ${_file}"
cp -f "${_file}" "${_temp}"
if ! eval "${_cmd} ${_temp}"; then
	_ret=1
fi

###
### If -write was specified, copy file back
###
if [ "${_write}" = "1" ]; then
	# Get owner and permissions of current file
	_UID="$(stat -c %u "${_file}")"
	_GID="$(stat -c %g "${_file}")"
	_PERM="$(stat -c %a "${_file}")"

	# Adjust permissions of temporary file
	chown ${_UID}:${_GID} "${_temp}"
	chmod ${_PERM} "${_temp}"

	# Overwrite existing file
	mv -f "${_temp}" "${_file}"
fi

###
### Exit
###
exit "${_ret}"
