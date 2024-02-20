const std = @import("std");
const test_allocator = std.testing.allocator;
const expect = std.testing.expect;
const eql = std.testing.eql;

// Define the generic struct for a 3D vector
pub fn vector_3(comptime T: type) type { //, comptime precision: u8

    // if (T  std.num.Numeric) {}
    // if (T != std.num.Multiplicative + std.num.Additive) {}
    // if (T != std.num.Multiplicative - std.meta.Ordered) {}
    // if (T != std.num.RealNumber) {}

    return struct {
        const Self = @This();
        x: T,
        y: T,
        z: T,

        // Constructor function
        pub fn init(x: T, y: T, z: T) Self {
            return Self{ .x = x, .y = y, .z = z };
        }

        // Method to add another vector
        pub fn add(self: Self, other: Self) Self {
            return Self.init(self.x + other.x, self.y + other.y, self.z + other.z);
        }

        // Method to multiply by a scalar
        pub fn mul(self: Self, scalar: T) Self {
            return Self.init(self.x * scalar, self.y * scalar, self.z * scalar);
        }

        // Method to compute the cross product
        pub fn cross_product(self: Self, other: Self) Self {
            return Self.init(self.y * other.z - self.z * other.y, self.z * other.x - self.x * other.z, self.x * other.y - self.y * other.x);
        }

        // Method to compute the cross product
        pub fn normalized(self: Self) Self {
            const d = self.len();
            return Self.init(self.x/d, self.y/d, self.z/d);
        }
        // Method to rotate the vector around an axis by a given angle
        pub fn copy(self: Self) Self {
            return Self.init(self.x, self.y, self.z);
        }

        // Method to compute the cross product
        pub fn dot(self: Self, other: Self) T {
            return self.x * other.x + self.y * other.y + self.z * other.z;
        }
        // Method to compute the squared length
        pub fn len2(self: Self) T {
            return self.dot(self);
        }

        // Method to compute the length
        pub fn len(self: Self) f32 {
            return std.math.sqrt(self.len2());
            // return std.math.sqrt(@as(f32, self.len2()));
        }

        // Method to rotate the vector around an axis by a given angle
        pub fn rot2(self: Self, rad: T) Self {
            const cosTheta = std.math.cos(rad);
            const sinTheta = std.math.sin(rad);

            const newX = self.x * cosTheta - self.y * sinTheta;
            const newY = self.x * sinTheta + self.y * cosTheta;
            return Self.init(newX, newY, self.z);
        }
        // Method to rotate the vector around an axis by a given angle
        pub fn str(self: Self, allocator: std.mem.Allocator) ![]u8 {
            const fmt = ".{{ {s}({d:.2}),{d:.2},{d:.2} }}";
            return try std.fmt.allocPrint(
                allocator,
                fmt,
                .{ @typeName(T), self.x, self.y, self.z },
            );
        }
    };
}


test "fmt" {
    const string = try std.fmt.allocPrint(
    test_allocator,
    "\n{d} + {d} = {d}\n",
    .{ 9, 10, 19 },
    );
    defer test_allocator.free(string);
    std.debug.print("{d} + {d} = {d}", .{ 9, 10, 19 });
}
test "vector3_add" {

    const Vec3_f32 = vector_3(f32);
    var vec1 = Vec3_f32.init(1.2, 2.05, 3.0);
    const vec2 = Vec3_f32.init(4.0, 5.0, 6.0);

    const added = vec1.add(vec2);
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const fmt_str = "\n{!s} + {!s} : {!s}\n";
    const fmt_data = .{ vec1.str(allocator), vec2.str(allocator), added.str(allocator)};
// Output or further operations with results
    std.debug.print(fmt_str, fmt_data);
}
test "vector3_mul" {

    const Vec3_f32 = vector_3(f32);
    var vec1 = Vec3_f32.init(1.2, 2.05, 3.0);

    const multiplied = vec1.mul(2.0);
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const fmt_str = "\n{!s} * 2.0 : {!s}\n";
    const fmt_data = .{ vec1.str(allocator), multiplied.str(allocator)};
// Output or further operations with results
    std.debug.print(fmt_str, fmt_data);
}
test "vector3_cross_prod" {

    const Vec3_f32 = vector_3(f32);
    var vec1 = Vec3_f32.init(1.2, 2.05, 3.0);
    const vec2 = Vec3_f32.init(4.0, 5.0, 6.0);

    const cross = vec1.cross_product(vec2);
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const fmt_str = "\n{!s} + {!s} : {!s}\n";
    const fmt_data = .{ vec1.str(allocator), vec2.str(allocator), cross.str(allocator)};
// Output or further operations with results
    std.debug.print(fmt_str, fmt_data);
}

test "vector3_normalized" {

    const Vec3_f32 = vector_3(f32);
    var vec1 = Vec3_f32.init(1.2, 2.05, 3.0);
    const vec2 = Vec3_f32.init(4.0, 5.0, 6.0);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const fmt_str = "\n normalized {!s} : {!s} , len : {d:.2}";
// Output or further operations with results
    std.debug.print(fmt_str, .{ vec1.str(allocator), vec1.normalized().str(allocator), vec1.normalized().len2()});
    std.debug.print(fmt_str, .{ vec2.str(allocator), vec2.normalized().str(allocator), vec2.normalized().len2()});
    std.debug.print("\n", .{});
}
test "vector3_len2" {

    const Vec3_f32 = vector_3(f32);
    var vec1 = Vec3_f32.init(1.2, 2.05, 3.0);

    const length_squared = vec1.len2();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const fmt_str = "\n |{!s}| : {d}\n";
    const fmt_data = .{ vec1.str(allocator), length_squared};
// Output or further operations with results
    std.debug.print(fmt_str, fmt_data);
}
test "vector3_len" {

    const Vec3_f32 = vector_3(f32);
    var vec1 = Vec3_f32.init(1.2, 2.05, 3.0);
    const length = vec1.len();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const fmt_str = "\n |{!s}| : {d}\n";
    const fmt_data = .{ vec1.str(allocator), length};
// Output or further operations with results
    std.debug.print(fmt_str, fmt_data);
}
test "vector3_rot2" {

    const Vec3_f32 = vector_3(f32);
    var vec1 = Vec3_f32.init(1.2, 2.05, 3.0);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const fmt_str = "\n{!s} rot {} rad : {!s}";
// Output or further operations with results
    std.debug.print(fmt_str, .{ vec1.str(allocator), std.math.pi, vec1.rot2(std.math.pi).str(allocator)});
    std.debug.print(fmt_str, .{ vec1.str(allocator), std.math.pi/2.0, vec1.rot2(std.math.pi/2.0).str(allocator)});
    std.debug.print(fmt_str, .{ vec1.str(allocator), std.math.pi/3.0, vec1.rot2(std.math.pi/3.0).str(allocator)});
    std.debug.print(fmt_str, .{ vec1.str(allocator), 2.0*std.math.pi/3.0, vec1.rot2(2.0*std.math.pi/3.0).str(allocator)});
    std.debug.print(fmt_str, .{ vec1.str(allocator), std.math.pi/4.0, vec1.rot2(std.math.pi/4.0).str(allocator)});
    std.debug.print("\n", .{});
}

test "vector3_dot" {

    const Vec3_f32 = vector_3(f32);
    var vec1 = Vec3_f32.init(1.2, 2.05, 3.0);
    const vec2 = Vec3_f32.init(4.0, 5.0, 6.0);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const fmt_str = "\n{!s} . {!s} : {d}";
    // Output or further operations with results
    std.debug.print(fmt_str, .{ vec1.str(allocator), vec2.str(allocator), vec1.dot(vec2)});
    std.debug.print(fmt_str, .{ vec2.str(allocator), vec1.str(allocator), vec2.dot(vec1)});
    std.debug.print("\n", .{});
}