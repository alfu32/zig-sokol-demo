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
        // pub fn corners(self: Self) [8]vec.vector_3(T) {
        //     const corner0 = self.corner();
        //     return [8]vec.vector_3(T){
        //         vec.vector_3(T).init( self.anchor.x, self.anchor.y, self.anchor.z ),
        //         vec.vector_3(T).init( self.anchor.x, self.anchor.y, corner.z ),
        //         vec.vector_3(T).init( self.anchor.x, corner.y,      self.anchor.z ),
        //         vec.vector_3(T).init( self.anchor.x, corner.y,      corner.z ),
        //         vec.vector_3(T).init( corner.x,      self.anchor.y, self.anchor.z ),
        //         vec.vector_3(T).init( corner.x,      self.anchor.y, corner.z ),
        //         vec.vector_3(T).init( corner.x,      corner.y,      self.anchor.z ),
        //         corner0,
        //     };
        // }

        // Method to convert the box to a string
        pub fn str(self: Self, allocator: Allocator) ![]u8  {
            const fmt = ".{{ vector_3{s}({!s}),vector_3{s}({!s}) }}";
            return try std.fmt.allocPrint(
            allocator,
            fmt,
            .{ @typeName(T), self.anchor.str(allocator),@typeName(T), self.size.str(allocator)},
            );
        }
    };
}
const expect = @import("std").testing.expect;
const assert = @import("std").debug.assert;

test "test contains_point" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const box1 = box_3(f64).init(vec.vector_3(f64){ .x = 1.0, .y = 1.0, .z = 1.0 }, vec.vector_3(f64){ .x = 2.0, .y = 2.0, .z = 2.0 });
    const pointInside = vec.vector_3(f64){ .x = 1.5, .y = 1.5, .z = 1.5 };
    const pointOutside = vec.vector_3(f64){ .x = 3.1, .y = 3.0, .z = 3.0 };

    const in1 = box1.contains_point(pointInside);
    const in2 = box1.contains_point(pointOutside);
    std.debug.print("\nbox1 {!s}, pointInside {!s} === is_inside {}", .{ box1.str(allocator), pointInside.str(allocator), in1 });
    std.debug.print("\nbox1 {!s}, pointOutside {!s} === is_inside {}", .{ box1.str(allocator), pointOutside.str(allocator), in2 });
    std.debug.print("\n", .{});
    try expect(box1.contains_point(pointInside) == true);
    try expect(box1.contains_point(pointOutside) == false);
}

test "test intersects_box" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const box1 = box_3(f64).init(vec.vector_3(f64){ .x = 0.0, .y = 0.0, .z = 0.0 }, vec.vector_3(f64){ .x = 2.0, .y = 2.0, .z = 2.0 });
    const box2 = box_3(f64).init(vec.vector_3(f64){ .x = 1.0, .y = 1.0, .z = 1.0 }, vec.vector_3(f64){ .x = 2.0, .y = 2.0, .z = 2.0 });
    const box3 = box_3(f64).init(vec.vector_3(f64){ .x = 3.0, .y = 3.0, .z = 3.0 }, vec.vector_3(f64){ .x = 2.0, .y = 2.0, .z = 2.0 });
    std.debug.print("\nbox1 {!s}, box2 {!s} === intersect {}", .{ box1.str(allocator), box2.str(allocator), box1.intersects_box(box2) });
    std.debug.print("\nbox1 {!s}, box3 {!s} === intersect {}", .{ box1.str(allocator), box3.str(allocator), box1.intersects_box(box3) });
    std.debug.print("\n", .{});
    try expect(box1.intersects_box(box2) == true);
    try expect(box1.intersects_box(box3) == false);
}

test "test corner" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const box1 = box_3(f64).init(vec.vector_3(f64){ .x = 1.0, .y = 1.0, .z = 1.0 }, vec.vector_3(f64){ .x = 2.0, .y = 2.0, .z = 2.0 });
    const expectedCorner = vec.vector_3(f64){ .x = 3.0, .y = 3.0, .z = 3.0 };
    std.debug.print("\nbox1 {!s} === expectedCorner {}", .{ box1.str(allocator), expectedCorner });
    std.debug.print("\n", .{});
    // try expect(try box1.corner().str(allocator) == try expectedCorner.str(allocator));
}

// test "test corners" {
//     const box1 = box_3(f64).init(vec.vector_3(f64){ .x = 0.0, .y = 0.0, .z = 0.0 }, vec.vector_3(f64){ .x = 2.0, .y = 2.0, .z = 2.0 });
//     const expectedCorners = [_]vec.vector_3(f64){
//         .{ .x = 0.0, .y = 0.0, .z = 0.0 },
//         .{ .x = 0.0, .y = 0.0, .z = 2.0 },
//         .{ .x = 0.0, .y = 2.0, .z = 0.0 },
//         .{ .x = 0.0, .y = 2.0, .z = 2.0 },
//         .{ .x = 2.0, .y = 0.0, .z = 0.0 },
//         .{ .x = 2.0, .y = 0.0, .z = 2.0 },
//         .{ .x = 2.0, .y = 2.0, .z = 0.0 },
//         .{ .x = 2.0, .y = 2.0, .z = 2.0 },
//     };
//     std.debug.print("\nexpected Corners {}",.{expectedCorners});
//     std.debug.print("\nactual corners {}",.{box1,box1.corners()});
//     std.debug.print("\n", .{});
//     // expect(box1.corners() == expectedCorners);
// }

test "test to_string" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const box1 = box_3(f64).init(vec.vector_3(f64){ .x = 1.0, .y = 1.0, .z = 1.0 }, vec.vector_3(f64){ .x = 2.0, .y = 2.0, .z = 2.0 });
    const expectedStr = ".{ vector_3f64(.{ f64(1.00),1.00,1.00 }),vector_3f64(.{ f64(2.00),2.00,2.00 }) }";
    std.debug.print("\nbox1        {!s}", .{box1.str(allocator)});
    std.debug.print("\nexpectedStr {!s}", .{expectedStr});
    std.debug.print("\n", .{});
    // try expect(std.mem.eql(u8, box1.str(allocator), expectedStr));
}
