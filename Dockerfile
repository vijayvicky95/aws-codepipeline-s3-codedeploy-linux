# Use the official Nginx image as a base
FROM nginx:1.25

# Create a non-root user and switch to it
RUN addgroup --system nginx && adduser --system --ingroup nginx nginx
USER nginx

# Copy your custom configuration or HTML files if needed
COPY --chown=nginx:nginx index.html /usr/share/nginx/html/

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
