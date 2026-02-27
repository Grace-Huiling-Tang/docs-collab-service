CREATE TABLE audit_events (
  id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL DEFAULT now(),
  version_id uuid, 
  event_type text NOT NULL CHECK (event_type IN ('created','updated','deleted','member_added','member_removed','role_change')),
CHECK (
  (event_type IN ('created','updated','deleted') AND version_id IS NOT NULL AND target_user_id IS NULL)
  OR
  (event_type IN ('member_added','member_removed','role_change') AND version_id IS NULL AND target_user_id IS NOT NULL)
)
, -- Type of event
  actor_user_id uuid NOT NULL, -- Foreign key to users table
  project_id uuid NOT NULL, -- Foreign key to projects table
    target_user_id uuid,
  CONSTRAINT fk_user
    FOREIGN KEY (actor_user_id) REFERENCES users(id) ON DELETE RESTRICT,
CONSTRAINT fk_project
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE RESTRICT,
    FOREIGN KEY (version_id) REFERENCES document_versions(id),
    FOREIGN KEY (target_user_id) REFERENCES users(id)
);