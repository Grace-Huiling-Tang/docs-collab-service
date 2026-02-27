CREATE TABLE audit_events (
  id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL DEFAULT now(),
  previous_version_id uuid NOT NULL,
  current_version_id uuid NOT NULL,
  event_type text NOT NULL CHECK (event_type IN ('created', 'updated', 'deleted')),
  user_id uuid NOT NULL, -- Foreign key to users table
  project_id uuid NOT NULL, -- Foreign key to projects table
  CONSTRAINT fk_user
    FOREIGN KEY (user_id) REFERENCES users(id),

  CONSTRAINT fk_project
    FOREIGN KEY (project_id) REFERENCES projects(id)
);