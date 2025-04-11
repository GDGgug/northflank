#!/bin/bash

# Create a directory for connection info
mkdir -p /home/ubuntu/connection_info

# Kill any existing tmate sessions
pkill -f tmate || true

# Wait a moment to ensure previous sessions are cleaned up
sleep 2

# Start new tmate session
tmate -S /tmp/tmate.sock new-session -d

# Wait for tmate to start up and establish connection
echo "Waiting for tmate session to be established..."
for i in $(seq 1 30); do
    if tmate -S /tmp/tmate.sock has-session 2>/dev/null; then
        break
    fi
    sleep 1
done

# Get connection strings
SSH_STRING=$(tmate -S /tmp/tmate.sock display -p '#{tmate_ssh}' 2>/dev/null)
WEB_STRING=$(tmate -S /tmp/tmate.sock display -p '#{tmate_web}' 2>/dev/null)

# Write to connection info file
CONNECTION_FILE="/home/ubuntu/connection_info/tmate_connection.txt"
echo "=== TMATE CONNECTION INFO ===" | tee $CONNECTION_FILE
echo "Last Updated: $(date)" | tee -a $CONNECTION_FILE
echo "SSH: $SSH_STRING" | tee -a $CONNECTION_FILE
echo "Web: $WEB_STRING" | tee -a $CONNECTION_FILE
echo "==========================" | tee -a $CONNECTION_FILE

# Keep updating the connection info every hour in case it changes
while true; do
    if ! tmate -S /tmp/tmate.sock has-session 2>/dev/null; then
        echo "Tmate session lost, restarting..."
        tmate -S /tmp/tmate.sock new-session -d
        sleep 5
    fi

    SSH_STRING=$(tmate -S /tmp/tmate.sock display -p '#{tmate_ssh}' 2>/dev/null)
    WEB_STRING=$(tmate -S /tmp/tmate.sock display -p '#{tmate_web}' 2>/dev/null)
    
    echo "=== TMATE CONNECTION INFO ===" > $CONNECTION_FILE
    echo "Last Updated: $(date)" >> $CONNECTION_FILE
    echo "SSH: $SSH_STRING" >> $CONNECTION_FILE
    echo "Web: $WEB_STRING" >> $CONNECTION_FILE
    echo "==========================" >> $CONNECTION_FILE
    
    # Also print to stdout for container logs
    echo "=== TMATE CONNECTION INFO ==="
    echo "Last Updated: $(date)"
    echo "SSH: $SSH_STRING"
    echo "Web: $WEB_STRING"
    echo "=========================="
    
    sleep 3600
done