const std = @import("std");
const nirvana = @import("nirvana");

pub fn main() !void {
    var compositor = nirvana.Compositor.init(std.heap.page_allocator);
    defer compositor.deinit();

    var host = nirvana.PluginHost.init(std.heap.page_allocator, &compositor);
    defer host.deinit();

    _ = try host.addOutput(.{
        .name = "virtual-1",
        .rect = nirvana.geometry.rect(0, 0, 1920, 1080),
    });

    _ = try host.createWorkspace(.{
        .name = "desk",
        .viewport = nirvana.geometry.rect(0, 0, 1920, 1080),
        .persistent = true,
    });

    const workspace = host.activeWorkspace().?;
    _ = try host.createWindow(workspace.id, .{
        .rect = nirvana.geometry.rect(120, 120, 900, 640),
        .metadata = .{ .app_id = "nirvana.demo", .title = "Nirvana Demo" },
    });

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(stdout_buffer[0..]);
    const stdout = &stdout_writer.interface;
    try stdout.print("nirvana: {d} output, {d} workspace, {d} window\n", .{
        compositor.outputs.items.len,
        compositor.workspaces.items.len,
        compositor.windowCount(),
    });
    try stdout.flush();
}
