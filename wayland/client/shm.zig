const c = @import("../c.zig").wl;
const display = @import("display.zig");
const types = @import("../types.zig");

const Proxy = display.Proxy;

pub const Shm = struct {
    handle: *c.wl_shm,

    pub fn interface() *const c.wl_interface {
        return &c.wl_shm_interface;
    }

    pub fn version(self: Shm) u32 {
        return c.wl_shm_get_version(self.handle);
    }

    pub fn createPool(self: Shm, fd: i32, size: i32) ShmPool {
        return .{ .handle = c.wl_shm_create_pool(self.handle, fd, size).? };
    }

    pub fn addListener(self: Shm, listener: *const c.wl_shm_listener, data: ?*anyopaque) !void {
        if (c.wl_shm_add_listener(self.handle, listener, data) != 0) return error.ListenerFailed;
    }

    pub fn deinit(self: Shm) void {
        if (self.version() >= c.WL_SHM_RELEASE_SINCE_VERSION) {
            c.wl_shm_release(self.handle);
        } else {
            c.wl_shm_destroy(self.handle);
        }
    }
};

pub const ShmPool = struct {
    handle: *c.wl_shm_pool,

    pub fn createBuffer(
        self: ShmPool,
        offset: i32,
        width: i32,
        height: i32,
        stride: i32,
        format: types.ShmFormat,
    ) ShmBuffer {
        return .{
            .handle = c.wl_shm_pool_create_buffer(
                self.handle,
                offset,
                width,
                height,
                stride,
                @intFromEnum(format),
            ).?,
        };
    }

    pub fn resize(self: ShmPool, size: i32) void {
        c.wl_shm_pool_resize(self.handle, size);
    }

    pub fn deinit(self: ShmPool) void {
        c.wl_shm_pool_destroy(self.handle);
    }
};

pub const ShmBuffer = struct {
    handle: *c.wl_buffer,

    pub fn interface() *const c.wl_interface {
        return &c.wl_buffer_interface;
    }

    pub fn deinit(self: ShmBuffer) void {
        c.wl_buffer_destroy(self.handle);
    }
};

pub const Error = error{ListenerFailed};
