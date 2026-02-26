CREATE TABLE projects (
  id uuid PRIMARY KEY,
  name text NOT NULL,
  create_by uuid NOT NULL FOREIGN KEY,
  created_at timestamptz NOT NULL DEFAULT now()
);