const std = @import("std");

pub const HtmlAttribute = struct {
    name: []const u8,
    value: []const u8,
};

pub const HtmlElement = struct {
    tag: []const u8,
    attributes: std.ArrayList(HtmlAttribute),
    children: std.ArrayList(*HtmlElement),
    inner_text: ?[]const u8,
    allocator: std.mem.Allocator,
    self_closing: bool = false,

    pub fn init(allocator: std.mem.Allocator, tag: []const u8) !*HtmlElement {
        const element = try allocator.create(HtmlElement);
        element.* = .{
            .tag = tag,
            .attributes = std.ArrayList(HtmlAttribute).init(allocator),
            .children = std.ArrayList(*HtmlElement).init(allocator),
            .inner_text = null,
            .allocator = allocator,
        };
        return element;
    }

    pub fn deinit(self: *HtmlElement) void {
        for (self.attributes.items) |attr| {
            self.allocator.free(attr.name);
            self.allocator.free(attr.value);
        }
        self.attributes.deinit();

        for (self.children.items) |child| {
            child.deinit();
        }
        self.children.deinit();

        if (self.inner_text) |text| {
            self.allocator.free(text);
        }

        self.allocator.destroy(self);
    }

    pub fn setAttribute(self: *HtmlElement, name: []const u8, value: []const u8) !void {
        const name_dup = try self.allocator.dupe(u8, name);
        const value_dup = try self.allocator.dupe(u8, value);
        try self.attributes.append(.{ .name = name_dup, .value = value_dup });
    }

    pub fn appendChild(self: *HtmlElement, child: *HtmlElement) !void {
        try self.children.append(child);
    }

    pub fn render(self: *const HtmlElement, writer: anytype) !void {
        try writer.print("<{s}", .{self.tag});

        // render attributes
        for (self.attributes.items) |attr| {
            try writer.print(" {s}=\"{s}\"", .{ attr.name, attr.value });
        }

        if (self.self_closing) {
            try writer.writeAll("/>");
            return;
        }

        try writer.writeAll(">");

        // Render inner text if any
        if (self.inner_text) |text| {
            try writer.writeAll(text);
        }

        // children
        for (self.children.items) |child| {
            try child.render(writer);
        }

        try writer.print("</{s}>", .{self.tag});
    }
};
