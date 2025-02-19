const rl = @import("raylib");
const std = @import("std");

const Gun = struct {
    pos_x: i32,
    pos_y: i32,
    width: i32,
    height: i32,
};
const Bullet = struct {
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

    const ball = Ball{
        .pos_x = @divExact(screenWidth, 2),
        .pos_y = 100,
        .vel_x = 50,
        .vel_y = 50,
        .base_point = 100,
        .current_point = 100,
    };

    const single_bullet = Bullet{
        .pos_x = 100,
        .pos_y = 100,
        .vel_y = 100,
    };
    const bullets = [5]Bullet{ single_bullet, single_bullet, single_bullet, single_bullet, single_bullet };

    // Game loop
    while (!rl.windowShouldClose()) {
        // Update
        // std.debug.print("mouse x pos = {}\n", .{rl.getMouseX()});

        gun.pos_x = rl.getMouseX() - @divExact(gun.width, 2);

        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        rl.drawRectangle(0, screenHeight - 50, screenWidth, 50, rl.Color.dark_green);
        // gun
        rl.drawRectangle(gun.pos_x, gun.pos_y, gun.width, gun.height, rl.Color.pink);

        // ball
        rl.drawCircle(ball.pos_x, ball.pos_y, 15, rl.Color.red);

        // TODO: fix this shit
        const integer = try std.fmt.parseInt(i32, ball.current_point, 10);
        std.debug.print("test num = {}\n", .{integer});
        // rl.drawText(integer, ball.pos_x, ball.pos_y, 20, rl.Color.white);

        // bullets
        for (bullets) |bullet| {
            rl.drawCircle(bullet.pos_x, bullet.pos_y, 15, rl.Color.yellow);
        }

        rl.drawText(game_text, screenWidth / 2 - game_text.len / 2 * 10, game_text.len / 2, 20, rl.Color.light_gray);
    }
}
