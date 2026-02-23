# Elixir4vet - Project TODO

## Missing / Incomplete Features

---

### High Priority

#### 1. Photograph Upload — Backend Only, No UI
- Schema, context (`Elixir4vet.Photographs`), and DB migration all exist
- **Missing:**
  - LiveView file upload handler for photograph processing
  - Upload form on event show/form pages
  - Photo display on event show page
  - Routes for photograph management endpoints
- **Files to update:**
  - `lib/elixir4vet_web/live/admin/event_live/show.ex`
  - `lib/elixir4vet_web/live/admin/event_live/form.ex`
  - `lib/elixir4vet_web/router.ex`

#### 2. Fine-Grained Permission Enforcement Not Wired Into LiveViews
- The RBAC system (`can?/3`, RO/RW/NA levels) is fully built in `lib/elixir4vet/authorization.ex`
- The permissions matrix UI exists for admins to configure it
- **Missing:** `handle_event` callbacks in LiveView modules do not call `can?/3` — only route-level admin/non-admin check is enforced
- A user with RO access could still submit write actions via the socket
- **Files to update:**
  - `lib/elixir4vet_web/live/admin/animal_live/form.ex`
  - `lib/elixir4vet_web/live/admin/event_live/form.ex`
  - `lib/elixir4vet_web/live/admin/user_live/form.ex`
  - `lib/elixir4vet_web/live/admin/organization_live/form.ex`

---

### Medium Priority

#### 3. Animal Owner Reassignment — Creation Only
- Adding an owner works during animal creation via the `owner_id` virtual field
- The owner select dropdown is hidden on the edit form (`if @live_action == :new` condition in form template)
- Context functions `add_animal_owner/4` and `remove_animal_owner/4` exist but are not surfaced in the UI
- **Missing:**
  - Owner management UI on the animal edit form (add/remove owners)
  - Support for ownership types ("owner", "co-owner", "guardian", "foster") in the UI
- **Files to update:**
  - `lib/elixir4vet_web/live/admin/animal_live/form.ex`
  - `lib/elixir4vet_web/live/admin/animal_live/show.ex`

---

### Low Priority

#### 4. Profile Changeset Has No Validation
- `profile_changeset/2` in `lib/elixir4vet/accounts/user.ex` only calls `cast/3`
- **Missing:** `validate_required`, `validate_length`, and phone format validation
- Registration validates phone format but profile updates bypass these checks
- **Files to update:**
  - `lib/elixir4vet/accounts/user.ex`

#### 5. Email Notifications Beyond Authentication
- `UserNotifier` only handles magic link login and email confirmation
- Swoosh is set up and working — just underutilized
- **Missing notifications for:**
  - Event creation / updates
  - Animal ownership changes
  - Role assignment changes
- **Files to update:**
  - `lib/elixir4vet/accounts/user_notifier.ex`

---

*Last Updated: 2026-02-23*
