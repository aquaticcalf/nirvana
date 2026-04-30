const geometry = @import("geometry.zig");
const style = @import("style.zig");

pub const WindowId = u64;
pub const WorkspaceId = u64;

pub const LayoutMode = enum {
    floating,
    tiled,
};

pub const WindowRole = enum {
    app,
    taskbar,
    panel,
    overlay,
};

pub const WindowMetadata = struct {
    app_id: []const u8 = "",
    title: []const u8 = "",
};

pub const Window = struct {
    id: WindowId,
    workspace_id: WorkspaceId,
    role: WindowRole = .app,
    mode: LayoutMode = .floating,
    rect: geometry.Rect,
    min_size: geometry.Size = .{ .width = 120, .height = 80 },
    max_size: geometry.Size = .{ .width = 16384, .height = 16384 },
    z_index: i32 = 0,
    focused: bool = false,
    visible: bool = true,
    metadata: WindowMetadata = .{},
    style: style.WindowStyle = .{},

    pub fn moveBy(self: *Window, delta: geometry.Point) void {
        self.rect = self.rect.translate(delta);
    }

    pub fn moveTo(self: *Window, point: geometry.Point) void {
        self.rect.origin = point;
    }

    pub fn resize(self: *Window, next_size: geometry.Size) void {
        self.rect.size = next_size.clamp(self.min_size, self.max_size);
    }

    pub fn isVisibleIn(self: Window, viewport: geometry.Rect) bool {
        return self.visible and self.rect.intersects(viewport);
    }
};
