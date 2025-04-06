const std = @import("std");
const mem = std.mem;
const heap = std.heap;
const Linenoise = @import("linenoise").Linenoise;

pub const Repl = struct {
    allocator: mem.Allocator,
    prompt: []const u8,
    ln: Linenoise,

    pub fn init(allocator: mem.Allocator, prompt: []const u8) Repl {
        return .{
            .allocator = allocator,
            .prompt = prompt,
            .ln = Linenoise.init(allocator),
        };
    }

    pub fn deinit(self: *Repl) void {
        self.ln.deinit();
    }

    pub fn println(_: *Repl, comptime fmt: []const u8, args: anytype) !void {
        const stdio = std.io.getStdOut().writer();
        try stdio.print(fmt ++ "\n", args);
    }

    pub fn print(_: *Repl, comptime fmt: []const u8, args: anytype) !void {
        const stdio = std.io.getStdOut().writer();
        try stdio.print(fmt, args);
    }

    pub fn clearScreen(_: *Repl) !void {
        const stdout = std.io.getStdErr();
        try stdout.writeAll("\x1b[H\x1b[2J");
    }

    pub fn readline(self: *Repl, prompt: ?[]const u8) !?[]const u8 {
        return try self.ln.linenoise(if (prompt) |some| some else self.prompt);
    }

    pub fn freeline(self: *Repl, line: ?[]const u8) void {
        self.allocator.free(line orelse return);
    }

    pub fn addHistory(self: *Repl, line: []const u8) !void {
        try self.ln.history.add(line);
    }

    pub fn popHistory(self: *Repl) void {
        self.ln.history.pop();
    }
};
