const std = @import("std");

pub fn resolveIPv4(name: []const u8) !std.net.Ip4Address {
    if (std.net.Address.parseIp4(name, 0)) |addr| {
        return addr.in;
    } else |_| {}

    var list = try std.net.getAddressList(std.heap.page_allocator, name, 0);
    defer list.deinit();

    for (list.addrs) |addr| {
        if (addr.any.family == std.posix.AF.INET) {
            return addr.in;
        }
    }
    return error.NoIPv4AddressFound;
}