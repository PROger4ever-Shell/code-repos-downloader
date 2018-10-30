#!/bin/bash

DST_PATH="$1";

if [ -z "$DST_PATH" ]; then
  (echo >&2  "The first parameter not specified - a path, where the repositories should be saved.")
  exit 1
fi


function handleFail() {
  local EXIT_STATUS=$1;
  local MSG="$2";
  
  if [ $EXIT_STATUS -eq 0 ]; then
    return 0;
  fi;

  # printing? cleaning?
  (echo >&2 "=== $MSG");
  
  return 3;
}

function exitOnFail() {
  local EXIT_STATUS=$1;  
  local MSG="$2";

  handleFail $EXIT_STATUS "$MSG";

  local EXIT_STATUS=$?;
  if [ $EXIT_STATUS -ne 0 ]; then
    exit $EXIT_STATUS
  fi;
}


while IFS= read -r SRC_REPO_URL; do
 (echo >&2 "=== Processing repo: $SRC_REPO_URL");

  REPO_PATH='';
  if [[ "$SRC_REPO_URL" =~ https?://(.+)\.git ]]; then
    REPO_PATH="${BASH_REMATCH[1]}";
  elif [[ "$SRC_REPO_URL" =~ git@(.*?):(.+)\.git ]]; then
    REPO_PATH="${BASH_REMATCH[1]}/${BASH_REMATCH[2]}";
  fi

  if [ -z "$REPO_PATH" ]; then
    (echo >&2 "=== Can't find repository in the URL: $REPO_PATH");
    exit 2;
  fi

  DST_PATH_CUR="$DST_PATH/$REPO_PATH";

  if [ -d "$DST_PATH_CUR" ]; then
    (echo >&2 "=== updating...");
    git -C "$DST_PATH_CUR" pull;
  else
    (echo >&2 "=== cloning...");
    git clone "$SRC_REPO_URL" "$DST_PATH_CUR";
  fi

  # submodules and other dependencies can be downloaded here

  exitOnFail $? "=== Something went wrong with \"$SRC_REPO_URL\". Interrupted.";
  echo "";
done
echo "done.";