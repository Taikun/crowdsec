#!/bin/bash

BOT_TOKEN="yourBtoToken"
CHAT_ID="yourChatID"
MESSAGE="$1"

curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
     -d chat_id="$CHAT_ID" \
     -d text="$MESSAGE"
