#include <stdio.h>
#include <SDL.h>

int SDL_main(int argc, char *argv[]) {
    printf("Starting SDL test...\n");
    fflush(stdout);
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        printf("SDL_Init failed: %s\n", SDL_GetError());
        fflush(stdout);
        return 1;
    }
    printf("SDL initialized\n");
    fflush(stdout);
    SDL_Quit();
    printf("Done\n");
    fflush(stdout);
    return 0;
}
