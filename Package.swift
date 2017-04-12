import PackageDescription

/// Run swift build -c release -Xlinker -L/usr/local/lib

let package = Package(
    name: "PtahRenderer",
    targets: [ Target(name: "PtahRenderer", dependencies: []),
               Target(name: "PtahRendererDemo", dependencies: ["PtahRenderer"]),
               Target(name: "PtahRendererDemoOffline", dependencies: ["PtahRendererDemo","PtahRenderer"]),
	],
    dependencies: [
		
	],
	exclude: ["data", "ext", "images", "renders", "PtahRendererDemoOnline"]
)

#if os(macOS)
    package.targets.append(Target(name: "PtahRendererDemoOnline", dependencies: ["PtahRendererDemo","PtahRenderer"]))
	package.dependencies.append(.Package(url: "https://github.com/kosua20/CGLFW3.git", majorVersion: 1))
#endif

#if os(Linux)
	package.targets.append(Target(name: "PtahRendererDemoOpenGL", dependencies: ["PtahRendererDemo","PtahRenderer"]))
	package.dependencies.append(.Package(url: "https://github.com/kosua20/CGLFW3Linux.git", majorVersion: 1))
	package.dependencies.append(.Package(url: "https://github.com/jaz303/JFOpenGL.swift.git", majorVersion: 3))
#endif
