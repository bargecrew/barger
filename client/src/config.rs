use serde_derive::Deserialize;
use std::fs;

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

fn normalize_path(path: &str) -> String {
    if path.contains('~') {
        return path.replace("~", dirs::home_dir().unwrap().to_str().as_ref().unwrap());
    }
    path.to_string()
}

pub fn get_profile(filename: &str, profile: &str) -> Result<Profile, String> {
    let normalized_filename = normalize_path(&filename);
    match fs::read_to_string(&normalized_filename) {
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
                return Err(format!("profile '{}' not found", &normalized_filename));
            }
            Err(err) => {
                eprintln!("{}", err);
                return Err(format!("could not parse file {}", &normalized_filename));
            }
        },
        Err(err) => {
            eprintln!("{}", err);
            return Err(format!("could not read file {}", &normalized_filename));
        }
    }
}
