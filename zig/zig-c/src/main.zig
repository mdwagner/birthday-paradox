const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("time.h");
    @cInclude("stdlib.h");
    @cInclude("stdbool.h");
    @cInclude("sys/time.h");
    @cDefine("sampleSize", "23");
});

pub export fn main(arg_argc: c_int, arg_argv: [*c][*c]u8) c_int {
    var argc = arg_argc;
    var argv = arg_argv;
    var iterations: c_int = c.atoi(argv[@intCast(c_int, @as(c_int, 1))]);
    simulate(iterations);
    return 0;
}

export fn simulate(arg_iterations: c_int) void {
    var iterations = arg_iterations;
    var start: struct_timeval = undefined;
    var end: struct_timeval = undefined;
    _ = gettimeofday(&start, (@intToPtr(?*c_void, @as(c_int, 0))));
    srand(@bitCast(c_uint, @truncate(c_int, start.tv_usec)));
    var duplicates: c_int = 0;
    {
        var x: c_int = 0;
        while (x < iterations) : (x += 1) {
            var data: [365]c_int = [1]c_int{0} ** 365;
            {
                var i: c_int = 0;
                while (i < @as(c_int, 23)) : (i += 1) {
                    var number: c_int = @floatToInt(c_int, ((@intToFloat(f32, rand()) / @intToFloat(f32, @as(c_int, 2147483647))) * @intToFloat(f32, @as(c_int, 365))));
                    if (data[@intCast(c_uint, number)] == @as(c_int, 1)) {
                        duplicates += 1;
                        break;
                    } else {
                        data[@intCast(c_uint, number)] = 1;
                    }
                }
            }
        }
    }
    _ = c.printf("iterations: %d\n", iterations);
    _ = c.printf("sample-size: %d\n", @as(c_int, 23));
    var results: f64 = ((@intToFloat(f64, duplicates) * 100) / @intToFloat(f64, iterations));
    _ = c.printf("percent: %0.2f\n", results);
    _ = gettimeofday(&end, (@intToPtr(?*c_void, @as(c_int, 0))));
    var start_time: f64 = (@intToFloat(f64, start.tv_sec) + (@intToFloat(f64, start.tv_usec) / 1000000));
    var end_time: f64 = (@intToFloat(f64, end.tv_sec) + (@intToFloat(f64, end.tv_usec) / 1000000));
    var diff: f32 = @floatCast(f32, (end_time - start_time));
}

const struct_timeval = extern struct {
    tv_sec: c_long,
    tv_usec: c_long,
};
extern fn gettimeofday(noalias __tv: [*c]struct_timeval, noalias __tz: ?*c_void) c_int;
extern fn rand() c_int;
extern fn srand(__seed: c_uint) void;
