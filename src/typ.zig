const std = @import("std");

/// Send the provided message to the WebAssembly host, and returns 0.
pub fn ok(msg: []const u8) i32 {
    send(msg);
    return 0;
}

/// Send the provided message to the WebAssembly host, and returns 1.
pub fn err(msg: []const u8) i32 {
    send(msg);
    return 1;
}

/// Send the provided message to the WebAssembly host.
pub fn send(msg: []const u8) void {
    wasm_minimal_protocol_send_result_to_host(msg.ptr, msg.len);
}

/// Write input arguments into the buffer pointed to by ptr.
pub fn in(ptr: [*]u8) void {
    wasm_minimal_protocol_write_args_to_buffer(ptr);
}

// ===
// Heap page allocator

const hpa = std.heap.page_allocator;

/// Allocate using a `std.heap.page_allocator`.
///
/// Call `free` with the result to free the memory.
pub fn alloc(comptime T: type, n: usize) ![]T {
    return hpa.alloc(T, n);
}

/// Free an array allocated with `alloc`.
pub fn free(memory: anytype) void {
    hpa.free(memory);
}

// ===
// Functions for the protocol

pub extern "typst_env" fn wasm_minimal_protocol_send_result_to_host(ptr: [*]const u8, len: usize) void;
pub extern "typst_env" fn wasm_minimal_protocol_write_args_to_buffer(ptr: [*]u8) void;
