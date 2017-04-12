import Foundation
import JFOpenGL

#if os(macOS)
import CGLFW3
#else
import CGLFW3Linux
#endif


class GLWindow {
	
	private let window : OpaquePointer
	private let view : GLView
	
	init(width: Int, height: Int) {
		glfwInit()
		glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3)
		glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2)
		glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE)
		glfwWindowHint(GLFW_RESIZABLE, GLFW_TRUE)
		glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GLFW_TRUE)
		
		window = glfwCreateWindow(Int32(width), Int32(height), "PtahDemo", nil, nil)
		
		glfwMakeContextCurrent(window)
		
		glfwSetScrollCallback(window, scrollCallback)
		glfwSetMouseButtonCallback(window, mouseButtonCallback)
		glfwSetCursorPosCallback (window, cursorPosCallback)
		
		// On HiDPI screens, we might have to initially resize the framebuffers size.
		var widthDPI : GLsizei = 0, heightDPI : GLsizei = 0
		glfwGetFramebufferSize(window, &widthDPI, &heightDPI)
		
		glViewport(0,0,widthDPI, heightDPI)
		glDisable(GL_DEPTH_TEST)
		glEnable(GL_CULL_FACE)
		glClearColor(1.0,0.0,0.0, 1.0)
		
		view = GLView(width: width, height : height)
		view.bind()
	}
	
	func draw(pixels: [UInt8]){
		view.draw(pixels:pixels)
		glfwSwapBuffers(window)
		glfwPollEvents()
	}
	
	func shouldClose() -> Bool {
		return glfwWindowShouldClose(window) == GLFW_TRUE
	}
	
	deinit {
		view.unbind()
		glfwTerminate()
	}
}


/// Callbacks

//	As GLFW3 is exposed as a C API here, the callbacks can't be class/instance methods. We also need to expose a few variables for them. We implicitely call simpler global scopes functions defined in the main.

fileprivate var deltaCursorX = 0.0
fileprivate var deltaCursorY = 0.0
fileprivate var shouldListenToCursor = false

fileprivate func mouseButtonCallback(window: OpaquePointer?, button: Int32, action: Int32, modifiers : Int32) -> Void {
	if button == GLFW_MOUSE_BUTTON_LEFT {
		if action == GLFW_PRESS {
			var x = 0.0, y = 0.0
			glfwGetCursorPos(window, &x, &y)
			deltaCursorX = x
			deltaCursorY = y
			shouldListenToCursor = true
		} else {
			shouldListenToCursor = false
		}
	}
}

fileprivate func cursorPosCallback(window: OpaquePointer?, x: Double, y: Double) -> Void {
	if shouldListenToCursor {
		dragCallback(deltaX: x - deltaCursorX,
		             deltaY: y - deltaCursorY)
		deltaCursorX = x
		deltaCursorY = y
	}
}

fileprivate func scrollCallback(window: OpaquePointer?, xoffset : Double, yoffset: Double) {
	scrollCallback(yoffset: yoffset)
}
