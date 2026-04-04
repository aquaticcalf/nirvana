const c = @cImport({
    @cInclude("wayland-client.h");
    @cInclude("wayland-server.h");
});

pub const wl = c;
