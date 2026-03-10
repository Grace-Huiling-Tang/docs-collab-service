# Product Requirements Document

## 1. TL;DR
Project Name: Docs-Collab
Owner: Huiling Tang
Product Lead (PM): Jianfeng Peng 
Tech Lead: Huiling Tang
QA Lead: Jianfeng Peng

Docs-Collab is a project-based document collaboration backend designed for small teams such as homeowners, architects, and contractors to manage shared project documents with controlled access and full version history. The MVP focuses on reliable document versioning, role-based access control, and auditability.

---

## 2. Problem Statement

Small project teams often collaborate using fragmented tools:

- email attachments
- Google Drive folders
- messaging apps
- manually renamed file versions

This leads to several issues:

- unclear ownership of documents
- conflicting revisions
- lost historical context
- weak access control
- lack of audit trail

The system aims to provide a structured collaboration backend to address these issues.

## 3. Target Users

Primary users include:

- homeowners managing renovation or construction projects
- architects producing design revisions
- contractors reviewing plans
- designers collaborating on project documents

These teams need a shared workspace to coordinate documents and revisions.

## 4. Product Goals

The system enables teams to:

- organize documents under projects
- control access with role‑based permissions
- maintain immutable document history
- restore past versions
- track critical actions through audit logs

## 5. Core User Workflow

The following workflow illustrates how a typical construction team collaborates using Docs-Collab.

### Example Scenario: Managing a Construction Project

1. **A homeowner creates a project**

  The homeowner creates a project workspace to organize all documents related to a house construction or renovation.

2. **The homeowner adds collaborators**

  The architect and contractor are added to the project as members with appropriate roles.
Example Role assignments:

- Homeowner → `OWNER`
- Family Member → `ADMIN`
 (can review and approve important changes)
- Architect → `EDITOR`
 (can create and update documents)
- Contractor → `VIEWER`
 (can view documents and provide feedback)(provide feedback is out of scope)

3. **The architect creates the initial design document**

  The architect uploads or creates the first document containing the initial design plan or specifications.

4. **The team iterates on the document**

As discussions happen, the architect updates the document with revisions.

Each update creates a **new immutable document version**, ensuring that the full history is preserved.

This allows the team to safely experiment with changes without risking the loss of previous work.

5. **Team members review document history**

  Members can inspect previous versions to understand how the design evolved over time.

6. **A previous version can be restored**

  If a recent revision introduces problems, the team can restore a previous version as the new current version.

7. **All actions are recorded**

  Important actions such as document creation, version updates, and membership changes are recorded in the audit log.

## 6. MVP Scope

The MVP must support:
- Authentication (user registration and login with email/password, issuing **JWT access tokens** for authenticated API access)
- Project creation
- Project membership with **RBAC (Role-Based Access Control)** roles
- Documents with **immutable versioning** (append-only versions)
- Basic **audit logging** for traceability
- CI that runs integration tests against a **fresh PostgreSQL** instance

## 7. Assumptions

The MVP is designed under the following assumptions:

- Documents in the MVP are assumed to be textual content stored directly in the database.
- All collaborators must already have an account in the system.
- Projects are owned by individual users rather than organizations.

## 8. Out of Scope
### Collaboration Features
- Real-time collaborative editing (OT/CRDT)
- In-document comments (inline annotations)

### Sharing & Access
- Public share links / anonymous access
- Invite-by-email

### Advanced Capabilities
- Full-text search
- Document diff rendering

### Infrastructure Extensions
- Binary file storage
- Password reset
- Approval workflows

## 9. Success Metrics

The MVP is considered successful if it satisfies the following criteria:

### Functional Correctness
- Every document update creates a new immutable version.
- The system never allows removal or demotion of the last `OWNER` of a project.
- Role-based permissions are enforced correctly for all protected operations.

### Reliability
- All Flyway migrations succeed on a fresh database.
- Critical project actions are recorded in the audit log.
- Document history remains intact after updates and restores.

### Security
- Passwords are stored only as bcrypt hashes.
- Unauthorized requests are rejected with the correct HTTP status codes.
- Users cannot access projects they are not members of.

### Performance
- Average API response time under normal load is less than 200 ms for read operations.
- List endpoints support pagination to avoid unbounded responses.
