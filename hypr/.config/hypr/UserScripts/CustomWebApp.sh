#!/bin/bash

# Parse Hyprland-style config
browser=$(grep '^\$browser' ~/.config/hypr/UserConfigs/01-UserDefaults.conf | sed 's/.*=\s*//')

declare -A APPS=(
  [whatsapp]="https://web.whatsapp.com"
  [chatgpt]="https://chat.openai.com"
  [grok]="https://grok.com"
  [github]="https://github.com"
  [claude]="https://claude.ai"
  [gemini]="https://gemini.google.com"
  [deepseek]="https://chat.deepseek.com"
)

arg="${1#--}"

if [[ -z "$arg" || -z "${APPS[$arg]}" ]]; then
  echo "Usage: $0 --<app>"
  echo "Available apps:"
  for key in "${!APPS[@]}"; do
    echo "  --$key"
  done
  exit 1
fi

$browser --target window "${APPS[$arg]}"
