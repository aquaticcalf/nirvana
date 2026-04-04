const axis = @import("axis.zig");
const extra = @import("kinds.zig");
const layout = @import("layout.zig");
const node = @import("node.zig");
const config = @import("config.zig");
const style = @import("style.zig");
const modes = @import("modes.zig");
const value = @import("value.zig");

pub const Edge = axis.Edge;
pub const Gutter = axis.Gutter;

pub const Align = modes.Align;
pub const BoxSizing = modes.BoxSizing;
pub const Direction = modes.Direction;
pub const Display = modes.Display;
pub const FlexDirection = modes.FlexDirection;
pub const Justify = modes.Justify;
pub const Overflow = modes.Overflow;
pub const PositionType = modes.PositionType;
pub const Wrap = modes.Wrap;

pub const Dimension = extra.Dimension;
pub const Errata = extra.Errata;
pub const ExperimentalFeature = extra.ExperimentalFeature;
pub const LogLevel = extra.LogLevel;
pub const MeasureMode = extra.MeasureMode;
pub const NodeType = extra.NodeType;
pub const Unit = extra.Unit;

pub const Layout = layout.Layout;
pub const Config = config.Config;
pub const Node = node.Node;
pub const Value = value.Value;
pub const Edges = style.Edges;
pub const BorderEdges = style.BorderEdges;
pub const Style = style.Style;

pub const pt = value.pt;
pub const pct = value.pct;
pub const auto = value.auto;
pub const maxContent = value.maxContent;
pub const fitContent = value.fitContent;
pub const stretch = value.stretch;
pub const insets = style.insets;
pub const borderEdges = style.borderEdges;

test {
    _ = @import("tests.zig");
}
