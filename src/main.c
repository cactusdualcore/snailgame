#include <stdio.h>
#include <stdint.h>
#include <raylib.h>

struct World {
    
};

struct World world = {
    
};

static const uint8_t DEFAULT_WINDOW_TITLE[] = "Snailgame";
static const int PREFERRED_FRAME_RATE = 60;

void initialize(void) {
    const int screen_width = 800;
    const int screen_height = 450;

    InitWindow(screen_width, screen_height, DEFAULT_WINDOW_TITLE);
    SetTargetFPS(60);
}

void update(void) {

}

void draw(void) {
    BeginDrawing();

    ClearBackground(RAYWHITE);
    DrawText("This game isn't actually about a snail. But it will be!\n", 140, 200, 20, LIGHTGRAY);

    EndDrawing();
}

void cleanup(void) {
    CloseWindow();
}

int main(void) {
    initialize();

    while (!WindowShouldClose())
    {
        update();
        draw();
    }

    return 0;
}
