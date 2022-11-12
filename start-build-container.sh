#!/bin/bash
set -e

WORKSPACE=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
source $WORKSPACE/utils.sh

ID=
SRC=

function usage() {
  echo "$0 --env <sles15.3|sles15.4|debian11> -s|--source <source dir> [-- <additional 'docker run' params>]"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --env)
      ENV="$2"
      shift 2
      ;;
    -s|--source)
      SRC="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      >&2 echo "Unknown argument $1"
      exit 1
      >&2 usage
      ;;
  esac
done

require_arg "$ENV" "Env"
require_arg "$SRC" "Source directory"

mkdir -p {cache,output}/$ENV

run docker run \
  -v $(realpath $SRC):/src:ro \
  -v $(realpath $PWD):/data:ro \
  -v $(realpath $PWD/cache/$ENV):/cache \
  -v $(realpath $PWD/output/$ENV):/output \
  "$@"
