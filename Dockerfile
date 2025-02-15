# Use the official Nginx image as a base
FROM nginx:latest

# Copy your website files to the Nginx HTML directory
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
