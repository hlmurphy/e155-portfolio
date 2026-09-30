/*********************************************************************
*                    SEGGER Microcontroller GmbH                     *
*                        The Embedded Experts                        *
**********************************************************************

-------------------------- END-OF-HEADER -----------------------------

File    : main.c
Purpose : e155 lab4 — Für Elise on Nucleo-L432KC
— Register-level implementation (no CMSIS) */

#include <stdint.h>

// Separate Song Scores
extern const int notes[][2];
extern const int angry_birds[][2];

// GPIO port register layout
typedef struct {
    volatile uint32_t MODER;
    volatile uint32_t OTYPER;
    volatile uint32_t OSPEEDR;
    volatile uint32_t PUPDR;
    volatile uint32_t IDR;
    volatile uint32_t ODR;
    volatile uint32_t BSRR;
} GPIO_TypeDef;

// TIM6  (basic timer) register layout
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

// Peripheral Base adresses
#define RCC_AHB2ENR     (*(volatile uint32_t *) (0x40021000 + 0x4C)) // GPIOA
#define RCC_APB1ENR1    (*(volatile uint32_t *) (0x40021000 + 0x58)) // TIM6

#define GPIOA   ((GPIO_TypeDef      *) 0x48000000UL)
#define TIM6    ((BASIC_TIM_TypeDef *) 0x40001000UL)

void gpio_init_pa8(void){
    RCC_AHB2ENR |= (1 << 0);        //GPIOEN
    GPIOA->MODER &= ~(0b11 << 16);  // clear MODER8[1:0]
    GPIOA->MODER |= (1 << 16);      // set MODER8 = 01 (general output)
}

void tim6_init(void){
    RCC_APB1ENR1 |= (1 << 4);       // TIM6EN
}
// play_tone: produce squarewave at freq_hz on PA8 for duration_ms milliseconds
void play_tone(uint32_t freq_hz, uint32_t duration_ms){ 
    uint32_t arr = (4000000 / (2 * freq_hz)) - 1; // MSI = 4 MHz establishing "max count" by the input freq
    uint32_t n_toggles = (2 * freq_hz * duration_ms) / 1000;
    TIM6 -> PSC = 0;
    TIM6 -> ARR = arr;
    TIM6 -> EGR |= (1 << 0);    // relod PSC/ARR
    TIM6 -> SR &= ~(1 << 0);    // clear the UIF
    TIM6 ->CR1 |= (1 << 0);     // CEN — start counter

    for (uint32_t i = 0; i < n_toggles; i++){
        while (!(TIM6->SR & (1 << 0))) {} // loop until UIF becomes 1
        TIM6 -> SR &= ~(1 << 0);  // clear UIF for next period
        GPIOA -> ODR ^= (1 << 8); // toggle PA8 (half-period marker)
    }

    TIM6 -> CR1 &= ~(1 << 0);   // stop counter
    GPIOA -> ODR &= ~(1 << 8);  // force PA8 low for conssistent silences ({0, x})
}
// Song Player given an array of frequencies and durations denoting musical notes

void play_rest(uint32_t ms){
    for (volatile uint32_t i = 0; i < ms * 1000; i++) {}
}
// Divide by zero condition guard
void play_note(uint32_t freq, uint32_t dur){
    if (freq == 0) {
        play_rest(dur); // protection again divide by zero
    } else {
        play_tone(freq, dur); // activate PA8 function
    }
}
// Terminator check: Play a song until {0, 0} detected 
void play_song(const int song[][2]){
    for (int i = 0; song[i][1] != 0; i++) {
        play_note(song[i][0], song[i][1]);
    }
}

// Initialize pin timer and play both songs
int main(void){
    gpio_init_pa8();
    tim6_init();
    while (1) {
        play_song(notes);       // Für Elise
        play_rest(2000);
        play_song(angry_birds); // Angry Birds
        play_rest(3000);
    }

    return 0;
}

/*************************** End of file ****************************/
