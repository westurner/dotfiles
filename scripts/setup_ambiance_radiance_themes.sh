#!/bin/bash
#cd ~

wget "http://gnome-look.org/CONTENT/content-files/146674-Ambiance&Radiance-XfceLXDE-11-10-2.tar.gz"
sudo tar xzvf "146674-Ambiance&Radiance-XfceLXDE-11-10-2.tar.gz"
sudo mv Ambiance-Xfce-LXDE /usr/share/themes/
sudo mv Radiance-Xfce-LXDE /usr/share/themes/
rm "146674-Ambiance&Radiance-XfceLXDE-11-10-2.tar.gz"
