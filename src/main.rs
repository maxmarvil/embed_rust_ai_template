#![no_std]
#![no_main]

use core::ptr::{read_volatile, write_volatile};
use panic_halt as _;

const RCC_APB2ENR: *mut u32 = 0x4002_1018 as *mut u32;
const GPIOC_CRH: *mut u32 = 0x4001_1004 as *mut u32;
const GPIOC_ODR: *mut u32 = 0x4001_100C as *mut u32;

const IOPCEN: u32 = 1 << 4;
const PIN13: u32 = 1 << 13;
const CRH_PIN13_MASK: u32 = 0xF << 20;
const CRH_PIN13_OUT_2MHZ: u32 = 0b0010 << 20;

#[cortex_m_rt::entry]
fn main() -> ! {
    unsafe {
        let apb2enr = read_volatile(RCC_APB2ENR);
        write_volatile(RCC_APB2ENR, apb2enr | IOPCEN);

        let crh = read_volatile(GPIOC_CRH);
        write_volatile(GPIOC_CRH, (crh & !CRH_PIN13_MASK) | CRH_PIN13_OUT_2MHZ);

        let mut odr = read_volatile(GPIOC_ODR);
        loop {
            odr ^= PIN13;
            write_volatile(GPIOC_ODR, odr);
            for _ in 0..500_000 {
                core::hint::spin_loop();
            }
        }
    }
}
