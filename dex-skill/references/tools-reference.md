# Dex Tools Reference

Complete parameter documentation for all Dex MCP tools.

## Table of Contents

- [Contacts](#contacts)
  - [dex_search_contacts](#dex_search_contacts)
  - [dex_list_contacts](#dex_list_contacts)
  - [dex_get_contact](#dex_get_contact)
  - [dex_create_contact](#dex_create_contact)
  - [dex_update_contact](#dex_update_contact)
  - [dex_complete_keep_in_touch](#dex_complete_keep_in_touch)
  - [dex_archive_contacts](#dex_archive_contacts)
  - [dex_delete_contacts](#dex_delete_contacts)
  - [dex_merge_contacts](#dex_merge_contacts)
  - [dex_filter_contacts](#dex_filter_contacts)
- [Tags](#tags)
  - [dex_list_tags](#dex_list_tags)
  - [dex_get_tag](#dex_get_tag)
  - [dex_create_tag](#dex_create_tag)
  - [dex_update_tag](#dex_update_tag)
  - [dex_delete_tag](#dex_delete_tag)
  - [dex_add_tags_to_contacts](#dex_add_tags_to_contacts)
  - [dex_remove_tags_from_contacts](#dex_remove_tags_from_contacts)
- [Groups](#groups)
  - [dex_list_groups](#dex_list_groups)
  - [dex_get_group](#dex_get_group)
  - [dex_create_group](#dex_create_group)
  - [dex_update_group](#dex_update_group)
  - [dex_delete_group](#dex_delete_group)
  - [dex_add_contacts_to_group](#dex_add_contacts_to_group)
  - [dex_remove_contacts_from_group](#dex_remove_contacts_from_group)
  - [dex_list_group_contacts](#dex_list_group_contacts)
- [Notes](#notes)
  - [dex_list_notes](#dex_list_notes)
  - [dex_get_note](#dex_get_note)
  - [dex_list_note_types](#dex_list_note_types)
  - [dex_create_note](#dex_create_note)
  - [dex_update_note](#dex_update_note)
  - [dex_delete_note](#dex_delete_note)
- [Reminders](#reminders)
  - [dex_list_reminders](#dex_list_reminders)
  - [dex_get_reminder](#dex_get_reminder)
  - [dex_create_reminder](#dex_create_reminder)
  - [dex_update_reminder](#dex_update_reminder)
  - [dex_delete_reminder](#dex_delete_reminder)
- [Custom Fields](#custom-fields)
  - [dex_list_custom_fields](#dex_list_custom_fields)
  - [dex_create_custom_field](#dex_create_custom_field)
  - [dex_update_custom_field](#dex_update_custom_field)
  - [dex_delete_custom_field](#dex_delete_custom_field)
  - [dex_set_custom_field_values](#dex_set_custom_field_values)
- [Calendar](#calendar)
  - [dex_list_calendar_events](#dex_list_calendar_events)
  - [dex_get_calendar_event](#dex_get_calendar_event)
  - [dex_create_calendar_event](#dex_create_calendar_event)
  - [dex_update_calendar_event](#dex_update_calendar_event)
  - [dex_delete_calendar_event](#dex_delete_calendar_event)
- [Email](#email)
  - [dex_search_emails](#dex_search_emails)

---

## Contacts

### dex_search_contacts

Search contacts by name, email, or any keyword. Returns up to `limit` results. Use an empty query to list contacts sorted by most recently interacted.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | string | Yes | Keyword query. Use empty string when `near` is the only filter or to browse by last interaction |
| `near` | string | No | Place for real geographic proximity search, such as `Bay Area` or `Sydney` |
| `radius_km` | number | No | Positive radius around `near` in kilometers (default 50) |
| `limit` | number | No | Max results (default 50, max 200) |

**Returns:** `{ items: Contact[], count: number }`

**Note:** Search returns a single batch up to `limit`. For paginated iteration over all contacts, use `dex_list_contacts` instead.

```json
{ "query": "Acme Corp" }
{ "query": "engineer", "near": "Bay Area", "radius_km": 75 }
{ "query": "", "limit": 20 }
```

When using `near`, do not repeat the place in `query`; the two fields combine with AND, so repeating it can over-filter results.

---

### dex_list_contacts

List all contacts with cursor-based pagination. Returns lightweight summaries (id, name, company, job title). Use `dex_get_contact` for full details. Use `dex_search_contacts` for keyword search.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `cursor` | string | No | Pagination cursor from previous response |
| `limit` | number | No | Results per page (default 100, max 500) |

**Returns:** `{ items: ContactSummary[], has_more: boolean, next_cursor?: string, count?: number }`

```json
{ "limit": 500 }
{ "cursor": "abc123", "limit": 100 }
```

---

### dex_get_contact

Get a single contact by ID with emails, phone numbers, saved/geocoded location, keep-in-touch cadence, tags, groups, custom fields, and optionally recent notes/timeline.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Contact ID |
| `include_notes` | boolean | No | Include recent notes/timeline items (default false) |

**When to use `include_notes: true`:** user wants interaction history, meeting prep, or context about a relationship.

---

### dex_create_contact

Create one or more contacts. Supports two modes:

- **Single mode:** Pass fields directly (backward compatible)
- **Batch mode:** Pass a `contacts` array for bulk creation (e.g. CSV import, up to 100 at once)

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `first_name` | string | No | First name (single mode) |
| `last_name` | string | No | Last name (single mode) |
| `company` | string | No | Company name (single mode) |
| `job_title` | string | No | Job title (single mode) |
| `email` | string | No | Single email address shorthand (single mode) |
| `emails` | array | No | Email addresses: `[{ email, label? }]` (single mode) |
| `phone` | string | No | Single phone number shorthand (single mode) |
| `phones` | array | No | Phone numbers: `[{ phone_number, label?, country_code? }]` (single mode) |
| `linkedin` | string | No | LinkedIn profile URL (single mode) |
| `twitter` | string | No | Twitter/X handle (single mode) |
| `birthday` | string | No | Birthday YYYY-MM-DD (single mode) |
| `description` | string | No | Notes about the contact (single mode) |
| `website` | string | No | Website URL (single mode) |
| `contacts` | array | No | Array of contacts for batch creation (max 100). Each item accepts the same fields above. When provided, top-level fields are ignored. |

**Single mode example:**
```json
{
  "first_name": "Jane",
  "last_name": "Doe",
  "company": "Acme Corp",
  "job_title": "VP Engineering",
  "email": "jane@acme.com"
}
```

**Batch mode example (CSV import):**
```json
{
  "contacts": [
    { "first_name": "Jane", "last_name": "Doe", "email": "jane@acme.com", "company": "Acme Corp" },
    { "first_name": "John", "last_name": "Smith", "email": "john@example.com", "company": "Example Inc" },
    { "first_name": "Alice", "last_name": "Chen", "email": "alice@startup.io", "job_title": "CTO" }
  ]
}
```

---

### dex_update_contact

Partial update — only provided fields are changed. For emails and phone numbers, use `add_*` / `remove_*` params — existing entries are preserved automatically.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string | Yes | Contact ID to update |
| `first_name` | string | No | First name |
| `last_name` | string | No | Last name |
| `company` | string | No | Company name |
| `job_title` | string | No | Job title |
| `email` | string | No | Add a single email (shorthand for `add_emails`) |
| `add_emails` | array | No | Emails to add: `[{ email, label? }]` |
| `remove_emails` | string[] | No | Email addresses to remove |
| `phone` | string | No | Add a single phone (shorthand for `add_phones`) |
| `add_phones` | array | No | Phones to add: `[{ phone_number, label?, country_code? }]` |
| `remove_phones` | string[] | No | Phone numbers to remove |
| `linkedin` | string | No | LinkedIn profile URL |
| `twitter` | string | No | Twitter/X handle |
| `birthday` | string | No | Birthday (YYYY-MM-DD) |
| `description` | string | No | Notes about the contact |
| `website` | string | No | Website URL |
| `starred` | boolean | No | Star/unstar contact |
| `keep_in_touch` | enum | No | Cadence: `7 days`, `14 days`, `1 mon`, `42 days`, `3 mons`, `6 mons`, `1 year`, `never`, or `unset` |
| `is_archived` | boolean | No | Archive/unarchive one contact; use `dex_archive_contacts` for bulk cleanup |

```json
{
  "id": "contact-uuid",
  "add_emails": [{ "email": "new@work.com", "label": "Work" }],
  "remove_phones": ["+15559999999"]
}
```

---

### dex_complete_keep_in_touch

Complete or snooze a contact's keep-in-touch cadence.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `contact_id` | string | Yes | Contact ID |
| `snooze_days` | integer or null | No | Positive number of days to defer without recording a touch; omit to mark the cadence complete |

Completing records that the user was just in touch and recalculates the next reminder from the contact's cadence. Snoozing only moves the next reminder.

```json
{ "contact_id": "contact-uuid" }
{ "contact_id": "contact-uuid", "snooze_days": 7 }
```

---

### dex_archive_contacts

Archive or restore up to 500 contacts while preserving notes, reminders, and history. Prefer this reversible operation over deletion for cleanup.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `contact_ids` | string[] (UUID) | Yes | Contact IDs to archive or restore (max 500) |
| `archived` | boolean | No | `true` (default) archives; `false` restores |

Archived contacts are hidden from default lists, search, and keep-in-touch reminders. Find them with `dex_filter_contacts` and `archived_only: true`.

```json
{ "contact_ids": ["c1", "c2"], "archived": true }
```

---

### dex_delete_contacts

Delete one or more contacts. Irreversible — confirm with the user and prefer `dex_archive_contacts` when recovery may matter.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `contact_ids` | string[] | Yes | Contact IDs to delete (min 1) |

---

### dex_merge_contacts

Merge duplicate contacts. Dex automatically keeps the oldest record in each group, regardless of input order, combines data onto it, and deletes the others.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `contact_id_groups` | string[][] | Yes | Groups of IDs to merge (each group min 2 IDs) |

```json
{
  "contact_id_groups": [
    ["contact-id-1a", "contact-id-1b", "contact-id-1c"],
    ["contact-id-2a", "contact-id-2b"]
  ]
}
```

Read `mergedContactIds` from the result to identify the survivor; never infer it from input order.

---

### dex_filter_contacts

Filter contacts with the same structured filters as Dex views. Conditions combine with AND. Use this instead of keyword search when the request specifies tags, groups, profile presence, dates, archived state, or custom fields.

| Parameter | Type | Description |
|-----------|------|-------------|
| `tags` / `exclude_tags` | string[] | Tag IDs or exact names to include or exclude |
| `tags_match` | enum | `any` (default) or `all` |
| `groups` / `exclude_groups` | string[] | Group IDs or exact names to include or exclude |
| `groups_match` | enum | `any` (default) or `all` |
| `name` | string | Fuzzy name match |
| `company` | string | Fuzzy company match |
| `job_title` | string | Fuzzy job-title match |
| `education` | string | Fuzzy education match |
| `description_contains` | string | Contact description contains text |
| `location` | string | Fuzzy saved-location text match |
| `near` | string | Real geographic proximity around a place |
| `radius_km` | number | Positive radius around `near` in kilometers (default 50) |
| `has_linkedin` | boolean | Require or exclude a LinkedIn profile |
| `linkedin_company` | string | LinkedIn work history contains company |
| `linkedin_education` | string | LinkedIn education history contains school |
| `has_twitter` / `has_instagram` | boolean | Require or exclude social handles |
| `has_email` / `has_phone` | boolean | Require or exclude contact methods |
| `starred` | boolean | Filter by starred state |
| `archived_only` | boolean | `true` returns only archived contacts; default returns active contacts |
| `last_interaction_after` / `last_interaction_before` | ISO datetime | Bound the last interaction |
| `created_after` / `created_before` | ISO datetime | Bound contact creation time |
| `custom_fields` | object[] | AND filters with `field_id`, `operator`, and optional `value` |
| `limit` | integer | Page size (default 50, max 200) |
| `cursor` | string | Cursor from the previous response |

Custom-field operators: `contains`, `eq`, `in`, `not_in`, `present`, `absent`, `gte`, and `lte`.

```json
{
  "tags": ["Investor"],
  "company": "Google",
  "last_interaction_before": "2026-01-01T00:00:00Z",
  "limit": 50
}
```

---

## Tags

### dex_list_tags

List all tags with optional pagination.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `cursor` | string | No | Pagination cursor |
| `limit` | number | No | Results per page (default 10) |

**Returns:** `{ items: Tag[], has_more: boolean, next_cursor?: string }`

---

### dex_get_tag

Get a single tag by ID.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tag_id` | string (UUID) | Yes | Tag ID |

---

### dex_create_tag

Create a new tag.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | Yes | Tag name |

```json
{ "name": "Investor" }
```

---

### dex_update_tag

Update an existing tag.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tag_id` | string (UUID) | Yes | Tag ID |
| `name` | string | No | New tag name |

---

### dex_delete_tag

Delete a tag. Irreversible.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tag_id` | string (UUID) | Yes | Tag ID |

---

### dex_add_tags_to_contacts

Add tags to contacts (bulk operation).

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tag_ids` | string[] (UUID) | Yes | Tag IDs to add |
| `contact_ids` | string[] (UUID) | Yes | Contact IDs to tag |

```json
{ "tag_ids": ["tag1"], "contact_ids": ["c1", "c2", "c3"] }
```

---

### dex_remove_tags_from_contacts

Remove tags from contacts (bulk operation).

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tag_ids` | string[] (UUID) | Yes | Tag IDs to remove |
| `contact_ids` | string[] (UUID) | Yes | Contact IDs to untag |

---

## Groups

### dex_list_groups

List all contact groups. Returns all groups at once (no pagination).

**Parameters:** None

**Returns:** `{ items: Group[] }`

---

### dex_get_group

Get a single group by ID.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `group_id` | string (UUID) | Yes | Group ID |

---

### dex_create_group

Create a new contact group.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | Yes | Group name (max 100 chars) |
| `emoji` | string | No | Emoji icon |
| `description` | string | No | Group description |

```json
{ "name": "Startup Advisors", "emoji": "🚀", "description": "Advisory board members" }
```

---

### dex_update_group

Update an existing group.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `group_id` | string (UUID) | Yes | Group ID |
| `name` | string | No | New name |
| `emoji` | string | No | New emoji |
| `description` | string | No | New description |

---

### dex_delete_group

Delete a group. Irreversible.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `group_id` | string (UUID) | Yes | Group ID |

---

### dex_add_contacts_to_group

Add contacts to a group (bulk operation).

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `group_id` | string (UUID) | Yes | Group ID |
| `contact_ids` | string[] (UUID) | Yes | Contact IDs to add |

```json
{ "group_id": "g1", "contact_ids": ["c1", "c2"] }
```

---

### dex_remove_contacts_from_group

Remove contacts from a group (bulk operation).

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `group_id` | string (UUID) | Yes | Group ID |
| `contact_ids` | string[] (UUID) | Yes | Contact IDs to remove |

---

### dex_list_group_contacts

List contacts in a group with pagination.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `group_id` | string (UUID) | Yes | Group ID |
| `cursor` | string | No | Pagination cursor |
| `limit` | number | No | Results per page (default 10) |

**Returns:** `{ items: Contact[], has_more: boolean, next_cursor?: string }`

---

## Notes

### dex_list_notes

List notes on contact timelines with optional filtering by contact.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `contact_id` | string (UUID) | No | Filter by contact ID |
| `cursor` | string | No | Pagination cursor |
| `limit` | number | No | Results per page (default 10) |
| `include_contacts` | boolean | No | Include contacts linked to each note; off by default |

**Returns:** `{ items: Note[], has_more: boolean, next_cursor?: string }`

---

### dex_get_note

Get a single note by ID.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `note_id` | string (UUID) | Yes | Note ID |
| `include_contacts` | boolean | No | Include contacts linked to the note; off by default |

---

### dex_list_note_types

List available note types (Meeting, Call, Coffee, Note, etc.). Call this before creating notes to pick the right type.

**Parameters:** None

**Returns:** Array of note types with `id`, `name`, and `emoji`.

---

### dex_create_note

Create a new note on a contact's timeline. Supports linking to one or multiple contacts.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `content` | string | Yes | Note content/body |
| `contact_id` | string (UUID) | No | Associate note to a single contact |
| `contact_ids` | string[] (UUID) | No | Associate note to multiple contacts at once. Can be combined with `contact_id`. |
| `event_time` | string (ISO 8601) | No | When the event occurred (defaults to now) |
| `note_type_id` | string (UUID) | No | Note type ID from `dex_list_note_types` (falls back to "Note") |
| `include_contacts` | boolean | No | Include linked contacts in the returned note |

**Single contact:**
```json
{
  "content": "Discussed Series A timeline. Action: send intro to LP contacts.",
  "contact_id": "c1",
  "event_time": "2026-03-01T14:00:00Z",
  "note_type_id": "meeting-type-id"
}
```

**Multiple contacts (e.g. group meeting note):**
```json
{
  "content": "Team standup — discussed Q3 milestones and blockers.",
  "contact_ids": ["c1", "c2", "c3"],
  "event_time": "2026-03-01T14:00:00Z"
}
```

---

### dex_update_note

Update an existing note.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `note_id` | string (UUID) | Yes | Note ID |
| `content` | string | No | New content |
| `event_time` | string (ISO 8601) | No | New event time |
| `include_contacts` | boolean | No | Include linked contacts in the returned note |

---

### dex_delete_note

Delete a note. Irreversible.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `note_id` | string (UUID) | Yes | Note ID |

---

## Reminders

### dex_list_reminders

List reminders/tasks with optional contact filtering and pagination.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `contact_id` | string (UUID) | No | Filter reminders by associated contact |
| `cursor` | string | No | Pagination cursor |
| `limit` | number | No | Results per page (default 10) |

**Returns:** `{ items: Reminder[], has_more: boolean, next_cursor?: string }`

---

### dex_get_reminder

Get a single reminder by ID.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `reminder_id` | string (UUID) | Yes | Reminder ID |

---

### dex_create_reminder

Create a new reminder/task.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `due_at_date` | string (YYYY-MM-DD) | Yes | Due date |
| `text` | string | No | Reminder text (title/description — no separate title field) |
| `contact_id` | string (UUID) | No | Associated contact |
| `recurrence` | enum | No | `weekly`, `biweekly`, `monthly`, `quarterly`, `biannually`, `yearly` |

```json
{
  "text": "Follow up with Jane about the partnership proposal",
  "due_at_date": "2026-03-15",
  "contact_id": "c1"
}
```

---

### dex_update_reminder

Update an existing reminder.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `reminder_id` | string (UUID) | Yes | Reminder ID |
| `text` | string | No | New text |
| `due_at_date` | string (YYYY-MM-DD) | No | New due date |
| `recurrence` | enum | No | New recurrence |
| `is_complete` | boolean | No | Mark complete/incomplete |

```json
{ "reminder_id": "r1", "is_complete": true }
```

---

### dex_delete_reminder

Delete a reminder. Irreversible.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `reminder_id` | string (UUID) | Yes | Reminder ID |

---

## Custom Fields

### dex_list_custom_fields

List all custom field definitions.

**Parameters:** None

**Returns:** Array of custom field definitions with `id`, `name`, `field_type`, and `categories`.

---

### dex_create_custom_field

Create a new custom field definition.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | Yes | Field name (max 100 chars) |
| `field_type` | enum | Yes | `input` (free text), `autocomplete` (dropdown), `datepicker` |
| `categories` | string[] | No | Dropdown options (only for `autocomplete` type) |

```json
{
  "name": "Deal Stage",
  "field_type": "autocomplete",
  "categories": ["Prospect", "Qualified", "Negotiation", "Closed Won", "Closed Lost"]
}
```

---

### dex_update_custom_field

Update an existing custom field definition.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (UUID) | Yes | Custom field ID |
| `name` | string | No | New name |
| `field_type` | enum | No | New type: `input`, `autocomplete`, `datepicker` |
| `categories` | string[] | No | New dropdown options |

---

### dex_delete_custom_field

Delete a custom field definition. Irreversible.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `custom_field_id` | string (UUID) | Yes | Custom field ID |

---

### dex_set_custom_field_values

Batch-update custom field values on contacts.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `updates` | object[] | Yes | Array of value updates (min 1) |

Each update object:

| Field | Type | Description |
|-------|------|-------------|
| `contact_id` | string (UUID) | Contact ID |
| `custom_field_id` | string (UUID) | Custom field ID |
| `text_value` | string | Value for text/autocomplete fields |
| `date_value` | string (YYYY-MM-DD) | Value for date fields |
| `array_value` | string[] | Value for multi-select fields |

```json
{
  "updates": [
    { "contact_id": "c1", "custom_field_id": "cf1", "text_value": "Enterprise" },
    { "contact_id": "c2", "custom_field_id": "cf1", "text_value": "Startup" },
    { "contact_id": "c3", "custom_field_id": "cf2", "date_value": "2026-01-15" }
  ]
}
```

---

## Calendar

Calendar tools operate live against all connected Google and Microsoft accounts. Events returned by list/get include the account `email` and `provider`. Reuse `email` as `account_email`; create/update/delete also accept `account_provider` to disambiguate one address connected under both providers. `dex_get_calendar_event` currently accepts only `account_email`.

### dex_list_calendar_events

List or search events across all connected calendars. Defaults to now through the next seven days.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `start` | ISO datetime | No | Range start with offset; defaults to now |
| `end` | ISO datetime | No | Range end with offset; defaults to seven days after `start` |
| `query` | string | No | Plain-text match across title, description, location, and attendees |
| `limit` | integer | No | Maximum events (default 50, max 250) |

**Returns:** `{ items: CalendarEvent[], count: number, _truncated?: ... }` as a single batch without a cursor.

```json
{
  "start": "2026-08-01T00:00:00-05:00",
  "end": "2026-09-01T00:00:00-05:00",
  "query": "Acme"
}
```

---

### dex_get_calendar_event

Get one live provider event, including attendees, conferencing links, and recurrence flags.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `event_id` | string | Yes | Provider event ID |
| `account_email` | string | No | Connected account email; use the event's returned `email` when known |

A successful lookup may refresh calendar-account metadata on linked Dex notes; it does not change provider event content. When the same address is connected under both providers, this tool cannot accept `account_provider`; start from `dex_list_calendar_events` and do not guess if the event cannot be resolved unambiguously.

---

### dex_create_calendar_event

Create a timed or all-day event on a connected calendar. Confirm before the call when attendees may receive invitations.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `summary` | string | Yes | Event title |
| `description` | string | No | Event description or notes |
| `location` | string | No | Event location |
| `attendees` | email[] | No | Attendees to invite (max 100) |
| `start_datetime` | ISO datetime | Conditional | Timed-event start with explicit offset; requires `end_datetime` |
| `end_datetime` | ISO datetime | Conditional | Timed-event end with explicit offset; requires `start_datetime` |
| `timezone` | string | No | IANA timezone such as `America/Mexico_City` |
| `start_date` | date | Conditional | All-day start (`YYYY-MM-DD`) |
| `end_date` | date | No | Exclusive all-day end; defaults to the day after `start_date` |
| `account_email` | string | No | Target connected account; otherwise Dex selects a writable primary/fallback account |
| `account_provider` | enum | No | `GOOGLE` or `OFFICE365` when the same email exists under both |

Provide either the timed pair or `start_date`, never both forms.

```json
{
  "summary": "Catch-up with Alex",
  "attendees": ["alex@example.com"],
  "start_datetime": "2026-08-03T14:00:00-05:00",
  "end_datetime": "2026-08-03T14:30:00-05:00",
  "timezone": "America/Mexico_City"
}
```

---

### dex_update_calendar_event

Update one provider event. At least one changed field is required.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `event_id` | string | Yes | Provider event ID |
| `summary` | string | No | Replacement title |
| `description` | string | No | Replacement description |
| `location` | string | No | Replacement location |
| `attendees` | email[] | No | Replacement attendee list; include everyone who should remain |
| `start_datetime` / `end_datetime` | ISO datetime | Conditional | Replacement timed range; provide both |
| `timezone` | string | No | IANA timezone |
| `start_date` / `end_date` | date | Conditional | Replacement all-day range; `end_date` is exclusive |
| `account_email` | string | No | Account that owns the event |
| `account_provider` | enum | No | `GOOGLE` or `OFFICE365` when needed to disambiguate |

Fetch the current event before changing attendees. Passing a recurring series ID updates the whole series. Confirm the replacement list, schedule, and recurring scope before calling.

This tool cannot move an event between connected accounts: `account_email` and `account_provider` identify the account that already owns `event_id`. To transfer an event, fetch the original, separately confirm creation on the target account, then separately confirm deletion from the source. Preserve the event details and warn that organizer identity, RSVP state, conferencing data, and provider notifications may change.

---

### dex_delete_calendar_event

Delete a provider event. This is irreversible and can cancel the meeting for all attendees.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `event_id` | string | Yes | Provider event ID |
| `account_email` | string | No | Account that owns the event |
| `account_provider` | enum | No | `GOOGLE` or `OFFICE365` when needed to disambiguate |

Always confirm the event identity, account, and attendee impact.

---

## Email

### dex_search_emails

Search message metadata live across all connected Google and Microsoft mailboxes. The tool is read-only and cannot send email.

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | string | No | Plain-text name, company, domain, or topic; omit for recent messages |
| `after` | ISO datetime | No | Only messages after this time |
| `before` | ISO datetime | No | Only messages before this time |
| `limit` | integer | No | Maximum messages (default 25, max 100) |

Without date bounds, results cover roughly the last six months. Provider operators such as `from:` and `to:` are neutralized. Results include sender, participants, subject, snippet, date, and provider link, but not full bodies.

```json
{
  "query": "Acme partnership",
  "after": "2026-05-01T00:00:00Z",
  "limit": 50
}
```

---

## Error Handling

Common error patterns:

- **Professional subscription required**: 403 response. Inform user they need a Dex Professional plan and provide upgrade URL.
- **Not found**: Contact/tag/group/note/reminder ID doesn't exist. Ask user to search again.
- **Invalid date**: Date string couldn't be parsed. Ensure ISO 8601 format.
- **Calendar write scope missing**: Ask the user to grant calendar access for that account in Settings → Sync & Integrations.
- **Ambiguous calendar account**: Reuse the event's `email`; for create/update/delete, also use its `provider`. Get-by-ID has no provider selector, so do not guess when one email exists under both providers.
- **Truncated response**: Response exceeded 25,000 chars. Use a smaller page for cursor tools or narrow the query/date range for single-batch tools.
