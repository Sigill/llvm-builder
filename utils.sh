require_arg() {
  if [ -z "$1" ]; then
    >&2 echo "$2 not specified"
    exit 1
  fi
}

run() {
  echo "$@"
  "$@"
}