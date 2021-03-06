#!/usr/bin/env zsh
#
# Make a directory and cd into it after it's creation.
#
# Author:
#   Larry Gordon
#
# Usage:
#   $ mkcd foo
#   $ mkcd /tmp/img/photos/large
#
# License:
#   The MIT License (MIT) <http://psyrendust.mit-license.org/2014/license.html>
# ------------------------------------------------------------------------------

mkcd() {
  mkdir -p "$@" && cd "$_";
}
