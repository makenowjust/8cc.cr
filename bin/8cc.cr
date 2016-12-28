#!/usr/bin/env bash

set -eu

VERSION=1.0.0

PROJECT_ROOT="$(dirname -- "$(dirname -- "$0")")"

RED=$'\e[31m'
GREEN=$'\e[32m'
YELLOW=$'\e[33m'
BLUE=$'\e[34m'
BOLD=$'\e[1m'
RESET=$'\e[0m'

declare compile_only= target= output= source= stats=
declare eir=

help_exit() {
  cat <<HELP
${BOLD}usage:$RESET $GREEN$0$RESET $YELLOW[-s]$RESET $YELLOW[-S]$RESET $YELLOW[-t target]$RESET $YELLOW[-o output]$RESET ${BLUE}source$RESET

${BOLD}options:$RESET
  $YELLOW-s$RESET               display statistics
  $YELLOW-S$RESET               only compile C to ELVM IR, not generate code
  $YELLOW-t target$RESET        specify target to compile (i.e. x86, c, cr, js...) $BOLD[default: c]$RESET
  $YELLOW-o output$RESET        specify output file name                           $BOLD[default: \${source%.*}.\$target]$RESET
  ${BLUE}source$RESET           specify compiled source file name                  $BOLD[required]$RESET
HELP
  exit $1
}

help_exit_with_error() {
  echo "$RED$1$RESET"
  echo
  help_exit 1
}

setup() {
  while (( $# > 0 )); do
    case "$1" in
      -s)
        stats=" --stats"
        shift
        ;;
      -S)
        compile_only=1
        shift
        ;;
      -t)
        (( $# == 1 )) && help_exit_with_error "-t requires an argument"
        target=$2
        shift 2
        ;;
      -o)
        (( $# == 1 )) && help_exit_with_error "-o requires an argument"
        output=$2
        shift 2
        ;;
      -h)
        help_exit 0
        ;;
      -v)
        echo "$VERSION"
        exit 0
        ;;
      -*)
        help_exit_with_error "unknown option: $1"
        ;;
      *)
        [[ -n $source ]] && help_exit_with_error "source is already specified"
        source=$1
        shift
        ;;
    esac
  done

  [[ -z $source ]] && help_exit_with_error "source is not specified"

  [[ -n $target && -n $compile_only ]] && help_exit_with_error "not specify target with -S"
  [[ -n $output && -n $compile_only ]] && help_exit_with_error "not specify output with -S"
  [[ $source == *.eir && -n $compile_only ]] && help_exit_with_error "source is already compiled"

  eir="${source%.*}.eir"
  [[ -z $target ]] && target=c
  [[ -z $output ]] && output="${source%.*}.$target"

  return 0
}

run_8cc() {
  if [[ $source != *.eir ]]; then
    local command="$(printf "cat %q | crystal build --no-codegen%s %q 2> %q" "$source" "$stats" "$PROJECT_ROOT/src/8cc.cr" "$eir")"
    echo "${BOLD}compile:${RESET} $command"
    eval "$command" || exit 1
  fi
}

run_elc() {
  local command="$(printf "(echo %q; cat %q) | crystal build --no-codegen%s %q 2> %q" "$target" "$eir" "$stats" "$PROJECT_ROOT/src/elc.cr" "$output")"
  echo "${BOLD}generate:${RESET} $command"
  eval "$command" || exit 1
}

setup "$@"
run_8cc
[[ -z $compile_only ]] && run_elc
