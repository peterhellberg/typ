//! typ 🖨️

const std = @import("std");

/// Send the provided message to the WebAssembly host, and return 0.
/// ________________________________________________________________
pub fn ok(msg: []const u8) i32 {
    send(msg);
    return 0;
}

/// Send the provided message to the WebAssembly host, and return 1.
/// ________________________________________________________________
pub fn err(msg: []const u8) i32 {
    send(msg);
    return 1;
}

/// Send a formatted message to the WebAssembly host.
///
/// If unable to `allocPrint` then return 1, else 0.
/// _________________________________________________
pub fn fmt(comptime format: []const u8, args: anytype) i32 {
    const str = std.fmt.allocPrint(hpa, format, args) catch return err(
        "unable to allocate for fmt",
    );
    defer hpa.free(str);

    return ok(str);
}

/// Send the provided message to the WebAssembly host.
/// __________________________________________________
pub fn send(msg: []const u8) void {
    wasm_minimal_protocol_send_result_to_host(msg.ptr, msg.len);
}

/// Write input arguments into the buffer pointed to by `ptr`.
/// __________________________________________________________
pub fn in(ptr: [*]u8) void {
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

/// Free a slice allocated with `alloc`.
/// ____________________________________
pub fn free(memory: anytype) void {
    hpa.free(memory);
}

// ===
// Functions for the protocol

pub extern "typst_env" fn wasm_minimal_protocol_send_result_to_host(ptr: [*]const u8, len: usize) void;
pub extern "typst_env" fn wasm_minimal_protocol_write_args_to_buffer(ptr: [*]u8) void;
