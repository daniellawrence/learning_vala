#!/bin/bash
rm iso2usb
valac --pkg gtk+-3.0 --pkg gmodule-2.0 --pkg gee-0.8 --pkg gio-2.0 --pkg glib-2.0 --save-temps iso2usb.vala
./iso2usb

