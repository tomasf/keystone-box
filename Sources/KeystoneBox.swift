import Cadova
import Helical
import Keystone

struct KeystoneBox: Shape3D {
    let wallThickness = 2.0
    let bottomThickness = 2.0

    let lidThickness = 3.0
    let lidThicknessInset = 1.0

    var innerSize: Vector3D {[
        slotSpaceLength,
        slotSpacing * Double(slotCount - 1) + slotSideMargin * 2,
        keystoneSize.y + 17
    ]}
    var outerSize: Vector3D {
        innerSize + [
            frontPanelDepth + wallThickness,
            wallThickness * 2,
            bottomThickness + lidThicknessInset
        ]
    }
    let innerBodyCornerRadius = 4.0

    let slotCount: Int
    let slotSpacing = 22.0
    let slotSideMargin = 20.0
    let slotSpaceLength = 50.0
    let slotZOffset = 10.0
    var slotCenterZ: Double { bottomThickness + keystoneSize.y / 2 + slotZOffset }
    var slotYOffsets: [Double] {
        (0..<slotCount).map {
            wallThickness + slotSideMargin + slotSpacing * Double($0)
        }
    }

    let baseMetrics = KeystoneSlot.Metrics(environment: .defaultEnvironment)
    var keystoneSize: Vector3D { baseMetrics.baseSize }
    var tabHeight: Double { baseMetrics.latchSpaceSize.y }
    var frontPanelDepth: Double { keystoneSize.z }

    // Strain relief
    let cableDiameter = 8.0
    let strainReliefHoleLength = 6.0
    let strainReliefThickness = 4.0
    let cableTieRampSize = 8.0
    let cableTieRampRadius = 0.5

    // Lid mount
    let lidMountHoleDiameter = 5.0
    var lidMountPostSize: Double { frontPanelDepth - wallThickness }
    var lidMountInset: Double { wallThickness + lidMountPostSize / 2 }
    let lidMountBolt = Bolt.hexSocketCountersunk(.m5, length: 16)

    // Bottom mount
    let mountHoleDiameter = 4.6
    let mountHoleBoltHeadDiameter = 12.0
    var mountHoleInsets: Vector2D { .init(
        x: wallThickness + lidMountPostSize + mountHoleBoltHeadDiameter / 2,
        y: wallThickness + mountHoleBoltHeadDiameter / 2
    )}

    var body: any Geometry3D {
        box
            .colored(.powderBlue)
            .inPart(named: "box")
        lid
            .translated(x: outerSize.x + 5)
            .colored(.paleGreen)
            .inPart(named: "lid")
    }

    var outerShape: any Geometry2D {
        Rectangle(outerSize.xy)
            .applyingEdgeProfile(.fillet(radius: lidMountInset))
    }

    var innerShape: any Geometry2D {
        readEnvironment { e in
            outerShape.offset(amount: -wallThickness - e.tolerance / 2, style: .round)
        }
    }

    var innerBodyShape: any Geometry2D {
        innerShape.subtracting {
            Rectangle([frontPanelDepth, outerSize.y])

            Rectangle(lidMountPostSize)
                .applyingEdgeProfile(.fillet(radius: lidMountPostSize / 2), to: .bottomLeft)
                .aligned(at: .right, .top)
                .translated(x: outerSize.x - wallThickness, y: outerSize.y / 2 - wallThickness)
                .symmetry(over: .y)
                .translated(y: outerSize.y / 2)
        }
        .rounded(radius: innerBodyCornerRadius)
    }

    var box: any Geometry3D {
        outerShape
            .extruded(height: outerSize.z)
            .subtracting {
                innerShape
                    .extruded(height: outerSize.z)
                    .translated(z: outerSize.z - lidThicknessInset)

                innerBodyShape
                    .extruded(height: outerSize.z)
                    .translated(z: bottomThickness)

                // Keystone slots
                for slotY in slotYOffsets {
                    KeystoneSlot()
                        .rotated(x: 90°, z: -90°)
                        .translated(x: frontPanelDepth, y: slotY, z: slotCenterZ)
                }

                // Bottom mount
                Cylinder(diameter: mountHoleDiameter, height: bottomThickness + 2)
                    .translated(
                        x: outerSize.x / 2 - mountHoleInsets.x,
                        y: outerSize.y / 2 - mountHoleInsets.y,
                        z: -1
                    )
                    .symmetry(over: .xy)
                    .translated(x: outerSize.x / 2, y: outerSize.y / 2)

                // Lid mount
                ThreadedHole(thread: lidMountBolt.thread, depth: lidMountBolt.length - lidThickness + 0.6)
                    .rotated(x: 180°)
                    .translated(
                        x: outerSize.x / 2 - lidMountInset,
                        y: outerSize.y / 2 - lidMountInset
                    )
                    .symmetry(over: .xy)
                    .translated(x: outerSize.x / 2, y: outerSize.y / 2, z: outerSize.z - lidThicknessInset)
            }
            .adding {
                // Strain relief
                let strainReliefFullLength = strainReliefHoleLength + 2 * strainReliefThickness
                Rectangle([strainReliefFullLength, cableDiameter])
                    .aligned(at: .centerY)
                    .extruded(
                        height: strainReliefThickness + cableDiameter/2 - 1,
                        topEdge: .fillet(radius: 2),
                        bottomEdge: .fillet(radius: cableDiameter / 2)
                    )
                    .translated(z: slotCenterZ - cableDiameter / 2 - strainReliefThickness)
                    .adding {
                        Box([strainReliefThickness, cableDiameter, slotCenterZ - cableDiameter / 2])
                            .aligned(at: .centerY)
                            .clonedAt(x: strainReliefHoleLength + strainReliefThickness)
                    }
                    .translated(x: outerSize.x - strainReliefFullLength)
                    .distributed(at: slotYOffsets, along: .y)

                let betweenSlotsY = zip(slotYOffsets, slotYOffsets.dropFirst()).map {
                    ($0 + $1) / 2
                }

                // Cable tie ramps
                Rectangle(x: cableTieRampSize * 2, y: cableTieRampSize)
                    .aligned(at: .centerX)
                    .subtracting {
                        Circle(radius: cableTieRampSize)
                            .aligned(at: .min)
                            .symmetry(over: .x)
                    }
                    .rounded(outsideRadius: cableTieRampRadius) {
                        Rectangle(x: cableTieRampRadius * 2, y: cableTieRampSize).aligned(at: .centerX)
                    }
                    .extruded(height: strainReliefFullLength)
                    .rotated(x: 90°, z: 90°)
                    .aligned(at: .maxX, .centerY)
                    .translated(x: outerSize.x, z: bottomThickness)
                    .distributed(at: betweenSlotsY, along: .y)
            }
            .subtracting {
                // Cable cutouts
                Circle(diameter: cableDiameter)
                    .clonedAt(x: -outerSize.x)
                    .convexHull()
                    .extruded(height: outerSize.x)
                    .rotated(y: 90°)
                    .translated(x: frontPanelDepth, z: slotCenterZ)
                    .distributed(at: slotYOffsets, along: .y)
            }
    }

    var lid: any Geometry3D {
        readEnvironment { e in
            outerShape
                .extruded(height: lidThickness - lidThicknessInset, bottomEdge: .chamfer(depth: 0.6))
                .adding {
                    innerShape.offset(amount: -e.tolerance / 2, style: .round)
                        .extruded(height: lidThickness)

                    // Back wall
                    Box([wallThickness * 2, innerSize.y - 2 * lidMountPostSize - 2 * innerBodyCornerRadius, outerSize.z - slotCenterZ])
                        .aligned(at: .centerY)
                        .applyingEdgeProfile(.fillet(radius: wallThickness), to: .top, along: .x)
                        .translated(
                            x: outerSize.x - wallThickness * 2,
                            y: outerSize.y / 2,
                            z: lidThicknessInset
                        )
                }
                .subtracting {
                    // Countersunk mount holes
                    lidMountBolt.clearanceHole(recessedHead: true)
                        .translated(z: 0.2)
                        .translated(x: outerSize.x / 2 - lidMountInset, y: outerSize.y / 2 - lidMountInset)
                        .symmetry(over: .xy)
                        .translated(x: outerSize.x / 2, y: outerSize.y / 2)

                    Cylinder(diameter: cableDiameter, height: outerSize.x)
                        .rotated(y: 90°)
                        .translated(x: frontPanelDepth, z: outerSize.z + lidThickness - lidThicknessInset - slotCenterZ)
                        .distributed(at: slotYOffsets, along: .y)

                    Box([wallThickness + e.tolerance, outerSize.y, outerSize.z])
                        .aligned(at: .maxX)
                        .translated(x: outerSize.x, z: lidThickness - lidThicknessInset)
                        .subtracting {
                            Cylinder(diameter: cableDiameter - e.tolerance, height: outerSize.x)
                                .rotated(y: 90°)
                                .clonedAt(z: -outerSize.z)
                                .convexHull()
                                .translated(x: frontPanelDepth, z: slotCenterZ)
                                .distributed(at: slotYOffsets, along: .y)
                        }
                }
        }
    }

    @GeometryBuilder3D
    var assembled: any Geometry3D {
        box
            .adding {
                lid
                    .rotated(x: 180°)
                    .aligned(at: .minY)
                    .translated(z: outerSize.z + lidThickness - lidThicknessInset + 0.15)
            }
            .aligned(at: .centerXY)
    }
}
