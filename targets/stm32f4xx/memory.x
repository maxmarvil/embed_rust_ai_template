/*
chip: STM32F407VG
board: TBD — укажите плату проекта
*/
/* Memory configuration for stm32f4xx family.
 * Base values for STM32F407VG — adjust for your Board
 * (CCM 64K at 0x10000000 is not included; it is not accessible via DMA).
 */
MEMORY
{
    FLASH : ORIGIN = 0x08000000, LENGTH =  1024K
    RAM   : ORIGIN = 0x20000000, LENGTH =   128K
}

/* The stack starts at the top of main RAM */
_stack_start = ORIGIN(RAM) + LENGTH(RAM);
