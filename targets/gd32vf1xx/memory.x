/*
chip: GD32VF103CB
board: TBD — укажите плату проекта (база: Sipeed Longan Nano)
*/
/* Memory configuration for gd32vf1xx family (RISC-V).
 * Base values for GD32VF103CB — adjust for your Board.
 */
MEMORY
{
    FLASH : ORIGIN = 0x08000000, LENGTH = 128K
    RAM   : ORIGIN = 0x20000000, LENGTH =  32K
}

/* The stack starts at the top of main RAM */
_stack_start = ORIGIN(RAM) + LENGTH(RAM);
