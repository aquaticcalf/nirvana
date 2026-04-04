pub const Dimension = enum(u16) {
    width = 0,
    height = 1,
};

pub const Errata = enum(u16) {
    none = 0,
    stretch_flex_basis = 1,
    absolute_position_without_insets_excludes_padding = 2,
    absolute_percent_against_inner_size = 4,
    all = 2147483647,
    classic = 2147483646,
};

pub const ExperimentalFeature = enum(u16) {
    web_flex_basis = 0,
};

pub const LogLevel = enum(u16) {
    @"error" = 0,
    warn = 1,
    info = 2,
    debug = 3,
    verbose = 4,
    fatal = 5,
};

pub const MeasureMode = enum(u16) {
    undefined = 0,
    exactly = 1,
    at_most = 2,
};

pub const NodeType = enum(u16) {
    default = 0,
    text = 1,
};

pub const Unit = enum(u16) {
    undefined = 0,
    point = 1,
    percent = 2,
    auto = 3,
    max_content = 4,
    fit_content = 5,
    stretch = 6,
};
