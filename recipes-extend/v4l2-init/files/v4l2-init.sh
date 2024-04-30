#!/bin/sh

media-ctl -d /dev/media0 -r
media-ctl -d /dev/media0 -l "'ap1302.0-003c':0 -> 'rzg2l_csi2 16000400.csi20':0 [1]"
media-ctl -d /dev/media0 -l "'rzg2l_csi2 16000400.csi20':1 -> 'CRU output':0 [1]"

media-ctl -d /dev/media0 -V "'ap1302.0-003c':0 [fmt:YUYV8_1X16/1920x1080 field:none colorspace:srgb]"
media-ctl -d /dev/media0 -V "'rzg2l_csi2 16000400.csi20':0 [fmt:YUYV8_1X16/1920x1080  field:none colorspace:srgb]"

echo "Link CSI20 to ap1302.0-003c with format YUYV8_1X16 and resolution 1920x1080"
