This file tracks milestones and definitions of done for the Docs Collaboration Service.


# Docs Collaboration Service - Roadmap

1) Microservice-style REST backend for project-scoped documents with RBAC (Owner/Admin/Editor/Viewer) and clean layered design (controller/service/repo).
2) Document metadata + immutable versioning with a latest-version pointer and audit logging for traceability.
3) PostgreSQL presistence via Flyway migrations and CI (Github Acitons) to run automated builds/tests on every push/PR.

## Milestones (Vertical Slices)

### Slice 1 - Auth + Flyway baseline
**Deliverables**
- Flyway migrations: 'user', 'projects', 'project_members'
- Auth endpoints:
    - 'POST /auth/register' (BCrypt)
    - 'POST /auth/login' (JWT)
    - 'GET /me' (protected)
- Email normalized storage (trim + lowercase)

**Definition of Done**
- Starting from an empty DB, flyway creates schema automatically
- Register/login works; '/me' returns 200 with token, 401 without/invalid token
- Automated tests cover auth happy path + failure cases

---

### Slice 2 - Projects + RBAC
**Deliverables**
- 'POST /projects' creates project and assigns creator as OWNER
- Membership management (Owner/Admin): add member, update role, remove member
- Centralized authorization checks in service layer

**Definition of Done**
- RBAC matrix enforced with correct 401 vs 403 behavior
- Tests cover role-based allow/deny

---

### Slice 3 - Documents + Immutable Versioning + Lateest Pointer
**Deliverables**
- Flyway migrations: 'documents', 'document_versions'
- Create document => creates version 1 and sets 'latest_version_id'
- Update document => creates new version N+1 (no in-place updates)

**Definition of Done**
- Old versions never change
- Latest pointer always points to newest version after update (transactional)
- Read-latest is efficient via latest pointer
- Tests cover version creation and retrieval

---

### Slice 4 - Audit Logging + Concurrency Safety
**Deliverables**
- Flyway migrations: 'audit_events'
- Audit events recorded for key actions (project/member/document/version)
- Concurrency strategy: perssimistic locking for version creation

**Definition of Done**
- Audit endpoint returns trace of actions per project
- Concurrent saves do not product duplicate (document_id, version_number)
- Tests cover concurrency + integrity constraints