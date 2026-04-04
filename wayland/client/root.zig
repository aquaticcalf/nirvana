const display = @import("../client/display.zig");
const compositor = @import("compositor.zig");
const shm = @import("shm.zig");
const seat = @import("seat.zig");
const output = @import("output.zig");
const device = @import("device.zig");
const shell = @import("shell.zig");

pub const Display = display.Display;
pub const EventQueue = display.EventQueue;
pub const Proxy = display.Proxy;
pub const Registry = display.Registry;
pub const Callback = display.Callback;
pub const Error = display.Error;

pub const Compositor = compositor.Compositor;
pub const Region = compositor.Region;
pub const Surface = compositor.Surface;
pub const Buffer = compositor.Buffer;

pub const Shm = shm.Shm;
pub const ShmPool = shm.ShmPool;

pub const Seat = seat.Seat;
pub const Pointer = seat.Pointer;
pub const Keyboard = seat.Keyboard;
pub const Touch = seat.Touch;

pub const Output = output.Output;

pub const DataDeviceManager = device.DataDeviceManager;
pub const DataDevice = device.DataDevice;
pub const DataOffer = device.DataOffer;
pub const DataSource = device.DataSource;

pub const Shell = shell.Shell;
pub const ShellSurface = shell.ShellSurface;
pub const Subcompositor = shell.Subcompositor;
pub const Subsurface = shell.Subsurface;
