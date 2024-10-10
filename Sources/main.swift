import SwiftSCAD

save(environment: .defaultEnvironment.withTolerance(0.3)) {
    for slotCount in [1, 2, 3, 5, 8, 10, 12] {
        KeystoneBox(slotCount: slotCount)
    }
    //KeystoneBox(slotCount: 3).assembled
}
