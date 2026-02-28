CREATE TABLE audit_events (
  id uuid PRIMARY KEY,
  created_at timestamptz NOT NULL DEFAULT now(),
  version_id uuid, 
  -- create, delete are for version events, member_added, member_removed, role_change are for membership events, udpate is for project info update like description, name, etc, In practice, updated content will not be stored. Just print, project setting updated.
  event_type text NOT NULL CHECK (
  (event_type IN ('created','deleted') AND version_id IS NOT NULL AND actor_user_id IS NOT NULL AND project_id IS NOT NULL AND target_user_id IS NULL)
  OR
  (event_type = 'updated' AND version_id IS NULL AND actor_user_id IS NOT NULL AND project_id IS NOT NULL AND target_user_id IS NULL)
  OR
  (event_type IN ('member_added','member_removed','role_change') AND project_id IS NOT NULL AND target_user_id IS NOT NULL AND version_id IS NULL AND actor_user_id IS NOT NULL)
),
 -- Type of event
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