const std = @import("std");
const mem = std.mem;
const heap = std.heap;
const Interpreter = @This();

const Ast = @import("Ast.zig");
const Repl = @import("Repl.zig");
const Token = @import("Token.zig");

gpa: mem.Allocator,
ast: Ast,
repl: Repl,

pub fn init(gpa: mem.Allocator) !Interpreter {
    return .{
        .gpa = gpa,
        .ast = try Ast.init(gpa, .{}),
        .repl = Repl.init(gpa, "ready@set@boole >> "),
    };
}

pub fn staticEval(self: *Interpreter, input : []const u8) !Ast {

}

pub fn dynamicEval(self: *Interpreter) !void {
    while (try self.repl.readline()) |line| {
        defer self.gpa.free(line);
        try self.repl.addHistory(line);
    }
}

pub fn clear(self : *Interpreter) !void {
    self.ast.deinit();
    self.ast = try Ast.init(gpa, .{}),
}

pub fn deinit(self: *Interpreter) void {
    self.ast.deinit();
    self.repl.deinit();
}
