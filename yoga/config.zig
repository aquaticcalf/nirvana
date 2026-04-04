const c = @import("c.zig").c;

pub const Config = struct {
    handle: c.YGConfigRef,

    pub fn init() Config {
        return .{ .handle = c.YGConfigNew() };
    }

    pub fn deinit(self: Config) void {
        c.YGConfigFree(self.handle);
    }
};
