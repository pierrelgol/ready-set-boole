const std = @import("std");
const mem = std.mem;
const math = std.math;
const heap = std.heap;
const Allocator = mem.Allocator;

pub fn StackUnmanaged(comptime T: type) type {
    return struct {
        const Self = @This();

        items: []T = &[_]T{},
        capacity: usize = 0,

        pub const Error = error{} || mem.Allocator.Error;

        pub const empty: Self = .{
            .items = &.{},
            .capacity = 0,
        };

        pub fn initCapacity(allocator: Allocator, num: usize) Allocator.Error!Self {
            var self = Self{};
            try self.ensureTotalCapacityPrecise(allocator, num);
            return self;
        }

        pub fn initBuffer(buffer: []T) Self {
            return .{
                .items = buffer[0..0],
                .capacity = buffer.len,
            };
        }

        pub fn deinit(self: *Self, allocator: Allocator) void {
            allocator.free(self.allocatedSlice());
            self.* = undefined;
        }

        pub fn push(self: *Self, allocator: Allocator, item: T) Allocator.Error!void {
            const new_item_ptr = try self.addOne(allocator);
            new_item_ptr.* = item;
        }

        pub fn pop(self: *Self) ?T {
            if (self.items.len == 0) return null;
            const val = self.items[self.items.len - 1];
            self.items.len -= 1;
            return val;
        }

        fn ensureTotalCapacity(self: *Self, gpa: Allocator, new_capacity: usize) Allocator.Error!void {
            if (self.capacity >= new_capacity) return;
            return self.ensureTotalCapacityPrecise(gpa, growCapacity(self.capacity, new_capacity));
        }

        fn ensureTotalCapacityPrecise(self: *Self, allocator: Allocator, new_capacity: usize) Allocator.Error!void {
            if (@sizeOf(T) == 0) {
                self.capacity = math.maxInt(usize);
                return;
            }

            if (self.capacity >= new_capacity) return;

            const old_memory = self.allocatedSlice();
            if (allocator.remap(old_memory, new_capacity)) |new_memory| {
                self.items.ptr = new_memory.ptr;
                self.capacity = new_memory.len;
            } else {
                const new_memory = try allocator.alloc(T, new_capacity);
                @memcpy(new_memory[0..self.items.len], self.items);
                allocator.free(old_memory);
                self.items.ptr = new_memory.ptr;
                self.capacity = new_memory.len;
            }
        }

        fn addOne(self: *Self, allocator: Allocator) Allocator.Error!*T {
            const newlen = self.items.len + 1;
            try self.ensureTotalCapacity(allocator, newlen);
            return self.addOneAssumeCapacity();
        }

        fn addOneAssumeCapacity(self: *Self) *T {
            std.debug.assert(self.items.len < self.capacity);

            self.items.len += 1;
            return &self.items[self.items.len - 1];
        }

        fn allocatedSlice(self: Self) []T {
            return self.items.ptr[0..self.capacity];
        }

        const init_capacity = @as(comptime_int, @max(1, std.atomic.cache_line / @sizeOf(T)));

        fn growCapacity(current: usize, minimum: usize) usize {
            var new = current;
            while (true) {
                new +|= new / 2 + init_capacity;
                if (new >= minimum)
                    return new;
            }
        }
    };
}
