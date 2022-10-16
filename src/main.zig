const std = @import("std");

pub const wmb = @import("wmb.zig");

comptime {
    _ = wmb;
}

pub const CoordinateSystem = enum {
    /// identity
    keep,

    /// X=forward, Y=left, Z=up
    gamestudio,

    /// X=right, Y=up, Z=back
    opengl,

    pub fn fromGamestudio(cs: CoordinateSystem, vec: Vector3) Vector3 {
        return switch (cs) {
            .keep => vec,
            .gamestudio => vec,
            .opengl => Vector3{
                .x = -vec.y, // right
                .y = vec.z, // up
                .z = -vec.x, // back
            },
        };
    }
};

pub const Vector3 = extern struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn abs(vec: Vector3) Vector3 {
        return Vector3{
            .x = @fabs(vec.x),
            .y = @fabs(vec.y),
            .z = @fabs(vec.z),
        };
    }

    pub fn format(vec: Vector3, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        try writer.print("({d:.3}, {d:.3}, {d:.3})", .{ vec.x, vec.y, vec.z });
    }
};

pub const Euler = extern struct {
    pan: f32,
    tilt: f32,
    roll: f32,

    pub fn format(vec: Euler, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        try writer.print("({d:3.0}, {d:3.0}, {d:3.0})", .{ vec.pan, vec.tilt, vec.roll });
    }
};

pub const Color = extern struct {
    r: f32,
    g: f32,
    b: f32,
    a: f32 = 1.0,

    pub fn format(vec: Color, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;
        try writer.print("#{X:0>2}{X:0>2}{X:0>2}{X:0>2}", .{
            @floatToInt(u8, std.math.clamp(255.0 * vec.r, 0, 255)),
            @floatToInt(u8, std.math.clamp(255.0 * vec.g, 0, 255)),
            @floatToInt(u8, std.math.clamp(255.0 * vec.b, 0, 255)),
            @floatToInt(u8, std.math.clamp(255.0 * vec.a, 0, 255)),
        });
    }

    pub fn fromVec3(val: Vector3) Color {
        return Color{
            .r = std.math.clamp(val.x / 100.0, 0, 100),
            .g = std.math.clamp(val.y / 100.0, 0, 100),
            .b = std.math.clamp(val.z / 100.0, 0, 100),
        };
    }

    pub fn fromDWORD(val: u32) Color {
        var bytes: [4]u8 = undefined;
        std.mem.writeIntLittle(u32, &bytes, val);

        return Color{
            .r = @intToFloat(f32, bytes[0]) / 255.0,
            .g = @intToFloat(f32, bytes[1]) / 255.0,
            .b = @intToFloat(f32, bytes[2]) / 255.0,
            .a = @intToFloat(f32, bytes[3]) / 255.0,
        };
    }
};

pub fn String(comptime N: comptime_int) type {
    return extern struct {
        const Str = @This();

        chars: [N]u8 = std.mem.zeroes([N]u8),

        pub fn len(str: Str) usize {
            return std.mem.indexOfScalar(u8, &str.chars, 0) orelse N;
        }

        pub fn get(str: *const Str) []const u8 {
            return str.chars[0..str.len()];
        }

        pub fn format(str: Str, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            _ = fmt;
            try std.fmt.formatText(str.get(), "S", options, writer);
        }

        comptime {
            std.debug.assert(@sizeOf(@This()) == N);
        }
    };
}
