#!/bin/bash

# Run user_generator.rc exactly once
/dockerstartup/user_generator.rc

# Start supervisord to manage services (update this path after debugging)
exec /usr/local/bin/supervisord -c /etc/supervisor/supervisord.conf
