pub const Value = union(enum) {
    undefined: f32,
    point: f32,
    percent: f32,
    auto: void,
    max_content: void,
    fit_content: void,
    stretch: void,

    pub fn from(value: anytype) Value {
        return switch (@TypeOf(value)) {
            Value => value,
            comptime_int => pt(@floatFromInt(value)),
            comptime_float, f16, f32, f64 => pt(@floatCast(value)),
            else => @compileError("expected yoga.Value or a numeric point value"),
        };
    }
};

pub inline fn pt(v: f32) Value {
    return .{ .point = v };
}

pub inline fn pct(v: f32) Value {
    return .{ .percent = v };
}

pub inline fn auto() Value {
    return .{ .auto = {} };
}

pub inline fn maxContent() Value {
    return .{ .max_content = {} };
}

pub inline fn fitContent() Value {
    return .{ .fit_content = {} };
}

pub inline fn stretch() Value {
    return .{ .stretch = {} };
}
