const std = @import("std");
const mem = std.mem;
const heap = std.heap;
const testing = std.testing;
const Ast = root.Ast;

const root = @import("../root.zig");

pub const Evaluator = struct {
    interpreter: root.Interpreter,
    ast: ?Ast,

    pub fn init(gpa: mem.Allocator) Evaluator {
        return .{
            .interpreter = root.Interpreter.init(gpa),
            .ast = null,
        };
    }

    pub fn deinit(self: *Evaluator) void {
        self.interpreter.deinit();
    }

    pub fn evalFormula(self: *Evaluator, formula: []const u8) !bool {
        self.ast = try self.interpreter.eval(formula);
        return try self.evalExpression();
    }

    pub fn evalExpression(self: *Evaluator) error{InvalidExpression}!bool {
        if (self.ast) |ast| {
            return try evalNode(ast.root orelse return error.InvalidExpression);
        }
        return error.InvalidExpression;
    }

    fn evalNode(node: *root.AstNode) error{InvalidExpression}!bool {
        return switch (node.getNodeKind()) {
            .leaf => evalLeaf(node),
            .unary => evalUnary(node),
            .binary => evalBinary(node),
        };
    }

    fn evalLeaf(node: *root.AstNode) error{InvalidExpression}!bool {
        const token = node.getToken();
        return switch (token) {
            .value => (token.value == .true),
            .variable => error.InvalidExpression,
            .operator => error.InvalidExpression,
        };
    }

    fn evalUnary(node: *root.AstNode) error{InvalidExpression}!bool {
        const token = node.getToken();
        return switch (token) {
            .value => error.InvalidExpression,
            .variable => error.InvalidExpression,
            .operator => |op| result: {
                switch (op) {
                    .negation => break :result !(try evalNode(node.lhs.?)),
                    else => break :result error.InvalidExpression,
                }
            },
        };
    }

    fn evalBinary(node: *root.AstNode) error{InvalidExpression}!bool {
        const token = node.getToken();
        const lhs = node.lhs orelse return error.InvalidExpression;
        const rhs = node.rhs orelse return error.InvalidExpression;
        return switch (token) {
            .value => error.InvalidExpression,
            .variable => error.InvalidExpression,
            .operator => |op| result: {
                switch (op) {
                    .conjunction => break :result (try evalNode(lhs) and try evalNode(rhs)),
                    .disjunction => break :result (try evalNode(lhs) or try evalNode(rhs)),
                    .exclusive_disjunction => break :result (try evalNode(lhs) != try evalNode(rhs)),
                    .material_condition => break :result ((!try evalNode(lhs)) or try evalNode(rhs)),
                    .logical_equivalence => break :result (try evalNode(lhs) == try evalNode(rhs)),
                    .negation => break :result error.InvalidExpression,
                }
            },
        };
    }
};

test Evaluator {
    const gpa = testing.allocator;

    var interpreter = Evaluator.init(gpa);
    defer interpreter.deinit();

    {
        const input: []const u8 = "01&1|";
        const result = try interpreter.evalFormula(input);
        std.debug.print("Formula : {s}\nEvaluate : {s}\nAst : {?}\n", .{ input, if (result) "True" else "False", interpreter.ast });
    }
    {
        const input: []const u8 = "10&";
        const result = try interpreter.evalFormula(input);
        std.debug.print("Formula : {s}\nEvaluate : {s}\nAst : {?}\n", .{ input, if (result) "True" else "False", interpreter.ast });
    }
    {
        const input: []const u8 = "10|";
        const result = try interpreter.evalFormula(input);
        std.debug.print("Formula : {s}\nEvaluate : {s}\nAst : {?}\n", .{ input, if (result) "True" else "False", interpreter.ast });
    }
    {
        const input: []const u8 = "11>";
        const result = try interpreter.evalFormula(input);
        std.debug.print("Formula : {s}\nEvaluate : {s}\nAst : {?}\n", .{ input, if (result) "True" else "False", interpreter.ast });
    }
    {
        const input: []const u8 = "10=";
        const result = try interpreter.evalFormula(input);
        std.debug.print("Formula : {s}\nEvaluate : {s}\nAst : {?}\n", .{ input, if (result) "True" else "False", interpreter.ast });
    }

    {
        const input: []const u8 = "1011||=";
        const result = try interpreter.evalFormula(input);
        std.debug.print("Formula : {s}\nEvaluate : {s}\nAst : {?}\n", .{ input, if (result) "True" else "False", interpreter.ast });
    }
}

test "fuzz test1" {
    const Context = struct {
        fn testOne(_: @This(), input: []const u8) anyerror!void {
            const gpa = testing.allocator;

            var interpreter = Evaluator.init(gpa);
            defer interpreter.deinit();
            _ = interpreter.evalFormula(input) catch {};
        }
    };

    try std.testing.fuzz(Context{}, Context.testOne, .{
        .corpus = &.{
            "0!0>1000!>=0110>0>&110>1=01&00>|110001110^>000&>|=11011^^110|0=0>0",
            "011111>!000&001>&1>10^0001^101|111>0^&=^1001^0&&!^0!>!1!0>1&00",
            "^1>0100!>0110=01&111>0101^|0110&1=01&110&!&01>^=10&1^>=111=0^==&11",
            "=&0!000!1000110^110>1^1010^0&!!011=10=1|1!=^11&00000!^=0&!0110",
            "010!!010>|>>|1|101^110101^0=11&&00^10!11>!0^|1000^10100=0111100001",
            ">111^0001|0=00&1010=|0000010101&1>|001111||100011!0000^&1^11=0",
            "|0011000|^11!0=00>>00=11!10>&|1101&100=&01=00=|010^=000&1^1!11!|0!",
            "110001100|^101000111100=!>01&|0101110!=01|&^1=1=000110=01001>=",
            "^1&111=0&10|1&0^&011000|=|11010>|>010!11!01100|!100>0001^|0011!11|",
            "110!00011>|000^1^1^00|1!00>1>=1^1||1!=!1!=1=0|0001!0!1=001^&0=",
            ">1|0&00000&|1111!=1&011=|010=!1100^10001011=11^111!^101010^^1010=1",
            "100000&0=&|1!|101!010!1101&1000101!1101^>&010000|!==!&|&0>!110",
            "101>0000&&1111>0|&00>>00100!10&&11&11>1^00010!0&!01^^=0|1000!111!=",
            "|01=|>!!>1|111!0!1011&1!1^1110|0&00>00000^1101101^>10&0|1>=||0",
            "|10=&00^&|0001|010^0111^00000|0!11001=100^001&0000=01&00010010!1!&",
            "0!010|0=>1111001|11!101111!0001110!&|1>&0010110001^=11111^0&=0",
            "^!011>00^11110=0>1^011000=010010>01>01!&&111^0=01!&0&0&0>11101&|10",
            "1111^&110&^=>1!|10!>10&1==11!1&0^1&!^&110|1&!1^!11000>01!!|&10",
        },
    });
}

test "fuzz test2" {
    const Context = struct {
        fn testOne(_: @This(), input: []const u8) anyerror!void {
            const gpa = testing.allocator;

            var interpreter = Evaluator.init(gpa);
            defer interpreter.deinit();
            _ = interpreter.evalFormula(input) catch {};
        }
    };

    try std.testing.fuzz(Context{}, Context.testOne, .{
        .corpus = &.{
            "e8=AM/*@/+qWM5!@wPW9Va`K)$_p`t1k7><UAHe!Ugt7t|0c(E5tS+o?)P8lL@L>a%9^r0$>,QC^^TtO2Q2m8K)Wi2kigH6N0^ONPc/,$+${db&5F|ph^P]*:j}R*P",
            "Mc$9AAz D:=)>|Mq^)f!>BHJ,mHs9&+J20q:C3;*6BvGL:LhJ#yPSlur=C{*`w63FZ-.{Rq0l=N4zbMOPwKf1)R XqXrNu@qNhEsHq zc'oR:#mL#lZ==j!~/T;{.t",
            "a6$aR0X%3rO7rTTD/e';,4nNOa15EPpoEusJ4AYM_@)#g&0F^wP! ^B%1yQ)KpEPJf,szxTFOP*PCA$I<UcKyp{gmy*iecaaoUG$:F+=KaP|8%w[XD0PUe'Fue=e9i",
            "-/:!z3vI#Lua>Tq]3XZHtdOOQ7(PH]Qo: x3FFU8[AqN@^Lg?WQ^eE!SU=H($e+ZANV<w!-a831r>ya*F`oN#?G~^Q|8ko0_xLjs_M*0G5eBi3D`08%4 9np>[7ph0",
        },
    });
}
