#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <spinel/clock.h>

static ClockSource* clock = NULL;

void registerClockSource(ClockSource* newClock) {
    if (clock != NULL) {
        printf("Tried to register a clock, but one is already registered\n");
        return;
    } else if (newClock == NULL) {
        return;
    } else if (newClock->getTime == NULL) {
        printf("Tried to register a new clock without a getTime function\n");
        return;
    }

    clock = newClock;
}

ClockTime* clockGetTime(void) {
    if (clock == NULL || clock->getTime == NULL) {
        return NULL;
    }
    return clock->getTime();
}

bool clockTimesEqual(ClockTime* a, ClockTime* b) {
    if (a == NULL || b == NULL) {
        // NULL, NULL aren't equal times, just equal pointers
        return false;
    }

    return a->year == b->year &&\
        a->month == b->month &&\
        a->day == b->day &&\
        a->hour == b->hour &&\
        a->minute == b->minute &&\
        a->second == b->second;
}