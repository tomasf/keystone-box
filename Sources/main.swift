import Cadova

await Project {
    for slotCount in [1, 2, 3, 5, 8, 10, 12] {
        await Model("keystone-box-\(slotCount)") {
            KeystoneBox(slotCount: slotCount)
        }
    }
} environment: {
    $0.tolerance = 0.3
}
