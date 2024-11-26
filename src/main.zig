const std = @import("std");
const rl = @import("raylib");

const CollisionInfo = struct {
    collided: bool,
    yAdjustment: f32,
};

fn checkCollision(position: rl.Vector2, paddle: *const rl.Rectangle) CollisionInfo {
    if (position.x >= paddle.x and position.x <= paddle.x + paddle.width) {
        if (position.y >= paddle.y and position.y <= paddle.y + paddle.height) {
            const offsetFromTop = position.y - paddle.y;
            const percentage = offsetFromTop / paddle.height;
            const adjustment = (percentage * 2.0) - 1.0;
            return .{
                .collided = true,
                .yAdjustment = adjustment,
            };
        }
    }
    return .{
        .collided = false,
        .yAdjustment = 0.0,
    };
}

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig example");
    defer rl.closeWindow();

    rl.setTargetFPS(165);

    const ballBaseSpeed = 300.0;
    var ballSpeed: f32 = ballBaseSpeed;
    const ballSpeedIncreasion = 20.0;
    const paddleSpeed = 200.0;

    var ballPos: rl.Vector2 = rl.Vector2.init(800.0 / 2.0, 450.0 / 2.0);
    var ballMovement: rl.Vector2 = rl.Vector2.init(1.0, 1.0);

    const paddleWidth = 10.0;
    const paddleHeight = 150.0;

    var paddleOneRect: rl.Rectangle = rl.Rectangle.init(5.0, (@as(f32, @floatFromInt(screenHeight)) / 2.0) - (paddleHeight / 2.0), paddleWidth, paddleHeight);
    var paddleTwoRect: rl.Rectangle = rl.Rectangle.init(@as(f32, @floatFromInt(screenWidth)) - paddleWidth - 5.0, (@as(f32, @floatFromInt(screenHeight)) / 2.0) - (paddleHeight / 2.0), paddleWidth, paddleHeight);

    var scoreLeft: i32 = 0;
    var scoreRight: i32 = 0;
    var started = false;

    while (!rl.windowShouldClose()) {
        if (started) {
            const delta = rl.getFrameTime();
            ballPos = ballPos.add(ballMovement.normalize().scale(ballSpeed * delta));
            ballSpeed += ballSpeedIncreasion * delta;

            if (ballPos.y < 0.0 or ballPos.y >= 450.0) {
                ballMovement.y *= -1.0;
            }

            var info = checkCollision(ballPos, &paddleOneRect);
            if (info.collided) {
                ballMovement.x *= -1.0;
                ballMovement.y = info.yAdjustment;
            }

            info = checkCollision(ballPos, &paddleTwoRect);
            if (info.collided) {
                ballMovement.x *= -1.0;
                ballMovement.y = info.yAdjustment;
            }

            if (ballPos.x < 0) {
                scoreRight += 1;
                ballPos.x = @as(f32, @floatFromInt(screenWidth)) / 2.0;
                ballPos.y = @as(f32, @floatFromInt(screenHeight)) / 2.0;
                ballSpeed = ballBaseSpeed;
            } else if (ballPos.x > screenWidth) {
                scoreLeft += 1;
                ballPos.x = @as(f32, @floatFromInt(screenWidth)) / 2.0;
                ballPos.y = @as(f32, @floatFromInt(screenHeight)) / 2.0;
                ballSpeed = ballBaseSpeed;
            }

            if (scoreLeft == 3 or scoreRight == 3) {
                started = false;
            }

            if (rl.isKeyDown(rl.KeyboardKey.key_s)) {
                paddleOneRect.y += paddleSpeed * delta;
            }

            if (rl.isKeyDown(rl.KeyboardKey.key_w)) {
                paddleOneRect.y -= paddleSpeed * delta;
            }

            if (rl.isKeyDown(rl.KeyboardKey.key_down)) {
                paddleTwoRect.y += paddleSpeed * delta;
            }

            if (rl.isKeyDown(rl.KeyboardKey.key_up)) {
                paddleTwoRect.y -= paddleSpeed * delta;
            }
        } else {
            if (rl.isKeyDown(rl.KeyboardKey.key_enter)) {
                started = true;
                scoreLeft = 0;
                scoreRight = 0;
            }
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);

        if (!started) {
            if ((scoreLeft > 0 or scoreRight > 0) and scoreLeft > scoreRight) {
                const textSize = rl.measureTextEx(rl.getFontDefault(), "Left won!", 20, 1);
                rl.drawText("Left won!", @divFloor(screenWidth, 2) - @divFloor(@as(i32, @intFromFloat(textSize.x)), 2), @divFloor(screenHeight, 2) - @as(i32, @intFromFloat(textSize.y)), 20, rl.Color.light_gray);
            } else if (scoreLeft > 0 or scoreRight > 0) {
                const textSize = rl.measureTextEx(rl.getFontDefault(), "Right won!", 20, 1);
                rl.drawText("Right won!", @divFloor(screenWidth, 2) - @divFloor(@as(i32, @intFromFloat(textSize.x)), 2), @divFloor(screenHeight, 2) - @as(i32, @intFromFloat(textSize.y)), 20, rl.Color.light_gray);
            }
            const textSize = rl.measureTextEx(rl.getFontDefault(), "Press Enter to start the game!", 20, 1);
            rl.drawText("Press Enter to start the game!", @divFloor(screenWidth, 2) - @divFloor(@as(i32, @intFromFloat(textSize.x)), 2), @divFloor(screenHeight, 2), 20, rl.Color.light_gray);
        } else {
            rl.drawCircle(@as(i32, @intFromFloat(ballPos.x)), @as(i32, @intFromFloat(ballPos.y)), 5.0, rl.Color.red);

            rl.drawRectangleRec(paddleOneRect, rl.Color.green);
            rl.drawRectangleRec(paddleTwoRect, rl.Color.blue);
        }
    }
}
