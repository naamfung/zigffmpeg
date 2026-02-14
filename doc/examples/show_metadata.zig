//! libavformat metadata extraction API usage example
//!
//! Show metadata from an input file.

const std = @import("std");

const av = @import("av");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 2) {
        std.debug.print(
            \\usage: {s} <input_file>
            \\example program to demonstrate the use of the libavformat metadata API.
            \\
        , .{args[0]});
        std.process.exit(1);
    }

    const stdout = std.fs.File.stdout().deprecatedWriter();

    const fc = try av.FormatContext.open_input(args[1], null, null, null);
    defer fc.close_input();

    try fc.find_stream_info(null);

    var it: ?*const av.Dictionary.Entry = null;
    while (fc.metadata.iterate(it)) |tag| : (it = tag) {
        try stdout.print("{s}={s}\n", .{ tag.key, tag.value });
    }
}
