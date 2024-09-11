const std = @import("std");

pub fn ok(msg: []const u8) i32 {
    send(msg);
    return 0;
}

pub fn err(msg: []const u8) i32 {
    send(msg);
    return 1;
}

pub fn send(msg: []const u8) void {
    wasm_minimal_protocol_send_result_to_host(msg.ptr, msg.len);
}

pub fn in(ptr: [*]u8) void {
    wasm_minimal_protocol_write_args_to_buffer(ptr);
}

// ===
// Heap page allocator

const hpa = std.heap.page_allocator;

pub fn alloc(comptime T: type, n: usize) ![]T {
    return hpa.alloc(T, n);
}

pub fn free(memory: anytype) void {
    hpa.free(memory);
}

// ===
// Functions for the protocol

pub extern "typst_env" fn wasm_minimal_protocol_send_result_to_host(ptr: [*]const u8, len: usize) void;
pub extern "typst_env" fn wasm_minimal_protocol_write_args_to_buffer(ptr: [*]u8) void;
