const std = @import("std");
const c = @import("../c.zig").wl;
const types = @import("../types.zig");

pub const Error = std.mem.Allocator.Error || error{ConnectionFailed};

pub const Display = struct {
    handle: *c.wl_display,

    pub fn connect(name: ?[]const u8) Error!Display {
        const handle = try connectHandle(name);
        return .{ .handle = handle orelse return error.ConnectionFailed };
    }

    pub fn connectDefault() Error!Display {
        return connect(null);
    }

    pub fn connectToFd(fd_arg: i32) Error!Display {
        const handle = c.wl_display_connect_to_fd(fd_arg);
        return if (handle) |h| .{ .handle = h } else error.ConnectionFailed;
    }

    pub fn deinit(self: Display) void {
        c.wl_display_disconnect(self.handle);
    }

    pub fn fd(self: Display) i32 {
        return c.wl_display_get_fd(self.handle);
    }

    pub fn registry(self: Display) Registry {
        return .{ .handle = c.wl_display_get_registry(self.handle).? };
    }

    pub fn sync(self: Display) Callback {
        return .{ .handle = c.wl_display_sync(self.handle).? };
    }

    pub fn createQueue(self: Display) ?EventQueue {
        const handle = c.wl_display_create_queue(self.handle) orelse return null;
        return .{ .handle = handle };
    }

    pub fn createQueueWithName(self: Display, name: []const u8) ?EventQueue {
        const z = std.heap.c_allocator.dupeZ(u8, name) catch return null;
        defer std.heap.c_allocator.free(z);
        const handle = c.wl_display_create_queue_with_name(self.handle, z.ptr) orelse return null;
        return .{ .handle = handle };
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

    pub fn dispatchQueue(self: Display, queue: EventQueue) !u31 {
        const rc = c.wl_display_dispatch_queue(self.handle, queue.handle);
        if (rc < 0) return error.DispatchFailed;
        return @intCast(rc);
    }

    pub fn dispatchQueuePending(self: Display, queue: EventQueue) !u31 {
        const rc = c.wl_display_dispatch_queue_pending(self.handle, queue.handle);
        if (rc < 0) return error.DispatchFailed;
        return @intCast(rc);
    }

    pub fn dispatchTimeout(self: Display, timeout: i32) !u31 {
        const rc = c.wl_display_dispatch_timeout(self.handle, timeout);
        if (rc < 0) return error.DispatchFailed;
        return @intCast(rc);
    }

    pub fn dispatchQueueTimeout(self: Display, queue: EventQueue, timeout: i32) !u31 {
        const rc = c.wl_display_dispatch_queue_timeout(self.handle, queue.handle, timeout);
        if (rc < 0) return error.DispatchFailed;
        return @intCast(rc);
    }

    pub fn flush(self: Display) !u31 {
        const rc = c.wl_display_flush(self.handle);
        if (rc < 0) return error.FlushFailed;
        return @intCast(rc);
    }

    pub fn roundtrip(self: Display) !u31 {
        const rc = c.wl_display_roundtrip(self.handle);
        if (rc < 0) return error.RoundtripFailed;
        return @intCast(rc);
    }

    pub fn roundtripQueue(self: Display, queue: EventQueue) !u31 {
        const rc = c.wl_display_roundtrip_queue(self.handle, queue.handle);
        if (rc < 0) return error.RoundtripFailed;
        return @intCast(rc);
    }

    pub fn prepareRead(self: Display) bool {
        return c.wl_display_prepare_read(self.handle) == 0;
    }

    pub fn prepareReadQueue(self: Display, queue: EventQueue) bool {
        return c.wl_display_prepare_read_queue(self.handle, queue.handle) == 0;
    }

    pub fn cancelRead(self: Display) void {
        c.wl_display_cancel_read(self.handle);
    }

    pub fn readEvents(self: Display) !void {
        if (c.wl_display_read_events(self.handle) != 0) return error.DispatchFailed;
    }

    pub fn lastError(self: Display) i32 {
        return c.wl_display_get_error(self.handle);
    }

    pub fn protocolError(self: Display) struct { code: u32, interface: [*:0]const u8 } {
        var interface: [*:0]const u8 = undefined;
        var code: u32 = undefined;
        c.wl_display_get_protocol_error(self.handle, &interface, &code);
        return .{ .code = code, .interface = interface };
    }

    pub fn setMaxBufferSize(self: Display, size: usize) void {
        c.wl_display_set_max_buffer_size(self.handle, size);
    }
};

pub const EventQueue = struct {
    handle: *c.wl_event_queue,

    pub fn deinit(self: EventQueue) void {
        c.wl_event_queue_destroy(self.handle);
    }

    pub fn name(self: EventQueue) []const u8 {
        const ptr = c.wl_event_queue_get_name(self.handle) orelse return "";
        return std.mem.span(ptr);
    }
};

pub const Proxy = struct {
    handle: *c.wl_proxy,

    pub fn id(self: Proxy) u32 {
        return c.wl_proxy_get_id(self.handle);
    }

    pub fn version(self: Proxy) u32 {
        return c.wl_proxy_get_version(self.handle);
    }

    pub fn className(self: Proxy) []const u8 {
        return std.mem.span(c.wl_proxy_get_class(self.handle));
    }

    pub fn setQueue(self: Proxy, queue: EventQueue) void {
        c.wl_proxy_set_queue(self.handle, queue.handle);
    }

    pub fn setUserData(self: Proxy, data: ?*anyopaque) void {
        c.wl_proxy_set_user_data(self.handle, data);
    }

    pub fn userData(self: Proxy, comptime T: type) ?*T {
        const data = c.wl_proxy_get_user_data(self.handle) orelse return null;
        return @ptrCast(@alignCast(data));
    }
};

pub const Registry = struct {
    handle: *c.wl_registry,

    pub fn interface() *const c.wl_interface {
        return &c.wl_registry_interface;
    }

    pub fn deinit(self: Registry) void {
        c.wl_registry_destroy(self.handle);
    }

    pub fn addListener(self: Registry, listener: *const c.wl_registry_listener, data: ?*anyopaque) !void {
        if (c.wl_registry_add_listener(self.handle, listener, data) != 0) return error.ListenerFailed;
    }

    pub fn bind(self: Registry, name: u32, iface: *const c.wl_interface, version: u32) ?*anyopaque {
        return c.wl_registry_bind(self.handle, name, iface, version);
    }
};

pub const Callback = struct {
    handle: *c.wl_callback,

    pub fn interface() *const c.wl_interface {
        return &c.wl_callback_interface;
    }

    pub fn deinit(self: Callback) void {
        c.wl_callback_destroy(self.handle);
    }

    pub fn addListener(self: Callback, listener: *const c.wl_callback_listener, data: ?*anyopaque) !void {
        if (c.wl_callback_add_listener(self.handle, listener, data) != 0) return error.ListenerFailed;
    }
};

fn connectHandle(name: ?[]const u8) Error!?*c.wl_display {
    if (name) |slice| {
        const z = try std.heap.c_allocator.dupeZ(u8, slice);
        defer std.heap.c_allocator.free(z);
        return c.wl_display_connect(z.ptr);
    }
    return c.wl_display_connect(null);
}
