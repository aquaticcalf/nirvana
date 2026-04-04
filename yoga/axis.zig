pub const Edge = enum(u16) {
    left = 0,
    top = 1,
    right = 2,
    bottom = 3,
    start = 4,
    end = 5,
    horizontal = 6,
    vertical = 7,
    all = 8,
};

pub const Gutter = enum(u16) {
    column = 0,
    row = 1,
    all = 2,
};
