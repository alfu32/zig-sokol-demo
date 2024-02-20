const std = @import("std");
const Allocator = std.mem.Allocator;
const vec = @import("g3_vector.zig");

// Define the generic struct for a 3D vector
pub fn box_3(comptime T: type) type { //, comptime precision: u8
    // Define the generic struct for a Box
    return struct {
        const Self = @This();
        anchor: vec.vector_3(T),
        size: vec.vector_3(T),
        // Constructor function for Box
        pub fn init(anchor: vec.vector_3(T), size: vec.vector_3(T)) Self {
            return Self{ .anchor = anchor, .size = size };
        }
        // Method to check if a point is contained within the box
        pub fn contains_point(self: Self, p: vec.vector_3(T)) bool {
            return p.x >= self.anchor.x and p.x <= self.anchor.x + self.size.x and
                p.y >= self.anchor.y and p.y <= self.anchor.y + self.size.y and
                p.z >= self.anchor.z and p.z <= self.anchor.z + self.size.z;
        }

        // Method to check if the box intersects with another box
        pub fn intersects_box(self: Self, other: Self) bool {
            return self.anchor.x < other.anchor.x + other.size.x and
                self.anchor.x + self.size.x > other.anchor.x and
                self.anchor.y < other.anchor.y + other.size.y and
                self.anchor.y + self.size.y > other.anchor.y and
                self.anchor.z < other.anchor.z + other.size.z and
                self.anchor.z + self.size.z > other.anchor.z;
        }

        // Method to compute the corner of the box
        pub fn corner(self: Self) vec.vector_3(T) {
            return vec.vector_3(T){
                .x = self.anchor.x + self.size.x,
                .y = self.anchor.y + self.size.y,
                .z = self.anchor.z + self.size.z,
            };
        }

        // Method to compute the corners of the box
        pub fn corners(self: Self) [8]vec.vector_3(T) {
            const corner0 = self.corner();
            return [_]vec.vector_3(T){
                .{ .x = self.anchor.x, .y = self.anchor.y, .z = self.anchor.z },
                .{ .x = self.anchor.x, .y = self.anchor.y, .z = corner.z },
                .{ .x = self.anchor.x, .y = corner.y, .z = self.anchor.z },
                .{ .x = self.anchor.x, .y = corner.y, .z = corner.z },
                .{ .x = corner.x, .y = self.anchor.y, .z = self.anchor.z },
                .{ .x = corner.x, .y = self.anchor.y, .z = corner.z },
                .{ .x = corner.x, .y = corner.y, .z = self.anchor.z },
                corner0,
            };
        }

        // Method to convert the box to a string
        pub fn to_string(self: Self, allocator: *Allocator) []u8 {
            const format = "Box: anchor({}) size({})";
            const anchorStr = self.anchor.to_string(allocator);
            const sizeStr = self.size.to_string(allocator);
            const length = anchorStr.len + sizeStr.len + format.len - 4; // Subtracting '{}' occurrences
            var buffer = std.mem.Buffer.init(allocator, u8, length);
            const writer = buffer.writer();
            writer.print("Box: anchor({}) size({})", .{ anchorStr, sizeStr });
            return writer.trimAllocatedBuffer();
        }
    };
}
const expect = @import("std").testing.expect;
const assert = @import("std").debug.assert;

test "test contains_point" {
    const box1 = box_3(f64).init(vec.vector_3(f64){ .x = 1.0, .y = 1.0, .z = 1.0 }, vec.vector_3(f64){ .x = 2.0, .y = 2.0, .z = 2.0 });
    const pointInside = vec.vector_3(f64){ .x = 1.5, .y = 1.5, .z = 1.5 };
    const pointOutside = vec.vector_3(f64){ .x = 3.0, .y = 3.0, .z = 3.0 };

    const in1 = box1.contains_point(pointInside);
    const in2 = box1.contains_point(pointOutside);
    std.debug.print("box1 {}, pointInside {} === is_inside {}",.{box1,pointInside,in1});
    std.debug.print("box1 {}, pointOutside {} === is_inside {}",.{box1,pointInside,in2});
    // expect(box1.contains_point(pointInside) == true);
    // expect(box1.contains_point(pointOutside) == false);
}

test "test intersects_box" {
    const box1 = box_3(f64).init(vec.vector_3(f64){ .x = 0.0, .y = 0.0, .z = 0.0 }, vec.vector_3(f64){ .x = 2.0, .y = 2.0, .z = 2.0 });
    const box2 = box_3(f64).init(vec.vector_3(f64){ .x = 1.0, .y = 1.0, .z = 1.0 }, vec.vector_3(f64){ .x = 2.0, .y = 2.0, .z = 2.0 });
    const box3 = box_3(f64).init(vec.vector_3(f64){ .x = 3.0, .y = 3.0, .z = 3.0 }, vec.vector_3(f64){ .x = 2.0, .y = 2.0, .z = 2.0 });
    std.debug.print("box1 {}, box2 {} === intersect {}",.{box1,box2,box1.intersects_box(box2)});
    std.debug.print("box1 {}, box3 {} === intersect {}",.{box1,box3,box1.intersects_box(box3)});
    // expect(box1.intersects_box(box2) == true);
    // expect(box1.intersects_box(box3) == false);
}

test "test corner" {
    const box1 = box_3(f64).init(vec.vector_3(f64){ .x = 1.0, .y = 1.0, .z = 1.0 }, vec.vector_3(f64){ .x = 2.0, .y = 2.0, .z = 2.0 });
    const expectedCorner = vec.vector_3(f64){ .x = 3.0, .y = 3.0, .z = 3.0 };
    std.debug.print("box1 {} === expectedCorner {}",.{box1,expectedCorner});
    // expect(box1.corner() == expectedCorner);
}

test "test corners" {
    const box1 = box_3(f64).init(vec.vector_3(f64){ .x = 0.0, .y = 0.0, .z = 0.0 }, vec.vector_3(f64){ .x = 2.0, .y = 2.0, .z = 2.0 });
    const expectedCorners = [_]vec.vector_3(f64){
        .{ .x = 0.0, .y = 0.0, .z = 0.0 },
        .{ .x = 0.0, .y = 0.0, .z = 2.0 },
        .{ .x = 0.0, .y = 2.0, .z = 0.0 },
        .{ .x = 0.0, .y = 2.0, .z = 2.0 },
        .{ .x = 2.0, .y = 0.0, .z = 0.0 },
        .{ .x = 2.0, .y = 0.0, .z = 2.0 },
        .{ .x = 2.0, .y = 2.0, .z = 0.0 },
        .{ .x = 2.0, .y = 2.0, .z = 2.0 },
    };
    std.debug.print("expected Corners {}",.{expectedCorners});
    std.debug.print("actual corners {}",.{box1,box1.corners()});
    // expect(box1.corners() == expectedCorners);
}

test "test to_string" {
    const box1 = box_3(f64).init(vec.vector_3(f64){ .x = 1.0, .y = 1.0, .z = 1.0 }, vec.vector_3(f64){ .x = 2.0, .y = 2.0, .z = 2.0 });
    const expectedStr = "Box: anchor((1, 1, 1)) size((2, 2, 2))";
    std.debug.print("box1 {}",.{box1});
    std.debug.print("expectedStr {}",.{expectedStr});
    // expect(std.mem.eql(u8, box1.to_string(Allocator.frontAllocator), expectedStr));
}
