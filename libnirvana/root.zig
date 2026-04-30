pub const geometry = @import("geometry.zig");
pub const style = @import("style.zig");
pub const window = @import("window.zig");
pub const workspace = @import("workspace.zig");
pub const output = @import("output.zig");
pub const compositor = @import("compositor.zig");
pub const plugin = @import("plugin.zig");

pub const Point = geometry.Point;
pub const Size = geometry.Size;
pub const Rect = geometry.Rect;
pub const Viewport = workspace.Viewport;
pub const Compositor = compositor.Compositor;
pub const Output = output.Output;
pub const OutputId = output.OutputId;
pub const Workspace = workspace.Workspace;
pub const WorkspaceId = workspace.WorkspaceId;
pub const Window = window.Window;
pub const WindowId = window.WindowId;
pub const LayoutMode = window.LayoutMode;
pub const WindowRole = window.WindowRole;
pub const PluginHost = plugin.Host;
pub const PluginApi = plugin.Api;
pub const Plugin = plugin.Plugin;
pub const PluginEvent = plugin.Event;

test {
    _ = geometry;
    _ = style;
    _ = window;
    _ = workspace;
    _ = output;
    _ = compositor;
    _ = plugin;
}
