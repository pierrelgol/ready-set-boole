const std = @import("std");
const meta = std.meta;

pub const Token = union(Kind) {
    value: Kind.Value,
    operator: Kind.Operator,
    variable: Kind.Variable,

    pub const Error = error{} || Kind.Error;

    pub fn init(kind: Kind, item: u8) Kind.Error!Token {
        return switch (kind) {
            .value => .{
                .value = try Kind.Value.valueFromU8(item),
            },
            .operator => .{
                .operator = try Kind.Operator.operatorFromU8(item),
            },
            .variable => .{
                .variable = try Kind.Variable.variableFromU8(item),
            },
        };
    }

    pub fn isOperator(self: *const Token) bool {
        return self.tag() == .operator;
    }

    pub fn isValue(self: *const Token) bool {
        return self.tag() == .value;
    }

    pub fn isVariable(self: *const Token) bool {
        return self.tag() == .variable;
    }

    pub fn tag(self: *const Token) Kind {
        return meta.activeTag(self.*);
    }

    pub fn equal(self: *const Token, token: Token) bool {
        return self.tag() == token.tag();
    }

    pub fn format(
        self: @This(),
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        switch (self) {
            .value => try writer.print("(Value:{c})", .{self.value.u8FromValue()}),
            .operator => try writer.print("(Operator:{c})", .{self.operator.u8FromOperator()}),
            .variable => try writer.print("(Variable:{c})", .{self.variable.u8FromVariable()}),
        }
    }
};

pub const Kind = enum {
    value,
    operator,
    variable,

    pub const Error = error{
        InvalidValueCharacter,
        InvalidOperatorCharacter,
        InvalidVariableCharacter,
    };

    pub const Value = enum {
        true,
        false,

        pub fn valueFromU8(item: u8) Error!Value {
            return switch (item) {
                '0' => Value.false,
                '1' => Value.true,
                else => Error.InvalidValueCharacter,
            };
        }

        pub fn u8FromValue(value: Value) u8 {
            return switch (value) {
                .true => '1',
                .false => '0',
            };
        }
    };

    pub const Operator = enum {
        negation,
        conjunction,
        disjunction,
        exclusive_disjunction,
        material_condition,
        logical_equivalence,

        pub fn operatorFromU8(item: u8) Error!Operator {
            return switch (item) {
                '!' => .negation,
                '&' => .conjunction,
                '|' => .disjunction,
                '^' => .exclusive_disjunction,
                '>' => .material_condition,
                '=' => .logical_equivalence,
                else => Error.InvalidOperatorCharacter,
            };
        }

        pub fn u8FromOperator(operator: Operator) u8 {
            return switch (operator) {
                .negation => '!',
                .conjunction => '&',
                .disjunction => '|',
                .exclusive_disjunction => '^',
                .material_condition => '>',
                .logical_equivalence => '=',
            };
        }
    };

    pub const Variable = enum {
        a,
        b,
        c,
        d,
        e,
        f,
        g,
        h,
        i,
        j,
        k,
        l,
        m,
        n,
        o,
        p,
        q,
        r,
        s,
        t,
        u,
        v,
        w,
        x,
        y,
        z,

        pub fn variableFromU8(item: u8) Error!Variable {
            return switch (item) {
                'A'...'Z' => |v| return map[v - 'A'],
                else => Error.InvalidVariableCharacter,
            };
        }

        pub fn u8FromVariable(variable: Variable) u8 {
            return @tagName(variable)[0] - 32;
        }

        const map = [_]Variable{ .a, .b, .c, .d, .e, .f, .g, .h, .i, .j, .k, .l, .m, .n, .o, .p, .q, .r, .s, .t, .u, .v, .w, .x, .y, .z };
    };
};
