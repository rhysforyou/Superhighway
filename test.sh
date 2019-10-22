#!/bin/bash
set -o pipefail

if [[ "$(uname -s)" -eq "Darwin" ]]; then
  echo "🔧  Running macOS tests"
  swift test
else
  echo "⚠️  Skipping macOS tests"
fi

if [[ "$(command -v docker-compose)" ]]; then
  echo "🔧  Running Linux tests"
  docker-compose run tests
else
  echo "⚠️  docker-compose not present in PATH, skipping Linux tests"
fi
