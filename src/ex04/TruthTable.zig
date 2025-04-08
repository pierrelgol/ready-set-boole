const std = @import("std");
const mem = std.mem;
const EnumMap = std.EnumMap;
const EnumSet = std.EnumSet;
const ArrayList = std.ArrayListUnmanaged;
const PermutationsSet = std.AutoArrayHashMapUnmanaged;

const root = @import("../root.zig");
const Token = root.Token;
const TokenKind = root.TokenKind;
const Lexer = root.Lexer;
const Parser = root.Parser;
const Ast = root.Ast;
const AstNode = root.AstNode;
const AstNodeKind = root.AstNode.Kind;
const Variable = TokenKind.Variable;
const AstEvaluator = root.AstEvaluator;
const Interpreter = root.Interpreter;

pub const Permutation = EnumMap(Variable, bool);
pub const TruthTable = struct {
    gpa: mem.Allocator,
    interpreter: Interpreter,
    variables: EnumSet(Variable),
    permutations: PermutationsSet(Permutation, void),

    pub fn init(gpa: mem.Allocator) TruthTable {
        return .{
            .gpa = gpa,
            .interpreter = Interpreter.init(gpa),
            .variables = EnumSet(Variable).initEmpty(),
            .permutations = PermutationsSet(Permutation, void).empty,
        };
    }

    pub fn deinit(self: *TruthTable) void {
        self.interpreter.deinit();
        self.permutations.deinit(self.gpa);
    }

    pub fn findAllVariables(self: *TruthTable, formula: []const u8) void {
        // first we need to find all the different unique instance of variables;
        for (formula) |token| {
            const variable = Variable.variableFromU8(token) catch continue;
            self.variables.setPresent(variable, true);
        }
    }

    pub fn isUniquePermutation(self: *TruthTable, permutation: *Permutation) bool {
        return (self.permutations.getEntry(permutation.*)) != null;
    }

    pub fn createUniquePermutation(self: *TruthTable) !void {
        const total_of_unique_variable: usize = self.variables.count();
        const total_of_unique_permutations = std.math.pow(usize, 2, total_of_unique_variable);

        for (0..total_of_unique_permutations) |i| {
            var permutation = Permutation.initFull(false);
            var var_index: usize = 0;
            var it = self.variables.iterator();
            while (it.next()) |variable| {
                const is_true: bool = (i >> @truncate(var_index)) & 1 == 1;
                permutation.put(variable, is_true);
                var_index += 1;
            }
            try self.permutations.putNoClobber(self.gpa, permutation, {});
        }
    }

    pub fn computeTruthThable(self: *TruthTable, formula: []const u8) !void {
        const ast_or_error = self.interpreter.eval(formula);
        if (ast_or_error) |ast| {
            self.findAllVariables(formula);
            try self.createUniquePermutation();
            const ast_root = ast.root orelse return;
            var it = self.permutations.iterator();
            while (it.next()) |permutation_entry| {
                const permutation = permutation_entry.key_ptr.*;
                var evaluator = AstEvaluator.init(ast_root, permutation);
                const evaluation_or_error = evaluator.eval() catch continue;
                std.debug.print("{s}\n", .{if (evaluation_or_error) "True" else "False"});
            }
        } else |err| {
            std.debug.print("error : {!}\n", .{err});
        }
    }
};

test TruthTable {
    const gpa = std.testing.allocator;

    var truth_table: TruthTable = .init(gpa);
    defer truth_table.deinit();

    try truth_table.computeTruthThable("AB&");
}
