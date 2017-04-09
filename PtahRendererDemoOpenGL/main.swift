import Foundation


#if os(macOS)
import Cocoa
import OpenGL.GL3
#else
import COpenGL
#endif

import CGLFW3


func main(){
	
	glfwInit()
	defer { glfwTerminate() }
	
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3)
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2)
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE)
	glfwWindowHint(GLFW_RESIZABLE, GLFW_TRUE)
	glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GLFW_TRUE)
	
	let window = glfwCreateWindow(800, 600, "Simulator", nil, nil)
	glfwMakeContextCurrent(window)
	guard window != nil else {
		print("Error at GLFW3 window creation.")
		return
	}
	
	// On HiDPI screens, we might have to initially resize the framebuffers size.
	var width : GLsizei = 0, height : GLsizei = 0
	glfwGetFramebufferSize(window, &width, &height)
	
	glViewport(0,0,width, height)
	glDisable(GLenum(GL_DEPTH_TEST))
	glClearColor(1.0,0.0,0.0, 1.0)
	
	// Callbacks
	//glfwSetFramebufferSizeCallback(window, resizeCallback)
	//glfwSetScrollCallback(window, scrollCallback)
	//glfwSetMouseButtonCallback(window, mouseButtonCallback)
	//glfwSetCursorPosCallback (window, cursorPosCallback)
	//glfwSetKeyCallback(window, keyCallback)
	
	// Main loop
	while glfwWindowShouldClose(window) == GLFW_FALSE {
		
		glfwPollEvents()
		glClear(GLenum(GL_COLOR_BUFFER_BIT))
		glfwSwapBuffers(window)
		
	}
}

main()
