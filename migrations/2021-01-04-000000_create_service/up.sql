CREATE TABLE services (
  id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL UNIQUE,
  group_id INTEGER REFERENCES groups (id),
  cluster_id INTEGER REFERENCES clusters (id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON services
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_updated_at();
