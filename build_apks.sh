#!/bin/bash

# Usage: ./build_apks.sh <input_aab> <output_apks> <keystore> <alias> [--install]

# --- Constants ---
BUNDLETOOL_VERSION="1.15.6"
BUNDLETOOL_URL="https://github.com/google/bundletool/releases/download/$BUNDLETOOL_VERSION/bundletool-all-$BUNDLETOOL_VERSION.jar"
BUNDLETOOL_JAR="bundletool.jar"

# --- Variables ---
INSTALL_APK=false

# --- Parse Arguments ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --install)
            INSTALL_APK=true
            shift
            ;;
        *)
            if [[ -z "$INPUT_AAB" ]]; then
                INPUT_AAB="$1"
            elif [[ -z "$OUTPUT_APKS" ]]; then
                OUTPUT_APKS="$1"
            elif [[ -z "$KEYSTORE" ]]; then
                KEYSTORE="$1"
            elif [[ -z "$ALIAS" ]]; then
                ALIAS="$1"
            else
                echo "❌ Unknown argument: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

# --- Validate required arguments ---
if [[ -z "$INPUT_AAB" || -z "$OUTPUT_APKS" || -z "$KEYSTORE" || -z "$ALIAS" ]]; then
    echo "Usage: $0 <input.aab> <output.apks> <keystore> <alias> [--install]"
    exit 1
fi

# --- Check if bundletool exists, download if missing ---
if [ ! -f "$BUNDLETOOL_JAR" ]; then
    echo "⚠️ bundletool.jar not found. Downloading..."
    if ! wget "$BUNDLETOOL_URL" -O "$BUNDLETOOL_JAR"; then
        echo "❌ Failed to download bundletool. Check your internet connection."
        exit 1
    fi
    echo "✅ Downloaded $BUNDLETOOL_JAR successfully."
fi

# --- Run bundletool ---
echo "📦 Generating APKs from AAB..."
java -jar "$BUNDLETOOL_JAR" build-apks \
    --bundle="$INPUT_AAB" \
    --output="$OUTPUT_APKS" \
    --mode=universal \
    --ks="$KEYSTORE" \
    --ks-key-alias="$ALIAS"

if [ $? -ne 0 ]; then
    echo "❌ Failed to generate APKs"
    exit 1
fi

echo "✅ APKs generated successfully at $OUTPUT_APKS"

# --- Install APK if --install flag is set ---
if [[ "$INSTALL_APK" == true ]]; then
    echo "📲 Installing APKs..."
    TEMP_DIR=$(mktemp -d)
    unzip -o "$OUTPUT_APKS" -d "$TEMP_DIR"
    
    UNIVERSAL_APK="$TEMP_DIR/universal.apk"
    if [ -f "$UNIVERSAL_APK" ]; then
        adb install "$UNIVERSAL_APK"
        if [ $? -eq 0 ]; then
            echo "✅ APK installed successfully!"
        else
            echo "❌ Failed to install APK. Is adb set up correctly?"
        fi
    else
        echo "❌ Could not find universal.apk in $OUTPUT_APKS"
    fi
    rm -rf "$TEMP_DIR"
fi