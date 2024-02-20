const std = @import("std");
const vec = @import("g3_vector.zig");

pub fn main() void {
    // Example usage
    const Vec3_f32 = vec.vector_3(f32);
    var vec1 = Vec3_f32.init(1.2, 2.05, 3.0);
    const vec2 = Vec3_f32.init(4.0, 5.0, 6.0);

    const added = vec1.add(vec2); // tati este bun!!!:)
    const multiplied = vec1.mul(2.0);
    const cross = vec1.cross_product(vec2);
    const length_squared = vec1.len2();
    const length = vec1.len();
    const rotated = vec1.rot2(0.5); // Assuming 0.5 radians rotation angle
    const dot_product = vec1.dot(vec2); // Assuming 0.5 radians rotation angle

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const fmt_str = "added:{!s},\nmultiplied:{!s},\ncross:{!s},\nlength_squared:{d},\nlength:{d},\nrotated:{!s},\ndot_product:{d}\n";
    const fmt_data = .{ added.str(allocator), multiplied.str(allocator), cross.str(allocator), length_squared, length, rotated.str(allocator), dot_product };
    // Output or further operations with results
    std.debug.print(fmt_str, fmt_data);
}
