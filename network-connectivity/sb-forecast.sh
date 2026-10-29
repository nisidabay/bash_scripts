#!/usr/bin/env bash
#
# Display weather forecast for dwmblocks.
#
# Dependencies: curl, jq
# Environment: $TERMINAL, $EDITOR

# CONFIGURATION
API_KEY="a3b127d885534db5a5f180706221306"
LOCATION="Madrid"
URL="http://api.weatherapi.com/v1/current.json?key=$API_KEY&q=$LOCATION&aqi=no"

# 1. Fetch data
weather_json=$(curl -s --max-time 10 "$URL")

# 2. Safety Check: If curl failed, exit
if [ -z "$weather_json" ]; then
    printf "❌ Offline\n"
    exit 1
fi

# 3. Check for API errors
if echo "$weather_json" | grep -q "error"; then
    printf "❌ API Error\n"
    exit 1
fi

# 4. Extract info using jq
if ! command -v jq &>/dev/null; then
    printf "❌ No jq\n"
    exit 1
fi

temp=$(echo "$weather_json" | jq -r '.current.temp_c')
condition=$(echo "$weather_json" | jq -r '.current.condition.text')

# 5. Match Condition (Case Insensitive)
case "${condition,,}" in
*sunny* | *clear*) icon="☀️" ;;
*cloudy* | *overcast* | *partly*) icon="☁️" ;;
*rain* | *drizzle* | *shower* | *patchy*) icon="🌧️" ;;
*snow* | *ice* | *blizzard*) icon="❄️" ;;
*thunder*) icon="⛈️" ;;
*fog* | *mist*) icon="🌫️" ;;
*) icon="🌈" ;;
esac

# 6. Output
# %.0f rounds the decimal (9.2 -> 9)
printf "%s %.0f°C\n" "$(echo "$icon" | sed 's/\xef\xb8\x8f//g')" "$temp"
