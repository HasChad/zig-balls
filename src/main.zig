const rl = @import("raylib");
const std = @import("std");

const Gravity = 1;
const Player = struct {
    pos: rl.Vector2,
    size: rl.Vector2,
};
const Bullet = struct {
    pos: rl.Vector2,
    index: i32,
    vel_y: i32,
    // is_active: bool,
};
const Ball = struct {
    pos: rl.Vector2,
    vel: rl.Vector2,
    base_point: i32,
    current_point: i32,
    size: f32,
};

pub fn main() anyerror!void {
    const screenWidth = 500;
    const screenHeight = 700;

    rl.initWindow(screenWidth, screenHeight, "Zig-Balls");
    rl.setTargetFPS(60);

    // Defer is used to execute a statement upon exiting the current block.
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60);

    // ! Initialization
    var player = Player{
        .pos = rl.Vector2{ .x = @divExact(screenWidth, 2), .y = screenHeight - 100 },
        .size = rl.Vector2{ .x = 50, .y = 50 },
    };

    var ball = Ball{
        .pos = rl.Vector2{ .x = @divExact(screenWidth, 2), .y = 100 },
        .vel = rl.Vector2{ .x = 4, .y = 0 },
        .base_point = 100,
        .current_point = 100,
        .size = @as(f32, @floatFromInt(100)) / 2.0,
    };

    const single_bullet = Bullet{
        .pos = rl.Vector2{ .x = 100, .y = 100 },
        .index = 1,
        .vel_y = 100,
    };

    const bullets = [5]Bullet{
        single_bullet,
        single_bullet,
        single_bullet,
        single_bullet,
        single_bullet,
    };

    // Game loop
    while (!rl.windowShouldClose()) {
        // ! Update
        // std.debug.print("mouse x pos = {}\n", .{rl.getMouseX()});

        rl.setWindowTitle(rl.textFormat("Zig-Balls - FPS: %i", .{rl.getFPS()}));

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
        //rl.drawTextEx(rl.font, rl.textFormat("%i", .{ball.current_point}), ball.pos, 20, 0, rl.Color.white);

        // bullets
        for (bullets) |bullet| {
            rl.drawLineEx(
                bullet.pos,
                rl.Vector2{ .x = bullet.pos.x, .y = bullet.pos.y - 20.0 },
                2,
                rl.Color.yellow,
            );
        }
    }
}
