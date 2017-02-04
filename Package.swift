import PackageDescription

let package = Package(
    name: "PtahRenderer",
    targets: [ Target(name: "PtahRenderer", dependencies: []),
               Target(name: "PtahRendererDemo", dependencies: ["PtahRenderer"]),
               Target(name: "PtahRendererDemoOffline", dependencies: ["PtahRendererDemo","PtahRenderer"])
            // ,  Target(name: "PtahRendererDemoOnline", dependencies: ["PtahRendererDemo","PtahRenderer"])
	],
	exclude: ["data", "ext", "images", "PtahRendererDemoOnline"]
)
