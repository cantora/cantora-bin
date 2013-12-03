#!/bin/bash

#library of useful shell functions

#use "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#to get the script dir for sourcing this file

err_exit () {
  echo "$0 error: $1"
  exit 1
}

dir_arg () {
  if [ ! -d "$1" ]; then
    err_exit "expected valid directory argument"
  fi
}

file_arg () {
  if [ ! -f "$1" ]; then
    err_exit "expected valid file argument"
  fi
}

non_empty_str_arg () {
  if [ -z "$1" ]; then
    err_exit "expected non-empty string argument"
  fi
}

prefix_n_spaces () {
  printf "%-${1}s" 
}
