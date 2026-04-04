const c = @import("../c.zig").wl;
const std = @import("std");
const server_display = @import("display.zig");
const server_resource = @import("client.zig");

pub const Global = struct {
    handle: *c.wl_global,

    pub fn destroy(self: Global) void {
        c.wl_global_destroy(self.handle);
    }

    pub fn remove(self: Global) void {
        c.wl_global_remove(self.handle);
    }

    pub fn interface(self: Global) [*:0]const u8 {
        return c.wl_global_get_interface(self.handle);
    }

    pub fn name(self: Global) u32 {
        return c.wl_global_get_name(self.handle);
    }

    pub fn version(self: Global) u32 {
        return c.wl_global_get_version(self.handle);
    }

    pub fn display(self: Global) server_display.Display {
        return .{ .handle = c.wl_global_get_display(self.handle).? };
    }

    pub fn userData(self: Global) ?*anyopaque {
        return c.wl_global_get_user_data(self.handle);
    }

    pub fn setUserData(self: Global, data: ?*anyopaque) void {
        c.wl_global_set_user_data(self.handle, data);
    }
};

pub fn createGlobal(
    disp: server_display.Display,
    iface: *const c.wl_interface,
    version: u32,
    data: ?*anyopaque,
) !Global {
    const handle = c.wl_display_create_global(disp.handle, iface, data, version) orelse return error.GlobalFailed;
    return .{ .handle = handle };
}

pub fn getGlobals(disp: server_display.Display) ?GlobalList {
    const list = c.wl_display_get_globals(disp.handle) orelse return null;
    return .{ .handle = list };
}

pub const GlobalList = struct {
    handle: *c.wl_global_list,

    pub fn deinit(self: GlobalList) void {
        c.wl_global_list_destroy(self.handle);
    }

    pub fn iterator(self: GlobalList) GlobalListIterator {
        return .{ .handle = self.handle };
    }
};

pub const GlobalListIterator = struct {
    handle: *c.wl_global_list,

    pub fn next(self: *GlobalListIterator) ?GlobalInfo {
        var info: c.wl_global_info = undefined;
        if (c.wl_global_list_next(self.handle, &info) == 0) return null;
        return .{
            .interface = std.mem.span(info.interface),
            .version = info.version,
            .name = info.name,
        };
    }
};

pub const GlobalInfo = struct {
    interface: []const u8,
    version: u32,
    name: u32,
};

pub const Listener = struct {
    link: c.wl_list,
    notify: fn (listener: *c.wl_listener, data: ?*anyopaque) callconv(.C) void,

    pub fn init(notify: fn (listener: *c.wl_listener, data: ?*anyopaque) callconv(.C) void) Listener {
        return .{
            .link = undefined,
            .notify = notify,
        };
    }

    pub fn raw(self: *Listener) *c.wl_listener {
        return @ptrCast(self);
    }
};

pub const Signal = extern struct {
    listener_list: c.wl_list,

    pub fn init() Signal {
        var signal: Signal = undefined;
        c.wl_signal_init(&signal);
        return signal;
    }

    pub fn add(self: *Signal, listener: *Listener, notify: c.wl_notify_func_t, data: ?*anyopaque) void {
        listener.notify = notify;
        c.wl_signal_add(self, listener.raw(), data);
    }

    pub fn get(self: *Signal, notify: c.wl_notify_func_t) ?*c.wl_listener {
        return c.wl_signal_get(self, notify);
    }

    pub fn emit(self: *Signal, data: ?*anyopaque) void {
        c.wl_signal_emit(self, data);
    }
};

pub const ShmBuffer = struct {
    handle: *c.wl_shm_buffer,

    pub fn fromResource(res: server_resource.Resource) ?ShmBuffer {
        const buf = c.wl_shm_buffer_get(res.handle) orelse return null;
        return .{ .handle = buf };
    }

    pub fn beginAccess(self: ShmBuffer) void {
        c.wl_shm_buffer_begin_access(self.handle);
    }

    pub fn endAccess(self: ShmBuffer) void {
        c.wl_shm_buffer_end_access(self.handle);
    }

    pub fn data(self: ShmBuffer) [*]u8 {
        return c.wl_shm_buffer_get_data(self.handle);
    }

    pub fn stride(self: ShmBuffer) i32 {
        return c.wl_shm_buffer_get_stride(self.handle);
    }

    pub fn format(self: ShmBuffer) u32 {
        return c.wl_shm_buffer_get_format(self.handle);
    }

    pub fn width(self: ShmBuffer) i32 {
        return c.wl_shm_buffer_get_width(self.handle);
    }

    pub fn height(self: ShmBuffer) i32 {
        return c.wl_shm_buffer_get_height(self.handle);
    }
};

pub const Error = error{GlobalFailed};
