const std = @import("std");
const nirvana = @import("nirvana");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    var host = nirvana.PluginHost.init(std.heap.page_allocator);
    defer host.deinit();

    _ = try host.createWorkspace(.{
        .name = "desk",
        .viewport = nirvana.geometry.rect(0, 0, 1920, 1080),
        .persistent = true,
    });

    const workspace = host.activeWorkspace().?;
    _ = try workspace.createWindow(.{
        .rect = nirvana.geometry.rect(120, 120, 900, 640),
        .metadata = .{ .app_id = "nirvana.demo", .title = "Nirvana Demo" },
    });

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(stdout_buffer[0..]);
    const stdout = &stdout_writer.interface;
    try stdout.print("nirvana: {d} workspace, {d} window\n", .{
        host.workspaces.items.len,
        workspace.windows.items.len,
    });
    try stdout.flush();
}

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}
