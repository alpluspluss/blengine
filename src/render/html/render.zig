const std = @import("std");
const Node = @import("../../ast/node.zig").Node;
const HtmlElement = @import("element.zig").HtmlElement;

pub const HtmlRenderer = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) HtmlRenderer {
        return .{ .allocator = allocator };
    }

    pub fn renderNode(self: *HtmlRenderer, node: *const Node) !*HtmlElement {
        return switch (node.node_type) {
            .root => self.renderRoot(node),
            .heading => self.renderHeading(node),
            .paragraph => self.renderParagraph(node),
            .text => self.renderText(node),
            .link => self.renderLink(node),
            .code => self.renderCode(node),
            .code_block => self.renderCodeBlock(node),
        };
    }

    fn renderRoot(self: *HtmlRenderer, node: *const Node) !*HtmlElement {
        var div = try HtmlElement.init(self.allocator, "div");
        if (node.children) |children| {
            for (children.items) |child| {
                const child_element = try self.renderNode(child);
                try div.appendChild(child_element);
            }
        }
        return div;
    }

    fn renderHeading(self: *HtmlRenderer, node: *const Node) !*HtmlElement {
        const level = node.level orelse 1;
        var tag_buf: [2]u8 = undefined;
        const tag = try std.fmt.bufPrint(&tag_buf, "h{d}", .{level});

        var heading = try HtmlElement.init(self.allocator, tag);
        if (node.content) |content| {
            heading.inner_text = try self.allocator.dupe(u8, content);
        }
        return heading;
    }

    // TODO: other render API for node types
};
