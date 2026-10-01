FROM instrumentisto/flutter:3.41 AS builder
WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get --no-color

COPY . .
RUN flutter build web --release --dart-define=APP_ENV=prod

FROM nginx:1.27-alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
