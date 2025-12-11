const rl = @import("raylib");
const main = @import("main.zig");

pub fn draw_game(app: main.App) void {
    rl.beginDrawing();
    defer rl.endDrawing();
    rl.clearBackground(rl.Color.black);

    // ground
    rl.drawRectangle(
        0,
        main.SCREEN_HEIGHT - 50,
        main.SCREEN_WIDTH,
        50,
        rl.Color.dark_green,
    );

    // player
    rl.drawRectangleV(
        app.player.pos,
        app.player.size,
        rl.Color.pink,
    );

    // ball
    rl.drawCircleV(
        app.ball.pos,
        app.ball.size,
        rl.Color.red,
    );

    drawCenteredText(
        rl.textFormat("%i", .{app.ball.current_point}),
        @intFromFloat(app.ball.pos.x),
        @intFromFloat(app.ball.pos.y),
        20,
        rl.Color.white,
    );

    // bullets
    for (app.bullets.items) |bullet| {
        rl.drawCircleV(
            bullet.pos,
            3,
            rl.Color.yellow,
        );
    }
}

fn drawCenteredText(text: [:0]const u8, centerX: i32, y: i32, fontSize: i32, color: rl.Color) void {
    const textWidth = rl.measureText(text, fontSize);
    rl.drawText(
        text,
        centerX - @divTrunc(textWidth, 2),
        y - @divExact(fontSize, 2),
        fontSize,
        color,
    );
}
