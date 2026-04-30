const std = @import("std");
const geometry = @import("geometry.zig");
const output_mod = @import("output.zig");
const workspace_mod = @import("workspace.zig");
const window_mod = @import("window.zig");

pub const CreateWorkspaceOptions = struct {
    name: []const u8,
    viewport: geometry.Rect,
    persistent: bool = false,
};

pub const Event = union(enum) {
    started,
    stopped,
    output_added: output_mod.OutputId,
    workspace_added: workspace_mod.WorkspaceId,
    workspace_activated: workspace_mod.WorkspaceId,
    window_created: window_mod.WindowId,
    window_focused: window_mod.WindowId,
    viewport_changed: workspace_mod.WorkspaceId,
};

pub const Compositor = struct {
    allocator: std.mem.Allocator,
    outputs: std.ArrayList(output_mod.Output) = .empty,
    workspaces: std.ArrayList(workspace_mod.Workspace) = .empty,
    events: std.ArrayList(Event) = .empty,
    active_workspace_id: ?workspace_mod.WorkspaceId = null,
    next_output_id: output_mod.OutputId = 1,
    next_workspace_id: workspace_mod.WorkspaceId = 1,

    pub fn init(allocator: std.mem.Allocator) Compositor {
        return .{ .allocator = allocator };
    }

    pub fn deinit(self: *Compositor) void {
        for (self.workspaces.items) |*workspace| {
            workspace.deinit();
        }
        self.workspaces.deinit(self.allocator);
        self.outputs.deinit(self.allocator);
        self.events.deinit(self.allocator);
    }

    pub fn addOutput(self: *Compositor, options: output_mod.OutputOptions) !output_mod.OutputId {
        const id = self.next_output_id;
        self.next_output_id += 1;
        try self.outputs.append(self.allocator, .{
            .id = id,
            .name = options.name,
            .make = options.make,
            .model = options.model,
            .rect = options.rect,
            .scale = options.scale,
            .active_workspace_id = self.active_workspace_id,
        });
        try self.recordEvent(.{ .output_added = id });
        return id;
    }

    pub fn createWorkspace(self: *Compositor, options: CreateWorkspaceOptions) !workspace_mod.WorkspaceId {
        const id = self.next_workspace_id;
        self.next_workspace_id += 1;
        try self.workspaces.append(self.allocator, workspace_mod.Workspace.init(self.allocator, .{
            .id = id,
            .name = options.name,
            .viewport = options.viewport,
            .persistent = options.persistent,
        }));

        if (self.active_workspace_id == null) {
            self.active_workspace_id = id;
            for (self.outputs.items) |*output| {
                if (output.active_workspace_id == null) output.active_workspace_id = id;
            }
        }

        try self.recordEvent(.{ .workspace_added = id });
        return id;
    }

    pub fn activateWorkspace(self: *Compositor, id: workspace_mod.WorkspaceId) !bool {
        if (self.getWorkspace(id) == null) return false;
        self.active_workspace_id = id;
        try self.recordEvent(.{ .workspace_activated = id });
        return true;
    }

    pub fn activeWorkspace(self: *Compositor) ?*workspace_mod.Workspace {
        const id = self.active_workspace_id orelse return null;
        return self.getWorkspace(id);
    }

    pub fn getWorkspace(self: *Compositor, id: workspace_mod.WorkspaceId) ?*workspace_mod.Workspace {
        for (self.workspaces.items) |*workspace| {
            if (workspace.id == id) return workspace;
        }
        return null;
    }

    pub fn getOutput(self: *Compositor, id: output_mod.OutputId) ?*output_mod.Output {
        for (self.outputs.items) |*output| {
            if (output.id == id) return output;
        }
        return null;
    }

    pub fn createWindow(
        self: *Compositor,
        workspace_id: workspace_mod.WorkspaceId,
        options: workspace_mod.WindowOptions,
    ) !window_mod.WindowId {
        const workspace = self.getWorkspace(workspace_id) orelse return error.WorkspaceNotFound;
        const id = try workspace.createWindow(options);
        try self.recordEvent(.{ .window_created = id });
        return id;
    }

    pub fn focusWindow(self: *Compositor, window_id: window_mod.WindowId) !bool {
        var found = false;
        for (self.workspaces.items) |*workspace| {
            if (workspace.focusWindow(window_id)) {
                self.active_workspace_id = workspace.id;
                found = true;
            }
        }
        if (found) try self.recordEvent(.{ .window_focused = window_id });
        return found;
    }

    pub fn recordEvent(self: *Compositor, event: Event) !void {
        try self.events.append(self.allocator, event);
    }

    pub fn windowCount(self: Compositor) usize {
        var count: usize = 0;
        for (self.workspaces.items) |workspace| {
            count += workspace.windows.items.len;
        }
        return count;
    }
};

test "compositor owns outputs and spatial workspaces" {
    var compositor = Compositor.init(std.testing.allocator);
    defer compositor.deinit();

    const output_id = try compositor.addOutput(.{
        .name = "eDP-1",
        .rect = geometry.rect(0, 0, 1920, 1080),
    });
    const workspace_id = try compositor.createWorkspace(.{
        .name = "desk",
        .viewport = geometry.rect(0, 0, 1920, 1080),
    });
    const window_id = try compositor.createWindow(workspace_id, .{
        .rect = geometry.rect(2400, 0, 900, 700),
    });

    try std.testing.expect(compositor.getOutput(output_id).?.active_workspace_id == workspace_id);
    try std.testing.expect(try compositor.focusWindow(window_id));
    try std.testing.expectEqual(@as(usize, 1), compositor.windowCount());
    try std.testing.expectEqual(@as(usize, 4), compositor.events.items.len);
}
