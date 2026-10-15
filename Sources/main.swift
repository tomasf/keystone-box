import Cadova

await Project {
    await Model("keystone-box") {
        Metadata(
            title: "Keystone Box",
            description: "A surface-mount box with a screw-on lid, slots for keystone modules and strain relief for the cables."
        )

        @Parameter("Slots", in: 1...16, description: "Number of keystone modules")
        var slotCount = 3

        @Parameter("Cable diameter", in: 5...12, step: 0.5, unit: "mm", description: "Diameter of the network cables")
        var cableDiameter = 8.0

        @Parameter("Tolerance", in: 0...0.6, step: 0.05, unit: "mm", description: "Extra clearance for the modules and the lid. The default usually works fine.")
        var tolerance = 0.3

        Environment {
            $0.tolerance = tolerance
        }

        KeystoneBox(slotCount: slotCount, cableDiameter: cableDiameter)
    }
}
