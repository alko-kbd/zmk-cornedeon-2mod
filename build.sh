#!/usr/bin/bash

# Keyboard name
KEYBOARD="cornedeon_2mod"
BOARD="nice_nano//zmk"

# Paths
WORKSPACE_DIR="/workspaces/zmk"
pushd ${WORKSPACE_DIR}
trap "popd" EXIT
KEYBOARD_DIR="zmk-${KEYBOARD//_/-}"
CONFIG_DIR="${WORKSPACE_DIR}/${KEYBOARD_DIR}/config"
MODULES_DIR="${WORKSPACE_DIR}/${KEYBOARD_DIR};${WORKSPACE_DIR}/ext/cirque-input-module;${WORKSPACE_DIR}/ext/zmk-analog-input-driver;${WORKSPACE_DIR}/ext/zmk-split-peripheral-input-relay"
OUTPUT_DIR="${WORKSPACE_DIR}/${KEYBOARD_DIR}/firmware"

if [ -z "$1" ]; then
    echo "X: shield name not specified."
    echo "Usage: $0 <shield_name>"
    exit 1
fi

SHIELD="${KEYBOARD}_$1"

echo "=== Build: ${SHIELD} ==="

west build -s app -p -b ${BOARD} -S studio-rpc-usb-uart -- \
  -DSHIELD="$SHIELD" \
  -DZMK_CONFIG="$CONFIG_DIR" \
  -DZMK_EXTRA_MODULES="$MODULES_DIR" \
  -DCONFIG_ZMK_STUDIO=y

if [ $? -ne 0 ]; then
    echo "X: build error"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
SOURCE_FILE="build/zephyr/zmk.uf2"
TARGET_FILE="$OUTPUT_DIR/zmk_${SHIELD}.uf2"

if [ -f "$SOURCE_FILE" ]; then
    cp "$SOURCE_FILE" "$TARGET_FILE"
    echo "=== Success! uf2 copied to: $TARGET_FILE ==="
else
    echo "x: ${SOURCE_FILE} not found"
    exit 1
fi
