//! Substrate Node Template CLI library.
#![warn(missing_docs)]

mod chain_spec;
#[macro_use]
mod service;
#[macro_use]
extern crate lazy_static;

mod cli;
mod command;
mod rpc;
mod hurracloud;

fn main() -> sc_cli::Result<()> {
	command::run()
}
