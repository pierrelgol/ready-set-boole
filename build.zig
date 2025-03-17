const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    {
        const run_step_00 = b.step("run00", "Run the app");
        const test_step_00 = b.step("test00", "Run unit tests");

        const ex00 = b.dependency("ex00", .{
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(ex00.artifact("ex00"));

        const run_cmd_00 = b.addRunArtifact(ex00.artifact("ex00"));
        run_cmd_00.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd_00.addArgs(args);
        }
        run_step_00.dependOn(&run_cmd_00.step);

        const exe_unit_tests_00 = b.addTest(.{
            .root_module = ex00.module("ex00"),
        });

        const run_exe_unit_tests_00 = b.addRunArtifact(exe_unit_tests_00);
        test_step_00.dependOn(&run_exe_unit_tests_00.step);
    }

    {
        const run_step_01 = b.step("run01", "Run the app");
        const test_step_01 = b.step("test01", "Run unit tests");

        const ex01 = b.dependency("ex01", .{
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(ex01.artifact("ex01"));

        const run_cmd_01 = b.addRunArtifact(ex01.artifact("ex01"));
        run_cmd_01.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd_01.addArgs(args);
        }
        run_step_01.dependOn(&run_cmd_01.step);

        const exe_unit_tests_01 = b.addTest(.{
            .root_module = ex01.module("ex01"),
        });

        const run_exe_unit_tests_01 = b.addRunArtifact(exe_unit_tests_01);
        test_step_01.dependOn(&run_exe_unit_tests_01.step);
    }
    {
        const run_step_02 = b.step("run02", "Run the app");
        const test_step_02 = b.step("test02", "Run unit tests");

        const ex02 = b.dependency("ex02", .{
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(ex02.artifact("ex02"));

        const run_cmd_02 = b.addRunArtifact(ex02.artifact("ex02"));
        run_cmd_02.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd_02.addArgs(args);
        }
        run_step_02.dependOn(&run_cmd_02.step);

        const exe_unit_tests_02 = b.addTest(.{
            .root_module = ex02.module("ex02"),
        });

        const run_exe_unit_tests_02 = b.addRunArtifact(exe_unit_tests_02);
        test_step_02.dependOn(&run_exe_unit_tests_02.step);
    }
    {
        const run_step_03 = b.step("run03", "Run the app");
        const test_step_03 = b.step("test03", "Run unit tests");

        const ex03 = b.dependency("ex03", .{
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(ex03.artifact("ex03"));

        const run_cmd_03 = b.addRunArtifact(ex03.artifact("ex03"));
        run_cmd_03.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd_03.addArgs(args);
        }
        run_step_03.dependOn(&run_cmd_03.step);

        const exe_unit_tests_03 = b.addTest(.{
            .root_module = ex03.module("ex03"),
        });

        const run_exe_unit_tests_03 = b.addRunArtifact(exe_unit_tests_03);
        test_step_03.dependOn(&run_exe_unit_tests_03.step);
    }
    {
        const run_step_04 = b.step("run04", "Run the app");
        const test_step_04 = b.step("test04", "Run unit tests");

        const ex04 = b.dependency("ex04", .{
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(ex04.artifact("ex04"));

        const run_cmd_04 = b.addRunArtifact(ex04.artifact("ex04"));
        run_cmd_04.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd_04.addArgs(args);
        }
        run_step_04.dependOn(&run_cmd_04.step);

        const exe_unit_tests_04 = b.addTest(.{
            .root_module = ex04.module("ex04"),
        });

        const run_exe_unit_tests_04 = b.addRunArtifact(exe_unit_tests_04);
        test_step_04.dependOn(&run_exe_unit_tests_04.step);
    }
    {
        const run_step_05 = b.step("run05", "Run the app");
        const test_step_05 = b.step("test05", "Run unit tests");

        const ex05 = b.dependency("ex05", .{
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(ex05.artifact("ex05"));

        const run_cmd_05 = b.addRunArtifact(ex05.artifact("ex05"));
        run_cmd_05.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd_05.addArgs(args);
        }
        run_step_05.dependOn(&run_cmd_05.step);

        const exe_unit_tests_05 = b.addTest(.{
            .root_module = ex05.module("ex05"),
        });

        const run_exe_unit_tests_05 = b.addRunArtifact(exe_unit_tests_05);
        test_step_05.dependOn(&run_exe_unit_tests_05.step);
    }
    {
        const run_step_06 = b.step("run06", "Run the app");
        const test_step_06 = b.step("test06", "Run unit tests");

        const ex06 = b.dependency("ex06", .{
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(ex06.artifact("ex06"));

        const run_cmd_06 = b.addRunArtifact(ex06.artifact("ex06"));
        run_cmd_06.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd_06.addArgs(args);
        }
        run_step_06.dependOn(&run_cmd_06.step);

        const exe_unit_tests_06 = b.addTest(.{
            .root_module = ex06.module("ex06"),
        });

        const run_exe_unit_tests_06 = b.addRunArtifact(exe_unit_tests_06);
        test_step_06.dependOn(&run_exe_unit_tests_06.step);
    }
    {
        const run_step_07 = b.step("run07", "Run the app");
        const test_step_07 = b.step("test07", "Run unit tests");

        const ex07 = b.dependency("ex07", .{
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(ex07.artifact("ex07"));

        const run_cmd_07 = b.addRunArtifact(ex07.artifact("ex07"));
        run_cmd_07.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd_07.addArgs(args);
        }
        run_step_07.dependOn(&run_cmd_07.step);

        const exe_unit_tests_07 = b.addTest(.{
            .root_module = ex07.module("ex07"),
        });

        const run_exe_unit_tests_07 = b.addRunArtifact(exe_unit_tests_07);
        test_step_07.dependOn(&run_exe_unit_tests_07.step);
    }
    {
        const run_step_08 = b.step("run08", "Run the app");
        const test_step_08 = b.step("test08", "Run unit tests");

        const ex08 = b.dependency("ex08", .{
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(ex08.artifact("ex08"));

        const run_cmd_08 = b.addRunArtifact(ex08.artifact("ex08"));
        run_cmd_08.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd_08.addArgs(args);
        }
        run_step_08.dependOn(&run_cmd_08.step);

        const exe_unit_tests_08 = b.addTest(.{
            .root_module = ex08.module("ex08"),
        });

        const run_exe_unit_tests_08 = b.addRunArtifact(exe_unit_tests_08);
        test_step_08.dependOn(&run_exe_unit_tests_08.step);
    }
    {
        const run_step_09 = b.step("run09", "Run the app");
        const test_step_09 = b.step("test09", "Run unit tests");

        const ex09 = b.dependency("ex09", .{
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(ex09.artifact("ex09"));

        const run_cmd_09 = b.addRunArtifact(ex09.artifact("ex09"));
        run_cmd_09.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd_09.addArgs(args);
        }
        run_step_09.dependOn(&run_cmd_09.step);

        const exe_unit_tests_09 = b.addTest(.{
            .root_module = ex09.module("ex09"),
        });

        const run_exe_unit_tests_09 = b.addRunArtifact(exe_unit_tests_09);
        test_step_09.dependOn(&run_exe_unit_tests_09.step);
    }
    {
        const run_step_10 = b.step("run10", "Run the app");
        const test_step_10 = b.step("test10", "Run unit tests");

        const ex10 = b.dependency("ex10", .{
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(ex10.artifact("ex10"));

        const run_cmd_10 = b.addRunArtifact(ex10.artifact("ex10"));
        run_cmd_10.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd_10.addArgs(args);
        }
        run_step_10.dependOn(&run_cmd_10.step);

        const exe_unit_tests_10 = b.addTest(.{
            .root_module = ex10.module("ex10"),
        });

        const run_exe_unit_tests_10 = b.addRunArtifact(exe_unit_tests_10);
        test_step_10.dependOn(&run_exe_unit_tests_10.step);
    }
    {
        const run_step_11 = b.step("run11", "Run the app");
        const test_step_11 = b.step("test11", "Run unit tests");

        const ex11 = b.dependency("ex11", .{
            .target = target,
            .optimize = optimize,
        });
        b.installArtifact(ex11.artifact("ex11"));

        const run_cmd_11 = b.addRunArtifact(ex11.artifact("ex11"));
        run_cmd_11.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd_11.addArgs(args);
        }
        run_step_11.dependOn(&run_cmd_11.step);

        const exe_unit_tests_11 = b.addTest(.{
            .root_module = ex11.module("ex11"),
        });

        const run_exe_unit_tests_11 = b.addRunArtifact(exe_unit_tests_11);
        test_step_11.dependOn(&run_exe_unit_tests_11.step);
    }
}
