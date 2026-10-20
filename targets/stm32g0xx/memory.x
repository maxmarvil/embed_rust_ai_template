/*
chip: STM32G071RB
board: TBD — укажите плату проекта (база: NUCLEO-G071RB)
*/
/* Memory configuration for stm32g0xx family.
 * Base values for STM32G071RB — adjust for your Board.
 */
MEMORY
{
    FLASH : ORIGIN = 0x08000000, LENGTH = 128K
    RAM   : ORIGIN = 0x20000000, LENGTH =  36K
}

/* The stack starts at the top of main RAM */
_stack_start = ORIGIN(RAM) + LENGTH(RAM);
