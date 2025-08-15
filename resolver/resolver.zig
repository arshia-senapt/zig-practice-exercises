const std = @import("std");
const builtin = @import("builtin");
const native_os = builtin.os.tag;

pub fn resolveFirstIPv4(allocator: std.mem.Allocator,name: []const u8) !std.net.Address {

    if (std.net.Address.parseIp4(name, 0)) |addr| {
        return addr;
    } else |_| {}

    if (native_os == .macos or native_os == .linux) {
        var list = std.net.getAddressList(allocator, name, 0) catch {
            return error.NoIPv4AddressFound;
        };
        defer list.deinit();

        for (list.addrs) |addr| {
            if (addr.any.family == std.posix.AF.INET) {
                return addr;
            }
        }
    } else if (native_os == .freebsd) {
        return error.OperatingSystemComingSoon;
    } else {
        return error.OperatingSystemNotSupported;
    }
    return error.NoIPv4AddressFound;
}

pub fn resolveAllIPv4(allocator: std.mem.Allocator,name: []const u8) ![]std.net.Address {

    var result = std.ArrayList(std.net.Address).init(allocator);
    errdefer result.deinit();

    if (std.net.Address.parseIp4(name, 0)) |addr| {
        try result.append(addr);
        return result.toOwnedSlice();
    } else |_| {}

    if (native_os == .macos or native_os == .linux) {
        var list = try std.net.getAddressList(allocator, name, 0);
        defer list.deinit();

        for (list.addrs) |addr| {
            if (addr.any.family == std.posix.AF.INET) {
                try result.append(addr);
            }
        }
    } else if (native_os == .freebsd) {
        return error.OperatingSystemNotSupported;
    } else {
        return error.OperatingSystemNotSupported;
    }

    if (result.items.len == 0) {
        return error.NoIPv4AddressFound;
    }
    return result.toOwnedSlice();
}

pub fn resolveFastestIPv4(allocator: std.mem.Allocator, name: []const u8) !std.net.Address {
    const port: u16 = 80;
    var fastest_addr: ?std.net.Address = null;
    var fastest_time: i128 = std.math.maxInt(i128);

    if (std.net.Address.parseIp4(name, port)) |addr| {
        return addr;
    } else |_| {}

    if (native_os == .macos or native_os == .linux) {
        var list = try std.net.getAddressList(allocator, name, port);
        defer list.deinit();

        for (list.addrs) |addr| {
            if (addr.any.family != std.posix.AF.INET) continue;

            const start = std.time.nanoTimestamp();

            var conn = std.net.tcpConnectToAddress(addr) catch {
                continue;
            };
            defer conn.close();

            const elapsed = std.time.nanoTimestamp() - start;

            if (elapsed < fastest_time) {
                fastest_time = elapsed;
                fastest_addr = addr;
            }
        }
    } else {
        return error.OperatingSystemNotSupported;
    }

    if (fastest_addr) |addr| {
        return addr;
    }
    return error.NoIPv4AddressFound;
}

test "resolveFirstIPv4 returns valid address for localhost" {
    const allocator = std.testing.allocator;
    const addr = try resolveFirstIPv4(allocator, "127.0.0.1");
    try std.testing.expect(addr.any.family == std.posix.AF.INET);
    const ip4 = addr.in;
    const bytes = @as(*const [4]u8, @ptrCast(&ip4.sa.addr));
    try std.testing.expectEqual(127, bytes[0]);
}

test "resolveAllIPv4 returns at least one address for localhost" {
    const allocator = std.testing.allocator;
    const addrs = try resolveAllIPv4(allocator, "127.0.0.1");
    defer allocator.free(addrs);
    try std.testing.expect(addrs.len > 0);
    try std.testing.expect(addrs[0].any.family == std.posix.AF.INET);
}

test "resolveFirstIPv4 fails for invalid hostname" {
    const allocator = std.testing.allocator;
    const result = resolveFirstIPv4(allocator, "invalid.invalid");
    try std.testing.expectError(error.NoIPv4AddressFound, result);
}

test "resolveAllIPv4 fails for invalid hostname" {
    const allocator = std.testing.allocator;
    const result = resolveAllIPv4(allocator, "invalid.invalid") catch {
        return;
    };
    _ = result;
    try std.testing.expect(false);
}

test "resolveFastestIPv4 returns an address for localhost TCP port 80" {
    const allocator = std.testing.allocator;
    const addr = try resolveFastestIPv4(allocator, "127.0.0.1");
    try std.testing.expect(addr.any.family == std.posix.AF.INET);
}

test "resolveFastestIPv4 fails for invalid hostname" {
    const allocator = std.testing.allocator;
    const result = resolveFastestIPv4(allocator, "invalid.invalid") catch {
        return;
    };
    _ = result;
    try std.testing.expect(false);
}