//! typ 🖨️

const std = @import("std");

/// Send a message to the WebAssembly host.
///
/// Return 0.
/// ________________________________________________________________
pub fn str(msg: []const u8) i32 {
    return send(msg, 0);
}

/// Send a formatted message to the WebAssembly host.
///
/// Return 1 if unable to `allocPrint`, else 0.
/// _________________________________________________
pub fn strf(comptime format: []const u8, args: anytype) i32 {
    const msg = allocPrint(format, args) catch {
        return err("strf: failed fmt");
    };
    defer hpa.free(msg);

    return send(msg, 0);
}

/// Send a error message to the WebAssembly host.
///
/// Return 1.
/// _____________________________________________
pub fn err(msg: []const u8) i32 {
    return send(msg, 1);
}

/// Send a formatted error message to the WebAssembly host.
///
/// Return 1.
/// ________________________________________________________
pub fn errf(comptime format: []const u8, args: anytype) i32 {
    const msg = allocPrint(format, args) catch {
        return err("errf: failed fmt");
    };
    defer hpa.free(msg);

    return send(msg, 1);
}

/// Parse arguments into an array of [C]T
///
/// Requires `comptime` number of arguments.
/// ________________________________________
pub fn parse(comptime C: usize, T: type, ns: [C]usize) ![C]T {
    var n: usize = 0;

    for (ns) |u| n += u;

    const args = try alloc(u8, n);
    defer free(args);

    write(args.ptr);

    return switch (C) {
        0 => .{},
        1 => switch (T) {
            f32 => .{try std.fmt.parseFloat(f32, args[0..ns[0]])},
            i32 => .{try std.fmt.parseInt(i32, args[0..ns[0]], 10)},
            u32 => .{try std.fmt.parseInt(u32, args[0..ns[0]], 10)},
            else => @compileError("Cannot parse this type: " ++ @typeName(T)),
        },
        2 => switch (T) {
            f32 => .{
                try std.fmt.parseFloat(f32, args[0..ns[0]]),
                try std.fmt.parseFloat(f32, args[ns[0]..]),
            },
            i32 => .{
                try std.fmt.parseInt(i32, args[0..ns[0]], 10),
                try std.fmt.parseInt(i32, args[ns[0]..], 10),
            },
            u32 => .{
                try std.fmt.parseInt(u32, args[0..ns[0]], 10),
                try std.fmt.parseInt(u32, args[ns[0]..], 10),
            },
            else => @compileError("Cannot parse this type: " ++ @typeName(T)),
        },
        else => @compileError("Cannot parse this type: " ++ @typeName(T)),
    };
}

/// Send the provided message to the WebAssembly host.
///
/// Return `exit_code`.
/// __________________________________________________
pub fn send(msg: []const u8, exit_code: i32) i32 {
    wasm_minimal_protocol_send_result_to_host(msg.ptr, msg.len);

    return exit_code;
}

/// Write input arguments into the buffer pointed to by `ptr`.
/// __________________________________________________________
pub fn write(ptr: [*]u8) void {
    wasm_minimal_protocol_write_args_to_buffer(ptr);
}

// ===
// Heap page allocator

const hpa = std.heap.page_allocator;

/// Allocate using a `std.heap.page_allocator`.
///
/// Call `free` with the result to free the memory.
/// _______________________________________________
pub fn alloc(comptime T: type, n: usize) ![]T {
    return hpa.alloc(T, n);
}

/// Allocate and format a string with `std.fmt.allocPrint`
/// using a `std.heap.page_allocator`.
///
/// You likely want to use `strf` or `errf` instead.
/// ______________________________________________________
pub fn allocPrint(comptime format: []const u8, args: anytype) ![]u8 {
    const msg = try std.fmt.allocPrint(hpa, format, args);

    return msg;
}

/// Free a slice allocated with `alloc`.
/// ____________________________________
pub fn free(memory: anytype) void {
    hpa.free(memory);
}

// ===
// Functions for the protocol

pub extern "typst_env" fn wasm_minimal_protocol_send_result_to_host(ptr: [*]const u8, len: usize) void;
pub extern "typst_env" fn wasm_minimal_protocol_write_args_to_buffer(ptr: [*]u8) void;
