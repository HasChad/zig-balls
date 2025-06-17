const std = @import("std");
const rl = @import("raylib");
const Vec2 = rl.Vector2;

const Gravity = 0.3;
const Player = struct {
    pos: Vec2,
    size: Vec2,
};
const Bullet = struct {
    pos: Vec2,
    vel_y: f32,
    ttl: f32,
    // is_active: bool,
};
const Ball = struct {
    pos: Vec2,
    vel: Vec2,
    base_point: i32,
    current_point: i32,
    size: f32,
};

pub fn main() anyerror!void {
    const screenWidth = 500;
    const screenHeight = 700;
    const allocator = std.heap.page_allocator;
    const gpa = std.heap.page_allocator;

    rl.initWindow(screenWidth, screenHeight, "Zig-Balls");
    rl.setTargetFPS(60);

    // Defer is used to execute a statement upon exiting the current block.
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60);

    // ! Initialization
    var player = Player{
        .pos = Vec2{ .x = @divExact(screenWidth, 2), .y = screenHeight - 100 },
        .size = Vec2{ .x = 50, .y = 50 },
    };

    var ball = Ball{
        .pos = Vec2{ .x = @divExact(screenWidth, 2), .y = 100 },
        .vel = Vec2{ .x = 4, .y = 0 },
        .base_point = 100,
        .current_point = 100,
        .size = @as(f32, @floatFromInt(100)) / 2.0,
    };

    // var ball_hashmap = std.AutoHashMap(Ball).init(gpa);
    // defer ball_hashmap.deinit();

    var bullet_list = std.ArrayList(Bullet).init(allocator);
    defer bullet_list.deinit();

    // Game loop
    while (!rl.windowShouldClose()) {
        // ! Update
        // std.debug.print("mouse x pos = {}\n", .{rl.getMouseX()});
        rl.setWindowTitle(rl.textFormat("Zig-Balls - FPS: %i", .{rl.getFPS()}));

        if (rl.isMouseButtonDown(.left)) {
            try bullet_list.append(Bullet{
                .pos = Vec2{
                    .x = player.pos.x + player.size.x / 2,
                    .y = player.pos.y,
                },
                .vel_y = 10.0,
                .ttl = 1.0,
            });
        }

        var i: usize = bullet_list.items.len;
        while (i > 0) {
            i -= 1;
            bullet_list.items[i].ttl -= rl.getFrameTime();

            if (bullet_list.items[i].ttl < 0.0) {
                _ = bullet_list.orderedRemove(i);
                continue;
            } else {
                bullet_list.items[i].pos.y -= bullet_list.items[i].vel_y;
            }

            const pos_X = bullet_list.items[i].pos.x - ball.pos.x;
            const pos_Y = bullet_list.items[i].pos.y - ball.pos.y;

            if (std.math.sqrt(pos_X * pos_X + pos_Y * pos_Y) < ball.size) {
                ball.current_point -= 1;
                _ = bullet_list.orderedRemove(i);
            }

            // add ball split or die
        }

        player.pos.x = @as(f32, @floatFromInt(rl.getMouseX())) - @divExact(player.size.x, 2);

        ball.vel.y += Gravity;
        ball.pos.y += ball.vel.y;
        ball.pos.x += ball.vel.x;

        if (ball.pos.y + ball.size > screenHeight - 50) {
            ball.pos.y = screenHeight - 50 - ball.size;
            ball.vel.y = -ball.vel.y;
        }

        if (ball.pos.x - ball.size < 0) {
            ball.vel.x = -ball.vel.x;
        }

        if (ball.pos.x + ball.size > screenWidth) {
            ball.vel.x = -ball.vel.x;
        }

        // ! Draw
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.black);

        // ground
        rl.drawRectangle(
            0,
            screenHeight - 50,
            screenWidth,
            50,
            rl.Color.dark_green,
        );

        // player
        rl.drawRectangleV(
            player.pos,
            player.size,
            rl.Color.pink,
        );

        // ball
        rl.drawCircleV(
            ball.pos,
            ball.size,
            rl.Color.red,
        );

        drawCenteredText(rl.textFormat("%i", .{ball.current_point}), @intFromFloat(ball.pos.x), @intFromFloat(ball.pos.y), 20, rl.Color.white);

        // bullets
        for (bullet_list.items) |bullet| {
            rl.drawCircleV(
                bullet.pos,
                3,
                rl.Color.yellow,
            );
        }
    }
}

pub fn drawCenteredText(text: [:0]const u8, centerX: i32, y: i32, fontSize: i32, color: rl.Color) void {
    const textWidth = rl.measureText(text, fontSize);
    rl.drawText(
        text,
        centerX - @divTrunc(textWidth, 2),
        y - @divExact(fontSize, 2),
        fontSize,
        color,
    );
}
