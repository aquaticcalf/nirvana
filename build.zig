const std = @import("std");

const CXXFLAGS = .{
    "--std=c++20",
    "-Wall",
    "-Wextra",
    "-Werror",
};

const yoga_files = .{
    "YGConfig.cpp",
    "YGEnums.cpp",
    "YGNode.cpp",
    "YGNodeLayout.cpp",
    "YGNodeStyle.cpp",
    "YGPixelGrid.cpp",
    "YGValue.cpp",
    "algorithm/AbsoluteLayout.cpp",
    "algorithm/Baseline.cpp",
    "algorithm/Cache.cpp",
    "algorithm/CalculateLayout.cpp",
    "algorithm/FlexLine.cpp",
    "algorithm/PixelGrid.cpp",
    "config/Config.cpp",
    "debug/AssertFatal.cpp",
    "debug/Log.cpp",
    "event/event.cpp",
    "node/LayoutResults.cpp",
    "node/Node.cpp",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const yoga_dep = b.dependency("yoga", .{
        .target = target,
        .optimize = optimize,
    });

    const yoga_mod = b.addModule("yoga", .{
        .root_source_file = b.path("yoga/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libcpp = true,
    });

    const wayland_mod = b.addModule("wayland", .{
        .root_source_file = b.path("wayland/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const yoga_lib = b.addLibrary(.{
        .name = "yoga",
        .root_module = yoga_mod,
    });

    yoga_lib.addCSourceFiles(.{
        .root = yoga_dep.path("yoga"),
        .files = &yoga_files,
        .flags = &CXXFLAGS,
    });

    yoga_lib.installHeadersDirectory(yoga_dep.path("yoga"), "yoga", .{
        .include_extensions = &.{".h"},
    });

    yoga_lib.addIncludePath(yoga_dep.path(""));

    b.installArtifact(yoga_lib);

    const wayland_lib = b.addLibrary(.{
        .name = "wayland",
        .root_module = wayland_mod,
    });

    wayland_lib.linkLibC();
    wayland_lib.linkSystemLibrary("wayland-client");
    wayland_lib.linkSystemLibrary("wayland-server");

    b.installArtifact(wayland_lib);

    const mod = b.addModule("nirvana", .{
        .root_source_file = b.path("compositor/root.zig"),
        .target = target,
        .imports = &.{
            .{ .name = "yoga", .module = yoga_mod },
        },
    });

    const exe = b.addExecutable(.{
        .name = "nirvana",
        .root_module = b.createModule(.{
            .root_source_file = b.path("compositor/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "nirvana", .module = mod },
            },
        }),
    });

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const mod_tests = b.addTest(.{
        .name = "nirvana",
        .root_module = mod,
    });

    const run_mod_tests = b.addRunArtifact(mod_tests);
    run_mod_tests.setName("run nirvana tests");

    const exe_tests = b.addTest(.{
        .name = "compositor",
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);
    run_exe_tests.setName("run compositor tests");

    const wayland_tests = b.addTest(.{
        .name = "wayland",
        .root_module = wayland_mod,
    });

    const run_wayland_tests = b.addRunArtifact(wayland_tests);
    run_wayland_tests.setName("run wayland tests");

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);
    test_step.dependOn(&run_wayland_tests.step);
}
