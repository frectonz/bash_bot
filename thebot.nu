#!/usr/bin/env nu

# Telegram hello bot in Nushell (http, no curl/jq needed)
# Usage: BOT_TOKEN=123:abc nu thebot.nu

def main [
  --poll-interval: duration = 10sec  # how long to wait between polls
] {
  # Replace <BOT_TOKEN> with your bot token, or set $env.BOT_TOKEN
  let token = ($env.BOT_TOKEN? | default "<BOT_TOKEN>")
  let api = $"https://api.telegram.org/bot($token)"

  mut last_update_id = 0

  loop {
    let updates = (http get $"($api)/getUpdates?offset=($last_update_id + 1)" | get result)

    for update in $updates {
      # Skip updates that aren't plain messages (edits, callbacks, ...)
      let message = $update.message?
      if $message != null {
        let chat_id = $message.chat.id
        let username = ($message.chat.username? | default ($message.chat.first_name? | default "there"))

        print $"Received message from @($username) in chat ID ($chat_id)"

        http post --content-type application/json $"($api)/sendMessage" {
          chat_id: $chat_id
          text: $"Hello @($username)!"
        } | ignore
      }

      $last_update_id = $update.update_id
    }

    sleep $poll_interval
  }
}
