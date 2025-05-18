# Use a maintained base image with NoVNC and XFCE
FROM accetto/ubuntu-vnc-xfce-g3:latest

# Switch to root user to install packages
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

# Create .htpasswd file for basic auth (username: admin, password: set via HTTP_PASSWORD)
RUN htpasswd -bc /etc/nginx/.htpasswd admin ${HTTP_PASSWORD:-defaultpassword}

# Copy Nginx configuration to proxy NoVNC and enforce basic auth
COPY nginx.conf /etc/nginx/nginx.conf

# Copy custom supervisord.conf to include Nginx
COPY supervisord.conf /etc/supervisor/supervisord.conf

# Switch back to the default non-root user (assumed to be 'headless')
USER headless

# Expose the dynamic port (Render sets PORT environment variable)
EXPOSE ${PORT:-6080}

# Set resolution and VNC password
ENV VNC_RESOLUTION=1600x761 \
    VNC_PW=yourvncpassword

# Start supervisord to manage Nginx and NoVNC
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
