const types = @import("types.zig");
const client = @import("client/root.zig");
const server = @import("server/root.zig");

pub const c = @import("c.zig").wl;

pub const Rect = types.Rect;
pub const ShmFormat = types.ShmFormat;
pub const BufferTransform = types.BufferTransform;
pub const SeatCapabilities = types.SeatCapabilities;
pub const OutputMode = types.OutputMode;
pub const OutputSubpixel = types.OutputSubpixel;
pub const OutputTransform = types.OutputTransform;
pub const OutputScale = types.OutputScale;
pub const OutputGeometryFlags = types.OutputGeometryFlags;

pub const rect = types.rect;

pub const Display = client.Display;
pub const EventQueue = client.EventQueue;
pub const Proxy = client.Proxy;
pub const Registry = client.Registry;
pub const Callback = client.Callback;
pub const Compositor = client.Compositor;
pub const Region = client.Region;
pub const Surface = client.Surface;
pub const Buffer = client.Buffer;
pub const Shm = client.Shm;
pub const ShmPool = client.ShmPool;
pub const Seat = client.Seat;
pub const Pointer = client.Pointer;
pub const Keyboard = client.Keyboard;
pub const Touch = client.Touch;
pub const Output = client.Output;
pub const DataDeviceManager = client.DataDeviceManager;
pub const DataDevice = client.DataDevice;
pub const DataOffer = client.DataOffer;
pub const DataSource = client.DataSource;
pub const Shell = client.Shell;
pub const ShellSurface = client.ShellSurface;
pub const Subcompositor = client.Subcompositor;
pub const Subsurface = client.Subsurface;

pub const connect = Display.connect;
pub const connectDefault = Display.connectDefault;
pub const connectToFd = Display.connectToFd;

pub const server_Display = server.Display;
pub const server_EventLoop = server.EventLoop;
pub const server_EventQueue = server.EventQueue;
pub const server_Client = server.Client;
pub const server_Resource = server.Resource;
pub const server_Global = server.Global;
pub const server_GlobalList = server.GlobalList;
pub const server_GlobalListIterator = server.GlobalListIterator;
pub const server_GlobalInfo = server.GlobalInfo;
pub const server_Listener = server.Listener;
pub const server_Signal = server.Signal;
pub const server_ShmBuffer = server.ShmBuffer;
pub const server_FdSource = server.FdSource;
pub const server_TimerSource = server.TimerSource;
pub const server_SignalSource = server.SignalSource;
pub const server_IdleSource = server.IdleSource;
pub const server_createGlobal = server.createGlobal;
pub const server_getGlobals = server.getGlobals;
pub const server_createResource = server.createResource;
pub const server_addResource = server.addResource;

pub const Error = client.Error;
pub const server_Error = server.Error;
