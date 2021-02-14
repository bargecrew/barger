CREATE TABLE tokens (
  id SERIAL NOT NULL PRIMARY KEY,
  token VARCHAR NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON tokens
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_updated_at();

CREATE TABLE user_tokens (
  id SERIAL NOT NULL PRIMARY KEY,
  user_id SERIAL references users(id),
  token_id SERIAL references tokens(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON user_tokens
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_updated_at();
