#!/bin/bash

# Replace <YOUR_BOT_TOKEN> with your actual bot token
BOT_TOKEN="6201355048:AAE622cm_Vwvwg2PlK2hDT5IlvH_3rJ6KAI"

# Set the polling interval in seconds
POLL_INTERVAL=10

# Initialize the last message ID to 0
LAST_MESSAGE_ID=0

# Loop indefinitely to poll for new messages
while true
do
  # Get the latest messages from the server
  response=$(curl -s "https://api.telegram.org/bot$BOT_TOKEN/getUpdates?offset=$((LAST_MESSAGE_ID+1))")

  # Check if there are any messages
  if [[ $(echo "$response" | jq '.result | length') -gt 0 ]]
  then
    # Extract the chat ID and username from the latest message
    chat_id=$(echo "$response" | jq -r '.result[-1].message.chat.id')
    username=$(echo "$response" | jq -r '.result[-1].message.chat.username')

    # Log the incoming message
    echo "Received message from @$username in chat ID $chat_id"

    # Send a hello message to the user with their username
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
    -d chat_id="$chat_id" \
    -d text="Hello @$username!"
    
    # Update the last message ID
    LAST_MESSAGE_ID=$(echo "$response" | jq -r '.result[-1].update_id')
  fi

  # Wait for the specified interval before polling again
  sleep $POLL_INTERVAL
done

