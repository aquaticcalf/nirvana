const c = @import("../c.zig").wl;
const display = @import("display.zig");
const types = @import("../types.zig");

const EventQueue = display.EventQueue;
const Proxy = display.Proxy;

pub const Compositor = struct {
    handle: *c.wl_compositor,

    pub fn interface() *const c.wl_interface {
        return &c.wl_compositor_interface;
    }

    pub fn version(self: Compositor) u32 {
        return c.wl_compositor_get_version(self.handle);
    }

    pub fn createSurface(self: Compositor) Surface {
        return .{ .handle = c.wl_compositor_create_surface(self.handle).? };
    }

    pub fn createRegion(self: Compositor) Region {
        return .{ .handle = c.wl_compositor_create_region(self.handle).? };
    }

    pub fn deinit(self: Compositor) void {
        if (self.version() >= c.WL_COMPOSITOR_RELEASE_SINCE_VERSION) {
            c.wl_compositor_release(self.handle);
        } else {
            c.wl_compositor_destroy(self.handle);
        }
    }
};

pub const Region = struct {
    handle: *c.wl_region,

    pub fn interface() *const c.wl_interface {
        return &c.wl_region_interface;
    }

    pub fn add(self: Region, rect: types.Rect) void {
        c.wl_region_add(self.handle, rect.x, rect.y, rect.width, rect.height);
    }

    pub fn addRect(self: Region, x: i32, y: i32, width: i32, height: i32) void {
        c.wl_region_add(self.handle, x, y, width, height);
    }

    pub fn subtract(self: Region, rect: types.Rect) void {
        c.wl_region_subtract(self.handle, rect.x, rect.y, rect.width, rect.height);
    }

    pub fn subtractRect(self: Region, x: i32, y: i32, width: i32, height: i32) void {
        c.wl_region_subtract(self.handle, x, y, width, height);
    }

    pub fn deinit(self: Region) void {
        c.wl_region_destroy(self.handle);
    }
};

pub const Surface = struct {
    handle: *c.wl_surface,

    pub fn interface() *const c.wl_interface {
        return &c.wl_surface_interface;
    }

    pub fn attach(self: Surface, buffer: ?Buffer, x: i32, y: i32) *Surface {
        c.wl_surface_attach(self.handle, if (buffer) |b| b.handle else null, x, y);
        return self;
    }

    pub fn damage(self: Surface, rect: types.Rect) *Surface {
        c.wl_surface_damage(self.handle, rect.x, rect.y, rect.width, rect.height);
        return self;
    }

    pub fn damageRect(self: Surface, x: i32, y: i32, width: i32, height: i32) *Surface {
        c.wl_surface_damage(self.handle, x, y, width, height);
        return self;
    }

    pub fn damageBuffer(self: Surface, rect: types.Rect) *Surface {
        c.wl_surface_damage_buffer(self.handle, rect.x, rect.y, rect.width, rect.height);
        return self;
    }

    pub fn damageBufferRect(self: Surface, x: i32, y: i32, width: i32, height: i32) *Surface {
        c.wl_surface_damage_buffer(self.handle, x, y, width, height);
        return self;
    }

    pub fn frame(self: Surface) display.Callback {
        return .{ .handle = c.wl_surface_frame(self.handle).? };
    }

    pub fn setOpaqueRegion(self: Surface, region: ?Region) *Surface {
        c.wl_surface_set_opaque_region(self.handle, if (region) |r| r.handle else null);
        return self;
    }

    pub fn setInputRegion(self: Surface, region: ?Region) *Surface {
        c.wl_surface_set_input_region(self.handle, if (region) |r| r.handle else null);
        return self;
    }

    pub fn setBufferScale(self: Surface, scale: i32) *Surface {
        c.wl_surface_set_buffer_scale(self.handle, scale);
        return self;
    }

    pub fn setBufferTransform(self: Surface, transform: types.BufferTransform) *Surface {
        c.wl_surface_set_buffer_transform(self.handle, @intFromEnum(transform));
        return self;
    }

    pub fn offset(self: Surface, x: i32, y: i32) *Surface {
        c.wl_surface_offset(self.handle, x, y);
        return self;
    }

    pub fn commit(self: Surface) void {
        c.wl_surface_commit(self.handle);
    }

    pub fn deinit(self: Surface) void {
        c.wl_surface_destroy(self.handle);
    }
};

pub const Buffer = struct {
    handle: *c.wl_buffer,

    pub fn interface() *const c.wl_interface {
        return &c.wl_buffer_interface;
    }

    pub fn addListener(self: Buffer, listener: *const c.wl_buffer_listener, data: ?*anyopaque) !void {
        if (c.wl_buffer_add_listener(self.handle, listener, data) != 0) return error.ListenerFailed;
    }

    pub fn deinit(self: Buffer) void {
        c.wl_buffer_destroy(self.handle);
    }
};

pub const Error = error{ListenerFailed};
