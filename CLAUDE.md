# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**Slingspace** is a zero-gravity 6DOF spaceflight game built with Godot 4.6 (GDScript). The player pilots a ship through procedurally generated planets using momentum-based physics (Jolt engine, gravity = 0).

## Development Commands

This is a Godot 4.6 project. There is no build system beyond the Godot editor/CLI.

```bash
# Run the game headlessly (CI / quick smoke test)
godot --headless --quit

# Export (requires export templates installed)
godot --export-release "Linux/X11" build/slingspace.x86_64

# Run the project in the editor
godot -e
```

Godot uses `.godot/` as a local cache directory (gitignored). Scene files (`.tscn`, `.scn`) are tracked via **Git LFS** — ensure `git lfs` is installed before cloning.

## Architecture

### Entry Point

`game.gd` / `game.scn` — root scene. Handles mouse capture and ESC-to-pause. All other nodes are children of this scene.

### Player Subsystem (`scripts/player/`, `scenes/player/`)

- **`player.gd`** — `RigidBody3D`. Reads gamepad input each physics frame and directly sets `linear_velocity` and `angular_velocity` via basis-matrix manipulation. No damping; pure momentum. Exposes speed to a UI label.
- **`camera_pivot.gd`** — Follows the ship with `slerp`/`lerp` interpolation each frame. Supports camera pitch via right-stick Y.

Input is gamepad-only (mapped in `project.godot`): L2/R2 = throttle, left stick = pitch/yaw, right stick X = roll, right stick Y = camera pitch.

### Planet Subsystem (`scripts/planet/`)

Procedural cube-sphere terrain. The pipeline:

1. **`planet_data.gd`** (`Resource`) — stores `PlanetNoise[]` layers and `PlanetBiome[]` definitions. Emits `changed` signal so the editor previews update in real-time (`@tool`).
2. **`planet.gd`** (`StaticBody3D`) — owns 6 `PlanetMeshFace` children (one per cube axis direction). Rebuilds faces on `planet_data.changed`.
3. **`planet_mesh_face.gd`** — generates `ArrayMesh` + `ConcavePolygonShape3D` for one cube face. ~200×200 vertices per face. Defers collision updates via `call_deferred` to avoid mid-physics issues.
4. **`planet_noise.gd`** (`Resource`) — a single noise layer: amplitude, min_height, optional mask (uses first layer's output as a continent mask).
5. **`planet_biome.gd`** (`Resource`) — a biome with a gradient `Texture2D` and a `start_height` for latitude-based assignment. Blended into a 2D texture atlas (rows = biomes, columns = elevation gradient) used by the terrain shader.

**Elevation formula per vertex:** `sphere_normal × radius × (summed_noise_elevation + 1.0)`. Noise is sampled at `point × 100` for continent-scale features.

### Data Files

Planet configurations are saved as `.tres` resource files under `assets/`. The ship model + textures live in `assets/test_ship_0/`.

## Coding Conventions

- Always declare variable types explicitly — every `var`, loop variable, and parameter must have a type annotation (e.g. `var foo: String = ...`, `for child: Node in ...`). Never use bare `:=` inference.
- `@tool` annotation on planet scripts enables real-time editor preview; be careful that tool-mode code paths don't crash in the editor (guard with `Engine.is_editor_hint()` when needed).
- Mesh and collision rebuilds must use `call_deferred("_rebuild_mesh")` patterns, not inline calls from physics callbacks.
