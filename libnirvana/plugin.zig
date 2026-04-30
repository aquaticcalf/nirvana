const std = @import("std");
const workspace_mod = @import("workspace.zig");
const window_mod = @import("window.zig");

pub const PluginId = u64;

pub const Event = union(enum) {
    started,
    stopped,
    workspace_added: workspace_mod.WorkspaceId,
    window_created: window_mod.WindowId,
    window_focused: window_mod.WindowId,
    viewport_changed: workspace_mod.WorkspaceId,
};

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

    pub fn activeWorkspace(self: Api) ?*workspace_mod.Workspace {
        return self.host.activeWorkspace();
    }

    pub fn listWindows(self: Api, allocator: std.mem.Allocator) ![]WindowSnapshot {
        var snapshots: std.ArrayList(WindowSnapshot) = .empty;
        errdefer snapshots.deinit(allocator);

        for (self.host.workspaces.items) |*workspace| {
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
    workspaces: std.ArrayList(workspace_mod.Workspace) = .empty,
    plugins: std.ArrayList(RegisteredPlugin) = .empty,
    active_workspace_id: ?workspace_mod.WorkspaceId = null,
    next_plugin_id: PluginId = 1,
    next_workspace_id: workspace_mod.WorkspaceId = 1,

    pub fn init(allocator: std.mem.Allocator) Host {
        return .{ .allocator = allocator };
    }

    pub fn deinit(self: *Host) void {
        const api = Api{ .host = self };
        for (self.plugins.items) |registered| {
            if (registered.plugin.deinit) |deinit_plugin| {
                deinit_plugin(api, registered.plugin.userdata);
            }
        }
        self.plugins.deinit(self.allocator);

        for (self.workspaces.items) |*workspace| {
            workspace.deinit();
        }
        self.workspaces.deinit(self.allocator);
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

    pub fn emit(self: *Host, event: Event) !void {
        const api = Api{ .host = self };
        for (self.plugins.items) |registered| {
            if (registered.plugin.on_event) |on_event| {
                try on_event(api, event, registered.plugin.userdata);
            }
        }
    }

    pub fn createWorkspace(self: *Host, options: CreateWorkspaceOptions) !workspace_mod.WorkspaceId {
        const id = self.next_workspace_id;
        self.next_workspace_id += 1;
        try self.workspaces.append(self.allocator, workspace_mod.Workspace.init(self.allocator, .{
            .id = id,
            .name = options.name,
            .viewport = options.viewport,
            .persistent = options.persistent,
        }));
        if (self.active_workspace_id == null) self.active_workspace_id = id;
        try self.emit(.{ .workspace_added = id });
        return id;
    }

    pub fn activeWorkspace(self: *Host) ?*workspace_mod.Workspace {
        const id = self.active_workspace_id orelse return null;
        return self.getWorkspace(id);
    }

    pub fn getWorkspace(self: *Host, id: workspace_mod.WorkspaceId) ?*workspace_mod.Workspace {
        for (self.workspaces.items) |*workspace| {
            if (workspace.id == id) return workspace;
        }
        return null;
    }

    pub fn focusWindow(self: *Host, window_id: window_mod.WindowId) bool {
        var found = false;
        for (self.workspaces.items) |*workspace| {
            if (workspace.focusWindow(window_id)) {
                self.active_workspace_id = workspace.id;
                found = true;
            }
        }
        if (found) self.emit(.{ .window_focused = window_id }) catch {};
        return found;
    }
};

pub const CreateWorkspaceOptions = struct {
    name: []const u8,
    viewport: @import("geometry.zig").Rect,
    persistent: bool = false,
};

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

    var host = Host.init(std.testing.allocator);
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
    var workspace = host.getWorkspace(workspace_id).?;
    const window_id = try workspace.createWindow(.{
        .rect = @import("geometry.zig").rect(32, 32, 900, 640),
        .metadata = .{ .app_id = "term", .title = "Terminal" },
    });
    try host.emit(.{ .window_created = window_id });

    try std.testing.expectEqual(@as(usize, 1), state.seen_windows);
}
