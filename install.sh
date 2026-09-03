#!/bin/sh

set -eu

repository="yanun0323/skills"
ref="${SKILLS_REF:-master}"
destination="${SKILLS_DIR:-${HOME:?HOME is not set}/.agents/skills}"
tmp_dir=""
stage_dir=""

cleanup() {
  if [ -n "$stage_dir" ]; then
    rm -rf "$stage_dir"
  fi
  if [ -n "$tmp_dir" ]; then
    rm -rf "$tmp_dir"
  fi
}

fail() {
  printf 'Unable to update skills: %s\n' "$1" >&2
  exit 1
}

trap cleanup EXIT
trap 'exit 1' HUP INT TERM

command -v curl >/dev/null 2>&1 || fail "curl is required"
command -v tar >/dev/null 2>&1 || fail "tar is required"
command -v mktemp >/dev/null 2>&1 || fail "mktemp is required"

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/skills-install.XXXXXX") || fail "could not create a temporary directory"
archive="$tmp_dir/repository.tar.gz"
extract_dir="$tmp_dir/repository"
mkdir -p "$extract_dir"

printf 'Downloading %s at %s...\n' "$repository" "$ref"
curl --fail --location --silent --show-error \
  "https://codeload.github.com/$repository/tar.gz/$ref" \
  --output "$archive" || fail "download failed"

tar -xzf "$archive" -C "$extract_dir" || fail "downloaded archive could not be extracted"

set -- "$extract_dir"/*
[ "$#" -eq 1 ] && [ -d "$1/skills" ] || fail "the repository does not contain a skills directory"
source_dir="$1/skills"

mkdir -p "$destination" || fail "could not create $destination"
stage_dir=$(mktemp -d "$destination/.skills-install.XXXXXX") || fail "could not prepare files in $destination"

skill_count=0
for skill in "$source_dir"/*; do
  [ -d "$skill" ] || continue
  skill_name=${skill##*/}
  prepared="$stage_dir/$skill_name"
  mkdir -p "$prepared"
  cp -R "$skill/." "$prepared/"
  skill_count=$((skill_count + 1))
done

[ "$skill_count" -gt 0 ] || fail "the repository contains no skills"

for prepared in "$stage_dir"/*; do
  skill_name=${prepared##*/}
  target="$destination/$skill_name"
  rm -rf "$target"
  mv "$prepared" "$target"
  printf 'Updated %s\n' "$skill_name"
done

printf 'Updated %s skill(s) in %s\n' "$skill_count" "$destination"
