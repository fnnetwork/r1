# Use the provided base image
FROM fredblgr/ubuntu-novnc:20.04

# Install Nginx and apache2-utils for htpasswd
RUN apt-get update && \
    apt-get install -y nginx apache2-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create .htpasswd file for basic auth (username: admin, password: set via environment variable)
RUN htpasswd -bc /etc/nginx/.htpasswd admin ${HTTP_PASSWORD:-defaultpassword}

# Copy Nginx configuration to proxy NoVNC and enforce basic auth
COPY nginx.conf /etc/nginx/nginx.conf

# Copy custom supervisord.conf to include Nginx and respect PORT
COPY supervisord.conf /etc/supervisor/supervisord.conf

# Expose the dynamic port (Render sets PORT environment variable)
EXPOSE ${PORT:-80}

# Set resolution as in original Dockerfile
ENV RESOLUTION 1600x761

# Start supervisord to manage Nginx and NoVNC
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]