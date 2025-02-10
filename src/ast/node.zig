const std = @import("std");

pub const NodeType = enum {
    ROOT,
    TEXT,
    HEADING,
    PARAGRAPH,
    LINK,
    CODE,
    CODE_BLOCK,
};

pub const Node = struct {
    allocator: std.mem.Allocator,
    node_type: NodeType,
    content: ?[]const u8 = null,
    level: ?u8 = null,
    children: ?std.ArrayList(*Node) = null,

    pub fn init(allocator: std.mem.Allocator, node_type: NodeType) !*Node {
        const node = try allocator.create(Node);
        node.* = .{
            .allocator = allocator,
            .node_type = node_type,
            .content = null,
            .level = null,
            .children = null,
        };
        return node;
    }

    pub fn deinit(self: *Node) void {
        if (self.children) |*children| {
            for (children.items) |child| {
                child.deinit();
            }
            children.deinit();
        }
        if (self.content) |content| {
            self.allocator.free(content);
        }
        self.allocator.destroy(self);
    }

    pub fn appendChild(self: *Node, child: *Node) !void {
        if (self.children == null) {
            self.children = std.ArrayList(*Node).init(self.allocator);
        }
        try self.children.?.append(child);
    }
};
