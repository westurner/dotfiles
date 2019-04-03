#!/bin/sh

wget 'https://zoom.us/linux/download/pubkey'
rpm --import package-signing-key.pub

wget 'https://zoom.us/client/latest/zoom_x86_64.rpm'
