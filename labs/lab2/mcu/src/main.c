/*********************************************************************
*                    SEGGER Microcontroller GmbH                     *
*                        The Embedded Experts                        *
**********************************************************************

-------------------------- END-OF-HEADER -----------------------------

File    : main.c
Author  : Haspard Murphy <hmurphy@g.hmc.edu>
Date    : 2026-09-15
Course  : HMC E155, Lab 2
Purpose : "Held-in-reset surrogate" firmware for the Nucleo L432KC on
          the E155 dev board.

          The MCU is intended to be electrically held in reset by
          tying NRST to GND, so this program should never execute.
          It is flashed as belt-and-suspenders in case NRST is
          released temporarily (e.g. for a J-Link reprogram or
          during a power-cycle) so that the pins the FPGA depends on
          stay in their reset-default state.

          Lab 2 wiring context:
            - SW7 positions 1-8 are all mechanically closed, bridging
              eight MCU pins to eight FPGA pins.
            - MCU pins involved: PA5, PA6, PA9, PA10 (bridge to
              s0[3:0] on the FPGA, driven from an external 4-position
              DIP switch on the breadboard through J6), and PA11,
              PB3, PB4, PB5 (bridge to FPGA outputs anode_0, anode_1,
              col_leds[3], rows[0] which fan out to the breadboard
              via J6).
            - Any MCU pin driving one of those lines would fight the
              FPGA output or the external switch. Keeping every pin
              in reset-default analog-input Hi-Z prevents that.

          Behavior of this firmware:
            - No RCC clock enables (peripheral clocks stay off).
            - No GPIO MODER / PUPDR / ODR / BSRR writes.
            - No interrupt enables.
            - Core idles in Wait-For-Interrupt forever.

          Because every peripheral is untouched, every pin stays in
          its post-reset configuration: MODER=11 (analog input),
          PUPDR=00 (no pull), OTYPER/OSPEEDR irrelevant. This is the
          same electrical state as if NRST were held low.

          Build & flash (SEGGER Embedded Studio, per the E155 "Segger
          Embedded Studio setup" tutorial):
            1. File > New Project > "C/C++ executable for STMicro
               STM32L4xx", target STM32L432KCUx.
            2. Install CMSIS 5 CMSIS-CORE and STM32L4xx CPU Support
               packages via the SEGGER package manager if not already
               present.
            3. Replace the wizard-generated main.c with this file.
            4. Build (F7).
            5. LIFT the NRST-to-GND jumper temporarily.
            6. Target > Connect J-Link, then Target > Download.
            7. Restore the NRST-to-GND jumper once "Download
               successful" appears.

*/

#include <stm32l432xx.h>

int main(void) {
    // Intentionally do not touch RCC, GPIO, or any peripheral
    // register. Every pin remains in its reset-default analog-input
    // Hi-Z state so the FPGA and the external DIP-switch board can
    // share the SW7-bridged lines without contention.
    while (1) {
        __WFI();
    }
}

/*************************** End of file ****************************/
