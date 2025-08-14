const std = @import("std");
const resolver = @import("resolver.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    const name = "hurrdurr.com";

    const bytes = try resolver.resolveIPv4(name);
    try stdout.print("Resolved {s} → IPv4: {}.{}.{}.{}\n",
        .{ name, bytes[0], bytes[1], bytes[2], bytes[3] });
}
