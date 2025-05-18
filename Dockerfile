# Use a maintained base image with NoVNC and XFCE
FROM accetto/ubuntu-vnc-xfce-g3:20.04

# Switch to root user to install packages and adjust permissions
USER root

# Ensure the /var/lib/apt/lists/partial directory exists with correct permissions
RUN mkdir -p /var/lib/apt/lists/partial && \
    chown root:root /var/lib/apt/lists/partial && \
    chmod 755 /var/lib/apt/lists/partial && \
    # Install Nginx and apache2-utils for htpasswd
    apt-get update && \
    apt-get install -y nginx apache2-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Debug: Find the supervisord binary path
RUN echo "Looking for supervisord..." && \
    which supervisord || echo "supervisord not found in PATH" && \
    find / -type f -name "supervisord" 2>/dev/null || echo "supervisord not found"

# Create .htpasswd file for basic auth (username: admin, password: set via HTTP_PASSWORD)
RUN htpasswd -bc /etc/nginx/.htpasswd admin ${HTTP_PASSWORD:-defaultpassword}

# Copy Nginx configuration to proxy NoVNC and enforce basic auth
COPY nginx.conf /etc/nginx/nginx.conf

# Copy custom supervisord.conf to include Nginx
COPY supervisord.conf /etc/supervisor/supervisord.conf

# Copy modified user_generator.rc to skip user creation
COPY user_generator.rc /dockerstartup/user_generator.rc

# Copy custom startup script to control the startup flow
COPY startup.sh /dockerstartup/startup.sh

# Adjust permissions on /dockerstartup/ and scripts
RUN chown -R headless:headless /dockerstartup && \
    chmod -R 755 /dockerstartup && \
    chmod +x /dockerstartup/user_generator.rc && \
    chmod +x /dockerstartup/startup.sh

# Switch back to the default non-root user (headless)
USER headless

# Expose the dynamic port (Render sets PORT environment variable)
EXPOSE ${PORT:-6080}

# Set resolution, VNC password, and user UID/GID to match headless (1000:1000)
ENV VNC_RESOLUTION=1600x761 \
    VNC_PW=yourvncpassword \
    USER_UID=1000 \
    USER_GID=1000

# Use the custom startup script as the entrypoint
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
