const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b.addModule("typ", .{
        .root_source_file = b.path("src/typ.zig"),
    });
}
