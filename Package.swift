import PackageDescription

/// Run swift build -c release -Xlinker -L/usr/local/lib

let package = Package(
    name: "PtahRenderer",
    targets: [ Target(name: "PtahRenderer", dependencies: []),
               Target(name: "PtahRendererDemo", dependencies: ["PtahRenderer"]),
               Target(name: "PtahRendererDemoOffline", dependencies: ["PtahRendererDemo","PtahRenderer"]),
                Target(name: "PtahRendererDemoOpenGL", dependencies: ["PtahRendererDemo","PtahRenderer"])
            // ,  Target(name: "PtahRendererDemoOnline", dependencies: ["PtahRendererDemo","PtahRenderer"])
	],
    dependencies: [
		.Package(url: "https://github.com/kosua20/COpenGL.git", majorVersion: 1),
		.Package(url: "https://github.com/kosua20/CGLFW3.git", majorVersion: 1)
	],
	exclude: ["data", "ext", "images", "renders", "PtahRendererDemoOnline"]
)
