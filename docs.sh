#!/usr/bin/env sh
swift package --allow-writing-to-directory "./docs" \
  generate-documentation --target "SwiftWebview" \
  --disable-indexing \
  --hosting-base-path "SwiftWebview" \
  --output-path "./docs"
