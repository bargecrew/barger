CREATE TABLE configurations (
  id SERIAL PRIMARY KEY,
  key VARCHAR NOT NULL,
  value VARCHAR NOT NULL,
  service_id INTEGER REFERENCES services (id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (key, service_id)
);

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON configurations
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_updated_at();
