#!/usr/bin/env bash

set -o pipefail

TEE=
OUT=

while [[ $# -gt 0 ]]; do
  case $1 in
    --tee)
      TEE="$2"
      shift 2
      ;;
    --out)
      OUT="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      >&2 echo "Unknown argument $1"
      exit 1
      ;;
  esac
done

if [ -n "$OUT" ]; then
  echo "Output is redirected to $OUT"
  bash "$@" &> "$OUT"
elif [ -n "$TEE" ]; then
  bash "$@" |& tee "$TEE"
else
  2>&1 bash "$@"
fi
