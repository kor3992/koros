# KorOS OpenRC Integration

## Init system

- OpenRC
- Init binary: /usr/bin/openrc-init
- Shutdown: openrc-shutdown
- Service scripts: openrc-arch-services-git

## Important

Arch Linux officially supports systemd.
KorOS uses OpenRC as its primary init system.

## Current challenges

- Device management without systemd
- Session management without systemd-logind
- KDE Plasma Wayland compatibility
- Network management
- Boot process and initramfs integration

## Build requirements

- Custom archiso profile
- OpenRC packages
- OpenRC service configuration
- Custom boot parameters

