package texture

import "core:fmt"
import "core:strings"
import stbi "vendor:stb/image"
import "vendor:glfw"
import gl "vendor:OpenGL"

Texture :: struct {
	textureTarget: int,
	textureObj: int,
	imageWidth: i32,
	imageHeight: i32,
	imageBPP: i32,
	filename: string,
}

//@TODO does it have to be a pointer of using is enough?
load :: proc(using self: ^Texture) {
	input_cstring := strings.clone_to_cstring(self.filename);

	stbi.set_flip_vertically_on_load(1)
	image_data := stbi.load(input_cstring, &self.imageWidth, &self.imageHeight, &self.imageBPP, 0)
	if image_data == nil do fmt.println("Image loading failed")
	delete(input_cstring)
	defer stbi.image_free(image_data)
}
