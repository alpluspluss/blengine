const std = @import("std");
const testing = std.testing;
const blengine = @import("blengine");

test "html element creation" {
    const allocator = testing.allocator;

    var div = try blengine.HtmlElement.init(allocator, "div");
    defer div.deinit();

    try testing.expectEqualStrings(div.tag, "div");
    try testing.expect(div.inner_text == null);
}

test "html element rendering" {
    const allocator = testing.allocator;

    var div = try blengine.HtmlElement.init(allocator, "div");
    defer div.deinit();

    try div.setAttribute("class", "container");

    var span = try blengine.HtmlElement.init(allocator, "span");
    span.inner_text = try allocator.dupe(u8, "Hello");
    try div.appendChild(span);

    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();
    try div.render(list.writer());

    const expected = "<div class=\"container\"><span>Hello</span></div>";
    try testing.expectEqualStrings(expected, list.items);
}
