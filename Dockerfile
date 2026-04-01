FROM nginx:alpine

# Remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy pre-built app
COPY dist /usr/share/nginx/html

# Expose port
EXPOSE 3000

# Update nginx config to run on port 3000
RUN sed -i 's/80/3000/g' /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
