FROM instrumentisto/flutter:3.41.6 AS builder
WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get --no-color

COPY . .
RUN flutter build web --release --dart-define=APP_ENV=prod
RUN flutter build apk --release --dart-define=APP_ENV=prod

FROM nginx:1.27-alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY --from=builder /app/build/app/outputs/flutter-apk/app-release.apk /usr/share/nginx/html/downloads/pathseek.apk
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
