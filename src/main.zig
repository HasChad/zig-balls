const std = @import("std");
const rl = @import("raylib");
const draw = @import("draw.zig");
const Vec2 = rl.Vector2;

pub const SCREEN_WIDTH = 500;
pub const SCREEN_HEIGHT = 700;
const GRAVITY = 0.3;

const Player = struct {
    pos: Vec2,
    size: Vec2,
    shooting_Timer: f32,
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

    rl.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Zig-Balls");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    var app = App{
        .player = Player{
            .pos = Vec2{ .x = @divExact(SCREEN_WIDTH, 2), .y = SCREEN_HEIGHT - 100 },
            .size = Vec2{ .x = 50, .y = 50 },
            .shooting_Timer = 0.0,
        },
        .ball = Ball{
            .pos = Vec2{ .x = @divExact(SCREEN_WIDTH, 2), .y = 100 },
            .vel = Vec2{ .x = 4, .y = 0 },
            .base_point = 100,
            .current_point = 100,
            .size = 100 / 2,
        },
        .bullets = std.ArrayList(Bullet).empty,
    };

    defer app.bullets.deinit(allocator);

    while (!rl.windowShouldClose()) {
        // std.debug.print("mouse x pos = {}\n", .{rl.getMouseX()});
        rl.setWindowTitle(rl.textFormat("Zig-Balls - FPS: %i", .{rl.getFPS()}));

        app.player.pos.x = @as(f32, @floatFromInt(rl.getMouseX())) - app.player.size.x / 2;

        if (rl.isMouseButtonDown(.left) and app.player.shooting_Timer == 0) {
            app.player.shooting_Timer = 0.05;
            try app.bullets.append(allocator, Bullet{
                .pos = Vec2{
                    .x = app.player.pos.x + app.player.size.x / 2,
                    .y = app.player.pos.y,
                },
                .vel_y = 10.0,
                .ttl = 1.0,
            });
        }

        if (app.player.shooting_Timer > 0) {
            app.player.shooting_Timer -= rl.getFrameTime();

            if (app.player.shooting_Timer < 0) {
                app.player.shooting_Timer = 0;
            }
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

        ball_controller(&app.ball);

        draw.draw_game(app);
    }
}

pub fn ball_controller(ball: *Ball) void {
    ball.vel.y += GRAVITY;
    ball.pos.y += ball.vel.y;
    ball.pos.x += ball.vel.x;

    if (ball.pos.y + ball.size > SCREEN_HEIGHT - 50) {
        ball.pos.y = SCREEN_HEIGHT - 50 - ball.size;
        ball.vel.y = -ball.vel.y;
    }

    if (ball.pos.x - ball.size < 0 or ball.pos.x + ball.size > SCREEN_WIDTH) {
        ball.vel.x = -ball.vel.x;
    }
}
