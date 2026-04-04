const c = @import("c.zig").c;
const axis = @import("axis.zig");
const modes = @import("modes.zig");
const layout_mod = @import("layout.zig");
const style_mod = @import("style.zig");
const value_mod = @import("value.zig");
const config_mod = @import("config.zig");

const Edge = axis.Edge;
const Gutter = axis.Gutter;
const Direction = modes.Direction;
const FlexDirection = modes.FlexDirection;
const Align = modes.Align;
const Justify = modes.Justify;
const Display = modes.Display;
const Overflow = modes.Overflow;
const Wrap = modes.Wrap;
const BoxSizing = modes.BoxSizing;
const PositionType = modes.PositionType;
const Layout = layout_mod.Layout;
const Style = style_mod.Style;
const Edges = style_mod.Edges;
const BorderEdges = style_mod.BorderEdges;
const Value = value_mod.Value;
const Config = config_mod.Config;

pub const Node = struct {
    handle: c.YGNodeRef,

    pub fn init() Node {
        return .{ .handle = c.YGNodeNew() };
    }

    pub fn initWithConfig(config: Config) Node {
        return .{ .handle = c.YGNodeNewWithConfig(config.handle) };
    }

    pub fn deinit(self: Node) void {
        c.YGNodeFree(self.handle);
    }

    pub fn calculateLayout(self: Node, w: ?f32, h: ?f32, dir: Direction) void {
        c.YGNodeCalculateLayout(self.handle, w orelse 0.0, h orelse 0.0, @intFromEnum(dir));
    }

    pub fn insertChild(self: Node, child: Node, index: usize) void {
        c.YGNodeInsertChild(self.handle, child.handle, index);
    }

    pub fn appendChild(self: Node, child: Node) void {
        self.insertChild(child, self.getChildCount());
    }

    pub fn getChildCount(self: Node) usize {
        return c.YGNodeGetChildCount(self.handle);
    }

    pub fn getLayout(self: Node) Layout {
        return .{
            .left = c.YGNodeLayoutGetLeft(self.handle),
            .right = c.YGNodeLayoutGetRight(self.handle),
            .top = c.YGNodeLayoutGetTop(self.handle),
            .bottom = c.YGNodeLayoutGetBottom(self.handle),
            .width = c.YGNodeLayoutGetWidth(self.handle),
            .height = c.YGNodeLayoutGetHeight(self.handle),
        };
    }

    pub fn flexDirection(self: Node, dir: FlexDirection) void {
        c.YGNodeStyleSetFlexDirection(self.handle, @intFromEnum(dir));
    }

    pub fn direction(self: Node, dir: Direction) void {
        c.YGNodeStyleSetDirection(self.handle, @intFromEnum(dir));
    }

    pub fn width(self: Node, value: anytype) void {
        switch (Value.from(value)) {
            .point => |v| c.YGNodeStyleSetWidth(self.handle, v),
            .percent => |v| c.YGNodeStyleSetWidthPercent(self.handle, v),
            .auto => c.YGNodeStyleSetWidthAuto(self.handle),
            .max_content => c.YGNodeStyleSetWidthMaxContent(self.handle),
            .fit_content => c.YGNodeStyleSetWidthFitContent(self.handle),
            .stretch => c.YGNodeStyleSetWidthStretch(self.handle),
            .undefined => {},
        }
    }

    pub fn height(self: Node, value: anytype) void {
        switch (Value.from(value)) {
            .point => |v| c.YGNodeStyleSetHeight(self.handle, v),
            .percent => |v| c.YGNodeStyleSetHeightPercent(self.handle, v),
            .auto => c.YGNodeStyleSetHeightAuto(self.handle),
            .max_content => c.YGNodeStyleSetHeightMaxContent(self.handle),
            .fit_content => c.YGNodeStyleSetHeightFitContent(self.handle),
            .stretch => c.YGNodeStyleSetHeightStretch(self.handle),
            .undefined => {},
        }
    }

    pub fn margin(self: Node, edge: Edge, value: anytype) void {
        switch (Value.from(value)) {
            .point => |v| c.YGNodeStyleSetMargin(self.handle, @intFromEnum(edge), v),
            .percent => |v| c.YGNodeStyleSetMarginPercent(self.handle, @intFromEnum(edge), v),
            .auto => c.YGNodeStyleSetMarginAuto(self.handle, @intFromEnum(edge)),
            else => {},
        }
    }

    pub fn margins(self: Node, values: anytype) void {
        applyEdgeValues(self, Edges.from(values), setMargin);
    }

    pub fn padding(self: Node, edge: Edge, value: anytype) void {
        switch (Value.from(value)) {
            .point => |v| c.YGNodeStyleSetPadding(self.handle, @intFromEnum(edge), v),
            .percent => |v| c.YGNodeStyleSetPaddingPercent(self.handle, @intFromEnum(edge), v),
            else => {},
        }
    }

    pub fn paddings(self: Node, values: anytype) void {
        applyEdgeValues(self, Edges.from(values), setPadding);
    }

    pub fn border(self: Node, edge: Edge, w: f32) void {
        c.YGNodeStyleSetBorder(self.handle, @intFromEnum(edge), w);
    }

    pub fn borders(self: Node, values: anytype) void {
        const resolved = BorderEdges.from(values);
        applyBorderValue(self, .all, resolved.all);
        applyBorderValue(self, .horizontal, resolved.x);
        applyBorderValue(self, .vertical, resolved.y);
        applyBorderValue(self, .left, resolved.left);
        applyBorderValue(self, .right, resolved.right);
        applyBorderValue(self, .top, resolved.top);
        applyBorderValue(self, .bottom, resolved.bottom);
        applyBorderValue(self, .start, resolved.start);
        applyBorderValue(self, .end, resolved.end);
    }

    pub fn flexGrow(self: Node, grow: f32) void {
        c.YGNodeStyleSetFlexGrow(self.handle, grow);
    }

    pub fn flexShrink(self: Node, shrink: f32) void {
        c.YGNodeStyleSetFlexShrink(self.handle, shrink);
    }

    pub fn flex(self: Node, f: f32) void {
        c.YGNodeStyleSetFlex(self.handle, f);
    }

    pub fn justifyContent(self: Node, justify: Justify) void {
        c.YGNodeStyleSetJustifyContent(self.handle, @intFromEnum(justify));
    }

    pub fn alignItems(self: Node, a: Align) void {
        c.YGNodeStyleSetAlignItems(self.handle, @intFromEnum(a));
    }

    pub fn alignSelf(self: Node, a: Align) void {
        c.YGNodeStyleSetAlignSelf(self.handle, @intFromEnum(a));
    }

    pub fn alignContent(self: Node, a: Align) void {
        c.YGNodeStyleSetAlignContent(self.handle, @intFromEnum(a));
    }

    pub fn gap(self: Node, gutter: Gutter, value: anytype) void {
        switch (Value.from(value)) {
            .point => |v| c.YGNodeStyleSetGap(self.handle, @intFromEnum(gutter), v),
            .percent => |v| c.YGNodeStyleSetGapPercent(self.handle, @intFromEnum(gutter), v),
            else => {},
        }
    }

    pub fn gapAll(self: Node, value: anytype) void {
        self.gap(.all, value);
    }

    pub fn rowGap(self: Node, value: anytype) void {
        self.gap(.row, value);
    }

    pub fn columnGap(self: Node, value: anytype) void {
        self.gap(.column, value);
    }

    pub fn display(self: Node, d: Display) void {
        c.YGNodeStyleSetDisplay(self.handle, @intFromEnum(d));
    }

    pub fn overflow(self: Node, o: Overflow) void {
        c.YGNodeStyleSetOverflow(self.handle, @intFromEnum(o));
    }

    pub fn wrap(self: Node, w: Wrap) void {
        c.YGNodeStyleSetFlexWrap(self.handle, @intFromEnum(w));
    }

    pub fn positionType(self: Node, pos: PositionType) void {
        c.YGNodeStyleSetPositionType(self.handle, @intFromEnum(pos));
    }

    pub fn position(self: Node, edge: Edge, value: anytype) void {
        switch (Value.from(value)) {
            .point => |v| c.YGNodeStyleSetPosition(self.handle, @intFromEnum(edge), v),
            .percent => |v| c.YGNodeStyleSetPositionPercent(self.handle, @intFromEnum(edge), v),
            .auto => c.YGNodeStyleSetPositionAuto(self.handle, @intFromEnum(edge)),
            else => {},
        }
    }

    pub fn positions(self: Node, values: anytype) void {
        applyEdgeValues(self, Edges.from(values), setPosition);
    }

    pub fn aspectRatio(self: Node, ratio: f32) void {
        c.YGNodeStyleSetAspectRatio(self.handle, ratio);
    }

    pub fn boxSizing(self: Node, box: BoxSizing) void {
        c.YGNodeStyleSetBoxSizing(self.handle, @intFromEnum(box));
    }

    pub fn minWidth(self: Node, value: anytype) void {
        switch (Value.from(value)) {
            .point => |v| c.YGNodeStyleSetMinWidth(self.handle, v),
            .percent => |v| c.YGNodeStyleSetMinWidthPercent(self.handle, v),
            .auto => c.YGNodeStyleSetMinWidthAuto(self.handle),
            .max_content => c.YGNodeStyleSetMinWidthMaxContent(self.handle),
            .fit_content => c.YGNodeStyleSetMinWidthFitContent(self.handle),
            .stretch => c.YGNodeStyleSetMinWidthStretch(self.handle),
            .undefined => {},
        }
    }

    pub fn minHeight(self: Node, value: anytype) void {
        switch (Value.from(value)) {
            .point => |v| c.YGNodeStyleSetMinHeight(self.handle, v),
            .percent => |v| c.YGNodeStyleSetMinHeightPercent(self.handle, v),
            .auto => c.YGNodeStyleSetMinHeightAuto(self.handle),
            .max_content => c.YGNodeStyleSetMinHeightMaxContent(self.handle),
            .fit_content => c.YGNodeStyleSetMinHeightFitContent(self.handle),
            .stretch => c.YGNodeStyleSetMinHeightStretch(self.handle),
            .undefined => {},
        }
    }

    pub fn maxWidth(self: Node, value: anytype) void {
        switch (Value.from(value)) {
            .point => |v| c.YGNodeStyleSetMaxWidth(self.handle, v),
            .percent => |v| c.YGNodeStyleSetMaxWidthPercent(self.handle, v),
            .auto => c.YGNodeStyleSetMaxWidthAuto(self.handle),
            .max_content => c.YGNodeStyleSetMaxWidthMaxContent(self.handle),
            .fit_content => c.YGNodeStyleSetMaxWidthFitContent(self.handle),
            .stretch => c.YGNodeStyleSetMaxWidthStretch(self.handle),
            .undefined => {},
        }
    }

    pub fn maxHeight(self: Node, value: anytype) void {
        switch (Value.from(value)) {
            .point => |v| c.YGNodeStyleSetMaxHeight(self.handle, v),
            .percent => |v| c.YGNodeStyleSetMaxHeightPercent(self.handle, v),
            .auto => c.YGNodeStyleSetMaxHeightAuto(self.handle),
            .max_content => c.YGNodeStyleSetMaxHeightMaxContent(self.handle),
            .fit_content => c.YGNodeStyleSetMaxHeightFitContent(self.handle),
            .stretch => c.YGNodeStyleSetMaxHeightStretch(self.handle),
            .undefined => {},
        }
    }

    pub fn apply(self: Node, style: Style) void {
        if (style.direction) |value| self.direction(value);
        if (style.flex_direction) |value| self.flexDirection(value);
        if (style.justify_content) |value| self.justifyContent(value);
        if (style.align_items) |value| self.alignItems(value);
        if (style.align_self) |value| self.alignSelf(value);
        if (style.align_content) |value| self.alignContent(value);
        if (style.display) |value| self.display(value);
        if (style.overflow) |value| self.overflow(value);
        if (style.wrap) |value| self.wrap(value);
        if (style.position_type) |value| self.positionType(value);
        if (style.box_sizing) |value| self.boxSizing(value);
        if (style.width) |value| self.width(value);
        if (style.height) |value| self.height(value);
        if (style.min_width) |value| self.minWidth(value);
        if (style.min_height) |value| self.minHeight(value);
        if (style.max_width) |value| self.maxWidth(value);
        if (style.max_height) |value| self.maxHeight(value);
        if (style.margin) |value| self.margins(value);
        if (style.padding) |value| self.paddings(value);
        if (style.position) |value| self.positions(value);
        if (style.border) |value| self.borders(value);
        if (style.gap) |value| self.gapAll(value);
        if (style.row_gap) |value| self.rowGap(value);
        if (style.column_gap) |value| self.columnGap(value);
        if (style.flex) |value| self.flex(value);
        if (style.flex_grow) |value| self.flexGrow(value);
        if (style.flex_shrink) |value| self.flexShrink(value);
        if (style.aspect_ratio) |value| self.aspectRatio(value);
    }
};

fn applyEdgeValues(self: Node, values: Edges, setter: fn (Node, Edge, Value) void) void {
    applyEdgeValue(self, .all, values.all, setter);
    applyEdgeValue(self, .horizontal, values.x, setter);
    applyEdgeValue(self, .vertical, values.y, setter);
    applyEdgeValue(self, .left, values.left, setter);
    applyEdgeValue(self, .right, values.right, setter);
    applyEdgeValue(self, .top, values.top, setter);
    applyEdgeValue(self, .bottom, values.bottom, setter);
    applyEdgeValue(self, .start, values.start, setter);
    applyEdgeValue(self, .end, values.end, setter);
}

fn applyEdgeValue(self: Node, edge: Edge, value: ?Value, setter: fn (Node, Edge, Value) void) void {
    if (value) |resolved| setter(self, edge, resolved);
}

fn applyBorderValue(self: Node, edge: Edge, value: ?f32) void {
    if (value) |resolved| self.border(edge, resolved);
}

fn setMargin(self: Node, edge: Edge, value: Value) void {
    self.margin(edge, value);
}

fn setPadding(self: Node, edge: Edge, value: Value) void {
    self.padding(edge, value);
}

fn setPosition(self: Node, edge: Edge, value: Value) void {
    self.position(edge, value);
}
