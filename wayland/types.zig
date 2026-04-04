const c = @import("c.zig").wl;

pub const Rect = struct {
    x: i32 = 0,
    y: i32 = 0,
    width: i32,
    height: i32,
};

pub const ShmFormat = enum(u32) {
    invalid = c.WL_SHM_FORMAT_INVALID,
    c8 = c.WL_SHM_FORMAT_C8,
    rgb332 = c.WL_SHM_FORMAT_RGB332,
    bgr233 = c.WL_SHM_FORMAT_BGR233,
    xrgb4444 = c.WL_SHM_FORMAT_XRGB4444,
    xbgr4444 = c.WL_SHM_FORMAT_XBGR4444,
    rgbx4444 = c.WL_SHM_FORMAT_RGBX4444,
    bgrx4444 = c.WL_SHM_FORMAT_BGRX4444,
    argb4444 = c.WL_SHM_FORMAT_ARGB4444,
    xbgr1555 = c.WL_SHM_FORMAT_XBGR1555,
    rgbx5551 = c.WL_SHM_FORMAT_RGBX5551,
    bgrx5551 = c.WL_SHM_FORMAT_BGRX5551,
    argb1555 = c.WL_SHM_FORMAT_ARGB1555,
    bgra5551 = c.WL_SHM_FORMAT_BGRA5551,
    rgb565 = c.WL_SHM_FORMAT_RGB565,
    bgr565 = c.WL_SHM_FORMAT_BGR565,
    rgb888 = c.WL_SHM_FORMAT_RGB888,
    bgr888 = c.WL_SHM_FORMAT_BGR888,
    xbgr8888 = c.WL_SHM_FORMAT_XBGR8888,
    rgbx8888 = c.WL_SHM_FORMAT_RGBX8888,
    bgrx8888 = c.WL_SHM_FORMAT_BGRX8888,
    abgr8888 = c.WL_SHM_FORMAT_ABGR8888,
    rgba8888 = c.WL_SHM_FORMAT_RGBA8888,
    argb8888 = c.WL_SHM_FORMAT_ARGB8888,
    xrgb8888 = c.WL_SHM_FORMAT_XRGB8888,
    xrgb2101010 = c.WL_SHM_FORMAT_XRGB2101010,
    xbgr2101010 = c.WL_SHM_FORMAT_XBGR2101010,
    rgbx1010102 = c.WL_SHM_FORMAT_RGBX1010102,
    bgrx1010102 = c.WL_SHM_FORMAT_BGRX1010102,
    abgr2101010 = c.WL_SHM_FORMAT_ABGR2101010,
    rgba1010102 = c.WL_SHM_FORMAT_RGBA1010102,
    bgra1010102 = c.WL_SHM_FORMAT_BGRA1010102,
    yuv420 = c.WL_SHM_FORMAT_YUV420,
    yvu420 = c.WL_SHM_FORMAT_YVU420,
    yuy2 = c.WL_SHM_FORMAT_YUY2,
    yvyu = c.WL_SHM_FORMAT_YVYU,
    i420 = c.WL_SHM_FORMAT_I420,
    yv12 = c.WL_SHM_FORMAT_YV12,
    nv12 = c.WL_SHM_FORMAT_NV12,
    nv21 = c.WL_SHM_FORMAT_NV21,
    nv16 = c.WL_SHM_FORMAT_NV16,
    nv61 = c.WL_SHM_FORMAT_NV61,
    y410 = c.WL_SHM_FORMAT_Y410,
    xyzw8888 = c.WL_SHM_FORMAT_XYZW8888,
    vuy888 = c.WL_SHM_FORMAT_VUY888,
    vuyA8888 = c.WL_SHM_FORMAT_VUYA8888,
    xyz8888 = c.WL_SHM_FORMAT_XYZ8888,
    xyzf16161616f = c.WL_SHM_FORMAT_XYZF16161616F,
    xv2101010 = c.WL_SHM_FORMAT_XV2101010,
    xvYU12 = c.WL_SHM_FORMAT_XVYU12,
    abgr16161616f = c.WL_SHM_FORMAT_ABGR16161616F,
    rgba16161616f = c.WL_SHM_FORMAT_RGBA16161616F,
};

pub const BufferTransform = enum(i32) {
    normal = c.WL_OUTPUT_TRANSFORM_NORMAL,
    @"90" = c.WL_OUTPUT_TRANSFORM_90,
    @"180" = c.WL_OUTPUT_TRANSFORM_180,
    @"270" = c.WL_OUTPUT_TRANSFORM_270,
    flipped = c.WL_OUTPUT_TRANSFORM_FLIPPED,
    flipped_90 = c.WL_OUTPUT_TRANSFORM_FLIPPED_90,
    flipped_180 = c.WL_OUTPUT_TRANSFORM_FLIPPED_180,
    flipped_270 = c.WL_OUTPUT_TRANSFORM_FLIPPED_270,
};

pub const BufferScale = enum(i32) {
    scale_1 = 1,
    scale_2 = 2,
    scale_3 = 3,
    scale_4 = 4,
    scale_5 = 5,
    scale_6 = 6,
    scale_7 = 7,
    scale_8 = 8,
};

pub const SeatCapabilities = packed struct(u32) {
    pointer: bool = false,
    keyboard: bool = false,
    touch: bool = false,
    _padding: u29 = 0,

    pub fn from(bits: u32) SeatCapabilities {
        return @bitCast(bits);
    }
};

pub const OutputMode = packed struct(u32) {
    current: bool = false,
    preferred: bool = false,
    _padding: u30 = 0,

    pub fn from(bits: u32) OutputMode {
        return @bitCast(bits);
    }
};

pub const OutputSubpixel = enum(u32) {
    unknown = c.WL_OUTPUT_SUBPIXEL_UNKNOWN,
    none = c.WL_OUTPUT_SUBPIXEL_NONE,
    horizontal_rgb = c.WL_OUTPUT_SUBPIXEL_HORIZONTAL_RGB,
    horizontal_bgr = c.WL_OUTPUT_SUBPIXEL_HORIZONTAL_BGR,
    vertical_rgb = c.WL_OUTPUT_SUBPIXEL_VERTICAL_RGB,
    vertical_bgr = c.WL_OUTPUT_SUBPIXEL_VERTICAL_BGR,
};

pub const OutputTransform = enum(u32) {
    normal = c.WL_OUTPUT_TRANSFORM_NORMAL,
    @"90" = c.WL_OUTPUT_TRANSFORM_90,
    @"180" = c.WL_OUTPUT_TRANSFORM_180,
    @"270" = c.WL_OUTPUT_TRANSFORM_270,
    flipped = c.WL_OUTPUT_TRANSFORM_FLIPPED,
    flipped_90 = c.WL_OUTPUT_TRANSFORM_FLIPPED_90,
    flipped_180 = c.WL_OUTPUT_TRANSFORM_FLIPPED_180,
    flipped_270 = c.WL_OUTPUT_TRANSFORM_FLIPPED_270,
};

pub const OutputScale = enum(i32) {
    scale_1 = 1,
    scale_2 = 2,
    scale_3 = 3,
    scale_4 = 4,
    scale_5 = 5,
    scale_6 = 6,
    scale_7 = 7,
    scale_8 = 8,
};

pub const OutputGeometryFlags = packed struct(u32) {
    x: bool = false,
    y: bool = false,
    width: bool = false,
    height: bool = false,
    refresh: bool = false,
    _padding: u27 = 0,

    pub fn from(bits: u32) OutputGeometryFlags {
        return @bitCast(bits);
    }
};

pub inline fn rect(x: i32, y: i32, width: i32, height: i32) Rect {
    return .{ .x = x, .y = y, .width = width, .height = height };
}
