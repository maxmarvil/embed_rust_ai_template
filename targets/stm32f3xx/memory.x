/*
chip: STM32F303VC
board: TBD — укажите плату проекта (база: Nucleo-32/F303RE-класс)
*/
/* Memory configuration for stm32f3xx family.
 * Base values for STM32F303VC — adjust for your Board.
 */
MEMORY
{
    FLASH : ORIGIN = 0x08000000, LENGTH = 256K
    RAM   : ORIGIN = 0x20000000, LENGTH =  40K
}

/* The stack starts at the top of main RAM */
_stack_start = ORIGIN(RAM) + LENGTH(RAM);
