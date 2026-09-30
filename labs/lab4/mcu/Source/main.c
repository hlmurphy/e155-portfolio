/*********************************************************************
*                    SEGGER Microcontroller GmbH                     *
*                        The Embedded Experts                        *
**********************************************************************

-------------------------- END-OF-HEADER -----------------------------

File    : main.c
Purpose : e155 lab4 — Für Elise on Nucleo-L432KC
— Register-level implementation (no CMSIS) */

#include <stdint.h>
extern const int notes[][2];
extern const int alla_turca[][2];

typedef struct {
    volatile uint32_t MODER;
    volatile uint32_t OTYPER;
    volatile uint32_t OSPEEDR;
    volatile uint32_t PUPDR;
    volatile uint32_t IDR;
    volatile uint32_t ODR;
    volatile uint32_t BSRR;
} GPIO_TypeDef;

typedef struct {
    volatile uint32_t CR1;
    volatile uint32_t CR2;
    volatile uint32_t reserved_0x08;
    volatile uint32_t DIER;
    volatile uint32_t SR;
    volatile uint32_t EGR;
    volatile uint32_t reserved_0x18;
    volatile uint32_t reserved_0x1C;
    volatile uint32_t reserved_0x20;
    volatile uint32_t CNT;
    volatile uint32_t PSC;
    volatile uint32_t ARR;
} BASIC_TIM_TypeDef;

#define RCC_AHB2ENR     (*(volatile uint32_t *) (0x40021000 + 0x4C))
#define RCC_APB1ENR1    (*(volatile uint32_t *) (0x40021000 + 0x58))

#define GPIOA   ((GPIO_TypeDef      *) 0x48000000UL)
#define TIM6    ((BASIC_TIM_TypeDef *) 0x40001000UL)

void gpio_init_pa8(void){
    RCC_AHB2ENR |= (1 << 0);
    GPIOA->MODER &= ~(0b11 << 16);
    GPIOA->MODER |= (1 << 16);
}

void tim6_init(void){
    RCC_APB1ENR1 |= (1 << 4);
}

void play_tone(uint32_t freq_hz, uint32_t duration_ms){
    uint32_t arr = (4000000 / (2 * freq_hz)) - 1;
    uint32_t n_toggles = (2 * freq_hz * duration_ms) / 1000;
    TIM6 -> PSC = 0;
    TIM6 -> ARR = arr;
    TIM6 -> EGR |= (1 << 0);
    TIM6 -> SR &= ~(1 << 0);
    TIM6 ->CR1 |= (1 << 0);

    for (uint32_t i = 0; i < n_toggles; i++){
        while (!(TIM6->SR & (1 << 0))) {}
        TIM6 -> SR &= ~(1 << 0);
        GPIOA -> ODR ^= (1 << 8);
    }

    TIM6 -> CR1 &= ~(1 << 0);
}
// Song Player given an array of frequencies and durations denoting musical notesz

void play_rest(uint32_t ms){
    for (volatile uint32_t i = 0; i < ms * 1000; i++) {}
}

void play_note(uint32_t freq, uint32_t dur){
    if (freq == 0) {
        play_rest(dur);
    } else {
        play_tone(freq, dur);
    }
}

void play_song(const int song[][2]){
    for (int i = 0; notes[i][1] != 0; i++) {
        play_note(notes[i][0], notes[i][1]);
    }
}

int main(void){
    gpio_init_pa8();
    tim6_init();
    while (1) {
        play_song(notes);
        play_rest(2000);
        play_song(alla_turca);
        play_rest(3000);
    }
    // while(1){
    //     play_tone(440, 2000);
    //     for (volatile int i = 0; i < 4000000; i++) {}
    // }

    return 0;
}

/*************************** End of file ****************************/
