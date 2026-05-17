#!/bin/bash

# Function to check internet connectivity
check_internet() {
    ping -c 1 8.8.8.8 &> /dev/null
    if [ $? -eq 0 ]; then
        echo "Internet: Available"
        return 0
    else
        echo "Internet: Not available"
        return 1
    fi
}

# Function to check speed and rate it
check_speed() {
    if ! command -v speedtest-cli &> /dev/null; then
        echo "speedtest-cli not found. Install it with: sudo apt install speedtest-cli"
        RATING="Unknown"
        return 1
    fi

    echo "Checking speed..."
    SPEED_OUTPUT=$(speedtest-cli --simple 2>/dev/null)

    if [[ -z "$SPEED_OUTPUT" ]]; then
        echo "Could not retrieve speed test results."
        RATING="Unknown"
        return 1
    fi

    echo "$SPEED_OUTPUT"

    # Extract download speed
    DOWNLOAD=$(echo "$SPEED_OUTPUT" | grep 'Download' | awk '{print $2}')

    if [[ -z "$DOWNLOAD" ]]; then
        RATING="Unknown"
    else
        DOWNLOAD_INT=${DOWNLOAD%.*}  # convert to integer
        if [ "$DOWNLOAD_INT" -ge 100 ]; then
            RATING="Excellent"
        elif [ "$DOWNLOAD_INT" -ge 50 ]; then
            RATING="Good"
        elif [ "$DOWNLOAD_INT" -ge 20 ]; then
            RATING="Average"
        else
            RATING="Bad"
        fi
    fi

    echo "Speed Rating: $RATING"
}

# Open a new gnome-terminal with custom geometry
gnome-terminal --geometry=30x10+800+100 -- bash -c '
echo "Running speed test... this might take a while"
sleep 0.5

# Check internet
if ping -c 1 8.8.8.8 &> /dev/null; then
    echo "Internet: Available"
else
    echo "Internet: Not available"
    RATING="Unknown"
fi

# Run speed test and rate it
if command -v speedtest-cli &> /dev/null; then
    SPEED_OUTPUT=$(speedtest-cli --simple 2>/dev/null)
    if [[ -z "$SPEED_OUTPUT" ]]; then
        echo "Could not retrieve speed test results."
        RATING="Unknown"
    else
        echo "$SPEED_OUTPUT"
        DOWNLOAD=$(echo "$SPEED_OUTPUT" | grep "Download" | awk "{print \$2}")
        if [[ -z "$DOWNLOAD" ]]; then
            RATING="Unknown"
        else
            DOWNLOAD_INT=${DOWNLOAD%.*}
            if [ "$DOWNLOAD_INT" -ge 100 ]; then
                RATING="Excellent"
            elif [ "$DOWNLOAD_INT" -ge 50 ]; then
                RATING="Good"
            elif [ "$DOWNLOAD_INT" -ge 20 ]; then
                RATING="Average"
            else
                RATING="Bad"
            fi
        fi
    fi
else
    echo "speedtest-cli not found"
    RATING="Unknown"
fi

echo "Speed Rating: $RATING"
espeak "Your internet speed is $RATING"
echo "Terminal will close in 10 seconds..."
sleep 10
'