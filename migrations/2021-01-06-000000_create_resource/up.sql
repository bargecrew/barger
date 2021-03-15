CREATE TABLE resources (
  id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  content JSON NOT NULL,
  service_id INTEGER REFERENCES services (id),
  change_set_id INTEGER REFERENCES change_sets (id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (name, service_id, change_set_id)
);

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON resources
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_updated_at();
