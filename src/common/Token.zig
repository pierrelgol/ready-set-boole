const std = @import("std");

pub const Kind = enum { variable, value, operator };

pub const Token = union(Kind) {
    variable: Variable,
    value: Value,
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
            true => '1',
            false => '0',
        };
    }

    pub fn toPrettySymbol(self: Value) u16 {
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
        try writer.print("{c}", .{self.toSymbol()});
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

    pub fn toPrettySymbol(self: Operator) u16 {
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
        try writer.print("{c}", .{self.toSymbol()});
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

    pub const Identifier = enum(u8) {
        A = 'A',
        B = 'B',
        C = 'C',
        D = 'D',
        E = 'E',
        F = 'F',
        G = 'G',
        H = 'H',
        I = 'I',
        J = 'J',
        K = 'K',
        L = 'L',
        M = 'M',
        N = 'N',
        O = 'O',
        P = 'P',
        Q = 'Q',
        R = 'R',
        S = 'S',
        T = 'T',
        U = 'U',
        V = 'V',
        W = 'W',
        X = 'X',
        Y = 'Y',
        Z = 'Z',
        none = '?',
    };
};
