import Foundation
import PtahRenderer

#if os(macOS)
import Cocoa
import OpenGL.GL3
#else
import COpenGL
#endif


let vertexString = ["#version 330",
                    "in vec2 position;",
					"out vec2 uv;",
					"void main(){",
					"gl_Position = vec4(position,0.0,1.0);",
					"uv = vec2(position.x, -position.y)*0.5+0.5;",
					"}" ].joined(separator:"\n")

let fragmentString = ["#version 330",
                    "in vec2 uv;",
                    "uniform sampler2D tex;",
                    "out vec3 fragColor;",
                    "void main(){",
                    "fragColor = texture(tex, uv).rgb;",
                    "//fragColor = vec3(0.0,1.0,0.5);",
                    "}" ].joined(separator:"\n")

// TODO: clean and comment this mess.

class GLView {
	
    private var _program : GLuint
	private var _texture : GLuint
	private var _vertexArray : GLuint
	private var _width : GLsizei
	private var _height : GLsizei
	
	init(width: Int, height: Int){
		_program = glCreateProgram()
		_width = GLsizei(width)
		_height = GLsizei(height)
		_texture = 0
		_vertexArray = 0
		
		glGenTextures(1, &_texture)
		glBindTexture(GLenum(GL_TEXTURE_2D), _texture)
		glPixelStorei(GLenum(GL_UNPACK_ALIGNMENT), 1)
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_REPEAT)
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_REPEAT)
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_NEAREST)
		glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST)
		// Allocate texture memory.
		glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGB, _width, _height, 0, GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), nil)

		if let vshader = loadShader(content: vertexString, type: GLenum(GL_VERTEX_SHADER)),
			let fshader = loadShader(content: fragmentString, type: GLenum(GL_FRAGMENT_SHADER)){
			glAttachShader(_program, vshader)
			glDeleteShader(vshader)
			glAttachShader(_program, fshader)
			glDeleteShader(fshader)
		}
		
		glLinkProgram(_program)
		var flag : GLint = 0
		glGetProgramiv(_program, GLenum(GL_LINK_STATUS), &flag)
		if flag == GL_FALSE { print("_program \(_program) failed to link") }
		
		glUseProgram(_program)
		loadGeometry()
		let id = glGetUniformLocation(_program, "tex".cString(using: String.Encoding.utf8))
		glUniform1i(id, 0);
		glUseProgram(0)
		
    }
	
	func draw(pixels : [UInt8]){
		glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGB, _width, _height, 0, GLenum(GL_RGB), GLenum(GL_UNSIGNED_BYTE), pixels)
		glDrawElements(GLenum(GL_TRIANGLES), 6, GLenum(GL_UNSIGNED_INT), nil)
	}
	
	func bind(){
		glUseProgram(_program)
		glActiveTexture(0)
		glBindTexture(GLenum(GL_TEXTURE_2D), _texture)
		glBindVertexArray(_vertexArray)
	}
	
	func unbind(){
		glBindTexture(GLenum(GL_TEXTURE_2D), 0)
		glBindVertexArray(0)
		glUseProgram(0)
	}
	
	deinit {
		glDeleteTextures(1,&_texture)
		glDeleteVertexArrays(1,&_vertexArray)
		glDeleteProgram(_program)
	}
	
	private func loadShader(content : String, type : GLenum) -> GLuint? {
		var glContent = UnsafePointer<GLchar>?(content.cString(using: String.Encoding.utf8)!)
		let shader = glCreateShader(type)
		var size = GLint(content.characters.count)
		glShaderSource(shader, 1, &glContent, &size)
		glCompileShader(shader)
		
		var flag : GLint = 0
		glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &flag)
		if(flag == GL_FALSE){
			var length: GLint = 0
			glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &length)
			// Retrieve the info log.
			var str : [GLchar] = Array(repeating: GLchar(0), count: Int(length) + 1)
			var size: GLsizei = 0
			glGetShaderInfoLog(shader, GLsizei(length), &size, &str)
			print("Shader compilation error: " + String(cString: str))
			glDeleteShader(shader)
			return nil
		}
		return shader
	}
	
	private func loadGeometry(){
		// Create vertex array.
		glGenVertexArrays(1, &_vertexArray)
		glBindVertexArray(_vertexArray)
		
		// Create position buffer.
		let pos : [Float] = [-1.0, -1.0,   1.0, -1.0,   1.0, 1.0,   -1.0, 1.0]
		var vertexBuffer : GLuint = 0
		glGenBuffers(1, &vertexBuffer)
		glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
		glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<Float>.size * 2 * pos.count, pos, GLenum(GL_STATIC_DRAW))
		
		// Attribute location setup.
		let id = glGetAttribLocation(_program, "position".cString(using: String.Encoding.utf8))
		if id < 0 {
			print("Error setting attribute")
			return
		}
		// Vertex attribute setup.
		let vertexPositionLocation = GLuint(id)
		glEnableVertexAttribArray(vertexPositionLocation)
		glVertexAttribPointer(vertexPositionLocation, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 0, nil)
		glVertexAttribDivisor(vertexPositionLocation, 0)
		glBindBuffer(GLenum(GL_ARRAY_BUFFER), 0)
		
		// Index buffer setup.
		let index = [GLuint]([0, 1, 2,   0, 2, 3])
		var indexBuffer : GLuint = 0
		glGenBuffers(1, &indexBuffer);
		glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer);
		glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), MemoryLayout<GLuint>.size * index.count, index,GLenum(GL_STATIC_DRAW))
		glBindVertexArray(0);
	}

}
