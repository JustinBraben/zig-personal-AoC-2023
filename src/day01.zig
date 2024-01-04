const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day01.txt");

pub fn main() !void {
    print("\n", .{});

    var lines = splitSeq(u8, data, "\n");

    var answer1: u32 = 0;
    var answer2: u32 = 0;

    while (lines.next()) |line| {
        print("{s}\n", .{line});
        answer1 += parseLinePart1(line);
        answer2 += parseLinePart2(line);
    }

    print("Answer to part 1 : {}\n", .{answer1});
    print("Answer to part 2 : {}\n", .{answer2});
}

fn parseLinePart1(line: []const u8) u32 {
    var res: u32 = 0;
    var prevDigit: u8 = '0';
    var firstFound: bool = false;

    for (line) |c| {
        if (std.ascii.isDigit(c)) {
            prevDigit = c;

            if (!firstFound) {
                res += 10 * (c - '0');
                firstFound = true;
            }

            //print("{c}, ", .{c});
        }
    }

    res += prevDigit - '0';

    print("\n", .{});

    return res;
}

fn parseLinePart2(line: []const u8) u32 {
    var res: u32 = 0;
    var first: ?u8 = null;
    var last: ?u8 = null;

    var indexLine: usize = 0;

    const digit_names = [_][]const u8{ "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

    while (indexLine < line.len) : (indexLine += 1) {
        const curChar: u8 = line[indexLine];
        if (std.ascii.isDigit(curChar)) {
            last = curChar - '0';
            first = first orelse last;
            continue;
        }

        for (digit_names, 0..) |name, indexDigitNames| {
            if (std.mem.startsWith(u8, line[indexLine..], name)) {
                last = @as(u8, @intCast(indexDigitNames));
                first = first orelse last;
                break;
            }
        }
    }

    res = 10 * (first orelse 0) + (last orelse 0);

    return res;
}

// Useful stdlib functions
const tokenizeAny = std.mem.tokenizeAny;
const tokenizeSeq = std.mem.tokenizeSequence;
const tokenizeSca = std.mem.tokenizeScalar;
const splitAny = std.mem.splitAny;
const splitSeq = std.mem.splitSequence;
const splitSca = std.mem.splitScalar;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
