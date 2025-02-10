const std = @import("std");
const testing = std.testing;
const Node = @import("../src/ast/node.zig").Node;

test "node creation" {
    const allocator = testing.allocator;

    var root = try Node.init(allocator, .root);
    defer root.deinit();

    try testing.expectEqual(root.node_type, .root);
    try testing.expect(root.children == null);
    try testing.expect(root.content == null);
}

test "node append child" {
    const allocator = testing.allocator;

    var root = try Node.init(allocator, .root);
    defer root.deinit();

    var text = try Node.init(allocator, .text);
    text.content = try allocator.dupe(u8, "Hello");
    try root.appendChild(text);

    try testing.expectEqual(root.children.?.items.len, 1);
    try testing.expectEqual(root.children.?.items[0].node_type, .text);
    try testing.expectEqualStrings(root.children.?.items[0].content.?, "Hello");
}
