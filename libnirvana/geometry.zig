const std = @import("std");

pub const Point = struct {
    x: f32 = 0,
    y: f32 = 0,

    pub fn add(self: Point, delta: Point) Point {
        return .{ .x = self.x + delta.x, .y = self.y + delta.y };
    }

    pub fn sub(self: Point, delta: Point) Point {
        return .{ .x = self.x - delta.x, .y = self.y - delta.y };
    }
};

pub const Size = struct {
    width: f32,
    height: f32,

    pub fn clamp(self: Size, min: Size, max: Size) Size {
        return .{
            .width = std.math.clamp(self.width, min.width, max.width),
            .height = std.math.clamp(self.height, min.height, max.height),
        };
    }
};

pub const Rect = struct {
    origin: Point = .{},
    size: Size,

    pub fn init(x: f32, y: f32, width: f32, height: f32) Rect {
        return .{
            .origin = .{ .x = x, .y = y },
            .size = .{ .width = width, .height = height },
        };
    }

    pub fn left(self: Rect) f32 {
        return self.origin.x;
    }

    pub fn right(self: Rect) f32 {
        return self.origin.x + self.size.width;
    }

    pub fn top(self: Rect) f32 {
        return self.origin.y;
    }

    pub fn bottom(self: Rect) f32 {
        return self.origin.y + self.size.height;
    }

    pub fn center(self: Rect) Point {
        return .{
            .x = self.left() + self.size.width / 2,
            .y = self.top() + self.size.height / 2,
        };
    }

    pub fn translate(self: Rect, delta: Point) Rect {
        return .{ .origin = self.origin.add(delta), .size = self.size };
    }

    pub fn containsPoint(self: Rect, target: Point) bool {
        return target.x >= self.left() and target.x <= self.right() and
            target.y >= self.top() and target.y <= self.bottom();
    }

    pub fn intersects(self: Rect, other: Rect) bool {
        return self.left() < other.right() and self.right() > other.left() and
            self.top() < other.bottom() and self.bottom() > other.top();
    }

    pub fn unionWith(self: Rect, other: Rect) Rect {
        const x1 = @min(self.left(), other.left());
        const y1 = @min(self.top(), other.top());
        const x2 = @max(self.right(), other.right());
        const y2 = @max(self.bottom(), other.bottom());
        return Rect.init(x1, y1, x2 - x1, y2 - y1);
    }
};

pub fn point(x: f32, y: f32) Point {
    return .{ .x = x, .y = y };
}

pub fn size(width: f32, height: f32) Size {
    return .{ .width = width, .height = height };
}

pub fn rect(x: f32, y: f32, width: f32, height: f32) Rect {
    return Rect.init(x, y, width, height);
}

test "rect intersection uses spatial workspace coordinates" {
    const viewport = rect(100, 100, 800, 600);
    try std.testing.expect(viewport.intersects(rect(50, 50, 100, 100)));
    try std.testing.expect(!viewport.intersects(rect(-1000, -1000, 50, 50)));
}
