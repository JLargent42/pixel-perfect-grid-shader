# pixel-perfect-grid-shader
A GLSL shader to scale 240x160 content onto a 640x480 RGB display

This is a GLSL shader designed to minimize scaling artifacts when scaling 240x160 content onto a 640x480 RGB display.

## Important!
For this shader to work properly, your base input image should be using nearest-neightbor upscaling. Otherwise, you will see artifacts!

Additionally, if you want to preserve the aspect ratio of the input source, be sure to update the "Horizontal line frequency" parameter to 2.67.

This shader only works on displays with an RGB subpixel layout. Depending on your display, you also may need to adjust the "Shader x offset" or "Shader y offset" to align with the nearest-neighbor input.

## How it works

This shader achieves its effect by creating a two subpixel border between each set of two full pixels. If the base image has nearest neighbor upscaling, this will create well-balanced pixels in the horizontal direction.
This creates a separate problem - subpixel imbalance. This is particularly noticeable around the borders, where every vertical border line is surrounded by two subpixels of the same color, amplifying their intensity. To mitigate that, the shader slightly decreases the output of those subpixels. The shader also slightly boosts the color of other subpixels to somewhat correct for this.

The rows scale cleanly with a 3x scale. However, this causes the pixel groups to have a 2x3 pixel area. To make them appear more square, every third pixel has reduced brightness, creating a grid effect when combined with the vertical borders.

![4by3](https://github.com/user-attachments/assets/42ae9c63-7941-4913-88c8-c6ae5bbd5dfc)


Scaling rows like this also causes another issue - the aspect ratio is changed. In some cases, this may be acceptable (and it's the default expectation for the shader). But in other cases, this won't work.
If the aspect ratio must be preserved, pixel imbalance is unavoidable. However, we can adjust the rows to draw every 2.67 pixels. This results in a clean, balanced appearance, though the grid becomes slightly unbalanced as a result.

![3x2](https://github.com/user-attachments/assets/62aa85a3-06bf-4f59-80ef-dce5fcb78bc2)


## Configuration

This shader is highly configurable. For basic configuration, you can adjust the brightness of bordering subpixels per channel, adjust the brightness of non-bordering subpixels per channel, and adjust the strength of the horizontal grid lines as needed. The current default parameters are tuned to my display and personal preference, but everything can be adjusted in the shader parameters menu.
