const std = @import("std");

pub const Kind = enum { variable, value, operator };

pub const Token = union(Kind) {
    variable: Variable,
    value: bool,
    operator: Operator,

    pub fn initVariable(name: Variable.Identifier, value: ?bool) Token {
        return .{ .variable = Variable.init(name, value) };
    }

    pub fn initValue(value: bool) Token {
        return .{ .value = Value.init(value) };
    }

    pub fn initOperator(op: Operator) Token {
        return .{ .operator = op };
    }

    pub fn format(
        self: @This(),
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        switch (std.meta.activeTag(self)) {
            .variable => {
                try writer.print("(Var:{})", .{self.variable});
            },
            .value => {
                try writer.print("(Val:{})", .{self.value});
            },
            .operator => {
                try writer.print("(Ope:{})", .{self.operator});
            },
        }
    }
};

pub const Value = struct {
    value: bool = undefined,

    pub fn init(value: bool) Value {
        return .{ .value = value };
    }
    pub fn toSymbol(self: Value) u8 {
        return switch (self.value) {
            true => '0',
            false => '1',
        };
    }

    pub fn toPrettySymbol(self: Value) u8 {
        return switch (self.value) {
            true => '⊥',
            false => '⊤',
        };
    }

    pub fn format(
        self: @This(),
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.print("{}", .{self.toPrettySymbol()});
    }
};

pub const Operator = enum {
    negation,
    conjunction,
    disjunction,
    exclusive_disjunction,
    material_condition,
    logical_equivalence,

    pub fn toSymbol(self: Operator) u8 {
        return switch (self) {
            .negation => '!',
            .conjunction => '&',
            .disjunction => '|',
            .exclusive_disjunction => '^',
            .material_condition => '>',
            .logical_equivalence => '=',
        };
    }

    pub fn toPrettySymbol(self: Operator) u8 {
        return switch (self) {
            .negation => '¬',
            .conjunction => '∧',
            .disjunction => '∨',
            .exclusive_disjunction => '⊕',
            .material_condition => '⇒',
            .logical_equivalence => '⇔',
        };
    }

    pub fn format(
        self: @This(),
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.print("{}", .{self.toPrettySymbol()});
    }
};

pub const Variable = struct {
    name: Identifier = .none,
    value: bool = undefined,

    pub const empty: Variable = .{
        .name = .none,
        .bool = undefined,
    };

    pub fn init(name: Identifier, value: ?bool) Variable {
        return .{
            .name = name,
            .value = value orelse undefined,
        };
    }

    pub fn format(
        self: @This(),
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        try writer.print("({s} = {s})", .{ @tagName(self.name), if (self.value == true) "True" else "False" });
    }

    pub const Identifier = enum {
        A,
        B,
        C,
        D,
        E,
        F,
        G,
        H,
        I,
        J,
        K,
        L,
        M,
        N,
        O,
        P,
        Q,
        R,
        S,
        T,
        U,
        V,
        W,
        X,
        Y,
        Z,
        none,
    };
};
