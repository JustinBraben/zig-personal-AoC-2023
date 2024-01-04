const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day02.txt");

const ParseErr = error{
    TooManyParts,
    InvalidItem,
};

const Round = struct {
    num_red: u32,
    num_green: u32,
    num_blue: u32,
};

const Game = struct {
    id: u32,
    rounds: ?[]Round,
};

const digit_names = [_][]const u8{ "red", "green", "blue" };

pub fn main() !void {
    print("\n", .{});

    var res: u32 = 0;

    const ideal_set = Round{
        .num_red = 12,
        .num_green = 13,
        .num_blue = 14,
    };

    var lines = splitSeq(u8, data, "\n");

    //print("Possible Game | red, {} | green, {} | blue, {}\n", .{ ideal_set.num_red, ideal_set.num_green, ideal_set.num_blue });

    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        //const g = try makeGame(line);

        //print("Current Game {} | red, {} | green, {} | blue, {} | Possible : {}\n", .{ g.id, g.num_red, g.num_green, g.num_blue, try parseGameBool(line, ideal_set) });
        //print("Game is possible : {}\n", .{try parseGameBool(line, ideal_set)});

        //res += try parseGame(line, ideal_set);
        res += try parseGameRounds(line, ideal_set);
        //res += 1;

        //const game = try makeGame(line);
        //print("{}\n", .{game});
    }

    print("Answer to Part 1 : {}\n", .{res});
}

fn parseGameRounds(line: []const u8, bag: Round) !u32 {
    var g = Game{
        .id = 0,
        .rounds = null,
    };

    var line_tokens = tokenizeSeq(u8, line, ": ");

    const game_str = line_tokens.next() orelse return ParseErr.InvalidItem;
    const sets_str = line_tokens.next() orelse return ParseErr.InvalidItem;
    if (line_tokens.next() != null) return ParseErr.TooManyParts;

    // game_str[5..] gets a slice of the game id, from index 5 of the array to the end
    g.id = try parseInt(u32, game_str[5..], 10);

    var round_tokens = tokenizeSeq(u8, sets_str, "; ");

    while (round_tokens.next()) |round_token| {
        var in_round_tokens = tokenizeSeq(u8, round_token, ", ");

        //print("Rounds : | {s}\n", .{round_token});

        while (in_round_tokens.next()) |in_round_token| {
            var num_cube_tokens = tokenizeSeq(u8, in_round_token, " ");
            const cube_quantity_str = num_cube_tokens.next() orelse return ParseErr.InvalidItem;
            const cube_color_str = num_cube_tokens.next() orelse return ParseErr.InvalidItem;

            if (std.mem.eql(u8, cube_color_str, "red")) {
                const round_quantity = try parseInt(u8, cube_quantity_str[0..], 10);
                if (round_quantity > bag.num_red) {
                    //print("Failed Game {}, needs {} red cubes but only have {}\n", .{ g.id, round_quantity, bag.num_red });
                    return 0;
                }
            }
            if (std.mem.eql(u8, cube_color_str, "green")) {
                const round_quantity = try parseInt(u8, cube_quantity_str[0..], 10);
                if (round_quantity > bag.num_green) {
                    //print("Failed Game {}, needs {} green cubes but only have {}\n", .{ g.id, round_quantity, bag.num_green });
                    return 0;
                }
            }
            if (std.mem.eql(u8, cube_color_str, "blue")) {
                const round_quantity = try parseInt(u8, cube_quantity_str[0..], 10);
                if (round_quantity > bag.num_blue) {
                    //print("Failed Game {}, needs {} blue cubes but only have {}\n", .{ g.id, round_quantity, bag.num_blue });
                    return 0;
                }
            }
        }
    }

    //print("Succesful Game : | {}\n", .{g.id});
    return g.id;
}

fn parseGameBool(line: []const u8, bag: Round) !bool {
    const g = try makeGame(line);

    if (g.num_red < bag.num_red) {
        return false;
    }

    if (g.num_blue < bag.num_blue) {
        return false;
    }

    if (g.num_green < bag.num_green) {
        return false;
    }

    return true;
}

fn parseGame(line: []const u8, bag: Round) !u32 {
    const g = try makeGame(line);

    if (g.num_red < bag.num_red) {
        return 0;
    }

    if (g.num_blue < bag.num_blue) {
        return 0;
    }

    if (g.num_green < bag.num_green) {
        return 0;
    }

    return g.id;
}

fn makeGame(line: []const u8) !Game {
    var g = Game{
        .id = 0,
        .num_red = 0,
        .num_green = 0,
        .num_blue = 0,
    };

    var line_tokens = tokenizeSeq(u8, line, ": ");

    const game_str = line_tokens.next() orelse return ParseErr.InvalidItem;
    const sets_str = line_tokens.next() orelse return ParseErr.InvalidItem;
    if (line_tokens.next() != null) return ParseErr.TooManyParts;

    // game_str[5..] gets a slice of the game id, from index 5 of the array to the end
    g.id = try parseInt(u32, game_str[5..], 10);

    //print("{s}, {s}\n", .{ game_str, sets_str });

    var sets_tokens = tokenizeSeq(u8, sets_str, "; ");

    while (sets_tokens.next()) |set_str| {

        //print("Game : {} | Sets : {s}\n", .{ g.id, set_str });
        var in_set_tokens = tokenizeSeq(u8, set_str, ", ");

        while (in_set_tokens.next()) |in_set_str| {
            //print("Game : {} | Sets : {s}\n", .{ g.id, in_set_str });
            var num_cube_tokens = tokenizeSeq(u8, in_set_str, " ");
            const cube_quantity_str = num_cube_tokens.next() orelse return ParseErr.InvalidItem;
            const cube_color_str = num_cube_tokens.next() orelse return ParseErr.InvalidItem;
            if (num_cube_tokens.next() != null) return ParseErr.TooManyParts;

            if (std.mem.eql(u8, cube_color_str, "red")) {
                g.num_red += try parseInt(u8, cube_quantity_str[0..], 10);
            }
            if (std.mem.eql(u8, cube_color_str, "green")) {
                g.num_green += try parseInt(u8, cube_quantity_str[0..], 10);
            }
            if (std.mem.eql(u8, cube_color_str, "blue")) {
                g.num_blue += try parseInt(u8, cube_quantity_str[0..], 10);
            }
        }
    }

    return g;
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
