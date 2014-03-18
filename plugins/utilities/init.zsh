#!/usr/bin/env zsh
#
# Utility functions for use in all shells.
#
# Author:
#   Larry Gordon
#
# License:
#   The MIT License (MIT) <http://psyrendust.mit-license.org/2014/license.html>
# ------------------------------------------------------------------------------


# Return the fully expanded path.
# Usage: alf cwd "$0"
# ------------------------------------------------------------------------------
_alf-cwd() {
  local arg_cwd="$0"

  # While the filename in $arg_cwd is a symlink
  while [ -L "$arg_cwd" ]; do
    # similar to above, but -P forces a change to the physical not symbolic directory
    local tmp_cwd="$( cd -P "$( dirname "$arg_cwd" )" && pwd )"

    # Get the value of symbolic link
    # If $arg_cwd is relative (doesn't begin with /), resolve relative
    # path where symlink lives
    arg_cwd="$(readlink -f "$arg_cwd")" && arg_cwd="$tmp_cwd/$arg_cwd"
  done
  echo "$( cd -P "$( dirname "$arg_cwd" )" && pwd )"
}


# Get or set an epoch for a given namespace
# ------------------------------------------------------------------------------
_alf-epoch() {
  local arg_flag="$1"
  local arg_name="$ALF_EPOCH/${2:-default}"
  if [[ $arg_flag == "--set" ]]; then
    echo "$(($(date +%s) / 60 / 60 / 24))" > "$arg_name"
  elif [[ $arg_flag == "--get" ]]; then
    # Get the epoch, if it doesn't exist create one
    [[ -f "$arg_name" ]] || _alf-epoch --set "$arg_name"
    echo "$(cat "$arg_name")"
  fi
}


# Helps with getting what you want out of a path
# -p: base path
# -e: file extension
# -f: file name with no extension
# -F: file name with extension
# ------------------------------------------------------------------------------
_alf-path() {
  while getopts "pfFe" opts; do
    [[ $opts == "p" ]] && local option="p" && continue
    [[ $opts == "f" ]] && local option="f" && continue
    [[ $opts == "F" ]] && local option="F" && continue
    [[ $opts == "e" ]] && local option="e" && continue
  done
  shift
  local path_p=${1%/*}
  local path_f=${1##*/}
  local path_F=${path_f%.*}
  local path_e=${path_f##*.}
  case $option in
    p) echo $path_p;;
    f) echo $path_f;;
    F) echo $path_F;;
    e) echo $path_e;;
    *) echo $1;;
  esac
}


# Strips ansi color codes from string
# ------------------------------------------------------------------------------
_alf-stripansi() {
  if [[ -n $PLATFORM_IS_LINUX ]]; then
    echo $(echo $1 >1 | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})*)?m//g")
  else
    echo $(echo $1 >1 | sed -E "s/"$'\E'"\[([0-9]{1,2}(;[0-9]{1,2})*)?m//g")
  fi
}


# Get or set alf version number
# ------------------------------------------------------------------------------
__alf-version() {
  local arg_flag="$1"
  local arg_target="${2:-alf}"
  local version_file="$ALF_VERSION/$arg_target.info"
  if [[ $arg_flag == "--set" ]]; then
    _alf_helper_git() {
      cd "$ALF_SRC"
      echo "$(git $@)"
    }
    # Get the version string from git (eg. v0.1.4-248-g5840656)
    local version=$(_alf_helper_git describe)
    # Get the tag number (eg. v0.1.4)
    local version_tag=$(echo $version | cut -d- -f 1)
    # Get the total number of commits (eg. 248)
    local version_commit=$(echo $version | cut -d- -f 2)
    # Get the latest sha (eg. g5840656)
    local version_sha=$(echo $version | cut -d- -f 3)
    # Get the date of the latest commit (eg. 2014-03-03)
    local version_date=$(echo $(_alf_helper_git show -s --format=%ci | cut -d\  -f 1))
    # Save version info (eg. v0.1.4p244 (2014-03-03 revision g67cfc97))
    local version_string="${version_tag}p${version_commit} (${version_date} revision ${version_sha})"
    # Save version prefix
    local version_prefix="${2:-alf}"
    # Output version info to a file (eg. alf v0.1.4p244 (2014-03-03 revision g67cfc97))
    if [[ "$arg_target" == "alf" ]]; then
      echo "echo -e \"\033[0;35m$version_prefix $version_string\033[0m\${_alf_startup_time_diff}\"" > "$version_file"
    else
      echo "$version_prefix $version_string" > "$version_file"
    fi
    unfunction _alf_helper_git
  else
    # Get the version info, if it doesn't exist create one
    [[ -f "$version_file" ]] || __alf-version --set "$arg_target"
    [[ "$arg_target" == "alf" ]] && source "$version_file" || cat "$version_file"
  fi
}