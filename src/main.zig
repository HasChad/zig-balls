const rl = @import("raylib");
const std = @import("std");

const Gun = struct {
    width: i32,
    height: i32,
    pos_x: i32,
    pos_y: i32,
};
const Bullet = struct {
    vel_y: i32,
    pos_x: i32,
    pos_y: i32,
};

pub fn main() anyerror!void {
    const screenWidth = 500;
    const screenHeight = 500;

    rl.initWindow(screenWidth, screenHeight, "Zig-Balls");

    // Defer is used to execute a statement upon exiting the current block.
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60);

    // Initialization
    var gun = Gun{
        .width = 50,
        .height = 50,
        .pos_x = @divExact(screenWidth, 2),
        .pos_y = screenHeight - 100,
    };

    // Game loop
    while (!rl.windowShouldClose()) {
        // Update
        // std.debug.print("mouse x pos = {}\n", .{rl.getMouseX()});

        gun.pos_x = rl.getMouseX() - @divExact(gun.width, 2);

        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);
        rl.drawRectangle(
            0,
            screenHeight - 50,
            screenWidth,
            50,
            rl.Color.dark_green,
        );

        rl.drawRectangle(
            gun.pos_x,
            gun.pos_y,
            gun.width,
            gun.height,
            rl.Color.pink,
        ); // gun

        rl.drawCircle(
            screenWidth / 2,
            screenHeight / 2,
            3,
            rl.Color.white,
        ); // center

        rl.drawText(
            "White Flower",
            screenWidth / 2,
            screenHeight / 2,
            20,
            rl.Color.light_gray,
        );
    }
}
