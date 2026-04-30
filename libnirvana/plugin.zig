const std = @import("std");
const compositor_mod = @import("compositor.zig");
const output_mod = @import("output.zig");
const workspace_mod = @import("workspace.zig");
const window_mod = @import("window.zig");

pub const PluginId = u64;
pub const Event = compositor_mod.Event;

pub const WindowSnapshot = struct {
    id: window_mod.WindowId,
    workspace_id: workspace_mod.WorkspaceId,
    role: window_mod.WindowRole,
    mode: window_mod.LayoutMode,
    focused: bool,
    visible: bool,
    app_id: []const u8,
    title: []const u8,
};

pub const Api = struct {
    host: *Host,

    pub fn compositor(self: Api) *compositor_mod.Compositor {
        return self.host.compositor;
    }

    pub fn activeWorkspace(self: Api) ?*workspace_mod.Workspace {
        return self.host.compositor.activeWorkspace();
    }

    pub fn listWindows(self: Api, allocator: std.mem.Allocator) ![]WindowSnapshot {
        var snapshots: std.ArrayList(WindowSnapshot) = .empty;
        errdefer snapshots.deinit(allocator);

        for (self.host.compositor.workspaces.items) |*workspace| {
            for (workspace.windows.items) |window| {
                try snapshots.append(allocator, .{
                    .id = window.id,
                    .workspace_id = window.workspace_id,
                    .role = window.role,
                    .mode = window.mode,
                    .focused = window.focused,
                    .visible = window.visible,
                    .app_id = window.metadata.app_id,
                    .title = window.metadata.title,
                });
            }
        }

        return snapshots.toOwnedSlice(allocator);
    }

    pub fn focusWindow(self: Api, window_id: window_mod.WindowId) bool {
        return self.host.focusWindow(window_id);
    }
};

pub const Plugin = struct {
    name: []const u8,
    userdata: ?*anyopaque = null,
    init: ?*const fn (api: Api, userdata: ?*anyopaque) anyerror!void = null,
    deinit: ?*const fn (api: Api, userdata: ?*anyopaque) void = null,
    on_event: ?*const fn (api: Api, event: Event, userdata: ?*anyopaque) anyerror!void = null,
};

const RegisteredPlugin = struct {
    id: PluginId,
    plugin: Plugin,
};

pub const Host = struct {
    allocator: std.mem.Allocator,
    compositor: *compositor_mod.Compositor,
    plugins: std.ArrayList(RegisteredPlugin) = .empty,
    next_plugin_id: PluginId = 1,
    next_event_index: usize = 0,

    pub fn init(allocator: std.mem.Allocator, compositor: *compositor_mod.Compositor) Host {
        return .{ .allocator = allocator, .compositor = compositor };
    }

    pub fn deinit(self: *Host) void {
        const api = Api{ .host = self };
        for (self.plugins.items) |registered| {
            if (registered.plugin.deinit) |deinit_plugin| {
                deinit_plugin(api, registered.plugin.userdata);
            }
        }
        self.plugins.deinit(self.allocator);
    }

    pub fn register(self: *Host, plugin: Plugin) !PluginId {
        const id = self.next_plugin_id;
        self.next_plugin_id += 1;
        try self.plugins.append(self.allocator, .{ .id = id, .plugin = plugin });

        if (plugin.init) |init_plugin| {
            try init_plugin(.{ .host = self }, plugin.userdata);
        }

        return id;
    }

    fn emit(self: *Host, event: Event) !void {
        const api = Api{ .host = self };
        for (self.plugins.items) |registered| {
            if (registered.plugin.on_event) |on_event| {
                try on_event(api, event, registered.plugin.userdata);
            }
        }
    }

    pub fn dispatchPending(self: *Host) !void {
        while (self.next_event_index < self.compositor.events.items.len) {
            const event = self.compositor.events.items[self.next_event_index];
            self.next_event_index += 1;
            try self.emit(event);
        }
    }

    pub fn createWorkspace(self: *Host, options: CreateWorkspaceOptions) !workspace_mod.WorkspaceId {
        const id = try self.compositor.createWorkspace(options);
        try self.dispatchPending();
        return id;
    }

    pub fn addOutput(self: *Host, options: output_mod.OutputOptions) !output_mod.OutputId {
        const id = try self.compositor.addOutput(options);
        try self.dispatchPending();
        return id;
    }

    pub fn createWindow(
        self: *Host,
        workspace_id: workspace_mod.WorkspaceId,
        options: workspace_mod.WindowOptions,
    ) !window_mod.WindowId {
        const id = try self.compositor.createWindow(workspace_id, options);
        try self.dispatchPending();
        return id;
    }

    pub fn activateWorkspace(self: *Host, id: workspace_mod.WorkspaceId) !bool {
        if (!try self.compositor.activateWorkspace(id)) return false;
        try self.dispatchPending();
        return true;
    }

    pub fn activeWorkspace(self: *Host) ?*workspace_mod.Workspace {
        return self.compositor.activeWorkspace();
    }

    pub fn getWorkspace(self: *Host, id: workspace_mod.WorkspaceId) ?*workspace_mod.Workspace {
        return self.compositor.getWorkspace(id);
    }

    pub fn focusWindow(self: *Host, window_id: window_mod.WindowId) bool {
        const found = self.compositor.focusWindow(window_id) catch return false;
        if (found) self.dispatchPending() catch return false;
        return found;
    }
};

pub const CreateWorkspaceOptions = compositor_mod.CreateWorkspaceOptions;

test "plugin can observe windows for a taskbar" {
    const TaskbarState = struct {
        seen_windows: usize = 0,

        fn onEvent(api: Api, event: Event, userdata: ?*anyopaque) !void {
            if (event != .window_created) return;
            const state: *@This() = @ptrCast(@alignCast(userdata.?));
            const snapshots = try api.listWindows(std.testing.allocator);
            defer std.testing.allocator.free(snapshots);
            state.seen_windows = snapshots.len;
        }
    };

    var compositor_state = compositor_mod.Compositor.init(std.testing.allocator);
    defer compositor_state.deinit();

    var host = Host.init(std.testing.allocator, &compositor_state);
    defer host.deinit();

    var state = TaskbarState{};
    _ = try host.register(.{
        .name = "taskbar",
        .userdata = &state,
        .on_event = TaskbarState.onEvent,
    });

    const workspace_id = try host.createWorkspace(.{
        .name = "desk",
        .viewport = @import("geometry.zig").rect(0, 0, 1920, 1080),
    });
    _ = try host.createWindow(workspace_id, .{
        .rect = @import("geometry.zig").rect(32, 32, 900, 640),
        .metadata = .{ .app_id = "term", .title = "Terminal" },
    });

    try std.testing.expectEqual(@as(usize, 1), state.seen_windows);
}

test "plugin can observe compositor events created outside host helpers" {
    const State = struct {
        windows: usize = 0,

        fn onEvent(api: Api, event: Event, userdata: ?*anyopaque) !void {
            _ = api;
            if (event != .window_created) return;
            const state: *@This() = @ptrCast(@alignCast(userdata.?));
            state.windows += 1;
        }
    };

    var compositor_state = compositor_mod.Compositor.init(std.testing.allocator);
    defer compositor_state.deinit();

    var host = Host.init(std.testing.allocator, &compositor_state);
    defer host.deinit();

    var state = State{};
    _ = try host.register(.{
        .name = "observer",
        .userdata = &state,
        .on_event = State.onEvent,
    });

    const workspace_id = try compositor_state.createWorkspace(.{
        .name = "desk",
        .viewport = @import("geometry.zig").rect(0, 0, 1920, 1080),
    });
    _ = try compositor_state.createWindow(workspace_id, .{
        .rect = @import("geometry.zig").rect(64, 64, 800, 600),
    });

    try host.dispatchPending();
    try std.testing.expectEqual(@as(usize, 1), state.windows);
}
