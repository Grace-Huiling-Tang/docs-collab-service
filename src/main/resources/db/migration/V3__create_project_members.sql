CREATE TABLE projects_members(
    project_id uuid,
    user_id uuid,
    role text (CHECK role in ('OWNER','ADMIN','EDITOR','VIEWER')),
    added_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (project_id, user_id),

    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id)    REFERENCES users(id)    ON DELETE CASCADE
);
