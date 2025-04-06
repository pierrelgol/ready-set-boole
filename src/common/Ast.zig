const std = @import("std");
const mem = std.mem;
const heap = std.heap;
const Token = @import("Token.zig").Token;
const TokenKind = @import("Token.zig").Kind;
const AstNode = @import("AstNode.zig").AstNode;
const AstNodeKind = @import("AstNode.zig").AstNode.Kind;

pub const Ast = struct {
    node_pool: heap.MemoryPool(AstNode),
    root: ?*AstNode,

    pub const Error = error{} || mem.Allocator.Error;

    pub fn init(gpa: mem.Allocator, capacity: usize) Error!Ast {
        const pool = try heap.MemoryPool(AstNode).initPreheated(gpa, capacity);
        return .{
            .node_pool = pool,
            .root = null,
        };
    }

    pub fn deinit(self: *Ast) void {
        self.node_pool.deinit();
    }

    pub fn makeNode(self: *Ast) Error!*AstNode {
        return try self.node_pool.create();
    }

    fn printNode(
        fba: mem.Allocator,
        writer: anytype,
        node: *const AstNode,
        prefix: []const u8,
        is_last: bool,
        is_root: bool,
    ) !void {
        if (is_root) {
            try std.fmt.format(writer, "{s}{}\n", .{ prefix, node });
        } else {
            const connector = if (is_last) "└──" else "├──";
            try std.fmt.format(writer, "{s}{s}{}\n", .{ prefix, connector, node });
        }

        var new_prefix: []const u8 = "";
        const prefix_addition = if (is_last) "   " else "│  ";

        if (!is_root) {
            new_prefix = try std.mem.concat(fba, u8, &.{ prefix, prefix_addition });
        } else {
            new_prefix = try std.mem.concat(fba, u8, &.{ prefix, "" });
        }

        const next_segment = if (is_root) "" else (if (is_last) "   " else "│  ");

        const children_prefix = try std.mem.concat(fba, u8, &.{ prefix, next_segment });

        var children_list: [2]?*const AstNode = [_]?*const AstNode{ null, null };
        var children_count: usize = 0;
        if (node.lhs) |left| {
            children_list[children_count] = left;
            children_count += 1;
        }
        if (node.rhs) |right| {
            children_list[children_count] = right;
            children_count += 1;
        }

        for (children_list[0..children_count], 0..) |maybe_child, idx| {
            if (maybe_child) |child| {
                const is_last_child = (idx == children_count - 1);

                try printNode(fba, writer, child, children_prefix, is_last_child, false);
            }
        }
    }

    pub fn format(
        self: @This(),
        comptime fmt_spec: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt_spec;
        _ = options;

        var buffer: [std.heap.pageSize()]u8 = undefined;
        var fba_instance = std.heap.FixedBufferAllocator.init(&buffer);
        const fba = fba_instance.allocator();

        if (self.root) |root_node| {
            try printNode(fba, writer, root_node, "", true, true);
        } else {
            try writer.print("(empty)\n", .{});
        }
    }
};
