#!/bin/bash

# Run user_generator.rc exactly once
/dockerstartup/user_generator.rc

# Start supervisord to manage services
exec /etc/supervisor/supervisord.conf
