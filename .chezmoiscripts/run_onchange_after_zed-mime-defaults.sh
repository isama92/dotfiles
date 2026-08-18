#!/bin/sh
set -eu

# skip on machines without GNOME tooling or without Zed
command -v gio >/dev/null 2>&1 || exit 0
[ -x "$HOME/.local/zed.app/bin/zed" ] || exit 0

for t in \
  text/plain application/x-zerosize text/markdown \
  application/x-php application/json application/yaml application/toml \
  application/xml application/sql application/x-shellscript \
  text/css text/x-scss text/javascript text/x-python \
  text/rust text/x-go text/x-makefile text/x-log text/x-patch \
  text/vnd.trolltech.linguist application/x-tiled-tsx
do
  gio mime "$t" dev.zed.Zed.desktop >/dev/null
done

# folders stay with the file manager
gio mime inode/directory org.gnome.Nautilus.desktop >/dev/null

update-desktop-database "$HOME/.local/share/applications"
