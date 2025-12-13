# Flutter build environment for SCM Release Simulation
FROM ghcr.io/cirruslabs/flutter:3.24.3

WORKDIR /app

# Copy only dependency files first (best practice)
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

# Copy full project
COPY . .

# Release simulation step (no heavy APK build)
RUN flutter --version
