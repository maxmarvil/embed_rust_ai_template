/*
chip: nRF52840_xxAA
board: TBD — укажите плату проекта
*/
/* Memory configuration for nrf528xx family.
 * Base values for nRF52840 — adjust for your Board
 * (nRF52832: 512K Flash / 64K RAM; nRF52810: 192K / 24K; nRF52811: 192K / 24K).
 */
MEMORY
{
    FLASH : ORIGIN = 0x00000000, LENGTH = 1024K
    RAM   : ORIGIN = 0x20000000, LENGTH =  256K
}

/* The stack starts at the top of main RAM */
_stack_start = ORIGIN(RAM) + LENGTH(RAM);
