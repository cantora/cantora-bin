#!/bin/bash

#library of useful shell functions

#use "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#to get the script dir for sourcing this file

errecho () {
  echo $* >&2
}
err_exit () {
  errecho "$0 error: $1"
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

help_flag_exists () {
  echo " $1 " | grep -i ' --\?h\(elp\)\? ' > /dev/null
  if [ $? = 0 ]; then
    return 0
  fi

  echo " $1 " | grep -i ' -? ' > /dev/null
  if [ $? = 0 ]; then
    return 0
  fi

  return 1
}

pw_prompt () {
  ttyname=$(tty)
  if [ -O $ttyname ]; then #test that file is owned by this user
    tmpfile=$(mktemp)
    echo 'GETPIN' > $tmpfile
    pinentry-curses --ttyname "$ttyname" < $tmpfile 2>/dev/null
    rm -f $tmpfile
  else
    echo 'GETPIN' | pinentry-gtk-2
  fi
}

pw_get () {
  pw_prompt | grep '^D ' | head -1 | sed 's/^D //'
}
