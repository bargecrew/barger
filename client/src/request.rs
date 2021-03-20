pub fn request() -> http::Result<()> {
    let filename = "~/.barger/token";
    let token = fs::read_to_string(filename)
        .expect(&format!("Could not read token from file {}", filename));
}
