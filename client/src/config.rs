use serde_derive::Deserialize;
use std::fs;
use toml;

#[derive(Deserialize)]
pub struct Profile {
    pub url: String,
    pub token: String,
}

#[derive(Deserialize)]
struct FileConfig {
    pub profile: Vec<FileProfile>,
}

#[derive(Deserialize)]
struct FileProfile {
    pub name: String,
    pub url: String,
    pub token: String,
}

pub fn get_profile(filename: &str, profile: &str) -> Result<Profile, String> {
    match fs::read_to_string(&filename) {
        Ok(content) => match toml::from_str::<FileConfig>(&content) {
            Ok(config) => {
                for i in 0..config.profile.len() {
                    if config.profile[i].name == profile {
                        return Ok(Profile {
                            url: config.profile[i].url.clone(),
                            token: config.profile[i].token.clone(),
                        });
                    }
                }
                return Err(format!("profile '{}' not found", &filename));
            }
            Err(_) => {
                return Err(format!("could not parse file {}", &filename));
            }
        },
        Err(_) => {
            return Err(format!("could not read file {}", &filename));
        }
    }
}
