// There's a great deal of things which are left for future expansion
// or for documentation.
#![allow(dead_code)]

#![feature(panic_info_message)]

#![cfg(any(target_arch = "x86", target_arch = "x86_64"))]
#![feature(abi_x86_interrupt)]

#![no_main]
#![no_std]

/// Home of architecture specific code.
/// Some interfaces to architecture specific data may be exported from here.
mod arch;
/// Things that are central to Spinel's operation
mod central;

use core::sync::atomic::spin_loop_hint;

use arch::arch_init;
use central::version_info;

#[no_mangle]
pub extern fn _start() -> ! {
    arch_init();

    println!(
        "{} {} on {} {}",
        version_info::OPERATING_SYSTEM_NAME,
        version_info::VERSION_STRING,
        version_info::PROCESSOR_NAME,
        version_info::MACHINE_NAME
    );
    println!("The system is coming up.");

    loop {
        spin_loop_hint();
    }
}
