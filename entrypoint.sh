#!/bin/bash

# Start SSH daemon
/usr/sbin/sshd

# Start tmate session as ubuntu user
su - ubuntu -c "/usr/local/bin/setup-tmate.sh" &

# Keep the container running
tail -f /dev/null 