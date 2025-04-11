#!/bin/bash

# Create a directory for connection info
mkdir -p /home/ubuntu/connection_info

# Start tmate session
tmate -S /tmp/tmate.sock new-session -d

# Wait for tmate to start up
sleep 2

# Get connection strings
SSH_STRING=$(tmate -S /tmp/tmate.sock display -p '#{tmate_ssh}')
WEB_STRING=$(tmate -S /tmp/tmate.sock display -p '#{tmate_web}')

# Write to connection info file
CONNECTION_FILE="/home/ubuntu/connection_info/tmate_connection.txt"
echo "=== TMATE CONNECTION INFO ===" | tee $CONNECTION_FILE
echo "Last Updated: $(date)" | tee -a $CONNECTION_FILE
echo "SSH: $SSH_STRING" | tee -a $CONNECTION_FILE
echo "Web: $WEB_STRING" | tee -a $CONNECTION_FILE
echo "==========================" | tee -a $CONNECTION_FILE

# Keep updating the connection info every hour in case it changes
while true; do
    SSH_STRING=$(tmate -S /tmp/tmate.sock display -p '#{tmate_ssh}')
    WEB_STRING=$(tmate -S /tmp/tmate.sock display -p '#{tmate_web}')
    
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
    
    sleep 3600  # Update every hour
done