Expo Android Local Build Environment 🚀
=================================

![Docker Image Version](https://img.shields.io/docker/v/erayalakese/eas-like-local-builder?label=docker) ![GitHub License](https://img.shields.io/github/license/erayalakese/eas-like-local-builder)

Meet **eas-like-local-builder**: a Docker image built to streamline local Expo Android app builds, mirroring the Expo Application Services (EAS) environment for local builds 🎯

Why Use This? 🤔
----------------

EAS cloud building can be costy, local builds require dependencies. This image tries to mimic EAS' [`ubuntu-22.04-jdk-17-ndk-r26b`](https://docs.expo.dev/build-reference/infrastructure/#ubuntu-2204-jdk-17-ndk-r26b-latest-sdk-51-sdk-52) Android build server image in your local (or CI/CD) environment.💥

Get Started 🛠️
---------------

### Step 1: Grab the Image 📦

*   **Pull It**:
    
        docker pull erayalakese/eas-like-local-builder
    
*   **Or Build It Yourself**:
    
        docker build -t eas-like-local-builder .
    

### Step 2: Run It 🏃‍♂️

Defaults to `eas build --platform android --local` with the `development` profile:

    docker container run -v /path/to/your/project:/app -w /app -it eas-like-local-builder

#### Switch Profiles 🔄

Use the `-e` flag for a custom profile like `production`:

    docker container run -e PROFILE=production -v /path/to/your/project:/app -w /app -it eas-like-local-builder

#### Remember expo auth 🔒

    docker volume create expo-data
    docker container run -e PROFILE=production -v expo-data:/root/.expo -v /path/to/your/project:/app -w /app -it eas-like-local-builder

#### Control VCS Behavior 🚫

To skip version control system (VCS) checks during the build (handy if you’re working without a Git repo), set `EAS_NO_VCS`:

    docker container run -e EAS_NO_VCS=1 -v /path/to/your/project:/app -w /app -it eas-like-local-builder

#### Override the Default Command ⚙️

If you ever need to run a different command (e.g., `eas login` or a build with a different profile), you’ll need to override the `CMD` at runtime. You can do this by appending the new command to the `docker run` instruction, like:

    docker container run -v /path/to/your/project:/app -w /app -it eas-like-local-builder eas login

### Explanation of Flags 📜

*   `-v /path/to/your/project:/app`: Mounts your project directory to `/app` inside the container. 📂
*   `-w /app`: Sets the working directory to `/app`. 🏠
*   `-it`: Runs the container interactively for commands that require input (e.g., EAS login). 🖥️
*   `-e PROFILE=...`: Sets the build profile (e.g., `production`); defaults to `development` if not specified. ⚙️
*   `-e EAS_NO_VCS=1`: Disables VCS checks—perfect for no-Git scenarios. 🚫

What’s Inside? 🧰
-----------------

*   **Ubuntu 22.04 (Jammy)**
*   **OpenJDK 17**
*   **Android NDK r26b**
*   **Node.js 18.18.0**
*   **npm 9.8.1**
*   **Yarn 1.22.21**
*   **pnpm 9.3.0**
*   **Bun 1.1.13**
*   **node-gyp 10.1.0**
*   **Git** (latest version)
*   **EAS CLI** (latest version)
*   **Android SDK**:
    *   `platform-tools`
    *   `platforms;android-33`
    *   `build-tools;33.0.0`

EAS Vibes 🎉
------------

Designed to match the [EAS Ubuntu 22.04 JDK 17 NDK r26b image](https://docs.expo.dev/build-reference/infrastructure/#ubuntu-2204-jdk-17-ndk-r26b-latest-sdk-51-sdk-52). Local builds, EAS consistency—boom! 💥

Disclaimer ⚠️
-------------
This repository and its developers are not affiliated with, endorsed by, or connected to Expo or ESA (Expo Application Services). This project is an independent effort to mimic the EAS build environment for local use. Use it at your own risk. 🚧

License 📄
----------

You can basically do everything with this repo and all the responsibility is yours.

The Unlicensed License—check out the [LICENSE](LICENSE) file for the details.
