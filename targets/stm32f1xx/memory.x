/*
chip: STM32F103C8
board: TBD — укажите плату проекта (база: Blue Pill)
*/
/* Memory configuration for stm32f1xx family.
 * Base values for STM32F103C8 (Blue Pill) — adjust for your Board.
 */
MEMORY
{
    FLASH : ORIGIN = 0x08000000, LENGTH = 64K
    RAM   : ORIGIN = 0x20000000, LENGTH = 20K
}

/* The stack starts at the top of main RAM */
_stack_start = ORIGIN(RAM) + LENGTH(RAM);
