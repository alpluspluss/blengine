const std = @import("std");
const Node = @import("ast/node.zig").Node;

pub const ProcessError = error{
    OutOfMemory,
    ParsingError,
    TransformError,
};

pub const PluginFn = *const fn (*Node) ProcessError!void;

pub const Plugin = struct {
    name: []const u8,
    transform: PluginFn,
};

pub const Processor = struct {
    allocator: std.mem.Allocator,
    plugins: std.ArrayList(Plugin),

    pub fn init(allocator: std.mem.Allocator) !*Processor {
        const processor = try allocator.create(Processor);
        processor.* = .{
            .allocator = allocator,
            .plugins = std.ArrayList(Plugin).init(allocator),
        };
        return processor;
    }

    pub fn deinit(self: *Processor) void {
        self.plugins.deinit();
        self.allocator.destroy(self);
    }

    pub fn use(self: *Processor, plugin: Plugin) !void {
        try self.plugins.append(plugin);
    }

    pub fn process(self: *Processor, content: []const u8) !*Node {
        var root = try Node.init(self.allocator, .ROOT);
        errdefer root.deinit();

        try self.parseContent(root, content);
        for (self.plugins.items) |plugin| {
            try plugin.transform(root);
        }

        return root;
    }

    fn parseContent(self: *Processor, root: *Node, content: []const u8) !void {
        // TODO: impl actual markdown parsing
        var text_node = try Node.init(self.allocator, .TEXT);
        text_node.content = try self.allocator.dupe(u8, content);
        try root.appendChild(text_node);
    }
};
