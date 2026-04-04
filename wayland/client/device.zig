const c = @import("../c.zig").wl;
const display = @import("display.zig");
const seat = @import("seat.zig");
const compositor = @import("compositor.zig");

const Proxy = display.Proxy;
const Seat = seat.Seat;
const Surface = compositor.Surface;

pub const DataDeviceManager = struct {
    handle: *c.wl_device_manager,

    pub fn interface() *const c.wl_interface {
        return &c.wl_device_manager_interface;
    }

    pub fn version(self: DataDeviceManager) u32 {
        return c.wl_device_manager_get_version(self.handle);
    }

    pub fn createDataSource(self: DataDeviceManager) DataSource {
        return .{ .handle = c.wl_device_manager_create_data_source(self.handle).? };
    }

    pub fn getDataDevice(self: DataDeviceManager, seat_handle: Seat) DataDevice {
        return .{ .handle = c.wl_device_manager_get_device(self.handle, seat_handle.handle).? };
    }

    pub fn deinit(self: DataDeviceManager) void {
        c.wl_device_manager_destroy(self.handle);
    }
};

pub const DataDevice = struct {
    handle: *c.wl_device,

    pub fn interface() *const c.wl_interface {
        return &c.wl_device_interface;
    }

    pub fn startDrag(self: DataDevice, source: ?DataSource, origin: Surface, icon: ?Surface, serial: u32) void {
        c.wl_device_start_drag(self.handle, if (source) |s| s.handle else null, origin.handle, if (icon) |i| i.handle else null, serial);
    }

    pub fn requestSelection(self: DataDevice, source: ?DataSource, serial: u32) void {
        c.wl_device_request_selection(self.handle, if (source) |s| s.handle else null, serial);
    }

    pub fn setSelection(self: DataDevice, source: ?DataSource, serial: u32) void {
        c.wl_device_set_selection(self.handle, if (source) |s| s.handle else null, serial);
    }

    pub fn addListener(self: DataDevice, listener: *const c.wl_device_listener, data: ?*anyopaque) !void {
        if (c.wl_device_add_listener(self.handle, listener, data) != 0) return error.ListenerFailed;
    }

    pub fn deinit(self: DataDevice) void {
        c.wl_device_destroy(self.handle);
    }
};

pub const DataOffer = struct {
    handle: *c.wl_data_offer,

    pub fn interface() *const c.wl_interface {
        return &c.wl_data_offer_interface;
    }

    pub fn accept(self: DataOffer, serial: u32, mime_type: ?[*:0]const u8) void {
        c.wl_data_offer_accept(self.handle, serial, mime_type);
    }

    pub fn receive(self: DataOffer, mime_type: [*:0]const u8, fd: i32) void {
        c.wl_data_offer_receive(self.handle, mime_type, fd);
    }

    pub fn finish(self: DataOffer) void {
        c.wl_data_offer_finish(self.handle);
    }

    pub fn setActions(self: DataOffer, actions: u32, preferred: u32) void {
        c.wl_data_offer_set_actions(self.handle, actions, preferred);
    }

    pub fn addListener(self: DataOffer, listener: *const c.wl_data_offer_listener, data: ?*anyopaque) !void {
        if (c.wl_data_offer_add_listener(self.handle, listener, data) != 0) return error.ListenerFailed;
    }

    pub fn deinit(self: DataOffer) void {
        c.wl_data_offer_destroy(self.handle);
    }
};

pub const DataSource = struct {
    handle: *c.wl_data_source,

    pub fn interface() *const c.wl_interface {
        return &c.wl_data_source_interface;
    }

    pub fn offer(self: DataSource, mime_type: [*:0]const u8) void {
        c.wl_data_source_offer(self.handle, mime_type);
    }

    pub fn setActions(self: DataSource, actions: u32) void {
        c.wl_data_source_set_actions(self.handle, actions);
    }

    pub fn addListener(self: DataSource, listener: *const c.wl_data_source_listener, data: ?*anyopaque) !void {
        if (c.wl_data_source_add_listener(self.handle, listener, data) != 0) return error.ListenerFailed;
    }

    pub fn deinit(self: DataSource) void {
        c.wl_data_source_destroy(self.handle);
    }
};

pub const Error = error{ListenerFailed};
