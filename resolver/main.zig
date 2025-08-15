const std = @import("std");
const resolver = @import("resolver.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const allocator = arena.allocator();

    const name = "hurrdurr.com";

    // const ip = try resolver.resolveFirstIPv4(allocator,name);
    // const ip4 = ip.in;
    // const bytes = @as(*const [4]u8, @ptrCast(&ip4.sa.addr));
    // try stdout.print("Resolved {s} → IPv4: {}.{}.{}.{}\n",
    //     .{ name, bytes[0], bytes[1], bytes[2], bytes[3] });


    // const ips = try resolver.resolveAllIPv4(allocator, name);
    //
    // for (ips) |ip| {
    //     const ip4 = ip.in;
    //     const bytes = @as(*const [4]u8, @ptrCast(&ip4.sa.addr));
    //     try stdout.print("Resolved {s} → IPv4: {}.{}.{}.{}\n",
    //         .{ name, bytes[0], bytes[1], bytes[2], bytes[3] });
    // }



        const ip = try resolver.resolveFastestIPv4(allocator,name);
    const ip4 = ip.in;
    const bytes = @as(*const [4]u8, @ptrCast(&ip4.sa.addr));
    try stdout.print("Resolved {s} → IPv4: {}.{}.{}.{}\n",
        .{ name, bytes[0], bytes[1], bytes[2], bytes[3] });
}
