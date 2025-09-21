# BVHView (fork)

Fork of [BVHView](https://github.com/orangeduck/BVHView) by [Daniel Holden](https://theorangeduck.com/), adapted for the [GENEA Leaderboard](https://genea-workshop.github.io/leaderboard/) research project.

## Roadmap & features

Feature list focuses on command-line usage. Proper GUI support is not guaranteed, even for completed features.

- [X] Add textured mesh load support (.gltf)
- [X] Add GENEA avatar mesh
- [X] Playback BVH animation onto target mesh
- [X] Add scrubber-synchronized WAV audio
- [X] Load BVH and WAV via command line args
- [X] Add SMPL-X meshes for the BEAT dataset
- [X] Add .mp4 video recording using FFMPEG
- [X] Add audio recording to .mp4 videos
- [ ] Add support for multiple animated models in the same scene

Low-prio features:
- [ ] Model shadows
- [ ] Orthographic camera
- [X] Dockerized setup, .devcontainer

(The list could change with time.)

## Dependencies

To use this repository you need to:
- Have Docker installed
- Download VSCode
- Install "Dev Containers" plugin
- Ctrl+Shift+P > Rebuild and Reopen in Container

When the container finishes building, you can try running:
```
make OUTDIR=build/linux PLATFORM=PLATFORM_LINUX; make OUTDIR=build/windows PLATFORM=PLATFORM_WINDOWS; make OUTDIR=build/webgl PLATFORM=PLATFORM_WEB
```

This will build BVHView for Linux, Windows (x64) and WebGL. If everything works, you'll get no errors.

The documentation below for this section is for the older way of setting up the repository. Hopefully you don't need to follow these instructions :)

### Raylib

Used to open a window, render GUI and graphics (OpenGL), and process user input.

1. Prepare `raylib` (refer to the [original BVHView instructions](https://github.com/orangeduck/BVHView)).
2. Uncomment `#define SUPPORT_FILEFORMAT_JPG` in `raylib/raylib/src/config.h`
   - This allows loading `.jpg` textures for user meshes
   - Other formats have not been tested, but feel free to try
3. Build `raylib` by running `make -B` in `raylib/raylib/src`
4. Build `raygui` (refer to the [original BVHView instructions](https://github.com/orangeduck/BVHView))

### cwalk

Convenience library for manipulating file paths.

1. Download `include/cwalk.h` and `src/cwalk.c` from [here](https://github.com/likle/cwalk).
2. Copy `cwalk.h` and `cwalk.c` to the `src/external` folder in this repository.
3. The `Makefile` will handle the rest when you start building.

### FFmpeg

Used to record videos by streaming the raylib framebuffer.

1. Follow the [original FFmpeg instructions](https://www.ffmpeg.org/download.html).

## Building

1. Follow the [original BVHView instructions](https://github.com/orangeduck/BVHView).

## Usage

Preferably use the *command line interface (CLI)*, as some features (such as `.wav` loading) are only supported via command line arguments.

CLI example:
- `cd "[...]/BVHView/"`
- `./bvhview.exe --bvh="./assets/bvh/genea/trn_2023_v0_000_main-agent.bvh" --wav="./assets/wav/genea/trn_2023_v0_000_main-agent.wav"` *(Remove `.exe` on Linux)*

You can find example files in `assets` folder.

### Args

All arguments are optional. Some additional undocumented options exist in the original source.

**Data**
- `--bvh` : Path to a `.bvh` animation data file.
- `--wav` : Path to a `.wav` audio file.
- `--mesh` : Path to a `.gltf` mesh. If not specified, capsules will be drawn instead. If `.bvh` is not specified, the mesh will be loaded with a default pose, otherwise it will be animated.

**Recording**
- `--record` : Toggle recording of the 3D scene (this hides the window and UI). *Default is disabled.*
- `--recordFps` : Toggle the FPS at which to record. *Default is 30.*
- `--recordDirectory` : Specify an absolute or relative path where recordings will be saved. *Default is `output/video` in the working directory.*
- `--recordName` : Specify the name of the recording. *Default is the name of the `.bvh` file.*

**Camera**
- `--cameraTrack` (boolean) : Forces the camera to track a bone.
- `--cameraTrackBone` (int) : Specifies which bone ID to track if `--cameraTrack` is specified.

**Ground**
- `--groundGridX` (int) : The number of grid cells along the X axis. *Default=11*
- `--groundGridZ` (int) : The number of grid cells along the Z axis. *Default=11*
- `--groundCellWidth` (float) : The size of each grid cell. *Default=2.0*

### Executable

Windows:
- For releases at `BVHView/bvhview.exe`
- For your own builds at `build/BVHView/bvhview.exe`

Linux:
- There are no releases currently
- For your own builds at `build/BVHView/bvhview`

## Mesh support
BVHView (specifically raylib) supports `.gltf`, not `.fbx` meshes. Read below how you can obtain those.

### SMPLX (BEAT2)
There is provided compatibility with SMPLX for the BEAT2 dataset.
1. Download the SMPLX meshes from TBD.
2. Extract the `.zip` to a location of your choice.
3. Setup the [smpl2bvh fork](https://github.com/GENEALeaderboard/smpl2bvh) for the GENEA Leaderboard.
4. Convert BEAT2 `.npz` files with: `python smpl2bvh.py --gender NEUTRAL --poses "[...]/1_wayne_0_2_2.npz" --output "[...]/output.bvh"`
5. Load the bvh with BVHView (Linux): `./bvhview --bvh="[...]/output.bvh" --mesh="[...]/smplx_neutral.gltf"`
   - Make sure to export with the same gender (smpl2bvh) as the mesh you want to load:
     - For `smplx_male.gltf` : `--gender MALE`
     - For `smplx_female.gltf` : `--gender FEMALE`
     - For `smplx_neutral.gltf` : `--gender NEUTRAL`
     - If you don't do this, you can still load `.bvh` files on all meshes, but the angles may be wrong.

### Custom meshes

Convert `fbx` meshes with Blender:

> Note: BVHView is a small software written in C and bvh-mesh compatibility is not polished. The instructions may be different for you based on your character specification.

1. Setup
   1. Install `Blender` ([Official website](https://www.blender.org/download/), [Steam](https://store.steampowered.com/app/365670/Blender/))
   2. Start `Blender`
   3. Delete all scene objects (Camera, Cube, Light...)
2. Import
   1. `File > Import > FBX (.fbx)`
   2. Select your `.fbx` mesh
   3. Import settings:
      1. Reset settings via `Restore Operator Defaults`
      2. Disable `Animation`
   4. Press `Import FBX`
3. Configure model
   1. In `Object Mode` select your armature and then `Object > Apply > All transforms`
   2. In `Object Mode` select your mesh and then `Object > Apply > All transforms`
4. Export
   1. `File > Export > glTF 2.0 (.glb/.gltf)`
   2. Choose export directory
      - *Example: `[...]/BVHView/assets/models/<your_model_folder/>`*
   3. Choose a file name
      - *Warning: you should update the contents of the exported `.gltf` file if you rename any files after the export*
   4. Export settings:
      1. Reset settings via `Restore Operator Defaults`
      2. `Format > glTF Separate (.gltf + .bin + textures)`
      3. Disable `Animation`
   5. Press `Export glTF 2.0`
   6. Test export by running `./bvhview --mesh="<path_to_gltf>"`

### Texture issues

If textures are not loaded correctly or visible, it could be due to texture files not being `.png` or `.jpg` -- only `.png` and `.jpg` are supported currently. For other formats, you should uncomment the corresponding lines in `/raylib/raylib/src/config.h`, rebuild `raylib`, then rebuild `BVHView`.

### Broken mesh issues

If your mesh or animation looks broken, it is likely because the BVH animation and model are incompatible. Diagnosing these issues is tricky, but you can try the following:
- Ensure your BVH and model have the *same* bone hierarchy. Different hierarchies can cause bone rotations to be loaded for the wrong bones.
  - You may need to enable `Add Leaf Bones` when exporting `.gltf` from Blender.
- Ensure ZXY rotation order in your BVH files.
- Ensure your model's `root` bone is exported as a `bone` and not a `model / object`.
- Ensure you use the same naming scheme in the model and BVH.
   - Namespaces shouldn't cause issues, but they could be used for data validation in the future.

---
---

# BVHView (original description)

BVHView is a simple [.bvh animation file format](https://research.cs.wisc.edu/graphics/Courses/cs-838-1999/Jeff/BVH.html) viewer built using [raylib](https://www.raylib.com/).



https://github.com/orangeduck/BVHView/assets/177299/9f976284-02c1-4a14-bca4-b8b3d7c9a774



* [Download (Windows)](https://theorangeduck.com/media/uploads/BVHView/bvhview.zip)
* [Project Page](https://theorangeduck.com/page/bvhview)
* [Web Demo](https://theorangeduck.com/media/uploads/BVHView/bvhview.html)

# Building

## Windows

Download and install [MinGW](https://www.mingw-w64.org/) in some form. Perhaps [w64devkit](https://www.mingw-w64.org/downloads/#w64devkit) or [MSYS2](https://www.mingw-w64.org/downloads/#msys2).

Download [raylib](https://github.com/raysan5/raylib) into `C:/raylib/raylib`.

Download [raygui](https://github.com/raysan5/raygui) into `C:/raylib/raygui`.

Build raylib by going to `C:/raylib/raylib/src` and running `make`.

Download this repo and run `make` in the main directory to build `bvhview.exe`.

To build a release version with optimizations enabled and no console window run `make BUILD_MODE=RELEASE` in the main directory instead.

## Linux

Download [raylib](https://github.com/raysan5/raylib) into `~/raylib/raylib`.

Download [raygui](https://github.com/raysan5/raygui) into `~/raylib/raygui`.

Follow [this guide](https://github.com/raysan5/raylib/wiki/Working-on-GNU-Linux) to install any dependencies. 

Build raylib by going to `~/raylib/raylib/src` and running `make`.

Download this repo and run `make` in the main directory to build `bvhview`.

To build a release version with optimizations enabled run `make BUILD_MODE=RELEASE` in the main directory instead.

## Other

For other platforms you should be able to build BVHView by hacking the `Makefile` a bit. Contributions here welcome.
