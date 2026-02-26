CREATE TABLE projects (
  id uuid PRIMARY KEY,
  name text NOT NULL,
  create_by uuid NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),

   FOREIGN KEY (create_by) REFERENCES users(id) ON DELETE CASCADE
);