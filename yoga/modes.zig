pub const Align = enum(u16) {
    auto = 0,
    flex_start = 1,
    center = 2,
    flex_end = 3,
    stretch = 4,
    baseline = 5,
    space_between = 6,
    space_around = 7,
    space_evenly = 8,
};

pub const BoxSizing = enum(u16) {
    border_box = 0,
    content_box = 1,
};

pub const Direction = enum(u16) {
    inherit = 0,
    ltr = 1,
    rtl = 2,
};

pub const Display = enum(u16) {
    flex = 0,
    none = 1,
    contents = 2,
};

pub const FlexDirection = enum(u16) {
    column = 0,
    column_reverse = 1,
    row = 2,
    row_reverse = 3,
};

pub const Justify = enum(u16) {
    flex_start = 0,
    center = 1,
    flex_end = 2,
    space_between = 3,
    space_around = 4,
    space_evenly = 5,
};

pub const Overflow = enum(u16) {
    visible = 0,
    hidden = 1,
    scroll = 2,
};

pub const PositionType = enum(u16) {
    static = 0,
    relative = 1,
    absolute = 2,
};

pub const Wrap = enum(u16) {
    no_wrap = 0,
    wrap = 1,
    wrap_reverse = 2,
};
