FROM instrumentisto/flutter:3.41.6 AS web-builder
WORKDIR /app
ARG APP_ENV=prod
ARG API_BASE_URL=https://169.58.74.99

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get --no-color

COPY . .
RUN flutter build web --release --dart-define=APP_ENV=${APP_ENV} --dart-define=API_BASE_URL=${API_BASE_URL}

FROM web-builder AS apk-builder
RUN flutter build apk --release --dart-define=APP_ENV=prod

FROM nginx:1.27-alpine AS web-local
COPY --from=web-builder /app/build/web /usr/share/nginx/html
COPY nginx.local.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

FROM nginx:1.27-alpine
COPY --from=web-builder /app/build/web /usr/share/nginx/html
COPY --from=apk-builder /app/build/app/outputs/flutter-apk/app-release.apk /usr/share/nginx/html/downloads/pathseek.apk
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
