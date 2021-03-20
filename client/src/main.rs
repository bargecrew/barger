extern crate clap;
extern crate http;

use clap::{App, Arg, SubCommand};
// use http::Request;
// use std::fs;

fn main() {
    // let filename = "~/.barger/token";
    // let token = fs::read_to_string(filename)
    //     .expect(&format!("Could not read token from file {}", filename));
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
            Arg::with_name("token")
                .short("t")
                .long("token")
                .value_name("STRING")
                .help("Sets JWT token")
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

    match matches.subcommand() {
        ("get", Some(sub_m)) => {}
        _ => {}
    }
}
