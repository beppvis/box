const std = @import("std");
const scanner = @import("lib/scanner.zig");
const Scanner = scanner.Scanner;

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    var dba = std.heap.DebugAllocator(.{}){};
    defer _ = dba.deinit();
    const allocator = dba.allocator();
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    try processArgs(allocator, args);
}
pub fn run(allocator:std.mem.Allocator,code: []const u8) !void{
    var scn = try Scanner.init(allocator,code);
    defer scn.deinit(allocator);
    try scn.scanTokens();
    for (scn.tokens.items) |token| {
        std.debug.print("{any}\n", .{token});
        if (token.literal) |_|{
            const literalString = try token.literalToString(allocator);
            defer allocator.free(literalString);
            std.debug.print("Literal Value {s}\n", .{literalString});
        }
    }
}

pub fn runFile(allocator: std.mem.Allocator, fileName: [:0]u8) !void{
    const content = try std.fs.cwd().readFileAlloc(allocator,fileName,std.math.maxInt(u64));
    errdefer allocator.free(content);
    try run(allocator,content);
}
// WARN: Buffer size is set to 1024 
pub fn interpreterMode(allocator:std.mem.Allocator) !void {
    var stdin = std.fs.File.stdin();
    var stdout= std.fs.File.stdout();
    const buffer = try allocator.alloc(u8,1024);
    defer allocator.free(buffer);
    var reader = stdin.reader(buffer);
    while (true) {
        _ = try stdout.write(">>");
        const contents = try reader.interface.takeDelimiter('\n');
        if (contents) |value|{
            try run(allocator,std.mem.trim(u8, value,"\r"));
        }
        else{
            break;
        }
    }
}

pub fn processArgs(allocator:std.mem.Allocator,args: [][:0]u8) !void {
    if (args.len > 2) {
        std.debug.print("Usage : box [fileName]", .{});
        return;
    }
    if (args.len == 2) {
        try runFile(allocator,args[1]);
    } else {
        try interpreterMode(allocator);
    }
    return;
}
