const rl = @import("raylib");
const std = @import("std");

const Gun = struct {
    pos_x: i32,
    pos_y: i32,
    width: i32,
    height: i32,
};
const Bullet = struct {
    index: i32,
    pos_x: i32,
    pos_y: i32,
    vel_y: i32,
};
const Ball = struct {
    pos_x: i32,
    pos_y: i32,
    vel_x: i32,
    vel_y: i32,
    base_point: i32,
    current_point: i32,
};

const Gravity = 1;

pub fn main() anyerror!void {
    const screenWidth = 500;
    const screenHeight = 500;

    rl.initWindow(screenWidth, screenHeight, "Zig-Balls");

    // Defer is used to execute a statement upon exiting the current block.
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60);

    // Initialization
    const game_text = "White Flower";

    var gun = Gun{
        .pos_x = @divExact(screenWidth, 2),
        .pos_y = screenHeight - 100,
        .width = 50,
        .height = 50,
    };

    var ball = Ball{
        .pos_x = @divExact(screenWidth, 2),
        .pos_y = 100,
        .vel_x = 4,
        .vel_y = 0,
        .base_point = 100,
        .current_point = 100,
    };

    const single_bullet = Bullet{
        .index = 1,
        .pos_x = 100,
        .pos_y = 100,
        .vel_y = 100,
    };
    const bullets = [5]Bullet{ single_bullet, single_bullet, single_bullet, single_bullet, single_bullet };

    // Game loop
    while (!rl.windowShouldClose()) {
        // ! Update
        // std.debug.print("mouse x pos = {}\n", .{rl.getMouseX()});

        gun.pos_x = rl.getMouseX() - @divExact(gun.width, 2);

        ball.vel_y += Gravity;
        ball.pos_y += ball.vel_y;
        ball.pos_x += ball.vel_x;

        if (ball.pos_y > screenHeight - 50) {
            ball.pos_y = screenHeight - 50;
            ball.vel_y = -ball.vel_y;
        }

        if (ball.pos_x < 0) {
            ball.vel_x = -ball.vel_x;
        }

        if (ball.pos_x > screenWidth) {
            ball.vel_x = -ball.vel_x;
        }

        // ! Draw
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        rl.drawRectangle(0, screenHeight - 50, screenWidth, 50, rl.Color.dark_green);
        // gun
        rl.drawRectangle(gun.pos_x, gun.pos_y, gun.width, gun.height, rl.Color.pink);

        // ball
        rl.drawCircle(ball.pos_x, ball.pos_y, 15, rl.Color.red);

        // TODO: fix this shit
        // const integer = try std.fmt.parseInt(i32, ball.current_point, 10);
        // rl.drawText(integer, ball.pos_x, ball.pos_y, 20, rl.Color.white);

        // bullets
        for (bullets) |bullet| {
            rl.drawLine(bullet.pos_x, bullet.pos_y, bullet.pos_x, bullet.pos_y + 15, rl.Color.yellow);
        }

        rl.drawText(game_text, screenWidth / 2 - game_text.len / 2 * 10, game_text.len / 2, 20, rl.Color.light_gray);
    }
}
