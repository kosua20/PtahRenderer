import PackageDescription

/// Run swift build -c release -Xlinker -L/usr/local/lib

let package = Package(
    name: "PtahRenderer",
    targets: [ Target(name: "PtahRenderer", dependencies: []),
               Target(name: "PtahRendererDemo", dependencies: ["PtahRenderer"]),
               Target(name: "PtahRendererDemoOffline", dependencies: ["PtahRendererDemo","PtahRenderer"]),
               Target(name: "PtahRendererDemoOpenGL", dependencies: ["PtahRendererDemo","PtahRenderer"])
	],
    dependencies: [ .Package(url: "https://github.com/SwiftGL/OpenGL.git", majorVersion: 3)],
	exclude: ["data", "ext", "dependencies", "images", "renders", "PtahRendererDemoOnline"]
)

#if os(macOS)
	package.dependencies.append(.Package(url: "https://github.com/kosua20/CGLFW3.git", majorVersion: 1))
#endif
#if os(Linux)
	package.dependencies.append(.Package(url: "https://github.com/kosua20/CGLFW3Linux.git", majorVersion: 1))
#endif
