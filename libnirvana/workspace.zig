const std = @import("std");
const geometry = @import("geometry.zig");
const style = @import("style.zig");
const window_mod = @import("window.zig");

pub const WorkspaceId = window_mod.WorkspaceId;
pub const Window = window_mod.Window;
pub const WindowId = window_mod.WindowId;

pub const Viewport = struct {
    rect: geometry.Rect,
    zoom: f32 = 1,

    pub fn pan(self: *Viewport, delta: geometry.Point) void {
        self.rect.origin = self.rect.origin.add(delta);
    }

    pub fn centerOn(self: *Viewport, point: geometry.Point) void {
        self.rect.origin = .{
            .x = point.x - self.rect.size.width / 2,
            .y = point.y - self.rect.size.height / 2,
        };
    }
};

pub const WorkspaceOptions = struct {
    id: WorkspaceId,
    name: []const u8,
    viewport: geometry.Rect,
    persistent: bool = false,
};

pub const WindowOptions = struct {
    role: window_mod.WindowRole = .app,
    mode: window_mod.LayoutMode = .floating,
    rect: geometry.Rect,
    metadata: window_mod.WindowMetadata = .{},
};

pub const Workspace = struct {
    allocator: std.mem.Allocator,
    id: WorkspaceId,
    name: []const u8,
    viewport: Viewport,
    windows: std.ArrayList(Window) = .empty,
    next_window_id: WindowId = 1,
    persistent: bool = false,
    style: style.WorkspaceStyle = .{},

    pub fn init(allocator: std.mem.Allocator, options: WorkspaceOptions) Workspace {
        return .{
            .allocator = allocator,
            .id = options.id,
            .name = options.name,
            .viewport = .{ .rect = options.viewport },
            .persistent = options.persistent,
        };
    }

    pub fn deinit(self: *Workspace) void {
        self.windows.deinit(self.allocator);
    }

    pub fn createWindow(self: *Workspace, options: WindowOptions) !WindowId {
        const id = self.next_window_id;
        self.next_window_id += 1;
        try self.windows.append(self.allocator, .{
            .id = id,
            .workspace_id = self.id,
            .role = options.role,
            .mode = options.mode,
            .rect = options.rect,
            .metadata = options.metadata,
            .z_index = @intCast(self.windows.items.len),
        });
        return id;
    }

    pub fn getWindow(self: *Workspace, id: WindowId) ?*Window {
        for (self.windows.items) |*window| {
            if (window.id == id) return window;
        }
        return null;
    }

    pub fn focusWindow(self: *Workspace, id: WindowId) bool {
        var found = false;
        for (self.windows.items) |*window| {
            window.focused = window.id == id;
            found = found or window.focused;
        }
        return found;
    }

    pub fn pan(self: *Workspace, delta: geometry.Point) void {
        self.viewport.pan(delta);
    }

    pub fn bounds(self: Workspace) ?geometry.Rect {
        if (self.windows.items.len == 0) return null;
        var result = self.windows.items[0].rect;
        for (self.windows.items[1..]) |window| {
            result = result.unionWith(window.rect);
        }
        return result;
    }

    pub fn visibleWindowCount(self: Workspace) usize {
        var count: usize = 0;
        for (self.windows.items) |window| {
            if (window.isVisibleIn(self.viewport.rect)) count += 1;
        }
        return count;
    }
};

test "workspace can pan to windows on an infinite plane" {
    const allocator = std.testing.allocator;
    var workspace = Workspace.init(allocator, .{
        .id = 1,
        .name = "dev",
        .viewport = geometry.rect(0, 0, 1920, 1080),
    });
    defer workspace.deinit();

    const local = try workspace.createWindow(.{
        .rect = geometry.rect(100, 100, 800, 600),
    });
    const remote = try workspace.createWindow(.{
        .rect = geometry.rect(5000, -900, 900, 700),
    });

    try std.testing.expect(workspace.focusWindow(local));
    try std.testing.expectEqual(@as(usize, 1), workspace.visibleWindowCount());

    workspace.viewport.centerOn(workspace.getWindow(remote).?.rect.center());
    try std.testing.expectEqual(@as(usize, 1), workspace.visibleWindowCount());
}
