# Expo Android Local Build Environment

![Docker Image Version](https://img.shields.io/docker/v/erayalakese/eas-like-local-builder?label=docker)
![GitHub License](https://img.shields.io/github/license/erayalakese/eas-like-local-builder)

`eas-like-local-builder` is a Dockerized local Android build environment designed to mimic Expo EAS build infrastructure for Android. This guide also includes how to convert production `.aab` outputs into `.apks` and install `universal.apk` onto a device.

## Why use this

EAS cloud builds can add cost, while local builds usually need a lot of setup. This image targets the EAS Android image family (`ubuntu-22.04-jdk-17-ndk-r26b`) so local and CI/CD builds are closer to EAS behavior.

Reference:
- https://docs.expo.dev/build-reference/infrastructure/#ubuntu-2204-jdk-17-ndk-r26b-latest-sdk-51-sdk-52

## Prerequisites (host machine, outside Docker)

Install these on your local machine:
- Docker Engine (or Docker Desktop)
- Docker Compose (`docker compose`)
- Java JDK (`java`) to run `bundletool.jar` via `build_apks.sh`
- `keytool` (usually part of JDK) if you need to create a new signing keystore, which you will if you want to test your build locally before playstore upload
- `unzip` to manually extract `.apks`
- Android Platform Tools (`adb`) if you want to install the generated `universal.apk`

Also required for install steps:
- An Android device/emulator with USB debugging enabled

## TLDR Quick command summary -> compiles source code into an apk you can install on your local device  

0) Create a local keystore (if you do not have one)

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

Use `my-release-key.jks` as `<keystore>` and `my_key_alias` as `<alias>`.

1) Build image once 

```bash
docker compose build
```

2) Login once (required)

```bash
docker compose up -d -name expo-builder  # Make sure you mount the directory with your source code as a volume to /workspace inside the container
docker exec -it expo-builder bash 
```

```bash
eas login
```

3) Build production AAB (run inside the container)
 
```bash
eas build --platform android --local --profile ${PROFILE:-development}
exit
```

4) Convert AAB -> APKS (Outside the docker container)

```bash
chmod +x ./build_apks.sh
./build_apks.sh <input.aab> <output.apks> <keystore.jks> <alias>
```

Example:

```bash
./build_apks.sh build-1234567890.aab output.apks my-release-key.jks my_key_alias
```

5a) Install directly via script

```bash
./build_apks.sh <input.aab> <output.apks> <keystore.jks> <alias> --install
```

5b) Manual install path

```bash
unzip -o <output.apks> -d ./apks-out
```

```bash
adb install ./apks-out/universal.apk
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
- generates an `.apks` archive, which is just a zip with a universal.apk inside
- with `--install`, unzips to a temp directory, finds `universal.apk`, and runs `adb install` to install the apk.

Notes:
- Keep output extension as `.apks` (not `.apk`).
- You may be prompted for keystore password.

## Why do I need to create a keystore (if I do not have one)?

When building an expo app using the `eas` cli you must login and create a project for your app. This also automatically creates and manages an android keystore for you in the expo cloud project.
This keystore is used to sign the compiled `.aab` which is the bundled format of the android app that you can upload to the playstore, note you cannot install this `.aab` file directly onto your device, this happens for the production profile only. When using a development profile a signed `.apk` is made using the `eas` keystore which you can install directly onto your phone.
To convert an `.aab` to an `.apk` you must use `bundletool`; however, this requires re-signing the application. Therefore you must either generate a new keystore to use locallly or download the existing one in `eas` expo cloud.

To downlaod the existing keystore run:

```bash
eas credentials -p android
```

OR

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

### Make `.apks` from a production `.aab`

```bash
./build_apks.sh ./build-1234567890.aab ./build-1234567890.apks ./my-release-key.jks my_key_alias
```

### Convert and install in one command

```bash
./build_apks.sh ./build-1234567890.aab ./build-1234567890.apks ./my-release-key.jks my_key_alias --install
```

### Manual unzip apks and install to device

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

## Disclaimer

This project is an independent effort to mimic an EAS-like local Android build environment. It is not affiliated with or endorsed by Expo.

## License

See [LICENSE](LICENSE).
