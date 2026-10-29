#!/usr/bin/env bash
#
# LEGACY — preserved as example, requires local AI backend
# Run selected AI model via fzf

{{AI_COMMAND}} $({{AI_LIST_MODELS}} | tail -n +2 | fzf | awk '{print $1}')
