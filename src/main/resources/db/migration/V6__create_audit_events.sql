CREATE TABLE audit_events (
  id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL DEFAULT now(),

  event_type text NOT NULL,
  actor_user_id uuid NOT NULL,
  project_id uuid NOT NULL,

  -- extensible metadata
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,

  CONSTRAINT fk_actor_user
    FOREIGN KEY (actor_user_id) REFERENCES users(id) ON DELETE RESTRICT,

  CONSTRAINT fk_project
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE RESTRICT

);
