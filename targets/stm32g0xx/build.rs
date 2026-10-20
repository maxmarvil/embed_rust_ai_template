// Копирует memory.x в OUT_DIR, чтобы линковщик нашёл его через -Tlink.x.
use std::env;
use std::fs;
use std::path::PathBuf;

fn main() {
    let out_dir = PathBuf::from(env::var_os("OUT_DIR").unwrap());
    fs::copy("memory.x", out_dir.join("memory.x"))
        .expect("не удалось скопировать memory.x в OUT_DIR");
    println!("cargo:rerun-if-changed=memory.x");
    println!("cargo:rustc-link-search={}", out_dir.display());
}
