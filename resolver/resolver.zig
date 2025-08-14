const std = @import("std");

fn ipv4ToString(addr: std.net.Address) *const [4]u8{
    const ipv4 = addr.in;
    const bytes = @as(*const [4]u8, @ptrCast(&ipv4.sa.addr));
    return bytes;
}

pub fn resolveIPv4(name: []const u8) !*const [4]u8 {
    if (std.net.Address.parseIp4(name, 0)) |addr| {
        const ip4 = addr.in;
        const bytes = @as(*const [4]u8, @ptrCast(&ip4.sa.addr));
        return bytes;
    } else |_| {}

    var list = try std.net.getAddressList(std.heap.page_allocator, name, 0);
    defer list.deinit();

    for (list.addrs) |addr| {
        if (addr.any.family == std.posix.AF.INET) {
            const ip4 = addr.in;
            const bytes = @as(*const [4]u8, @ptrCast(&ip4.sa.addr));
            return bytes;
        }
    }
    return error.NoIPv4AddressFound;
}