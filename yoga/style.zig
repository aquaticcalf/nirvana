const axis = @import("axis.zig");
const modes = @import("modes.zig");
const value_mod = @import("value.zig");

const Direction = modes.Direction;
const FlexDirection = modes.FlexDirection;
const Align = modes.Align;
const Justify = modes.Justify;
const Display = modes.Display;
const Overflow = modes.Overflow;
const Wrap = modes.Wrap;
const BoxSizing = modes.BoxSizing;
const PositionType = modes.PositionType;
const Value = value_mod.Value;

pub const Edges = struct {
    all: ?Value = null,
    x: ?Value = null,
    y: ?Value = null,
    left: ?Value = null,
    right: ?Value = null,
    top: ?Value = null,
    bottom: ?Value = null,
    start: ?Value = null,
    end: ?Value = null,

    pub fn from(value: anytype) Edges {
        return switch (@TypeOf(value)) {
            Edges => value,
            else => edgeFromUnknown(value),
        };
    }
};

pub const BorderEdges = struct {
    all: ?f32 = null,
    x: ?f32 = null,
    y: ?f32 = null,
    left: ?f32 = null,
    right: ?f32 = null,
    top: ?f32 = null,
    bottom: ?f32 = null,
    start: ?f32 = null,
    end: ?f32 = null,

    pub fn from(value: anytype) BorderEdges {
        return switch (@TypeOf(value)) {
            BorderEdges => value,
            comptime_int => .{ .all = @floatFromInt(value) },
            comptime_float, f16, f32, f64 => .{ .all = @floatCast(value) },
            else => borderFromUnknown(value),
        };
    }
};

pub const Style = struct {
    direction: ?Direction = null,
    flex_direction: ?FlexDirection = null,
    justify_content: ?Justify = null,
    align_items: ?Align = null,
    align_self: ?Align = null,
    align_content: ?Align = null,
    display: ?Display = null,
    overflow: ?Overflow = null,
    wrap: ?Wrap = null,
    position_type: ?PositionType = null,
    box_sizing: ?BoxSizing = null,
    width: ?Value = null,
    height: ?Value = null,
    min_width: ?Value = null,
    min_height: ?Value = null,
    max_width: ?Value = null,
    max_height: ?Value = null,
    margin: ?Edges = null,
    padding: ?Edges = null,
    position: ?Edges = null,
    border: ?BorderEdges = null,
    gap: ?Value = null,
    row_gap: ?Value = null,
    column_gap: ?Value = null,
    flex: ?f32 = null,
    flex_grow: ?f32 = null,
    flex_shrink: ?f32 = null,
    aspect_ratio: ?f32 = null,
};

pub inline fn insets(value: anytype) Edges {
    return Edges.from(value);
}

pub inline fn borderEdges(value: anytype) BorderEdges {
    return BorderEdges.from(value);
}

fn edgeFromUnknown(value: anytype) Edges {
    const T = @TypeOf(value);
    return switch (@typeInfo(T)) {
        .@"struct" => .{
            .all = edgeValueField(T, value, "all"),
            .x = edgeValueField(T, value, "x"),
            .y = edgeValueField(T, value, "y"),
            .left = edgeValueField(T, value, "left"),
            .right = edgeValueField(T, value, "right"),
            .top = edgeValueField(T, value, "top"),
            .bottom = edgeValueField(T, value, "bottom"),
            .start = edgeValueField(T, value, "start"),
            .end = edgeValueField(T, value, "end"),
        },
        else => .{ .all = Value.from(value) },
    };
}

fn edgeValueField(comptime T: type, value: T, comptime field: []const u8) ?Value {
    if (@hasField(T, field)) {
        return Value.from(@field(value, field));
    }
    return null;
}

fn borderFromUnknown(value: anytype) BorderEdges {
    const T = @TypeOf(value);
    return switch (@typeInfo(T)) {
        .@"struct" => .{
            .all = borderField(T, value, "all"),
            .x = borderField(T, value, "x"),
            .y = borderField(T, value, "y"),
            .left = borderField(T, value, "left"),
            .right = borderField(T, value, "right"),
            .top = borderField(T, value, "top"),
            .bottom = borderField(T, value, "bottom"),
            .start = borderField(T, value, "start"),
            .end = borderField(T, value, "end"),
        },
        else => @compileError("expected yoga.BorderEdges, a matching edge struct, or a numeric border width"),
    };
}

fn borderField(comptime T: type, value: T, comptime field: []const u8) ?f32 {
    if (@hasField(T, field)) {
        return switch (@TypeOf(@field(value, field))) {
            comptime_int => @floatFromInt(@field(value, field)),
            comptime_float, f16, f32, f64 => @floatCast(@field(value, field)),
            else => @compileError("expected a numeric border width"),
        };
    }
    return null;
}
