const c = @import("../c.zig").wl;
const server_display = @import("display.zig");

pub const Client = struct {
    handle: *c.wl_client,

    pub fn create(disp: server_display.Display, fd: i32) Client {
        return .{ .handle = c.wl_client_create(disp.handle, fd).? };
    }

    pub fn destroy(self: Client) void {
        c.wl_client_destroy(self.handle);
    }

    pub fn flush(self: Client) void {
        c.wl_client_flush(self.handle);
    }

    pub fn getFd(self: Client) i32 {
        return c.wl_client_get_fd(self.handle);
    }

    pub fn getCredentials(self: Client) struct { pid: i32, uid: i32, gid: i32 } {
        var pid: i32 = 0;
        var uid: i32 = 0;
        var gid: i32 = 0;
        c.wl_client_get_credentials(self.handle, &pid, &uid, &gid);
        return .{ .pid = pid, .uid = uid, .gid = gid };
    }

    pub fn getObject(self: Client, id: u32) ?Resource {
        const res = c.wl_client_get_object(self.handle, id) orelse return null;
        return .{ .handle = res };
    }

    pub fn postNoMemory(self: Client) void {
        c.wl_client_post_no_memory(self.handle);
    }

    pub fn postImplementationError(self: Client, msg: [*:0]const u8) void {
        c.wl_client_post_implementation_error(self.handle, msg);
    }

    pub fn userData(self: Client) ?*anyopaque {
        return c.wl_client_get_user_data(self.handle);
    }

    pub fn setUserData(self: Client, data: ?*anyopaque) void {
        c.wl_client_set_user_data(self.handle, data);
    }

    pub fn setMaxBufferSize(self: Client, size: usize) void {
        c.wl_client_set_max_buffer_size(self.handle, size);
    }

    pub fn display(self: Client) server_display.Display {
        return .{ .handle = c.wl_client_get_display(self.handle).? };
    }
};

pub const Resource = struct {
    handle: *c.wl_resource,

    pub fn interface(self: Resource) *const c.wl_interface {
        return c.wl_resource_get_interface(self.handle);
    }

    pub fn id(self: Resource) u32 {
        return c.wl_resource_get_id(self.handle);
    }

    pub fn version(self: Resource) u32 {
        return c.wl_resource_get_version(self.handle);
    }

    pub fn client(self: Resource) Client {
        return .{ .handle = c.wl_resource_get_client(self.handle).? };
    }

    pub fn userData(self: Resource) ?*anyopaque {
        return c.wl_resource_get_user_data(self.handle);
    }

    pub fn setUserData(self: Resource, data: ?*anyopaque) void {
        c.wl_resource_set_user_data(self.handle, data);
    }

    pub fn postError(self: Resource, code: u32, msg: [*:0]const u8) void {
        c.wl_resource_post_error(self.handle, code, msg);
    }

    pub fn postNoMemory(self: Resource) void {
        c.wl_resource_post_no_memory(self.handle);
    }

    pub fn destroy(self: Resource) void {
        c.wl_resource_destroy(self.handle);
    }

    pub fn remove(self: Resource) void {
        c.wl_resource_remove(self.handle);
    }

    pub fn addDestroyListener(self: Resource, listener: *c.wl_listener, data: ?*anyopaque) void {
        c.wl_resource_add_destroy_listener(self.handle, listener, data);
    }

    pub fn setDestructor(self: Resource, destructor: c.wl_resource_destructor_func_t) void {
        c.wl_resource_set_destructor(self.handle, destructor);
    }

    pub fn setImplementation(self: Resource, implementation: ?*const anyopaque, target: ?*anyopaque) void {
        c.wl_resource_set_implementation(self.handle, implementation, target, null);
    }

    pub fn className(self: Resource) [*:0]const u8 {
        return c.wl_resource_get_class(self.handle);
    }

    pub fn instanceOf(self: Resource, iface: *const c.wl_interface, implementation: ?*const anyopaque) bool {
        return c.wl_resource_instance_of(self.handle, iface, implementation);
    }

    pub fn getDestroyListener(self: Resource, notify: c.wl_notify_func_t) ?c.wl_listener {
        return c.wl_resource_get_destroy_listener(self.handle, notify);
    }
};

pub fn createResource(
    client: Client,
    id: u32,
    iface: *const c.wl_interface,
    version: u32,
    data: ?*anyopaque,
) !Resource {
    const handle = c.wl_resource_create(client.handle, iface, version, id, data) orelse return error.ResourceFailed;
    return .{ .handle = handle };
}

pub fn addResource(
    client: Client,
    id: u32,
    iface: *const c.wl_interface,
    version: u32,
    data: ?*anyopaque,
) !Resource {
    const handle = c.wl_client_add_resource(client.handle, id, iface, version, data) orelse return error.ResourceFailed;
    return .{ .handle = handle };
}

pub const Error = error{ResourceFailed};
