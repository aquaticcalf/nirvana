const std = @import("std");
const c = @import("../c.zig").wl;
const loop = @import("loop.zig");

pub const Error = std.mem.Allocator.Error || error{ InitFailed, AddSocketFailed, AddSocketAutoFailed };

pub const Display = struct {
    handle: *c.wl_display,

    pub fn init() !Display {
        const handle = c.wl_display_create() orelse return error.InitFailed;
        return .{ .handle = handle };
    }

    pub fn deinit(self: Display) void {
        c.wl_display_destroy(self.handle);
    }

    pub fn addSocket(self: Display, name: []const u8) !void {
        const z = try std.heap.c_allocator.dupeZ(u8, name);
        defer std.heap.c_allocator.free(z);
        if (c.wl_display_add_socket(self.handle, z.ptr) != 0) return error.AddSocketFailed;
    }

    pub fn addSocketAuto(self: Display) ![]const u8 {
        const name = c.wl_display_add_socket_auto(self.handle) orelse return error.AddSocketAutoFailed;
        return std.mem.span(name);
    }

    pub fn addSocketFd(self: Display, fd: i32) void {
        c.wl_display_add_socket_fd(self.handle, fd);
    }

    pub fn getFd(self: Display) i32 {
        return c.wl_display_get_fd(self.handle);
    }

    pub fn getEventLoop(self: Display) loop.EventLoop {
        return .{ .handle = c.wl_display_get_event_loop(self.handle).? };
    }

    pub fn start(self: Display) void {
        c.wl_display_start(self.handle);
    }

    pub fn run(self: Display) void {
        c.wl_display_run(self.handle);
    }

    pub fn terminate(self: Display) void {
        c.wl_display_terminate(self.handle);
    }

    pub fn dispatch(self: Display) !u31 {
        const rc = c.wl_display_dispatch(self.handle);
        if (rc < 0) return error.DispatchFailed;
        return @intCast(rc);
    }

    pub fn dispatchPending(self: Display) !u31 {
        const rc = c.wl_display_dispatch_pending(self.handle);
        if (rc < 0) return error.DispatchFailed;
        return @intCast(rc);
    }

    pub fn dispatchQueue(self: Display, queue: loop.EventQueue) !u31 {
        const rc = c.wl_display_dispatch_queue(self.handle, queue.handle);
        if (rc < 0) return error.DispatchFailed;
        return @intCast(rc);
    }

    pub fn dispatchQueuePending(self: Display, queue: loop.EventQueue) !u31 {
        const rc = c.wl_display_dispatch_queue_pending(self.handle, queue.handle);
        if (rc < 0) return error.DispatchFailed;
        return @intCast(rc);
    }

    pub fn flush(self: Display) !u31 {
        const rc = c.wl_display_flush(self.handle);
        if (rc < 0) return error.FlushFailed;
        return @intCast(rc);
    }

    pub fn createQueue(self: Display) loop.EventQueue {
        return .{ .handle = c.wl_display_create_queue(self.handle).? };
    }

    pub fn lastError(self: Display) i32 {
        return c.wl_display_get_error(self.handle);
    }

    pub fn flushClients(self: Display) void {
        c.wl_display_flush_clients(self.handle);
    }

    pub fn destroyClients(self: Display) void {
        c.wl_display_destroy_clients(self.handle);
    }

    pub fn initShm(self: Display) void {
        c.wl_display_init_shm(self.handle);
    }

    pub fn addShmFormat(self: Display, format: u32) void {
        c.wl_display_add_shm_format(self.handle, format);
    }

    pub fn serial(self: Display) u32 {
        return c.wl_display_get_serial(self.handle);
    }

    pub fn nextSerial(self: Display) u32 {
        return c.wl_display_next_serial(self.handle);
    }
};

pub const Error2 = error{ DispatchFailed, FlushFailed };
