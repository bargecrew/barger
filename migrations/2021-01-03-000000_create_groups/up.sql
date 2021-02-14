CREATE TABLE groups (
  id SERIAL NOT NULL PRIMARY KEY,
  name VARCHAR NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON groups
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_updated_at();

CREATE TABLE user_groups (
  id SERIAL NOT NULL PRIMARY KEY,
  user_id SERIAL references users(id),
  group_id SERIAL references groups(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON user_groups
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_updated_at();
