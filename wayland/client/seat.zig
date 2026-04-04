const c = @import("../c.zig").wl;
const display = @import("display.zig");
const types = @import("../types.zig");

const Proxy = display.Proxy;

pub const Seat = struct {
    handle: *c.wl_seat,

    pub fn interface() *const c.wl_interface {
        return &c.wl_seat_interface;
    }

    pub fn version(self: Seat) u32 {
        return c.wl_seat_get_version(self.handle);
    }

    pub fn getPointer(self: Seat) Pointer {
        return .{ .handle = c.wl_seat_get_pointer(self.handle).? };
    }

    pub fn getKeyboard(self: Seat) Keyboard {
        return .{ .handle = c.wl_seat_get_keyboard(self.handle).? };
    }

    pub fn getTouch(self: Seat) Touch {
        return .{ .handle = c.wl_seat_get_touch(self.handle).? };
    }

    pub fn addListener(self: Seat, listener: *const c.wl_seat_listener, data: ?*anyopaque) !void {
        if (c.wl_seat_add_listener(self.handle, listener, data) != 0) return error.ListenerFailed;
    }

    pub fn deinit(self: Seat) void {
        if (self.version() >= c.WL_SEAT_RELEASE_SINCE_VERSION) {
            c.wl_seat_release(self.handle);
        } else {
            c.wl_seat_destroy(self.handle);
        }
    }
};

pub const Pointer = struct {
    handle: *c.wl_pointer,

    pub fn interface() *const c.wl_interface {
        return &c.wl_pointer_interface;
    }

    pub fn version(self: Pointer) u32 {
        return c.wl_pointer_get_version(self.handle);
    }

    pub fn addListener(self: Pointer, listener: *const c.wl_pointer_listener, data: ?*anyopaque) !void {
        if (c.wl_pointer_add_listener(self.handle, listener, data) != 0) return error.ListenerFailed;
    }

    pub fn deinit(self: Pointer) void {
        if (self.version() >= c.WL_POINTER_RELEASE_SINCE_VERSION) {
            c.wl_pointer_release(self.handle);
        } else {
            c.wl_pointer_destroy(self.handle);
        }
    }
};

pub const Keyboard = struct {
    handle: *c.wl_keyboard,

    pub fn interface() *const c.wl_interface {
        return &c.wl_keyboard_interface;
    }

    pub fn version(self: Keyboard) u32 {
        return c.wl_keyboard_get_version(self.handle);
    }

    pub fn addListener(self: Keyboard, listener: *const c.wl_keyboard_listener, data: ?*anyopaque) !void {
        if (c.wl_keyboard_add_listener(self.handle, listener, data) != 0) return error.ListenerFailed;
    }

    pub fn deinit(self: Keyboard) void {
        if (self.version() >= c.WL_KEYBOARD_RELEASE_SINCE_VERSION) {
            c.wl_keyboard_release(self.handle);
        } else {
            c.wl_keyboard_destroy(self.handle);
        }
    }
};

pub const Touch = struct {
    handle: *c.wl_touch,

    pub fn interface() *const c.wl_interface {
        return &c.wl_touch_interface;
    }

    pub fn version(self: Touch) u32 {
        return c.wl_touch_get_version(self.handle);
    }

    pub fn addListener(self: Touch, listener: *const c.wl_touch_listener, data: ?*anyopaque) !void {
        if (c.wl_touch_add_listener(self.handle, listener, data) != 0) return error.ListenerFailed;
    }

    pub fn deinit(self: Touch) void {
        if (self.version() >= c.WL_TOUCH_RELEASE_SINCE_VERSION) {
            c.wl_touch_release(self.handle);
        } else {
            c.wl_touch_destroy(self.handle);
        }
    }
};

pub const Error = error{ListenerFailed};
