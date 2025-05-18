#Use the base image
FROM accetto/ubuntu-vnc-xfce-g3:latest

#Expose the port on which NoVNC runs (80 inside the container)
EXPOSE 80

#Set the environment variable for screen resolution
ENV RESOLUTION 1600x761

#Start the command to run NoVNC
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
