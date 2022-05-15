# Underwater caustics volume material for Armory 3D

![Animated screenshot](/.github/caustics.gif)

This is a custom material for Armory 3D for drawing underwater caustics inside of a mesh (preferably a rectangular solid) as if it was a volume. You can even move the camera into the volume mesh.
The material is more or less based on [this](https://alexanderameye.github.io/notes/realtime-caustics/) neat tutorial by Alexander Ameye, the caustics texture was generated with [this tool](https://www.cathalmcnally.com/news/free-caustics-generator/).

This material requires Armory SDK 22.05 or newer, earlier versions will not work correctly.

## Setup

> The included example file [CausticsVolume.blend](/CausticsVolume.blend) is not required for using this shader. You can delete it locally after downloading this repository.

### Project Setup
1. Clone this repository
2. Copy the `Assets`, `Bundled` and `Shaders` folders to your project's directory
3. Make sure that the scene has a sun light since the shader uses that to project the caustics onto the meshes inside the volume.
4. Load `Assets/Caustics_1.png` or a different caustics texture into your blend file and make sure its used and saved (with fake user or use it in a material node). Depending on the texture you might want to change some of the shader's [parameters](#parameters).
5. Make sure your project uses the deferred render path (`Render Properties > Armory Render Path > Renderer > Deferred Clustered`)

### Material Setup
1. In your project, add a cube and give it a new material.
   <br><br>
   > You might want to display the mesh as wireframe in the viewport by setting `Object Properties > Viewport Display > Display As` to `Wire`.
2. In the material properties, enable `Armory Props > Read Depth` and set `Custom Material` to `CausticsVolume`.
3. In the `Bind Textures` panel below (only visible if a `Custom Material` is set), select the caustics texture and set `Uniform Name` to `tex_caustics`
   <br><br>
   ![Material UI screenshot](/.github/material_setup.png)
   
   
## Parameters

In [`Shaders/CausticsVolume.frag.glsl`](/Shaders/CausticsVolume.frag.glsl) there are some parameters to change the look of the caustics:

```glsl
const float CAUSTICS_SPEED = 0.04; // How fast the caustics move
const float CAUSTICS_SCALE = 0.2; // The size of the caustics
const float CAUSTICS_STRENGTH = 2.4; // The brightness of the caustics
const float EDGE_FADE_RADIUS = 0.3; // Size of the fraction of the mesh that is used to fade in the caustics
const float EDGE_FADE_OFFSET = 0.2; // Offset the fade for finer control
```

There's also a `DEBUG` define in the shader, which when enabled will draw debug information instead of the final output. The drawn debug data is chosen by the `DEBUG_DRAW_MODE` define.
To get the best visual debug output, remove the blending settings from the `CausticsVolume.json` first.

## Roadmap

There are a few things that may (or may not) be improved in the future:

- Chromatic aberration for the caustics
- Support for the forward render path
- Tweak the parameters from within the Blender UI. This will require changes to Armory first.

## License
This work is licensed under the Zlib license which is a very permissive license also used by Armory and Kha at the time of writing this. You can find the license text [here](LICENSE.md).
