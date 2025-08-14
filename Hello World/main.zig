const std = @import("std");
const time = @import("std").time;
const cTime = @cImport({
    @cInclude("time.h");
});

pub fn main() !void {
    std.debug.print("Hello World!\n", .{});

    const timeStamp = std.time.timestamp();
    var cTimeStamp: cTime.time_t =(@intCast(timeStamp));
    var tm_result: cTime.struct_tm = undefined;
    if (cTime.localtime_r(&cTimeStamp, &tm_result) == null)
        return error.TimeConversionFailed;
    std.debug.print("UTC Date and Time: {d}/{d}/{d} {d}:{d}:{d}\n", .{
        tm_result.tm_mday,
        tm_result.tm_mon + 1,
        tm_result.tm_year + 1900,
        tm_result.tm_hour,
        tm_result.tm_min,
        tm_result.tm_sec,
    });
}