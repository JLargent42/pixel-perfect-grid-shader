# pixel-perfect-grid-shader
A GLSL shader to scale 240x160 content onto a 640x480 RGB display

![DSC_0994](https://github.com/user-attachments/assets/c6865bca-d065-42bb-8512-37b4d9e0cb63)


This is a GLSL shader designed to minimize scaling artifacts when scaling 240x160 content onto a 640x480 RGB display.

Version 2 of this shader takes a different objective from version 1: rather than trying to create the most balanced pixels possible at any cost, V2 tries to balance pixels as much as possible without any major artifacts.

This means that the focus is on creating a mostly balanced 3:2 output, not a "perfect" 4:3 stretched output. V2 is still entirely capable of better scaling with stretching provided that the "Horizontal line frequency" parameter is set to 3.0.

## IMPORTANT! READ BEFORE INSTALLING
For this shader to work properly, your base input image should be using nearest-neighbor upscaling. Otherwise, you will see artifacts!

This shader was designed for a video output of 640x426 with a 0px offset in either direction. Using 427px is known to have scaling artifacts, so it is **not recommended**.

This shader was tested on an RG35XXSP device running muOS. This should work the same across most other systems using an RGB subpixel layout, but I cannot confirm.

If you see bad pixel spacing, try adjusting the "Shader x offset" or "Shader y offset" parameters. Precise alignment is required for this shader.
This step should not be necessary if your device uses the settings above.

## Which version should I use?

Generally speaking, this is my usage:

* pxlpfct_v2_1_3by2.glslp with 640x426 output for maximum compatibility
* pxlpfct_v2_1_4by3.glslp with 640x480 output for games where stretching looks fine (mostly RPGs)
* pxlpfct_v2_0_3by2.glslp with 640x426 output for games without much vertical motion

## Is this better than X/Y/Z shader/overlay?

This is subjective, so I can't really answer that. The V2 shader isn't flawless - it's still creating subpixel imbalance. 
I was motivated to build this shader after being relatively disappointed by the slight blur of the "sharp-shimmerless" shader, and I think it succeeds at providing a sharper result.

I've taken a few pictures of various configurations of this shader alongside a couple other community favorites. See for yourself:

[Vertical health bar test](https://imgsli.com/MzIyNzI1/5/8)

[Text test](https://imgsli.com/MzIyNzM3/5/8)

## How it works

This shader achieves its effect by assigning 8 subpixels for every input pixel, then "boosting" the unbalanced color to mitigate color imbalance. This creates an effect very close to perfect scaling in the horizontal direction.
This creates a separate problem - subpixel imbalance. This is very difficult to see in person, but it does exist if you know where to look. To mitigate the imbalance, the shader slightly decreases the output of edge subpixels.

This causes a noticeable grid effect. The shader employs another trick to mitigate this. The power of the shader is scaled by the difference in colors for neighboring pixels. This effectively eliminates any perceptible grid effect.

Scaling in the vertical direction is much trickier. We can't really do subpixel tricks to boost resolution, so interpolation is necessary to balance here. This is why there are two variants of the core "V2". 

* "V2.0" uses a system where unbalanced lines are darkened proportional to the color difference in each channel. This darkening effect is very convincing at keeping edges nice and sharp, but it has two key downsides:
  1. Black pixels will appear unbalanced unless a reasonably strong horizontal grid line is used across the image.
  2. A camera panning vertically will cause a noticeable shimmer effect.
* "V2.1" uses a more standard interpolation, but only in the vertical direction. Unbalanced lines are a blend of the surrounding pixels, proportionate to how much of the line each pixel is supposed to occupy. This solves the two issues of V2.0, but it causes some edges to look slightly less sharp.
  This version is recommended as a general-purpose shader due to the minimal artifacting, but some content may still benefit from the clean lines of V2.0.

## Configuration

This shader is highly configurable. For basic configuration, you can adjust the brightness of bordering subpixels per channel, adjust the brightness of non-bordering subpixels per channel, and adjust the strength of the horizontal grid lines as needed. The current default parameters are tuned to my display and personal preference, but everything can be adjusted in the shader parameters menu.
