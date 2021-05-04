# Textureless noise nodes

This folder contains textureless noise nodes.

Perlin, cellilar and simplex noise nodes are based on shaders from [Godot 3.0 Noise Shaders](https://github.com/curly-brace/Godot-3.0-Noise-Shaders).
Random noise node is based on a random post from stackoverflow.

## Implementation details

Some noise function share common helper functions (e.g. `mod289_3`).
That causes errors when multiple noise nodes of different types are used in the same visual shader.
To avoid such errors names of those functions are prefixed with `HELPER_`.
Then in `_get_global_code` all `HELPER_` substrings in shader source are replaced by strings unique for every visual shader node type.
