extern crate clap;
extern crate dirs;
extern crate reqwest;
extern crate serde_derive;
extern crate toml;

mod config;
mod request;

use clap::{App, Arg, SubCommand};
use std::process;

fn main() {
    let matches = App::new("barger")
        .version("0.1.0")
        .author("Hrafn Orri Hrafnkelsson <HrafnOrri@BitCrow.net>")
        .about("Does awesome things")
        .arg(
            Arg::with_name("config")
                .short("c")
                .long("config")
                .value_name("FILE")
                .help("Sets a custom config file")
                .takes_value(true),
        )
        .arg(
            Arg::with_name("profile")
                .short("p")
                .long("profile")
                .value_name("STRING")
                .help("Sets the profile")
                .takes_value(true),
        )
        .subcommands(vec![
            SubCommand::with_name("create")
                .about("Create resource")
                .subcommand(SubCommand::with_name("cluster").about("Create clusters"))
                .subcommand(SubCommand::with_name("clusters").about("Create clusters")),
            SubCommand::with_name("delete")
                .about("Delete resource")
                .subcommand(SubCommand::with_name("cluster").about("Delete clusters"))
                .subcommand(SubCommand::with_name("clusters").about("Delete clusters")),
            SubCommand::with_name("get")
                .about("Get resource")
                .subcommand(SubCommand::with_name("cluster").about("Get clusters"))
                .subcommand(SubCommand::with_name("clusters").about("Get clusters")),
        ])
        .get_matches();

    match config::get_profile(
        matches.value_of("config").unwrap_or("~/.barger/config"),
        matches.value_of("profile").unwrap_or("default"),
    ) {
        Ok(_profile) => match matches.subcommand() {
            ("create", Some(sub_m)) => match sub_m.subcommand_name() {
                Some("cluster") => {
                    println!("create cluster");
                }
                Some("clusters") => {
                    println!("create clusters");
                }
                _ => {
                    println!("error: unknown command");
                    process::exit(1);
                }
            },
            ("delete", Some(sub_m)) => match sub_m.subcommand_name() {
                Some("cluster") => {
                    println!("delete cluster");
                }
                Some("clusters") => {
                    println!("delete clusters");
                }
                _ => {
                    println!("error: unknown command");
                    process::exit(1);
                }
            },
            ("get", Some(sub_m)) => match sub_m.subcommand_name() {
                Some("cluster") => {
                    println!("get cluster");
                }
                Some("clusters") => {
                    println!("get clusters");
                }
                _ => {
                    println!("error: unknown command");
                    process::exit(1);
                }
            },
            _ => {
                println!("error: unknown command");
                process::exit(1);
            }
        },
        Err(err) => {
            println!("error: {}", err);
            process::exit(1);
        }
    }
}
