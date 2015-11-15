#! /bin/bash
echo "This is a mock version of clamav"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if diff $1 $DIR/eicar.txt >/dev/null ; then
  echo "IT'S A VIRUS!"
  exit 1
else
  echo "Clean"
  exit 0
fi
