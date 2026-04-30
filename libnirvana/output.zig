const geometry = @import("geometry.zig");
const workspace_mod = @import("workspace.zig");

pub const OutputId = u64;

pub const Output = struct {
    id: OutputId,
    name: []const u8,
    make: []const u8 = "",
    model: []const u8 = "",
    rect: geometry.Rect,
    scale: f32 = 1,
    active_workspace_id: ?workspace_mod.WorkspaceId = null,

    pub fn containsWorkspaceViewport(self: Output, workspace: workspace_mod.Workspace) bool {
        return self.rect.intersects(workspace.viewport.rect);
    }
};

pub const OutputOptions = struct {
    name: []const u8,
    make: []const u8 = "",
    model: []const u8 = "",
    rect: geometry.Rect,
    scale: f32 = 1,
};
