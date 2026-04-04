const std = @import("std");
const yoga = @import("root.zig");

fn expectFloatEq(expected: f32, actual: f32) !void {
    try std.testing.expectApproxEqAbs(expected, actual, 0.001);
}

test "appendChild and flex layout produce readable geometry" {
    const root = yoga.Node.init();
    defer root.deinit();

    root.apply(.{
        .width = yoga.pt(200),
        .height = yoga.pt(100),
        .flex_direction = .row,
    });

    const fixed = yoga.Node.init();
    defer fixed.deinit();

    fixed.apply(.{
        .width = 50,
        .height = 100,
    });

    const fill = yoga.Node.init();
    defer fill.deinit();

    fill.apply(.{
        .flex_grow = 1,
        .height = 100,
    });

    root.appendChild(fixed);
    root.appendChild(fill);

    root.calculateLayout(null, null, .ltr);

    const root_layout = root.getLayout();
    const fixed_layout = fixed.getLayout();
    const fill_layout = fill.getLayout();

    try std.testing.expectEqual(@as(usize, 2), root.getChildCount());
    try expectFloatEq(200, root_layout.width);
    try expectFloatEq(100, root_layout.height);
    try expectFloatEq(0, fixed_layout.left);
    try expectFloatEq(50, fixed_layout.width);
    try expectFloatEq(50, fill_layout.left);
    try expectFloatEq(150, fill_layout.width);
}

test "padding shorthands accept plain numbers and percent values" {
    const root = yoga.Node.init();
    defer root.deinit();

    root.apply(.{
        .width = 100,
        .height = 80,
        .padding = yoga.insets(.{ .x = 12, .y = yoga.pct(10) }),
    });

    const child = yoga.Node.init();
    defer child.deinit();

    child.apply(.{
        .width = 20,
        .height = 10,
    });

    root.appendChild(child);
    root.calculateLayout(null, null, .ltr);

    const child_layout = child.getLayout();
    try expectFloatEq(12, child_layout.left);
    try expectFloatEq(8, child_layout.top);
    try expectFloatEq(20, child_layout.width);
    try expectFloatEq(10, child_layout.height);
}

test "absolute positioning shorthands place nodes predictably" {
    const root = yoga.Node.init();
    defer root.deinit();

    root.apply(.{
        .width = 120,
        .height = 90,
    });

    const badge = yoga.Node.init();
    defer badge.deinit();

    badge.apply(.{
        .position_type = .absolute,
        .position = yoga.insets(.{ .top = 4, .left = 7 }),
        .width = 16,
        .height = 18,
    });

    root.appendChild(badge);
    root.calculateLayout(null, null, .ltr);

    const layout = badge.getLayout();
    try expectFloatEq(7, layout.left);
    try expectFloatEq(4, layout.top);
    try expectFloatEq(16, layout.width);
    try expectFloatEq(18, layout.height);
}
