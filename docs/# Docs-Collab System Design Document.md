# Docs-Collab System Design Document


## 1. Overview


Docs-Collab is a project-based document collaboration backend for small teams such as homeowners, architects, contractors, and designers.


The system is designed to support:


- project-scoped document ownership
- role-based access control
- immutable document version history
- auditability of key project actions


This document describes the technical design of the MVP system.


---


## 2. Goals and Non-Goals


### Goals


The MVP system must support:


- authenticated users
- project creation and membership
- project-level RBAC
- document creation and updates
- immutable document versioning
- version history and restore flow
- audit logging for critical actions
- deterministic database setup with Flyway


### Non-Goals


The MVP does not support:


- real-time collaborative editing
- inline comments
- full-text search
- public share links
- binary file storage
- invite-by-email
- approval workflows
- advanced analytics


---


## 3. Architecture Overview


### 3.1 Architecture Options Considered
Several architecture styles were considered for the system:
**1. Microservices Architecture**
Each domain (auth, projects, documents, audit) would be implemented as an independent service with its own deployment and database.
Advantages:
- independent scaling
- strong service isolation
- suitable for large organizations
Disadvantages:
- significantly higher operational complexity
- distributed transactions become difficult
- service coordination overhead
- unnecessary for the scale of the MVP
---
**2. Traditional Monolith**
All functionality implemented in a single application with minimal internal modular separation.
Advantages:
- simplest architecture
- fastest to implement
Disadvantages:
- weak internal boundaries
- codebase may become difficult to maintain as the system grows
---
**3. Modular Monolith (Chosen)**
A single deployable backend application with clearly separated internal modules.
Advantages:
- low operational complexity
- easy local development
- strong logical separation between domains
- can evolve into microservices later if needed
Trade-off:
- cannot independently scale modules
- requires discipline to maintain clean module boundaries
---
### Final Decision
The MVP adopts a **modular monolith architecture** because it balances simplicity and maintainability while avoiding premature distributed complexity.


### 3.2 High-Level Components


The main logical components are:


- Auth Module
- Project & Membership Module
- Document Module
- Audit Module


---


## 4. Technology Decisions


### 4.1 Backend Framework Selection


Several backend framework options were considered for the MVP.


**1. Node.js (Express / NestJS)**


Advantages:
- fast development speed
- strong ecosystem for REST APIs
- good fit for JavaScript/TypeScript-based teams


Disadvantages:
- weaker architectural constraints in lightweight setups
- easier for codebases to become inconsistent without strong discipline
- less naturally aligned with enterprise-style layered backend design


---


**2. Python (FastAPI)**


Advantages:
- concise syntax
- rapid API development
- strong developer productivity
- good automatic API documentation support


Disadvantages:
- weaker compile-time guarantees compared to Java
- less opinionated for large backend architectures
- may require more discipline to maintain strict layering over time


---


**3. Java (Spring Boot) — Chosen**


Advantages:
- strong type safety
- mature ecosystem for backend systems
- excellent support for layered architecture
- strong integration with relational databases, migrations, and testing tools
- well suited for business-rule-heavy systems


Disadvantages:
- more verbose than lightweight frameworks
- higher initial setup and learning overhead


---


### Final Decision


Spring Boot was selected because the MVP is a backend-heavy system with strong relational data requirements, role-based authorization rules, immutable versioning, and audit logging.


The project benefits more from structural clarity, type safety, and mature backend tooling than from maximum prototyping speed.


### 4.2 Database Selection


Several database technologies were evaluated.
**1. MongoDB**
Advantages:
- flexible schema
- easy iteration during early product development
Disadvantages:
- weak relational integrity
- lack of strong foreign key constraints
- more complex transaction semantics
Because the system relies heavily on relationships such as:
- project membership
- document ownership
- version history
- audit events
a document database would introduce additional complexity.
---
**2. MySQL**
Advantages:
- mature relational database
- widely adopted
Disadvantages:
- fewer advanced features compared to PostgreSQL
- weaker JSON support
---
**3. PostgreSQL (Chosen)**
Advantages:
- strong relational guarantees
- robust transaction support
- excellent indexing capabilities
- native JSONB support for flexible audit metadata
Trade-off:
- schema changes require migrations
- slightly more rigid than document databases
---
### Final Decision
PostgreSQL is chosen because the system depends heavily on relational consistency and transactional integrity.


### 4.3 Database Migration Tool


Several approaches were considered for managing database schema changes.


**1. Manual SQL scripts**


Advantages:
- simple for very small projects
- full control over raw SQL


Disadvantages:
- hard to track schema history consistently
- error-prone in team environments
- no standardized migration ordering or execution model


---


**2. Liquibase**


Advantages:
- powerful schema management features
- supports advanced migration workflows
- strong enterprise adoption


Disadvantages:
- more verbose
- higher configuration complexity
- heavier than necessary for the MVP


---


**3. Flyway — Chosen**


Advantages:
- simple versioned migration model
- easy to understand and maintain
- strong fit for SQL-first schema evolution
- integrates well with Spring Boot and CI workflows


Disadvantages:
- fewer advanced migration features than Liquibase
- requires careful discipline in migration ordering


---


### Final Decision


Flyway was selected because the system benefits from a straightforward, versioned migration workflow that keeps schema evolution deterministic and easy to validate in CI.


The MVP prioritizes clarity and reliability over advanced migration features.


### 4.4 Authentication Strategy


Several authentication approaches were considered for the MVP.


**1. Session-based authentication**


Advantages:
- simple mental model
- easy server-side session invalidation


Disadvantages:
- requires server-side session storage
- less convenient for stateless API architectures
- adds complexity for horizontal scaling


---


**2. OAuth / SSO**


Advantages:
- integrates with third-party identity providers
- useful for enterprise environments


Disadvantages:
- introduces unnecessary complexity for the MVP
- requires additional setup and provider integration
- not aligned with the current scope


---


**3. JWT-based authentication — Chosen**


Advantages:
- stateless authentication model
- simple for API-based systems
- easy to integrate with frontend or future clients
- works well for small MVP deployments


Disadvantages:
- token revocation is harder than session invalidation
- requires careful token expiration handling
- token contents should not be treated as secret


---


### Final Decision


JWT-based authentication was chosen because the MVP is an API-driven backend and benefits from a simple stateless authentication mechanism.


Advanced features such as refresh tokens, password reset, email verification, and SSO are intentionally deferred to keep the MVP focused.
---


## 5. Domain Model


The core domain entities are:


- `User`
- `Project`
- `ProjectMember`
- `Document`
- `DocumentVersion`
- `AuditEvent`


### 5.1 User
Represents an authenticated account in the system.


### 5.2 Project
Represents a collaboration workspace.


A project is the main ownership boundary for documents, membership, and audit events.


### 5.3 ProjectMember
Represents the membership relationship between a user and a project.


This entity also stores the member’s role.


### 5.4 Document
Represents the stable identity of a document inside a project.


A document is a container for multiple immutable versions.


### 5.5 DocumentVersion
Represents one immutable version of a document.


### 5.6 AuditEvent
Represents a traceable business event such as project creation, role change, document creation, or version update.


---


## 6. Data Model / Schema Design


### 6.1 Users


Stores user identity and authentication data.


Key fields:


- `id`
- `email`
- `password_hash`
- `created_at`


Constraints:


- `email` must be unique


### 6.2 Projects


Stores project metadata.


Key fields:


- `id`
- `name`
- `created_by`
- `status`
- `created_at`


Notes:


- `status` may support values such as `ACTIVE` and `ARCHIVED`


### 6.3 Project Members


Stores project membership and role assignment.


Key fields:


- `project_id`
- `user_id`
- `role`
- `joined_at`


Constraints:


- one membership row per `(project_id, user_id)`


### 6.4 Documents


Stores stable document identity.


Key fields:


- `id`
- `project_id`
- `title`
- `latest_version_id`
- `created_by`
- `created_at`


Key design decision:


- document content is **not** stored directly in this table
- content lives in `document_versions`


### 6.5 Document Versions


Stores immutable document content history.


Key fields:


- `id`
- `document_id`
- `version_number`
- `content`
- `created_by`
- `created_at`


Constraints:


- `(document_id, version_number)` must be unique
- historical rows are immutable


### 6.6 Audit Events


Stores traceable project events.


Key fields:


- `id`
- `project_id`
- `actor_user_id`
- `event_type`
- `metadata`
- `created_at`


Notes:


- `metadata` can store context such as `document_id`, `version_id`, `old_role`, and `new_role`


---


## 7. Authorization Model


The system uses project-level RBAC.


Supported roles:


- `OWNER`
- `ADMIN`
- `EDITOR`
- `VIEWER`


### Permission Model


- `OWNER`
  - full project control
  - can manage roles and members
  - can manage documents
  - soft delete project (status->archived)


- `ADMIN`
  - can manage documents and versions
  - add and remove members
  - cannot modify OWNER roles
  - can manage non-owner memberships and roles


- `EDITOR`
  - can create documents
  - can modify documents (create new versions)
  - can read project content


- `VIEWER`
  - read-only access to project documents and version history


### Critical Rule


The system must never allow removal or demotion of the last `OWNER` in a project.


Authorization must be enforced server-side.


---
## 8. Document Versioning Design


Two main approaches were considered.


### Option 1: In-place Updates


Each document stores its content directly, and updates overwrite the existing content.


Advantages:
- simpler schema
- fewer tables
- faster read queries


Disadvantages:
- no reliable history
- difficult to audit changes
- impossible to restore past versions


---


### Option 2: Immutable Version History (Chosen)


Each update creates a new row in a `document_versions` table.


Advantages:
- complete historical traceability
- safe rollback to previous versions
- strong support for auditing and debugging


Trade-off:
- additional storage overhead
- slightly more complex queries
- requires a pointer to track the latest version


---


### Final Decision


The system adopts an **append-only immutable version model**, which aligns with the requirement for document traceability and safe revision management.
### Rules


- creating a document also creates version 1
- updating a document creates a new version row
- previous versions are never overwritten
- `documents.latest_version_id` points to the current version


### Restore Strategy


Restoring an old version does **not** modify the historical row.


Instead, the system creates a brand new version whose content is copied from the selected historical version.


This preserves a complete history.


---


## 9. Collaboration Model


Two collaboration models were considered.


**1. Real-time collaborative editing (OT / CRDT)**


Advantages:
- allows multiple users to edit the same document simultaneously
- provides a Google Docs–like experience


Disadvantages:
- significantly higher implementation complexity
- requires complex conflict resolution algorithms
- introduces additional synchronization infrastructure


---


**2. Version-based collaboration (Chosen)**


Users update documents by creating new versions rather than editing simultaneously.


Advantages:
- significantly simpler implementation
- strong historical traceability
- easier to reason about consistency


Trade-off:
- no real-time editing experience
- users must coordinate edits manually


---


### Final Decision


The MVP adopts **version-based collaboration**, which provides sufficient functionality while keeping system complexity manageable.


### Concurrency Control Strategy


The system uses **optimistic concurrency control**. When a client updates a document, it must provide the version it last read, for example:


- `expected_version_number`


If the document has changed since that read, the update is rejected with:


- `409 Conflict`


### Why


This prevents lost updates while keeping the MVP simpler than real-time collaborative editing.


---


## 10. Audit Logging


The system records audit events for critical actions, including:


- project creation
- member addition
- member removal
- role changes
- document creation
- document version creation
- version restore


### Design Requirement


Audit inserts should happen in the same transaction as the corresponding business action.


This ensures that audit records and business state remain consistent.


---


## 11. API Design


The API follows a resource-oriented REST style.


Illustrative routes:


### Authentication
- `POST /auth/register`
- `POST /auth/login`


### Projects
- `POST /projects`
- `GET /projects/{projectId}`


### Project Members
- `POST /projects/{projectId}/members`
- `PATCH /projects/{projectId}/members/{userId}`
- `DELETE /projects/{projectId}/members/{userId}`


### Project Documents
- `POST /projects/{projectId}/documents`
   - Creates a new document and automatically initializes version 1.
- `GET /projects/{projectId}/documents`


### Document Details and Versions
- `POST /documents/{documentId}/versions`
   - Creates a new immutable version for an existing document.
- `GET /documents/{documentId}`
- `GET /documents/{documentId}/versions`
- `POST /documents/{documentId}/restore`


### Audit Events
- `GET /projects/{projectId}/audit-events`


List endpoints should support pagination.


---


## 12. Error Handling


The API uses consistent HTTP status codes to communicate failure semantics to clients.  
This allows clients to reliably distinguish authentication failures, authorization failures, missing resources, and business rule conflicts.


Standard error semantics:


- `401 Unauthorized`
  - missing, invalid, or expired JWT


- `403 Forbidden`
  - authenticated but not allowed to perform the operation


- `404 Not Found`
  - resource does not exist, or is intentionally hidden


- `409 Conflict`
  - optimistic concurrency conflict
  - uniqueness conflict
  - business rule violation (e.g., removing the last `OWNER`)


---


## 13. Testing Strategy


Testing focuses on protecting critical domain invariants and ensuring that authorization, versioning, and transactional behavior remain correct.


### Unit Tests


Unit tests should cover:


- RBAC decision behavior
- last-owner protection
- version number increment logic
- restore-as-new-version logic
- optimistic concurrency validation


### Integration Tests


Integration tests validate interactions with the database and ensure that persistence behavior matches system expectations.
Integration tests should cover:


- Flyway migrations on a fresh database
- repository behavior
- transactional writes
- audit logging atomicity
- end-to-end document version flows


### Critical Scenarios


Important scenarios include:


- project creator becomes `OWNER`
- `VIEWER` cannot modify documents
- `EDITOR` can create a new version
- removing the last `OWNER` fails
- stale document updates return `409 Conflict`


All integration tests are executed in CI against a freshly provisioned PostgreSQL instance to ensure migrations and database interactions remain correct across environments.


---


## 14. Future Evolution


The current MVP architecture is intentionally scoped for project-based, version-based collaboration.  
However, the design leaves room for future technical evolution.


### Collaboration Features
**Real-time collaborative editing (OT/CRDT)**  
Future support for real-time collaborative editing would likely require:
- a synchronization layer for concurrent edits
- WebSocket or similar real-time communication infrastructure
- an operational model such as OT or CRDT
- conflict resolution logic for simultaneous edits
- client/server coordination beyond simple version submission
This is intentionally out of scope for the MVP because it changes the system from a version-based collaboration model into a real-time collaborative editing system.


**In-document comments (inline annotations)**  
Future support for inline comments would likely require:
- a dedicated `comments` entity rather than embedding comments into document content
- comment-to-document or comment-to-version associations
- optional anchoring to ranges or positions within textual content
- comment lifecycle states such as `OPEN` and `RESOLVED`
- additional authorization rules for who can create, view, and resolve comments
This is intentionally out of scope for the MVP because the current version focuses on core document ownership, immutable version history, and RBAC.


### Sharing & Access
**Public Share Links / Anonymous Access**
Future support for public sharing would likely require:
- a dedicated `share_links` model separate from project membership
- secure token generation for shareable URLs
- token-based authorization for anonymous users
- access policies such as read-only shared access
- expiration and revocation support for shared links
- audit events for link creation, revocation, and access
- optional rate limiting or abuse protection
This is intentionally out of scope for the MVP because it introduces a second access-control model beyond authenticated project membership.


**Email-based Invitations**  
Future support for email-based invitations would likely require:
- an invitation model separate from active project membership
- invitation tokens with expiration
- pending invitation states such as `PENDING`, `ACCEPTED`, and `EXPIRED`
- email delivery integration
- a join flow that converts an accepted invitation into a project membership
This is intentionally out of scope for the MVP because the current system assumes that all collaborators already have registered accounts.


### Advanced Capabilities
**Document Diff APIs**
Future support for document diff APIs would likely require:
- endpoints for comparing two versions of the same document
- a diff generation strategy for textual content
- version selection parameters such as `from_version` and `to_version`
- response models that can represent additions, deletions, and unchanged sections
This is intentionally out of scope for the MVP because the current system only needs version history and restore capability, not semantic comparison between versions.
**Search**
Future support for search would likely require:
- an indexing strategy for document titles and content
- search-specific query endpoints
- relevance ranking and filtering
- possible integration with a dedicated search engine if scale grows


This is intentionally out of scope for the MVP because the current system focuses on correctness of ownership, versioning, and access control rather than retrieval optimization.
### Infrastructure Extensions
**Password Reset**
Future support for password reset would require:
- a password reset token model
- secure token generation
- expiration and one-time-use enforcement
- email delivery integration
- rate limiting to prevent abuse
This is intentionally out of scope for the MVP because the initial system focuses on core document collaboration functionality.


**Binary File Storage**
Future support for binary file storage would likely require:
- moving document content storage from the database to an object storage system
- storing file metadata such as filename, MIME type, size, and storage key
- upload/download flows for binary content
- possible preview integration for supported file types
This is intentionally out of scope for the MVP because the current design assumes text-based document content stored directly in the database.


**Approval Workflows**
Future support for approval workflows would likely require:
- document or version states such as `DRAFT`, `PENDING_APPROVAL`, `APPROVED`, and `REJECTED`
- additional permissions for submit, review, approve, and reject actions
- workflow rules defining who can approve which changes
- audit logging for approval state transitions
This is intentionally out of scope for the MVP because it introduces a significantly more complex workflow model than simple version-based collaboration.


---


## 15. Open Questions / Trade-offs


### 15.1 Role Design
The MVP uses project-level roles only.  
A future version may introduce document-level permissions if needed.


### 15.2 Content Storage
The MVP assumes text-based document content stored directly in the database.  
A future version may move binary files to object storage.


### 15.3 Resource Visibility Policy
Unauthorized access should hides existence with `404`.


### 15.4 Project Lifecycle
The MVP should clarify whether projects and documents support hard delete or archive-only behavior.











