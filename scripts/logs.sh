#!/bin/bash
set -e

EC2_HOST="16.171.41.129"
SSH_KEY_PATH="~/.ssh/groundnut.pem"

ssh -o StrictHostKeyChecking=no -i $SSH_KEY_PATH ec2-user@$EC2_HOST << EOF
  echo "=== Docker Logs (myapp) ==="
  docker logs myapp --tail 200 || echo "No docker logs available."

  echo
  echo "=== App Logs (/var/log/myapp/app.log) ==="
  sudo tail -n 200 /var/log/myapp/app.log || echo "No app.log yet."
EOF
