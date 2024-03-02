const std = @import("std");

const itable = std.ComptimeStringMap([]const u8, .{
    .{ "aaa", &[_]u8{0x37} },
    .{ "aad", &[_]u8{0xd5} },
    .{ "aam", &[_]u8{0xd4} },
    .{ "aas", &[_]u8{0x3f} },
    .{ "adc", &[_]u8{ 0x10, 0x11, 0x12, 0x13, 0x14, 0x15 } },
    .{ "add", &[_]u8{ 0x00, 0x01, 0x02, 0x03, 0x04, 0x05 } },
    .{ "and", &[_]u8{ 0x20, 0x21, 0x22, 0x23, 0x24, 0x25 } },
    .{ "call", &[_]u8{ 0x9a, 0xe8 } },
    .{ "cbw", &[_]u8{0x98} },
    .{ "clc", &[_]u8{0xf8} },
    .{ "cld", &[_]u8{0xfc} },
    .{ "cli", &[_]u8{0xfa} },
    .{ "cmc", &[_]u8{0xf5} },
    .{ "cmp", &[_]u8{ 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d } },
    .{ "cmpsb", &[_]u8{0xa6} },
    .{ "cmpsw", &[_]u8{0xa7} },
    .{ "cwd", &[_]u8{0x99} },
    .{ "daa", &[_]u8{0x27} },
    .{ "das", &[_]u8{0x2f} },
    .{ "dec", &[_]u8{ 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f } },
    .{ "div", &[_]u8{0xf7} },
    .{ "esc", &[_]u8{ 0xd8, 0xd9, 0xda, 0xdb, 0xdc, 0xde, 0xdf } },
    .{ "hlt", &[_]u8{0xf4} },
    .{ "idiv", &[_]u8{0xf6} },
    .{ "imul", &[_]u8{0x69} },
    .{ "in", &[_]u8{ 0xe4, 0xe5, 0xec, 0xed } },
    .{ "inc", &[_]u8{ 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47 } },
    .{ "int", &[_]u8{ 0xcc, 0xcd } },
    .{ "into", &[_]u8{0xce} },
    .{ "iret", &[_]u8{0xcf} },
    .{ "jcc", &[_]u8{ 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7f } },
    .{ "jcxz", &[_]u8{0xe3} },
    .{ "jmp", &[_]u8{ 0xe9, 0xea, 0xeb } },
    .{ "lahf", &[_]u8{0x9f} },
    .{ "lds", &[_]u8{0xc5} },
    .{ "lea", &[_]u8{0x8d} },
    .{ "les", &[_]u8{0xc4} },
    .{ "lock", &[_]u8{0xf0} },
    .{ "lodsb", &[_]u8{0xac} },
    .{ "lodsw", &[_]u8{0xad} },
    .{ "loop", &[_]u8{ 0xe0, 0xe1, 0xe2 } },
    .{ "mov", &[_]u8{ 0xa0, 0xa1, 0xa2, 0xa3 } },
    .{ "movsb", &[_]u8{0xa4} },
    .{ "movsw", &[_]u8{0xa5} },
    .{ "mul", &[_]u8{0xf7} },
    .{ "neg", &[_]u8{0xf6} },
    .{ "nop", &[_]u8{0x90} },
    .{ "or", &[_]u8{ 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d } },
    .{ "out", &[_]u8{ 0xe6, 0xe7, 0xee, 0xef } },
    .{ "pop", &[_]u8{ 0x07, 0x0f, 0x17, 0x1f } },
    .{ "popf", &[_]u8{0x9d} },
    .{ "push", &[_]u8{ 0x06, 0x0e, 0x16, 0x1e, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x68, 0x6a } },
    .{ "pushf", &[_]u8{0x9c} },
    .{ "repxx", &[_]u8{ 0xf2, 0xf3 } },
    .{ "retn", &[_]u8{ 0xc2, 0xc3 } },
    .{ "retf", &[_]u8{ 0xca, 0xcb } },
    .{ "sahf", &[_]u8{0x9e} },
    .{ "scasb", &[_]u8{0xae} },
    .{ "scasw", &[_]u8{0xaf} },
    .{ "sub", &[_]u8{ 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d } },
    .{ "wait", &[_]u8{0x9b} },
    .{ "xor", &[_]u8{ 0x30, 0x31, 0x32, 0x33, 0x34, 0x35 } },
});

pub fn main() !void {
    var ally = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = ally.deinit();
    const gpa = ally.allocator();

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var args = try std.process.argsWithAllocator(gpa);
    defer args.deinit();

    if (!args.skip()) {
        try stdout.writeAll("error: no input\n");
        return;
    }
    try stdout.writeAll("Parsing the file...\n");

    const file_path = args.next().?;
    var f = try std.fs.cwd().openFile(file_path, .{});
    defer f.close();
    const stat = try f.stat();

    var raw_instset = std.ArrayList(u8).init(gpa);
    var instset = std.ArrayList([]const u8).init(gpa);
    var argset = std.ArrayList(u8).init(gpa);

    defer raw_instset.deinit();
    defer instset.deinit();
    defer argset.deinit();

    for (0..stat.size) |_| {
        const char = try f.reader().readByte();

        for (itable.kvs) |kv| {
            for (kv.value) |v| {
                if (char == v) {
                    try instset.append(kv.key);
                    try raw_instset.append(char);
                    try argset.append(0);
                } else {
                    try argset.append(char);
                }
            }
        }
    }

    for (instset.items, 0..) |inst, i| {
        try stdout.print("{d} (0x{X}) {s}", .{ i, raw_instset.items[i], inst });
        if (argset.items[i] == 0) {
            try stdout.writeByte('\n');
        } else {
            try stdout.print(" 0x{X}\n", .{argset.items[i]});
        }
    }
    try bw.flush();
}
