# Expo Android Local Build Environment

![Docker Image Version](https://img.shields.io/docker/v/erayalakese/eas-like-local-builder?label=docker)
![GitHub License](https://img.shields.io/github/license/erayalakese/eas-like-local-builder)

`eas-like-local-builder` is a Dockerized local Android build environment designed to mimic Expo EAS build infrastructure for Android. This guide also includes how to convert production `.aab` outputs into `.apks` and install `universal.apk`.

## Why use this

EAS cloud builds can add cost, while local builds usually need a lot of setup. This image targets the EAS Android image family (`ubuntu-22.04-jdk-17-ndk-r26b`) so local and CI/CD builds are closer to EAS behavior.

Reference:
- https://docs.expo.dev/build-reference/infrastructure/#ubuntu-2204-jdk-17-ndk-r26b-latest-sdk-51-sdk-52

## How the build process works

1. Build/run the Docker environment.
2. Log in to Expo/EAS inside the container.
3. Run local EAS Android build with the `production` profile.
4. EAS produces an Android App Bundle (`.aab`).
5. Run `build_apks.sh` to convert `.aab` to a universal `.apks` archive.
6. Either unzip `.apks` and use `universal.apk` manually, or pass `--install` to install with `adb`.

## What is inside this environment

From this repo Dockerfile:
- Ubuntu 22.04 (Jammy)
- OpenJDK 17
- Android NDK r26b
- Android SDK: `platform-tools`, `platforms;android-33`, `build-tools;33.0.0`
- Node.js 20 (via nvm)
- npm 9.8.1
- Yarn 1.22.21
- pnpm 9.3.0
- Bun 1.1.13
- node-gyp 10.1.0
- Git
- EAS CLI
- `EAS_NO_VCS=1` set in the image

## Get started

### Option 1: Use Docker Compose (recommended for this repo)

Build the image:

```bash
docker compose build
```

### Expo login first (required)

Start an interactive container shell:

```bash
docker compose run --rm expo-builder bash
```

Then authenticate:

```bash
expo login
# or
eas login
```

Exit when done:

```bash
exit
```

`docker-compose.yml` mounts `${HOME}/.cache/expo-data` to `/root/.expo`, so auth is persisted between runs.

### Build production AAB

```bash
docker compose run --rm -e PROFILE=production expo-builder
```

Default container command:

```bash
eas build --platform android --local --profile ${PROFILE:-development}
```

For this flow, always use `PROFILE=production`.

### Option 2: Use `docker run` directly

Pull image:

```bash
docker pull erayalakese/eas-like-local-builder
```

Or build locally:

```bash
docker build -t eas-like-local-builder .
```

Run production build:

```bash
docker container run \
  -e PROFILE=production \
  -v /path/to/your/project:/app \
  -w /app \
  -it eas-like-local-builder
```

Persist Expo auth with a named volume:

```bash
docker volume create expo-data
docker container run \
  -e PROFILE=production \
  -v expo-data:/root/.expo \
  -v /path/to/your/project:/app \
  -w /app \
  -it eas-like-local-builder
```

Override command for login or custom commands:

```bash
docker container run -it -v /path/to/your/project:/app -w /app eas-like-local-builder eas login
```

## How `build_apks.sh` works

Usage:

```bash
./build_apks.sh <input.aab> <output.apks> <keystore> <alias> [--install]
```

Script behavior:
- validates required arguments,
- downloads `bundletool.jar` if missing,
- runs bundletool in universal mode:
  - `java -jar bundletool.jar build-apks --mode=universal ...`
- generates an `.apks` archive,
- with `--install`, unzips to a temp directory, finds `universal.apk`, and runs `adb install`.

Notes:
- Keep output extension as `.apks` (not `.apk`).
- You may be prompted for keystore password.

## Create a keystore (if you do not have one)

Generate a release keystore with `keytool`:

```bash
keytool -genkeypair \
  -v \
  -storetype JKS \
  -keystore my-release-key.jks \
  -alias my_key_alias \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

After creation, use:
- `my-release-key.jks` as the `<keystore>` argument
- `my_key_alias` as the `<alias>` argument

## How to use the script properly

### Make `.apks` from a production `.aab`

```bash
./build_apks.sh ./build-1234567890.aab ./build-1234567890.apks ./my-release-key.jks my_key_alias
```

### Convert and install in one command

```bash
./build_apks.sh ./build-1234567890.aab ./build-1234567890.apks ./my-release-key.jks my_key_alias --install
```

### Manual unzip and install path

```bash
unzip -o ./build-1234567890.apks -d ./apks-out
ls ./apks-out
adb install ./apks-out/universal.apk
```

## Docker flag reference

- `-v /path/to/your/project:/app`: mount project into container
- `-w /app`: set working directory
- `-it`: interactive terminal (needed for login/input)
- `-e PROFILE=production`: select build profile
- `-e EAS_NO_VCS=1`: disable VCS checks when needed

## Quick command summary

```bash
# 1) Build image
docker compose build

# 2) Login once (required)
docker compose run --rm expo-builder bash
eas login
exit

# 3) Build production AAB
docker compose run --rm -e PROFILE=production expo-builder

# 4) Convert AAB -> APKS
./build_apks.sh <input.aab> <output.apks> <keystore.jks> <alias>

# 5a) Manual install path
unzip -o <output.apks> -d ./apks-out
adb install ./apks-out/universal.apk

# 5b) Or install directly via script
./build_apks.sh <input.aab> <output.apks> <keystore.jks> <alias> --install
```

## Disclaimer

This project is an independent effort to mimic an EAS-like local Android build environment. It is not affiliated with or endorsed by Expo.

## License

See [LICENSE](LICENSE).
