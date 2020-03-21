import os
import os.path

folder = "./assets/graphics/animated_shore_tiles"
print(os.listdir("./assets/graphics/animated_shore_tiles"))


def make_tres_files():
    png_files = []
    for file_name in os.listdir(folder):
        if file_name.endswith(".png"):
            png_files.append(file_name)

    animated_tiles = {}
    for png_file_name in png_files:
        tile_name: str = png_file_name[:-6]
        tile_number: int = int(png_file_name[-5])
        if tile_name not in animated_tiles:
            animated_tiles[tile_name] = {}
        animated_tiles[tile_name][tile_number] = png_file_name


    for animated_tile_name, tiles in animated_tiles.items():
        with open(os.path.join(folder, animated_tile_name + ".tres"), "w") as fp:
            fp.write(f'[gd_resource type="AnimatedTexture" load_steps={len(tiles) + 1} format=2]\n\n')
            for i in range(len(tiles)):
                tile_file_name = tiles[i]
                fp.write(f'[ext_resource path="res://assets/graphics/animated_shore_tiles/{tile_file_name}" type="Texture" id={i + 1}]\n')
            
            fp.write("\n")

            fp.write("[resource]\n")
            fp.write(f"frames = {len(tiles) + len(tiles) - 2}\n")
            fp.write(f"fps = 2.0")

            order = [0, 1, 0, 2]

            for i, order_number in enumerate(order):
                fp.write(f"frame_{i}/texture = ExtResource( {order_number + 1} )\n")
                if i != 0:
                    fp.write(f"frame_{i}/delay_sec = 0.0\n")


            # for i in range(len(tiles)):
            #     fp.write(f"frame_{i}/texture = ExtResource( {i + 1} )\n")
            #     if i != 0:
            #         fp.write(f"frame_{i}/delay_sec = 0.0\n")

            # reverse_order = list(range(len(tiles)))[1:-1]
            # reverse_order.reverse()

            # for i in reverse_order:
            #     fp.write(f"frame_{len(tiles) - 1 + i}/texture = ExtResource( {i + 1} )\n")
            #     if i != 0:
            #         fp.write(f"frame_{len(tiles) - 1 + i}/delay_sec = 0.0\n")

            fp.write("\n")


def make_tilemap():
    tres_files = []
    for file_name in os.listdir(folder):
        if file_name.endswith(".tres"):
            tres_files.append(file_name)

    with open("./src/game/tilesets/AnimatedCoasts.tscn", "w") as fp:
        fp.write(f"[gd_scene load_steps={len(tres_files)} format=2]\n\n")

        for i, tres_file in enumerate(tres_files):
            fp.write(f'[ext_resource path="res://assets/graphics/animated_shore_tiles/{tres_file}" type="Texture" id={i + 1}]\n')
            
        fp.write("\n")
        fp.write('[sub_resource type="TileSet" id=1]\n')

        for i, tres_file in enumerate(tres_files):
            fp.write(f'{i}/name = "{tres_file[:-4]}"\n')
            fp.write(f'{i}/texture = ExtResource( {i + 1} )\n')
            fp.write(f'{i}/tex_offset = Vector2( 0, 0 )\n')
            fp.write(f'{i}/modulate = Color( 1, 1, 1, 1 )\n')
            fp.write(f'{i}/region = Rect2( 0, 0, 16, 16 )\n')
            fp.write(f'{i}/tile_mode = 0\n')
            fp.write(f'{i}/occluder_offset = Vector2( 0, 0 )\n')
            fp.write(f'{i}/navigation_offset = Vector2( 0, 0 )\n')
            fp.write(f'{i}/shape_offset = Vector2( 0, 0 )\n')
            fp.write(f'{i}/shape_transform = Transform2D( 1, 0, 0, 1, 0, 0 )\n')
            fp.write(f'{i}/shape_one_way = false\n')
            fp.write(f'{i}/shape_one_way_margin = 0.0\n')
            fp.write(f'{i}/shapes = [  ]\n')
            fp.write(f'{i}/z_index = 0\n')

        fp.write("\n")
        fp.write('[node name="AnimatedCoasts" type="TileMap"]\n')
        fp.write('tile_set = SubResource( 1 )\n')
        fp.write('cell_size = Vector2( 16, 16 )\n')
        fp.write('format = 1\n')

make_tres_files()
make_tilemap()