#!/bin/bash

function disp_reset {
  xrandr --output HDMI-0 --mode 1920x1080 \
      --transform none \
      --panning 1920x1080+0+0 \
      --fb 1920x1080 \
      --dpi 96x96
  echo "Display reset done"
  sleep 8
}

function unity_reset {
  pkill -9 unity-settings
  echo "Unity reset done"
  sleep 4
}

function disp_trans {
  # transform: a,b,c,d,e,f,g,h,i
  # a b c
  # d e f
  #
  # g h i: cos T, -sin T, 0

  # a: x scale
  # b: left-right skew
  # c: x move (in pixel, -100 move 100px to the right)
  # d: rotation (for v1.5)
  # e: y scale
  # f: y move (in pixel, -100 move 100px to the bottom)
  # g: rotation
  # h: vertical bottom skew (0.000001)
  # i: zoom

  # 1920x1080 (0x1be) 148.500MHz +HSync +VSync *current +preferred

  # 0x1c6
  # 0x1c8
  # 1920x1080i

  xrandr --verbose \
    --output HDMI-0 --mode 1920x1080 \
      --transform 1,-0.17,0,0,1,0,-0.00016,0.00005,1 \
      --panning 4331x2192+0+0/1920x1020+0+0 \
      --dpi 96x96
  # --transform 1,-0.22,0,0,1,0,-0.0002,0.0001,1 \
  # --transform 1,-0.24,0,0,1,0,-0.00025,0.00004,1 \
  #             a,   b, c,d,e,  f,g,h,i
  echo "Display trans done"
  sleep 5

  # xrandr --output HDMI-0 --mode 1920x1080 --fb 1920x1080 --transform 1,-0.2,0,0,1,0,-0.0002,0.0001,1 --panning 3299x1505+0+0/1920x960+0+0

  # nvidia-settings -a CurrentMetaMode="HDMI-0: 1920x1080 {ViewPortIn=2200x1200,ViewPortOut=1920x1080-0-0}"
  # HDMI-0 connected primary 2200x1200+0+0 (0x1be) normal (normal left inverted right x axis y axis) 0mm x 0mm

}

# unity_reset
disp_reset
# unity_reset
disp_trans
# unity_reset
# disp_trans
