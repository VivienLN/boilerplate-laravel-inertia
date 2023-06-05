FROM nginx:latest
USER $user

# Copy nginx config
COPY docker/resources/nginx/etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf