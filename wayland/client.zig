const std = @import("std");
const c = @import("c.zig").wl;

pub const ConnectError = std.mem.Allocator.Error || error{ConnectionFailed};
pub const QueueError = std.mem.Allocator.Error || error{QueueCreationFailed};
pub const DispatchError = error{DispatchFailed};
pub const FlushError = error{FlushFailed};
pub const RoundtripError = error{RoundtripFailed};
pub const ListenerError = error{ListenerInstallFailed};

pub const Rect = struct {
    x: i32 = 0,
    y: i32 = 0,
    width: i32,
    height: i32,
};

pub const SeatCapabilities = packed struct(u32) {
    pointer: bool = false,
    keyboard: bool = false,
    touch: bool = false,
    _padding: u29 = 0,

    pub fn from(bits: u32) SeatCapabilities {
        return @bitCast(bits);
    }
};

pub const OutputMode = packed struct(u32) {
    current: bool = false,
    preferred: bool = false,
    _padding: u30 = 0,

    pub fn from(bits: u32) OutputMode {
        return @bitCast(bits);
    }
};

pub const ShmFormat = enum(u32) {
    argb8888 = c.WL_SHM_FORMAT_ARGB8888,
    xrgb8888 = c.WL_SHM_FORMAT_XRGB8888,
};

pub const BufferTransform = enum(i32) {
    normal = c.WL_OUTPUT_TRANSFORM_NORMAL,
    @"90" = c.WL_OUTPUT_TRANSFORM_90,
    @"180" = c.WL_OUTPUT_TRANSFORM_180,
    @"270" = c.WL_OUTPUT_TRANSFORM_270,
    flipped = c.WL_OUTPUT_TRANSFORM_FLIPPED,
    flipped_90 = c.WL_OUTPUT_TRANSFORM_FLIPPED_90,
    flipped_180 = c.WL_OUTPUT_TRANSFORM_FLIPPED_180,
    flipped_270 = c.WL_OUTPUT_TRANSFORM_FLIPPED_270,
};

pub const Display = struct {
    handle: *c.wl_display,

    pub fn connect(name: ?[]const u8) ConnectError!Display {
        const handle = try connectHandle(name);
        return .{ .handle = handle orelse return error.ConnectionFailed };
    }

    pub fn connectToFd(fd_arg: i32) ConnectError!Display {
        const handle = c.wl_display_connect_to_fd(fd_arg);
        return if (handle) |h| .{ .handle = h } else error.ConnectionFailed;
    }

    pub fn connectDefault() ConnectError!Display {
        return connect(null);
    }

    pub fn deinit(self: Display) void {
        c.wl_display_disconnect(self.handle);
    }

    pub fn raw(self: Display) *c.wl_display {
        return self.handle;
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

    pub fn createQueue(self: Display, name: ?[]const u8) QueueError!EventQueue {
        if (name) |slice| {
            const z = try std.heap.c_allocator.dupeZ(u8, slice);
            defer std.heap.c_allocator.free(z);

            return .{
                .handle = c.wl_display_create_queue_with_name(self.handle, z.ptr) orelse return error.QueueCreationFailed,
            };
        }

        return .{ .handle = c.wl_display_create_queue(self.handle) orelse return error.QueueCreationFailed };
    }

    pub fn dispatch(self: Display) DispatchError!u31 {
        return countOrDispatchError(c.wl_display_dispatch(self.handle));
    }

    pub fn dispatchPending(self: Display) DispatchError!u31 {
        return countOrDispatchError(c.wl_display_dispatch_pending(self.handle));
    }

    pub fn dispatchQueue(self: Display, queue: EventQueue) DispatchError!u31 {
        return countOrDispatchError(c.wl_display_dispatch_queue(self.handle, queue.handle));
    }

    pub fn dispatchQueuePending(self: Display, queue: EventQueue) DispatchError!u31 {
        return countOrDispatchError(c.wl_display_dispatch_queue_pending(self.handle, queue.handle));
    }

    pub fn dispatchTimeout(self: Display, timeout: i32) DispatchError!u31 {
        return countOrDispatchError(c.wl_display_dispatch_timeout(self.handle, timeout));
    }

    pub fn dispatchQueueTimeout(self: Display, queue: EventQueue, timeout: i32) DispatchError!u31 {
        return countOrDispatchError(c.wl_display_dispatch_queue_timeout(self.handle, queue.handle, timeout));
    }

    pub fn flush(self: Display) FlushError!u31 {
        return countOrFlushError(c.wl_display_flush(self.handle));
    }

    pub fn roundtrip(self: Display) RoundtripError!u31 {
        return countOrRoundtripError(c.wl_display_roundtrip(self.handle));
    }

    pub fn roundtripQueue(self: Display, queue: EventQueue) RoundtripError!u31 {
        return countOrRoundtripError(c.wl_display_roundtrip_queue(self.handle, queue.handle));
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

    pub fn readEvents(self: Display) DispatchError!void {
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

    pub fn raw(self: EventQueue) *c.wl_event_queue {
        return self.handle;
    }

    pub fn name(self: EventQueue) []const u8 {
        const ptr = c.wl_event_queue_get_name(self.handle) orelse return "";
        return std.mem.span(ptr);
    }
};

pub const Proxy = struct {
    handle: *c.wl_proxy,

    pub fn raw(self: Proxy) *c.wl_proxy {
        return self.handle;
    }

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

    pub fn raw(self: Registry) *c.wl_registry {
        return self.handle;
    }

    pub fn proxy(self: Registry) Proxy {
        return .{ .handle = @ptrCast(self.handle) };
    }

    pub fn deinit(self: Registry) void {
        c.wl_registry_destroy(self.handle);
    }

    pub fn addListener(self: Registry, listener: *const c.wl_registry_listener, data: ?*anyopaque) ListenerError!void {
        if (c.wl_registry_add_listener(self.handle, listener, data) != 0) {
            return error.ListenerInstallFailed;
        }
    }

    pub fn bindRaw(self: Registry, comptime T: type, name: u32, wl_interface: *const c.wl_interface, version: u32) ?T {
        const handle = c.wl_registry_bind(self.handle, name, wl_interface, version) orelse return null;
        return @ptrCast(@alignCast(handle));
    }

    pub fn bindCompositor(self: Registry, name: u32, version: u32) ?Compositor {
        const handle = self.bindRaw(*c.wl_compositor, name, Compositor.interface(), version) orelse return null;
        return .{ .handle = handle };
    }

    pub fn bindShm(self: Registry, name: u32, version: u32) ?Shm {
        const handle = self.bindRaw(*c.wl_shm, name, Shm.interface(), version) orelse return null;
        return .{ .handle = handle };
    }

    pub fn bindSeat(self: Registry, name: u32, version: u32) ?Seat {
        const handle = self.bindRaw(*c.wl_seat, name, Seat.interface(), version) orelse return null;
        return .{ .handle = handle };
    }

    pub fn bindOutput(self: Registry, name: u32, version: u32) ?Output {
        const handle = self.bindRaw(*c.wl_output, name, Output.interface(), version) orelse return null;
        return .{ .handle = handle };
    }
};

pub const Callback = struct {
    handle: *c.wl_callback,

    pub fn interface() *const c.wl_interface {
        return &c.wl_callback_interface;
    }

    pub fn raw(self: Callback) *c.wl_callback {
        return self.handle;
    }

    pub fn proxy(self: Callback) Proxy {
        return .{ .handle = @ptrCast(self.handle) };
    }

    pub fn addListener(self: Callback, listener: *const c.wl_callback_listener, data: ?*anyopaque) ListenerError!void {
        if (c.wl_callback_add_listener(self.handle, listener, data) != 0) {
            return error.ListenerInstallFailed;
        }
    }

    pub fn deinit(self: Callback) void {
        c.wl_callback_destroy(self.handle);
    }
};

pub const Compositor = struct {
    handle: *c.wl_compositor,

    pub fn interface() *const c.wl_interface {
        return &c.wl_compositor_interface;
    }

    pub fn raw(self: Compositor) *c.wl_compositor {
        return self.handle;
    }

    pub fn proxy(self: Compositor) Proxy {
        return .{ .handle = @ptrCast(self.handle) };
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

    pub fn raw(self: Region) *c.wl_region {
        return self.handle;
    }

    pub fn proxy(self: Region) Proxy {
        return .{ .handle = @ptrCast(self.handle) };
    }

    pub fn add(self: Region, rect: Rect) void {
        c.wl_region_add(self.handle, rect.x, rect.y, rect.width, rect.height);
    }

    pub fn subtract(self: Region, rect: Rect) void {
        c.wl_region_subtract(self.handle, rect.x, rect.y, rect.width, rect.height);
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

    pub fn raw(self: Surface) *c.wl_surface {
        return self.handle;
    }

    pub fn proxy(self: Surface) Proxy {
        return .{ .handle = @ptrCast(self.handle) };
    }

    pub fn attach(self: Surface, buffer: ?Buffer, x: i32, y: i32) void {
        c.wl_surface_attach(self.handle, if (buffer) |it| it.handle else null, x, y);
    }

    pub fn damage(self: Surface, rect: Rect) void {
        c.wl_surface_damage(self.handle, rect.x, rect.y, rect.width, rect.height);
    }

    pub fn damageBuffer(self: Surface, rect: Rect) void {
        c.wl_surface_damage_buffer(self.handle, rect.x, rect.y, rect.width, rect.height);
    }

    pub fn frame(self: Surface) Callback {
        return .{ .handle = c.wl_surface_frame(self.handle).? };
    }

    pub fn setOpaqueRegion(self: Surface, region: ?Region) void {
        c.wl_surface_set_opaque_region(self.handle, if (region) |it| it.handle else null);
    }

    pub fn setInputRegion(self: Surface, region: ?Region) void {
        c.wl_surface_set_input_region(self.handle, if (region) |it| it.handle else null);
    }

    pub fn setBufferScale(self: Surface, scale: i32) void {
        c.wl_surface_set_buffer_scale(self.handle, scale);
    }

    pub fn setBufferTransform(self: Surface, transform: BufferTransform) void {
        c.wl_surface_set_buffer_transform(self.handle, @intFromEnum(transform));
    }

    pub fn offset(self: Surface, x: i32, y: i32) void {
        c.wl_surface_offset(self.handle, x, y);
    }

    pub fn commit(self: Surface) void {
        c.wl_surface_commit(self.handle);
    }

    pub fn deinit(self: Surface) void {
        c.wl_surface_destroy(self.handle);
    }
};

pub const Shm = struct {
    handle: *c.wl_shm,

    pub fn interface() *const c.wl_interface {
        return &c.wl_shm_interface;
    }

    pub fn raw(self: Shm) *c.wl_shm {
        return self.handle;
    }

    pub fn proxy(self: Shm) Proxy {
        return .{ .handle = @ptrCast(self.handle) };
    }

    pub fn version(self: Shm) u32 {
        return c.wl_shm_get_version(self.handle);
    }

    pub fn addListener(self: Shm, listener: *const c.wl_shm_listener, data: ?*anyopaque) ListenerError!void {
        if (c.wl_shm_add_listener(self.handle, listener, data) != 0) {
            return error.ListenerInstallFailed;
        }
    }

    pub fn createPool(self: Shm, fd: i32, size: i32) ShmPool {
        return .{ .handle = c.wl_shm_create_pool(self.handle, fd, size).? };
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

    pub fn raw(self: ShmPool) *c.wl_shm_pool {
        return self.handle;
    }

    pub fn proxy(self: ShmPool) Proxy {
        return .{ .handle = @ptrCast(self.handle) };
    }

    pub fn createBuffer(
        self: ShmPool,
        offset: i32,
        width: i32,
        height: i32,
        stride: i32,
        format: ShmFormat,
    ) Buffer {
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

pub const Buffer = struct {
    handle: *c.wl_buffer,

    pub fn interface() *const c.wl_interface {
        return &c.wl_buffer_interface;
    }

    pub fn raw(self: Buffer) *c.wl_buffer {
        return self.handle;
    }

    pub fn proxy(self: Buffer) Proxy {
        return .{ .handle = @ptrCast(self.handle) };
    }

    pub fn addListener(self: Buffer, listener: *const c.wl_buffer_listener, data: ?*anyopaque) ListenerError!void {
        if (c.wl_buffer_add_listener(self.handle, listener, data) != 0) {
            return error.ListenerInstallFailed;
        }
    }

    pub fn deinit(self: Buffer) void {
        c.wl_buffer_destroy(self.handle);
    }
};

pub const Seat = struct {
    handle: *c.wl_seat,

    pub fn interface() *const c.wl_interface {
        return &c.wl_seat_interface;
    }

    pub fn raw(self: Seat) *c.wl_seat {
        return self.handle;
    }

    pub fn proxy(self: Seat) Proxy {
        return .{ .handle = @ptrCast(self.handle) };
    }

    pub fn version(self: Seat) u32 {
        return c.wl_seat_get_version(self.handle);
    }

    pub fn addListener(self: Seat, listener: *const c.wl_seat_listener, data: ?*anyopaque) ListenerError!void {
        if (c.wl_seat_add_listener(self.handle, listener, data) != 0) {
            return error.ListenerInstallFailed;
        }
    }

    pub fn pointer(self: Seat) Pointer {
        return .{ .handle = c.wl_seat_get_pointer(self.handle).? };
    }

    pub fn keyboard(self: Seat) Keyboard {
        return .{ .handle = c.wl_seat_get_keyboard(self.handle).? };
    }

    pub fn touch(self: Seat) Touch {
        return .{ .handle = c.wl_seat_get_touch(self.handle).? };
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

    pub fn raw(self: Pointer) *c.wl_pointer {
        return self.handle;
    }

    pub fn proxy(self: Pointer) Proxy {
        return .{ .handle = @ptrCast(self.handle) };
    }

    pub fn deinit(self: Pointer) void {
        if (c.wl_pointer_get_version(self.handle) >= c.WL_POINTER_RELEASE_SINCE_VERSION) {
            c.wl_pointer_release(self.handle);
        } else {
            c.wl_pointer_destroy(self.handle);
        }
    }
};

pub const Keyboard = struct {
    handle: *c.wl_keyboard,

    pub fn raw(self: Keyboard) *c.wl_keyboard {
        return self.handle;
    }

    pub fn proxy(self: Keyboard) Proxy {
        return .{ .handle = @ptrCast(self.handle) };
    }

    pub fn deinit(self: Keyboard) void {
        if (c.wl_keyboard_get_version(self.handle) >= c.WL_KEYBOARD_RELEASE_SINCE_VERSION) {
            c.wl_keyboard_release(self.handle);
        } else {
            c.wl_keyboard_destroy(self.handle);
        }
    }
};

pub const Touch = struct {
    handle: *c.wl_touch,

    pub fn raw(self: Touch) *c.wl_touch {
        return self.handle;
    }

    pub fn proxy(self: Touch) Proxy {
        return .{ .handle = @ptrCast(self.handle) };
    }

    pub fn deinit(self: Touch) void {
        if (c.wl_touch_get_version(self.handle) >= c.WL_TOUCH_RELEASE_SINCE_VERSION) {
            c.wl_touch_release(self.handle);
        } else {
            c.wl_touch_destroy(self.handle);
        }
    }
};

pub const Output = struct {
    handle: *c.wl_output,

    pub fn interface() *const c.wl_interface {
        return &c.wl_output_interface;
    }

    pub fn raw(self: Output) *c.wl_output {
        return self.handle;
    }

    pub fn proxy(self: Output) Proxy {
        return .{ .handle = @ptrCast(self.handle) };
    }

    pub fn version(self: Output) u32 {
        return c.wl_output_get_version(self.handle);
    }

    pub fn addListener(self: Output, listener: *const c.wl_output_listener, data: ?*anyopaque) ListenerError!void {
        if (c.wl_output_add_listener(self.handle, listener, data) != 0) {
            return error.ListenerInstallFailed;
        }
    }

    pub fn deinit(self: Output) void {
        if (self.version() >= c.WL_OUTPUT_RELEASE_SINCE_VERSION) {
            c.wl_output_release(self.handle);
        } else {
            c.wl_output_destroy(self.handle);
        }
    }
};

pub const DataDevice = struct {
    handle: *c.wl_device,

    pub fn interface() *const c.wl_interface {
        return &c.wl_device_interface;
    }

    pub fn raw(self: DataDevice) *c.wl_device {
        return self.handle;
    }

    pub fn proxy(self: DataDevice) Proxy {
        return .{ .handle = @ptrCast(self.handle) };
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

    pub fn addListener(self: DataDevice, listener: *const c.wl_device_listener, data: ?*anyopaque) ListenerError!void {
        if (c.wl_device_add_listener(self.handle, listener, data) != 0) {
            return error.ListenerInstallFailed;
        }
    }

    pub fn deinit(self: DataDevice) void {
        c.wl_device_destroy(self.handle);
    }
};

pub const DataDeviceManager = struct {
    handle: *c.wl_device_manager,

    pub fn interface() *const c.wl_interface {
        return &c.wl_device_manager_interface;
    }

    pub fn raw(self: DataDeviceManager) *c.wl_device_manager {
        return self.handle;
    }

    pub fn proxy(self: DataDeviceManager) Proxy {
        return .{ .handle = @ptrCast(self.handle) };
    }

    pub fn createDataSource(self: DataDeviceManager) DataSource {
        return .{ .handle = c.wl_device_manager_create_data_source(self.handle).? };
    }

    pub fn getDataDevice(self: DataDeviceManager, seat: Seat) DataDevice {
        return .{ .handle = c.wl_device_manager_get_device(self.handle, seat.handle).? };
    }

    pub fn deinit(self: DataDeviceManager) void {
        c.wl_device_manager_destroy(self.handle);
    }
};

pub const DataOffer = struct {
    handle: *c.wl_data_offer,

    pub fn interface() *const c.wl_interface {
        return &c.wl_data_offer_interface;
    }

    pub fn raw(self: DataOffer) *c.wl_data_offer {
        return self.handle;
    }

    pub fn proxy(self: DataOffer) Proxy {
        return .{ .handle = @ptrCast(self.handle) };
    }

    pub fn accept(self: DataOffer, serial: u32, mime_type: ?[*:0]const u8) void {
        c.wl_data_offer_accept(self.handle, serial, mime_type);
    }

    pub fn receive(self: DataOffer, mime_type: [*:0]const u8, fd: i32) void {
        c.wl_data_offer_receive(self.handle, mime_type, fd);
    }

    pub fn destroy(self: DataOffer) void {
        c.wl_data_offer_destroy(self.handle);
    }

    pub fn finish(self: DataOffer) void {
        c.wl_data_offer_finish(self.handle);
    }

    pub fn setActions(self: DataOffer, actions: u32, preferred: u32) void {
        c.wl_data_offer_set_actions(self.handle, actions, preferred);
    }

    pub fn addListener(self: DataOffer, listener: *const c.wl_data_offer_listener, data: ?*anyopaque) ListenerError!void {
        if (c.wl_data_offer_add_listener(self.handle, listener, data) != 0) {
            return error.ListenerInstallFailed;
        }
    }
};

pub const DataSource = struct {
    handle: *c.wl_data_source,

    pub fn interface() *const c.wl_interface {
        return &c.wl_data_source_interface;
    }

    pub fn raw(self: DataSource) *c.wl_data_source {
        return self.handle;
    }

    pub fn proxy(self: DataSource) Proxy {
        return .{ .handle = @ptrCast(self.handle) };
    }

    pub fn offer(self: DataSource, mime_type: [*:0]const u8) void {
        c.wl_data_source_offer(self.handle, mime_type);
    }

    pub fn destroy(self: DataSource) void {
        c.wl_data_source_destroy(self.handle);
    }

    pub fn setActions(self: DataSource, actions: u32) void {
        c.wl_data_source_set_actions(self.handle, actions);
    }

    pub fn addListener(self: DataSource, listener: *const c.wl_data_source_listener, data: ?*anyopaque) ListenerError!void {
        if (c.wl_data_source_add_listener(self.handle, listener, data) != 0) {
            return error.ListenerInstallFailed;
        }
    }
};

pub const Shell = struct {
    handle: *c.wl_shell,

    pub fn interface() *const c.wl_interface {
        return &c.wl_shell_interface;
    }

    pub fn raw(self: Shell) *c.wl_shell {
        return self.handle;
    }

    pub fn proxy(self: Shell) Proxy {
        return .{ .handle = @ptrCast(self.handle) };
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

    pub fn raw(self: ShellSurface) *c.wl_shell_surface {
        return self.handle;
    }

    pub fn proxy(self: ShellSurface) Proxy {
        return .{ .handle = @ptrCast(self.handle) };
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

    pub fn move(self: ShellSurface, seat: Seat, serial: u32) void {
        c.wl_shell_surface_move(self.handle, seat.handle, serial);
    }

    pub fn resize(self: ShellSurface, seat: Seat, serial: u32, edges: u32) void {
        c.wl_shell_surface_resize(self.handle, seat.handle, serial, edges);
    }

    pub fn setToplevel(self: ShellSurface) void {
        c.wl_shell_surface_set_toplevel(self.handle);
    }

    pub fn setTransient(self: ShellSurface, parent: Surface, x: i32, y: i32, flags: u32) void {
        c.wl_shell_surface_set_transient(self.handle, parent.handle, x, y, flags);
    }

    pub fn setFullscreen(self: ShellSurface, method: u32, framerate: u32, output: ?Output) void {
        c.wl_shell_surface_set_fullscreen(self.handle, method, framerate, if (output) |o| o.handle else null);
    }

    pub fn setPopup(self: ShellSurface, seat: Seat, serial: u32, parent: Surface, x: i32, y: i32, flags: u32) void {
        c.wl_shell_surface_set_popup(self.handle, seat.handle, serial, parent.handle, x, y, flags);
    }

    pub fn setMaximized(self: ShellSurface, output: ?Output) void {
        c.wl_shell_surface_set_maximized(self.handle, if (output) |o| o.handle else null);
    }

    pub fn deinit(self: ShellSurface) void {
        c.wl_shell_surface_destroy(self.handle);
    }

    pub fn addListener(self: ShellSurface, listener: *const c.wl_shell_surface_listener, data: ?*anyopaque) ListenerError!void {
        if (c.wl_shell_surface_add_listener(self.handle, listener, data) != 0) {
            return error.ListenerInstallFailed;
        }
    }
};

pub const Subcompositor = struct {
    handle: *c.wl_subcompositor,

    pub fn interface() *const c.wl_interface {
        return &c.wl_subcompositor_interface;
    }

    pub fn raw(self: Subcompositor) *c.wl_subcompositor {
        return self.handle;
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

    pub fn raw(self: Subsurface) *c.wl_subsurface {
        return self.handle;
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

    pub fn destroy(self: Subsurface) void {
        c.wl_subsurface_destroy(self.handle);
    }
};

fn countOrDispatchError(rc: c_int) DispatchError!u31 {
    if (rc < 0) return error.DispatchFailed;
    return @intCast(rc);
}

fn countOrFlushError(rc: c_int) FlushError!u31 {
    if (rc < 0) return error.FlushFailed;
    return @intCast(rc);
}

fn countOrRoundtripError(rc: c_int) RoundtripError!u31 {
    if (rc < 0) return error.RoundtripFailed;
    return @intCast(rc);
}

fn connectHandle(name: ?[]const u8) ConnectError!?*c.wl_display {
    if (name) |slice| {
        const z = try std.heap.c_allocator.dupeZ(u8, slice);
        defer std.heap.c_allocator.free(z);
        return c.wl_display_connect(z.ptr);
    }

    return c.wl_display_connect(null);
}
