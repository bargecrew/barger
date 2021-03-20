extern crate clap;
extern crate reqwest;
extern crate serde_derive;
extern crate toml;

mod config;
mod request;

use clap::{App, Arg, SubCommand};

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

    let _profile = config::get_profile(
        matches.value_of("config").unwrap_or("~/.barger/config"),
        matches.value_of("profile").unwrap_or("default"),
    );

    match matches.subcommand() {
        ("get", Some(_sub_m)) => {}
        _ => {}
    }
}
