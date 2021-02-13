CREATE TABLE permissions (
  id SERIAL NOT NULL PRIMARY KEY,
  username VARCHAR NOT NULL,
  password VARCHAR NOT NULL,
  email VARCHAR NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON permissions
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_updated_at();

CREATE TABLE group_permissions (
  id SERIAL NOT NULL PRIMARY KEY,
  group_id SERIAL references group(id),
  permission_id SERIAL references permissions(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON group_permissions
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_updated_at();

