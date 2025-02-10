const std = @import("std");
const testing = std.testing;
const blengine = @import("blengine");

test "processor initialization" {
    const allocator = testing.allocator;

    var processor = try blengine.Processor.init(allocator);
    defer processor.deinit();

    try testing.expectEqual(processor.plugins.items.len, 0);
}

test "processor plugin registration" {
    const allocator = testing.allocator;

    var processor = try blengine.Processor.init(allocator);
    defer processor.deinit();

    const test_plugin = struct {
        fn transform(node: *blengine.Node) !void {
            _ = node;
        }
    }.transform;

    try processor.use(.{
        .name = "test",
        .transform = test_plugin,
    });

    try testing.expectEqual(processor.plugins.items.len, 1);
    try testing.expectEqualStrings(processor.plugins.items[0].name, "test");
}
