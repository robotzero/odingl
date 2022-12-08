package texture

import "core:fmt"
import "core:strings"
import "core:os"
import stbi "vendor:stb/image"
import "vendor:glfw"
import gl "vendor:OpenGL"

Texture :: struct {
	textureTarget: u32,
	textureObj: u32,
	imageWidth: i32,
	imageHeight: i32,
	imageBPP: i32,
	filename: string,
}

load :: proc(using self: ^Texture) -> bool {
	input_cstring := strings.clone_to_cstring(self.filename);

	stbi.set_flip_vertically_on_load(1)
	image_data := stbi.load(input_cstring, &self.imageWidth, &self.imageHeight, &self.imageBPP, 0)
	if image_data == nil do fmt.println("Image loading failed")
	delete(input_cstring)
	defer stbi.image_free(image_data)

	gl.GenTextures(1, &self.textureObj)
	gl.BindTexture(self.textureTarget, self.textureObj)

	switch self.imageBPP {
		case 1: gl.TexImage2D(self.textureTarget, 0, gl.RED, self.imageWidth, self.imageHeight, 0, gl.RED, gl.UNSIGNED_BYTE, image_data)
		case 3: gl.TexImage2D(self.textureTarget, 0, gl.RGB, self.imageWidth, self.imageHeight, 0, gl.RGB, gl.UNSIGNED_BYTE, image_data)
		case 4: gl.TexImage2D(self.textureTarget, 0, gl.RGBA, self.imageWidth, self.imageHeight, 0, gl.RGBA, gl.UNSIGNED_BYTE, image_data)
	}
	
	gl.TexParameterf(self.textureTarget, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
	gl.TexParameterf(self.textureTarget, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
	gl.TexParameterf(self.textureTarget, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameterf(self.textureTarget, gl.TEXTURE_WRAP_T, gl.REPEAT)

	gl.BindTexture(self.textureTarget, 0)

	return true
}

bind :: proc(textureUnit: u32, using self: ^Texture) {
	gl.ActiveTexture(textureUnit)
	gl.BindTexture(self.textureTarget, self.textureObj)
}
