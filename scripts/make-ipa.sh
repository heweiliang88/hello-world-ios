#!/usr/bin/env bash
# 把 .app 打包成 .ipa
#
# IPA 本质是一个 zip，内部目录结构固定为 Payload/<App名>.app/
# 打包不需要任何签名工具，摆对结构再压缩即可。
#
# 用法：./make-ipa.sh <path/to/HelloWorld.app> [output.ipa]

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "用法: $0 <path/to/AppName.app> [output.ipa]" >&2
  exit 1
fi

APP_PATH="${1%/}"
APP_NAME="$(basename "$APP_PATH")"
EXEC_NAME="${APP_NAME%.app}"
OUT_IPA="${2:-$(pwd)/${EXEC_NAME}-unsigned.ipa}"

if [[ ! -d "$APP_PATH" ]]; then
  echo "❌ 找不到 .app 目录: $APP_PATH" >&2
  exit 1
fi

if [[ ! -f "$APP_PATH/Info.plist" ]]; then
  echo "❌ $APP_NAME 里没有 Info.plist，不是有效的 .app" >&2
  exit 1
fi

if [[ ! -f "$APP_PATH/$EXEC_NAME" ]]; then
  echo "⚠️  警告：找不到可执行文件 $APP_NAME/$EXEC_NAME，包可能不完整" >&2
fi

mkdir -p "$(dirname "$OUT_IPA")"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
mkdir -p "$TMP_DIR/Payload"

echo "→ 复制 $APP_NAME 到 Payload/"
# 用 -R 递归复制，不要用 -L，否则会解引用符号链接导致 App 启动失败
cp -R "$APP_PATH" "$TMP_DIR/Payload/"

echo "→ 压缩为 IPA"
rm -f "$OUT_IPA"
# -y 保留符号链接（关键），-r 递归，-q 静默
( cd "$TMP_DIR" && zip -qry "$OUT_IPA" Payload )

echo ""
echo "✅ 已生成: $OUT_IPA ($(du -h "$OUT_IPA" | cut -f1))"
