const c = @import("../c.zig").wl;
const std = @import("std");

pub const EventQueue = struct {
    handle: *c.wl_event_queue,

    pub fn deinit(self: EventQueue) void {
        c.wl_event_queue_destroy(self.handle);
    }
};

pub const EventLoop = struct {
    handle: *c.wl_event_loop,

    pub fn deinit(self: EventLoop) void {
        c.wl_event_loop_destroy(self.handle);
    }

    pub fn addFd(self: EventLoop, fd: i32, flags: c_int, data: ?*anyopaque, callback: c.wl_event_loop_fd_func_t) ?FdSource {
        const source = c.wl_event_loop_add_fd(self.handle, fd, flags, callback, data) orelse return null;
        return .{ .handle = source };
    }

    pub fn addTimer(self: EventLoop, data: ?*anyopaque, callback: c.wl_event_loop_timer_func_t) ?TimerSource {
        const source = c.wl_event_loop_add_timer(self.handle, callback, data) orelse return null;
        return .{ .handle = source };
    }

    pub fn addSignal(self: EventLoop, signal: i32, data: ?*anyopaque, callback: c.wl_event_loop_signal_func_t) ?SignalSource {
        const source = c.wl_event_loop_add_signal(self.handle, signal, callback, data) orelse return null;
        return .{ .handle = source };
    }

    pub fn addIdle(self: EventLoop, data: ?*anyopaque, callback: c.wl_event_loop_idle_func_t) ?IdleSource {
        const source = c.wl_event_loop_add_idle(self.handle, callback, data) orelse return null;
        return .{ .handle = source };
    }

    pub fn dispatch(self: EventLoop, timeout: i32) !u31 {
        const rc = c.wl_event_loop_dispatch(self.handle, timeout);
        if (rc < 0) return error.DispatchFailed;
        return @intCast(rc);
    }

    pub fn dispatchPending(self: EventLoop) !u31 {
        const rc = c.wl_event_loop_dispatch_pending(self.handle);
        if (rc < 0) return error.DispatchFailed;
        return @intCast(rc);
    }

    pub fn flush(self: EventLoop) void {
        c.wl_event_loop_flush(self.handle);
    }

    pub fn breakLoop(self: EventLoop) void {
        c.wl_event_loop_break(self.handle);
    }
};

pub const FdSource = struct {
    handle: *c.wl_event_source,

    pub fn remove(self: FdSource) void {
        c.wl_event_source_remove(self.handle);
    }

    pub fn update(self: FdSource, mask: c_int) void {
        c.wl_event_source_fd_update(self.handle, mask);
    }

    pub fn check(self: FdSource) void {
        c.wl_event_source_check(self.handle);
    }
};

pub const TimerSource = struct {
    handle: *c.wl_event_source,

    pub fn remove(self: TimerSource) void {
        c.wl_event_source_remove(self.handle);
    }

    pub fn update(self: TimerSource, timeout: i32, remain: i32) void {
        c.wl_event_source_timer_update(self.handle, timeout, remain);
    }
};

pub const SignalSource = struct {
    handle: *c.wl_event_source,

    pub fn remove(self: SignalSource) void {
        c.wl_event_source_remove(self.handle);
    }
};

pub const IdleSource = struct {
    handle: *c.wl_event_source,

    pub fn remove(self: IdleSource) void {
        c.wl_event_source_remove(self.handle);
    }

    pub fn setPriority(self: IdleSource, priority: i32) void {
        c.wl_event_source_set_priority(self.handle, priority);
    }
};

pub const Error = error{DispatchFailed};
