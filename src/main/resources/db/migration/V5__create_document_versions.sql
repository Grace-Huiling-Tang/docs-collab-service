CREATE TABLE document_versions(
    id uuid PRIMARY KEY,
    document_id uuid NOT NULL,
    version_number int NOT NULL CHECK (version_number>=1), 
    content text NOT NULL,
    created_by uuid NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),

    FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE RESTRICT,
    UNIQUE (document_id, version_number)
);
    
ALTER TABLE documents
    ADD CONSTRAINT fk_documents_latest_version
    FOREIGN KEY (latest_version_id)
    REFERENCES document_versions(id)
    ON DELETE SET NULL;