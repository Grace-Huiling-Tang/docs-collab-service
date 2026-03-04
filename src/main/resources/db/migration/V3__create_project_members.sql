CREATE TABLE projects_members(
    project_id uuid,
    user_id uuid,
    role text NOT NULL,
    added_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (project_id, user_id),

    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id)    REFERENCES users(id)    ON DELETE CASCADE,

    CONSTRAINT chk_project_members_role CHECK (role IN ('OWNER','ADMIN','EDITOR','VIEWER'))
);