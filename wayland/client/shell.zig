const c = @import("../c.zig").wl;
const display = @import("display.zig");
const compositor = @import("compositor.zig");
const seat = @import("seat.zig");
const output = @import("output.zig");

const Proxy = display.Proxy;
const Surface = compositor.Surface;
const Seat = seat.Seat;
const Output = output.Output;

pub const Shell = struct {
    handle: *c.wl_shell,

    pub fn interface() *const c.wl_interface {
        return &c.wl_shell_interface;
    }

    pub fn getShellSurface(self: Shell, surface: Surface) ShellSurface {
        return .{ .handle = c.wl_shell_get_shell_surface(self.handle, surface.handle).? };
    }

    pub fn deinit(self: Shell) void {
        c.wl_shell_destroy(self.handle);
    }
};

pub const ShellSurface = struct {
    handle: *c.wl_shell_surface,

    pub fn interface() *const c.wl_interface {
        return &c.wl_shell_surface_interface;
    }

    pub fn ping(self: ShellSurface, serial: u32) void {
        c.wl_shell_surface_ping(self.handle, serial);
    }

    pub fn ackConfigure(self: ShellSurface, serial: u32) void {
        c.wl_shell_surface_ack_configure(self.handle, serial);
    }

    pub fn setTitle(self: ShellSurface, title: [*:0]const u8) void {
        c.wl_shell_surface_set_title(self.handle, title);
    }

    pub fn setClass(self: ShellSurface, class: [*:0]const u8) void {
        c.wl_shell_surface_set_class(self.handle, class);
    }

    pub fn move(self: ShellSurface, seat_arg: Seat, serial: u32) void {
        c.wl_shell_surface_move(self.handle, seat_arg.handle, serial);
    }

    pub fn resize(self: ShellSurface, seat_arg: Seat, serial: u32, edges: u32) void {
        c.wl_shell_surface_resize(self.handle, seat_arg.handle, serial, edges);
    }

    pub fn setToplevel(self: ShellSurface) void {
        c.wl_shell_surface_set_toplevel(self.handle);
    }

    pub fn setTransient(self: ShellSurface, parent: Surface, x: i32, y: i32, flags: u32) void {
        c.wl_shell_surface_set_transient(self.handle, parent.handle, x, y, flags);
    }

    pub fn setFullscreen(self: ShellSurface, method: u32, framerate: u32, output_arg: ?Output) void {
        c.wl_shell_surface_set_fullscreen(self.handle, method, framerate, if (output_arg) |o| o.handle else null);
    }

    pub fn setPopup(self: ShellSurface, seat_arg: Seat, serial: u32, parent: Surface, x: i32, y: i32, flags: u32) void {
        c.wl_shell_surface_set_popup(self.handle, seat_arg.handle, serial, parent.handle, x, y, flags);
    }

    pub fn setMaximized(self: ShellSurface, output_arg: ?Output) void {
        c.wl_shell_surface_set_maximized(self.handle, if (output_arg) |o| o.handle else null);
    }

    pub fn addListener(self: ShellSurface, listener: *const c.wl_shell_surface_listener, data: ?*anyopaque) !void {
        if (c.wl_shell_surface_add_listener(self.handle, listener, data) != 0) return error.ListenerFailed;
    }

    pub fn deinit(self: ShellSurface) void {
        c.wl_shell_surface_destroy(self.handle);
    }
};

pub const Subcompositor = struct {
    handle: *c.wl_subcompositor,

    pub fn interface() *const c.wl_interface {
        return &c.wl_subcompositor_interface;
    }

    pub fn getSubsurface(self: Subcompositor, surface: Surface, parent: Surface) Subsurface {
        return .{ .handle = c.wl_subcompositor_get_subsurface(self.handle, surface.handle, parent.handle).? };
    }

    pub fn deinit(self: Subcompositor) void {
        c.wl_subcompositor_destroy(self.handle);
    }
};

pub const Subsurface = struct {
    handle: *c.wl_subsurface,

    pub fn interface() *const c.wl_interface {
        return &c.wl_subsurface_interface;
    }

    pub fn setPosition(self: Subsurface, x: i32, y: i32) void {
        c.wl_subsurface_set_position(self.handle, x, y);
    }

    pub fn placeAbove(self: Subsurface, sibling: Surface) void {
        c.wl_subsurface_place_above(self.handle, sibling.handle);
    }

    pub fn placeBelow(self: Subsurface, sibling: Surface) void {
        c.wl_subsurface_place_below(self.handle, sibling.handle);
    }

    pub fn setSync(self: Subsurface) void {
        c.wl_subsurface_set_sync(self.handle);
    }

    pub fn setDesync(self: Subsurface) void {
        c.wl_subsurface_set_desync(self.handle);
    }

    pub fn deinit(self: Subsurface) void {
        c.wl_subsurface_destroy(self.handle);
    }
};

pub const Error = error{ListenerFailed};
