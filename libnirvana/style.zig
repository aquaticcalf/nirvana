pub const Color = packed struct(u32) {
    b: u8,
    g: u8,
    r: u8,
    a: u8 = 255,

    pub fn rgb(r: u8, g: u8, b: u8) Color {
        return .{ .r = r, .g = g, .b = b };
    }

    pub fn rgba(r: u8, g: u8, b: u8, a: u8) Color {
        return .{ .r = r, .g = g, .b = b, .a = a };
    }
};

pub const Length = union(enum) {
    auto,
    px: f32,
    pct: f32,

    pub fn resolve(self: Length, basis: f32) ?f32 {
        return switch (self) {
            .auto => null,
            .px => |value| value,
            .pct => |value| basis * value / 100,
        };
    }
};

pub const Edges = struct {
    top: f32 = 0,
    right: f32 = 0,
    bottom: f32 = 0,
    left: f32 = 0,

    pub fn all(value: f32) Edges {
        return .{ .top = value, .right = value, .bottom = value, .left = value };
    }

    pub fn xy(x: f32, y: f32) Edges {
        return .{ .top = y, .right = x, .bottom = y, .left = x };
    }
};

pub const WindowStyle = struct {
    opacity: f32 = 1,
    border_width: f32 = 1,
    border_radius: f32 = 8,
    border_color: Color = Color.rgb(92, 96, 112),
    focus_ring_color: Color = Color.rgb(93, 95, 239),
    shadow_color: Color = Color.rgba(0, 0, 0, 120),
    shadow_radius: f32 = 24,
    padding: Edges = .{},
};

pub const WorkspaceStyle = struct {
    background: Color = Color.rgb(246, 247, 249),
    grid_color: Color = Color.rgba(30, 35, 45, 18),
    grid_size: f32 = 64,
    minimap_background: Color = Color.rgba(20, 24, 32, 210),
    minimap_window: Color = Color.rgba(255, 255, 255, 210),
    minimap_viewport: Color = Color.rgb(93, 95, 239),
};

pub const Selector = struct {
    app_id: ?[]const u8 = null,
    title: ?[]const u8 = null,
    workspace: ?[]const u8 = null,
    focused: ?bool = null,
    tiled: ?bool = null,
};

pub fn px(value: f32) Length {
    return .{ .px = value };
}

pub fn pct(value: f32) Length {
    return .{ .pct = value };
}

pub const auto: Length = .auto;
