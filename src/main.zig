const std = @import("std");
const Processor = @import("processor.zig").Processor;
const Node = @import("ast/node.zig").Node;

fn debugPlugin(node: *Node) !void {
    std.debug.print("Node type: {}\n", .{node.node_type});
    if (node.content) |content| {
        std.debug.print("Content: {s}\n", .{content});
    }
    if (node.children) |children| {
        for (children.items) |child| {
            try debugPlugin(child);
        }
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var processor = try Processor.init(allocator);
    defer processor.deinit();
    try processor.use(.{
        .name = "debug",
        .transform = debugPlugin,
    });

    const content = "# Hello World\nThis is a test.";
    var root = try processor.process(content);
    defer root.deinit();
}
