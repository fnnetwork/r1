# Use a maintained base image with NoVNC and XFCE
FROM accetto/ubuntu-vnc-xfce-g3:20.04

# Install Nginx and apache2-utils for htpasswd
RUN apt-get update && \
    apt-get install -y nginx apache2-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create .htpasswd file for basic auth (username: admin, password: set via HTTP_PASSWORD)
RUN htpasswd -bc /etc/nginx/.htpasswd admin ${HTTP_PASSWORD:-defaultpassword}

# Copy Nginx configuration to proxy NoVNC and enforce basic auth
COPY nginx.conf /etc/nginx/nginx.conf

# Copy custom supervisord.conf to include Nginx
COPY supervisord.conf /etc/supervisor/supervisord.conf

# Expose the dynamic port (Render sets PORT environment variable)
EXPOSE ${PORT:-6080}

# Set resolution and VNC password
ENV VNC_RESOLUTION=1600x761 \
    VNC_PW=yourvncpassword

# Start supervisord to manage Nginx and NoVNC
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]