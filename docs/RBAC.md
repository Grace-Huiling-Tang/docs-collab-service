# RBAC Matrix (Project-scoped)

## Roles
- OWNER 
- ADMIN 
- EDITOR 
- VIEWER

## General Rules
- Authentication uses JWT (401 if missing/invalid/expired token).
- Authorization is project-scoped via project_members role (403 if authenticated but not allowed).
- All documents operations mus verify membership in the target project.

## Permissions (initial MVP)
| ACTION | VIEWER | EDITOR | ADMIN | OWNER |
|---|---:|---:|---:|---:|
| View project documents & versions | Allowed | Allowed | Allowed | Allowed |
| Create document (creates version 1) | Forbidden | Allowed | Allowed | Allowed |
| Create new document version | Forbidden | Allowed | Allowed | Allowed |
| Manage members (add/remove/update roles) | Forbidden | Forbidden | Allowed | Allowed |
| View audit log | Forbidden | Allowed | Allowed | Allowed |



