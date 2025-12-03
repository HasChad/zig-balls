const std = @import("std");
const rl = @import("raylib");
const draw = @import("draw.zig");
const Vec2 = rl.Vector2;

pub const screenWidth = 500;
pub const screenHeight = 700;
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

pub const App = struct {
    player: Player,
    bullets: std.ArrayList(Bullet),
    ball: Ball,
};

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    rl.initWindow(screenWidth, screenHeight, "Zig-Balls");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    var app = App{
        .player = Player{
            .pos = Vec2{ .x = @divExact(screenWidth, 2), .y = screenHeight - 100 },
            .size = Vec2{ .x = 50, .y = 50 },
        },
        .ball = Ball{
            .pos = Vec2{ .x = @divExact(screenWidth, 2), .y = 100 },
            .vel = Vec2{ .x = 4, .y = 0 },
            .base_point = 100,
            .current_point = 100,
            .size = @as(f32, @floatFromInt(100)) / 2.0,
        },
        .bullets = std.ArrayList(Bullet).empty,
    };

    defer app.bullets.deinit(allocator);

    while (!rl.windowShouldClose()) {
        // ! Update
        // std.debug.print("mouse x pos = {}\n", .{rl.getMouseX()});
        rl.setWindowTitle(rl.textFormat("Zig-Balls - FPS: %i", .{rl.getFPS()}));

        if (rl.isMouseButtonDown(.left)) {
            try app.bullets.append(allocator, Bullet{
                .pos = Vec2{
                    .x = app.player.pos.x + app.player.size.x / 2,
                    .y = app.player.pos.y,
                },
                .vel_y = 10.0,
                .ttl = 1.0,
            });
        }

        var i: usize = app.bullets.items.len;
        while (i > 0) {
            i -= 1;
            app.bullets.items[i].ttl -= rl.getFrameTime();

            if (app.bullets.items[i].ttl < 0.0) {
                _ = app.bullets.orderedRemove(i);
                continue;
            } else {
                app.bullets.items[i].pos.y -= app.bullets.items[i].vel_y;
            }

            const pos_X = app.bullets.items[i].pos.x - app.ball.pos.x;
            const pos_Y = app.bullets.items[i].pos.y - app.ball.pos.y;

            if (std.math.sqrt(pos_X * pos_X + pos_Y * pos_Y) < app.ball.size) {
                app.ball.current_point -= 1;
                _ = app.bullets.orderedRemove(i);
            }
        }

        app.player.pos.x = @as(f32, @floatFromInt(rl.getMouseX())) - @divExact(app.player.size.x, 2);

        app.ball.vel.y += Gravity;
        app.ball.pos.y += app.ball.vel.y;
        app.ball.pos.x += app.ball.vel.x;

        if (app.ball.pos.y + app.ball.size > screenHeight - 50) {
            app.ball.pos.y = screenHeight - 50 - app.ball.size;
            app.ball.vel.y = -app.ball.vel.y;
        }

        if (app.ball.pos.x - app.ball.size < 0) {
            app.ball.vel.x = -app.ball.vel.x;
        }

        if (app.ball.pos.x + app.ball.size > screenWidth) {
            app.ball.vel.x = -app.ball.vel.x;
        }

        // ! Draw
        draw.draw_game(app);
    }
}
