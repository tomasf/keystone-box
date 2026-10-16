import Cadova

await Project {
    await Model("keystone-box") {
        Metadata(
            title: "Keystone Box",
            description: "A surface-mount box with a screw-on lid, slots for keystone modules and strain relief for the cables.",
            author: "Tomas Wincent Franzén",
            license: "MIT"
        )

        @Parameter("Slots", in: 1...16, description: "Number of keystone modules")
        var slotCount = 3

        // Spacing only means something between two slots or more
        let slotSpacing: Double
        if slotCount > 1 {
            @Parameter("Slot spacing", in: 20...40, step: 0.5, unit: "mm", description: "Distance between neighboring slots")
            var chosenSlotSpacing = 22.0
            slotSpacing = chosenSlotSpacing
        } else {
            slotSpacing = 22.0
        }

        @Parameter("Cable diameter", in: 5...12, step: 0.5, unit: "mm", description: "Diameter of the cables")
        var cableDiameter = 8.0

        @Parameter("Tolerance", in: 0...0.6, step: 0.05, unit: "mm", description: "Extra clearance for the modules and the lid. The default usually works fine.")
        var tolerance = 0.3

        Environment {
            $0.tolerance = tolerance
        }

        KeystoneBox(slotCount: slotCount, slotSpacing: slotSpacing, cableDiameter: cableDiameter)
    }
}
