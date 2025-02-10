const std = @import("std");
const testing = std.testing;
const blengine = @import("blengine");

test "node creation" {
    const allocator = testing.allocator;

    var root = try blengine.Node.init(allocator, .ROOT);
    defer root.deinit();

    try testing.expectEqual(root.node_type, .ROOT);
    try testing.expect(root.children == null);
    try testing.expect(root.content == null);
}

test "node append child" {
    const allocator = testing.allocator;

    var root = try blengine.Node.init(allocator, .ROOT);
    defer root.deinit();

    var text = try blengine.Node.init(allocator, .TEXT);
    text.content = try allocator.dupe(u8, "Hello");
    try root.appendChild(text);

    try testing.expectEqual(root.children.?.items.len, 1);
    try testing.expectEqual(root.children.?.items[0].node_type, .TEXT);
    try testing.expectEqualStrings(root.children.?.items[0].content.?, "Hello");
}
