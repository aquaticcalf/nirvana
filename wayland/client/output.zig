const c = @import("../c.zig").wl;
const display = @import("display.zig");
const types = @import("../types.zig");

const Proxy = display.Proxy;

pub const Output = struct {
    handle: *c.wl_output,

    pub fn interface() *const c.wl_interface {
        return &c.wl_output_interface;
    }

    pub fn version(self: Output) u32 {
        return c.wl_output_get_version(self.handle);
    }

    pub fn addListener(self: Output, listener: *const c.wl_output_listener, data: ?*anyopaque) !void {
        if (c.wl_output_add_listener(self.handle, listener, data) != 0) return error.ListenerFailed;
    }

    pub fn deinit(self: Output) void {
        if (self.version() >= c.WL_OUTPUT_RELEASE_SINCE_VERSION) {
            c.wl_output_release(self.handle);
        } else {
            c.wl_output_destroy(self.handle);
        }
    }
};

pub const Error = error{ListenerFailed};
