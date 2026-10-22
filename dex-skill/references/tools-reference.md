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
  - [dex_set_keep_in_touch](#dex_set_keep_in_touch)
  - [dex_archive_contacts](#dex_archive_contacts)
  - [dex_delete_contacts](#dex_delete_contacts)
  - [dex_merge_contacts](#dex_merge_contacts)
  - [dex_get_priority_tiers](#dex_get_priority_tiers)
  - [dex_set_contact_priority](#dex_set_contact_priority)
  - [dex_filter_contacts](#dex_filter_contacts)
  - [dex_add_related_contacts](#dex_add_related_contacts)
  - [dex_remove_related_contacts](#dex_remove_related_contacts)
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
  - [dex_list_upcoming_reminders_and_birthdays](#dex_list_upcoming_reminders_and_birthdays)
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
- [Research](#research)
  - [dex_research_contacts](#dex_research_contacts)
  - [dex_get_contact_research](#dex_get_contact_research)
- [Workspaces](#workspaces)
  - [dex_list_workspaces](#dex_list_workspaces)
  - [dex_list_workspace_members](#dex_list_workspace_members)

---

## Contacts

### dex_search_contacts

Search contacts by name, email, or any keyword. Returns up to `limit` results. Use an empty query to list contacts sorted by most recently interacted.

| Parameter   | Type   | Required | Description                                                                                     |
| ----------- | ------ | -------- | ----------------------------------------------------------------------------------------------- |
| `query`     | string | Yes      | Keyword query. Use empty string when `near` is the only filter or to browse by last interaction |
| `near`      | string | No       | Place for real geographic proximity search, such as `Bay Area` or `Sydney`. Personal Dex only   |
| `radius_km` | number | No       | Positive radius around `near` in kilometers (default 50). Personal Dex only                     |
| `limit`     | number | No       | Max results (default 50, max 200)                                                               |

**Returns:** `{ items: Contact[], count: number }`

**Note:** Search returns a single batch up to `limit`. For paginated iteration over all contacts, use `dex_list_contacts` instead.

```json
{ "query": "Acme Corp" }
{ "query": "engineer", "near": "Bay Area", "radius_km": 75 }
{ "query": "", "limit": 20 }
```

When using `near`, do not repeat the place in `query`; the two fields combine with AND, so repeating it can over-filter results.

`near` and `radius_km` are Personal Dex only: a Dex for Teams workspace connection refuses them with `workspace_context_unsupported`.

A `near` the geocoder can't place returns no items and a `warning`. Tell the user the place wasn't found, not that nobody is there, then retry with a city or region name (such as `Seattle, WA`) and a larger `radius_km`, or match the saved location text with `dex_filter_contacts`' `location`.

---

### dex_list_contacts

List all contacts with cursor-based pagination. Returns lightweight summaries (id, name, company, job title). Use `dex_get_contact` for full details. Use `dex_search_contacts` for keyword search.

| Parameter | Type   | Required | Description                              |
| --------- | ------ | -------- | ---------------------------------------- |
| `cursor`  | string | No       | Pagination cursor from previous response |
| `limit`   | number | No       | Results per page (default 100, max 500)  |

**Returns:** `{ items: ContactSummary[], has_more: boolean, next_cursor?: string, count?: number }`

```json
{ "limit": 500 }
{ "cursor": "abc123", "limit": 100 }
```

---

### dex_get_contact

Get a single contact by ID with emails, phone numbers, saved/geocoded location, keep-in-touch cadence, tags, groups, custom fields, and optionally recent notes/timeline.

| Parameter          | Type     | Required | Description                                                                                                                                                                                                                 |
| ------------------ | -------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `id`               | string   | Yes      | Contact ID                                                                                                                                                                                                                  |
| `include_notes`    | boolean  | No       | Include recent notes/timeline items (default false). Ignored when `fields` is supplied — select `recent_notes` there instead                                                                                                |
| `fields`           | string[] | No       | Allowlist of relation fields to return: `contact_emails`, `contact_phone_numbers`, `tags_contacts`, `groups_contacts`, `contacts_custom_fields`, `related_contacts`, `recent_notes`. Scalar contact fields always come back |
| `custom_field_ids` | string[] | No       | Return only these custom-field value rows. Pair with `fields: ["contacts_custom_fields"]` for the smallest response                                                                                                         |

**When to use `include_notes: true`:** user wants interaction history, meeting prep, or context about a relationship.

**Use `fields` on rich contacts.** A contact with many notes, tags, and custom fields can exceed the response limit; asking only for the relations you need keeps it inside.

**Keep-in-touch cadence.** On Personal Dex it is `frequency` / `never_keep_in_touch`. On a Dex for Teams workspace connection it is `keep_in_touch`, with the contact's Team cadence (shared with the workspace) as `team` and your own private My cadence as `my`, each left out when not set. So `keep_in_touch: {}` means the contact has no cadence at all, while a missing `keep_in_touch` key means the cadences could not be read — not that there are none.

`recent_notes` rows carry the same derived `meeting_type` as the note tools (see [Notes](#notes)).

---

### dex_create_contact

Create one or more contacts. Supports two modes:

- **Single mode:** Pass fields directly (backward compatible)
- **Batch mode:** Pass a `contacts` array for bulk creation (e.g. CSV import, up to 100 at once)

**Creating does NOT deduplicate.** A contact with the same name or email as an existing one becomes a second contact — Dex does not match on email. Search first (`dex_search_contacts`) when the person may already be in Dex.

**Pass an `idempotency_key` for a batch,** and reuse it if you must send the same call again. Without one, a repeated call creates every contact a second time.

| Parameter         | Type   | Required | Description                                                                                                                                                                                                                                     |
| ----------------- | ------ | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `first_name`      | string | No       | First name (single mode)                                                                                                                                                                                                                        |
| `last_name`       | string | No       | Last name (single mode)                                                                                                                                                                                                                         |
| `company`         | string | No       | Company name (single mode)                                                                                                                                                                                                                      |
| `job_title`       | string | No       | Job title (single mode)                                                                                                                                                                                                                         |
| `email`           | string | No       | Single email address shorthand (single mode)                                                                                                                                                                                                    |
| `emails`          | array  | No       | Email addresses: `[{ email, label? }]` (single mode)                                                                                                                                                                                            |
| `phone`           | string | No       | Single phone number shorthand (single mode)                                                                                                                                                                                                     |
| `phones`          | array  | No       | Phone numbers: `[{ phone_number, label?, country_code? }]` (single mode)                                                                                                                                                                        |
| `linkedin`        | string | No       | LinkedIn profile URL (single mode)                                                                                                                                                                                                              |
| `twitter`         | string | No       | Twitter/X handle (single mode)                                                                                                                                                                                                                  |
| `birthday`        | string | No       | Birthday `YYYY-MM-DD`, or `--MM-DD` when the year is unknown (single mode). The year is stored separately, so a full date keeps its year. **`--02-29` is rejected** — see below.                                                                |
| `description`     | string | No       | Notes about the contact (single mode)                                                                                                                                                                                                           |
| `website`         | string | No       | Website URL (single mode)                                                                                                                                                                                                                       |
| `location`        | string | No       | Where the contact is based, e.g. `Lisbon, Portugal` (single mode). Saved as their location (read back as `legacy_location`) and geocoded by Dex — not `description`                                                                             |
| `contacts`        | array  | No       | Array of contacts for batch creation (max 100). Each item accepts the same fields above. When provided, top-level fields are ignored.                                                                                                           |

**Birthdays: February 29 is a special case.** A year-less birthday is stored against the sentinel year 2100, which is not a leap year, so **`--02-29` is rejected** with an explanation. A full date such as `1996-02-29` is accepted but stored wrong — it silently rolls to March 1. Until that is fixed, ask the user whether they want `--02-28` or a specific full leap-year date they are willing to see as March 1; do not quietly pick one.

Only the real month lengths are accepted, so `--02-30`, `--04-31`, `--06-31`, `--09-31` and `--11-31` are rejected too.

**Returns:** `{ contacts: Contact[] }` — every created contact (up to 100) with its new `id`, in both modes. Each is a **lean contact row**: names, job title, company, `legacy_location`, birthday, social profiles, website, `is_archived`, emails and phones reduced to their value and label, plus `starred` / `frequency` / `never_keep_in_touch` on Personal Dex or `workspace_id` on a workspace connection. Internal bookkeeping fields are never included; use `dex_get_contact` for the full record. `dex_update_contact`, `dex_complete_keep_in_touch` (Personal Dex) and `dex_list_group_contacts` return the same lean row.

When full rows would not fit the response size limit, every row is trimmed to its id, names, job title and company (or, failing that, its id and names) rather than any row being dropped. If even that does not fit, `_truncated` reports how many rows were omitted. **The write already completed:** read the omitted contacts with `dex_filter_contacts`, setting `created_after` to a time just before the call, and never repeat the call.

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
    {
      "first_name": "Jane",
      "last_name": "Doe",
      "email": "jane@acme.com",
      "company": "Acme Corp"
    },
    {
      "first_name": "John",
      "last_name": "Smith",
      "email": "john@example.com",
      "company": "Example Inc"
    },
    {
      "first_name": "Alice",
      "last_name": "Chen",
      "email": "alice@startup.io",
      "job_title": "CTO"
    }
  ]
}
```

---

### dex_update_contact

Partial update — only provided fields are changed. For emails and phone numbers, use `add_*` / `remove_*` params — existing entries are preserved automatically.

**Omitting a field and sending `null` are different.** Every parameter typed `string / null` below accepts an explicit `null` that CLEARS the stored value; omitting it leaves the value alone. Only send `null` when the user asked to remove something. Clearing `birthday` clears the separately stored year with it.

| Parameter         | Type          | Required | Description                                                                                                                                                                                                                                                                                                         |
| ----------------- | ------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string        | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior.                                                                     |
| `id`              | string        | Yes      | Contact ID to update                                                                                                                                                                                                                                                                                                |
| `first_name`      | string        | No       | First name                                                                                                                                                                                                                                                                                                          |
| `last_name`       | string        | No       | Last name                                                                                                                                                                                                                                                                                                           |
| `company`         | string / null | No       | Company name                                                                                                                                                                                                                                                                                                        |
| `job_title`       | string / null | No       | Job title                                                                                                                                                                                                                                                                                                           |
| `email`           | string        | No       | Add a single email (shorthand for `add_emails`)                                                                                                                                                                                                                                                                     |
| `add_emails`      | array         | No       | Emails to add: `[{ email, label? }]`                                                                                                                                                                                                                                                                                |
| `remove_emails`   | string[]      | No       | Email addresses to remove                                                                                                                                                                                                                                                                                           |
| `phone`           | string        | No       | Add a single phone (shorthand for `add_phones`)                                                                                                                                                                                                                                                                     |
| `add_phones`      | array         | No       | Phones to add: `[{ phone_number, label?, country_code? }]`                                                                                                                                                                                                                                                          |
| `remove_phones`   | string[]      | No       | Phone numbers to remove                                                                                                                                                                                                                                                                                             |
| `linkedin`        | string / null | No       | LinkedIn profile URL                                                                                                                                                                                                                                                                                                |
| `twitter`         | string / null | No       | Twitter/X handle                                                                                                                                                                                                                                                                                                    |
| `birthday`        | string / null | No       | Birthday `YYYY-MM-DD`, or `--MM-DD` when the year is unknown; pass `null` to clear. `--02-29` is rejected — see the February 29 note under `dex_create_contact`                                                                                                                                                     |
| `description`     | string / null | No       | Notes about the contact                                                                                                                                                                                                                                                                                             |
| `website`         | string / null | No       | Website URL                                                                                                                                                                                                                                                                                                         |
| `location`        | string / null | No       | Where the contact is based, e.g. `Lisbon, Portugal`; pass `null` to clear. Saved as their location (read back as `legacy_location`) and geocoded by Dex                                                                                                                                                             |
| `starred`         | boolean       | No       | Star/unstar contact. Personal Dex only: on a Dex for Teams workspace connection it fails the WHOLE update, other fields included, so leave it out there                                                                                                                                                             |
| `keep_in_touch`   | enum          | No       | Cadence: `7 days`, `14 days`, `1 mon`, `42 days`, `3 mons`, `6 mons`, `1 year`, `never`, or `unset`                                                                                                                                                                                                                 |
| `is_archived`     | boolean       | No       | `true` archives this one contact (hidden from lists, search, and reminders; reversible), `false` restores it. Confirm first; use `dex_archive_contacts` for several. On a Dex for Teams workspace connection, where `dex_archive_contacts` is refused, this is the way to archive or restore, one contact at a time |

```json
{
  "id": "contact-uuid",
  "add_emails": [{ "email": "new@work.com", "label": "Work" }],
  "remove_phones": ["+15559999999"]
}
```

**Returns:** `{ contact }`, the contact after the update as a lean contact row (see `dex_create_contact`).

---

### dex_complete_keep_in_touch

Complete or snooze a contact's keep-in-touch cadence.

| Parameter         | Type            | Required | Description                                                                                                                                                                                                                                     |
| ----------------- | --------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string          | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `contact_id`      | string          | Yes      | Contact ID                                                                                                                                                                                                                                      |
| `snooze_days`     | integer or null | No       | Positive number of days to defer without recording a touch; omit to mark the cadence complete                                                                                                                                                   |
| `kind`            | string          | No       | Dex for Teams workspace only: `"team"` (shared with the workspace, needs write access) or `"my"` (your own, private). Optional when the contact has one cadence, required when it has both. Refused on Personal Dex                             |

Completing records that the user was just in touch and recalculates the next reminder from the contact's cadence. Snoozing only moves the next reminder. On Personal Dex it returns `{ contact }`, a lean contact row (see `dex_create_contact`) plus `last_seen_at` and `next_reminder_at`.

In a Dex for Teams workspace it acts on the contact's Team or My cadence and returns the rescheduled `cadence` (plus `note_id` when We met wrote a note: shared for a Team cadence, private for My, none for a viewer). That shared note counts as your own touch too, so marking a Team cadence done also restarts your My cadence on the contact, if you have one. A workspace snooze only hides the cadence until it ends and never moves its due date, so a snooze that ends on or before the next due date changes nothing, and the result carries a `warning` saying so.

```json
{ "contact_id": "contact-uuid" }
{ "contact_id": "contact-uuid", "snooze_days": 7 }
```

---

### dex_set_keep_in_touch

Set or clear the keep-in-touch cadence for up to 500 contacts in one call — the bulk companion to `dex_update_contact`'s `keep_in_touch` field.

| Parameter         | Type    | Required | Description                                                                                                                                                                                                                                     |
| ----------------- | ------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string  | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `contact_ids`     | array   | Yes      | Contact IDs to put on the cadence (max 500 per call)                                                                                                                                                                                            |
| `cadence`         | string  | Yes      | Applied to ALL of `contact_ids`: a reminder interval, `"never"` (don't keep in touch), or `"unset"` (no cadence). In a workspace pass exactly one of `cadence`, `frequency_days` or `frequency_id`                                              |
| `kind`            | string  | No       | Dex for Teams workspace only, and required there: `"team"` (shared with the workspace, needs write access) or `"my"` (your own, private). Refused on Personal Dex                                                                               |
| `frequency_days`  | integer | No       | Dex for Teams workspace only: the workspace frequency of exactly this many days. Never creates a frequency. Refused on Personal Dex                                                                                                             |
| `frequency_id`    | string  | No       | Dex for Teams workspace only: the id of the workspace frequency. Refused on Personal Dex                                                                                                                                                        |

Intervals: `"7 days"` = weekly, `"14 days"` = every 2 weeks, `"1 mon"` = monthly, `"42 days"` = every 6 weeks, `"3 mons"` = quarterly, `"6 mons"` = every 6 months, `"1 year"` = yearly. Every value overwrites whatever cadence each contact already has — and `"never"`/`"unset"` leave nothing in its place — so confirm with the user before changing a large set. Marking a due keep-in-touch as done is `dex_complete_keep_in_touch`, not this tool.

**Returns:** `requested` (distinct IDs, duplicates collapsed) and `updated`, plus `not_updated_ids` when some IDs do not carry the cadence afterwards. On Personal Dex `updated` counts the IDs verified to carry the requested cadence afterwards, including ones that already had it. On a workspace connection `updated` counts the cadences this call wrote (`created` + `changed` + `removed`); contacts already in the requested state are counted in `unchanged`, not in `updated`, and `not_updated` lists the rest with a reason code.

```json
{ "contact_ids": ["contact-uuid-1", "contact-uuid-2"], "cadence": "3 mons" }
```

---

### dex_archive_contacts

Archive or restore up to 500 contacts while preserving notes, reminders, and history. Prefer this reversible operation over deletion for cleanup. Always show the user which contacts will be archived and get their confirmation first.

| Parameter         | Type            | Required     | Description                                                                                                                                                                                                                                     |
| ----------------- | --------------- | ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string          | No           | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `contact_ids`     | string[] (UUID) | Yes          | Contact IDs to archive or restore (max 500)                                                                                                                                                                                                     |
| `archived`        | boolean         | No           | `true` (default) archives; `false` restores                                                                                                                                                                                                     |
| `expected_count`  | integer         | Above 20 ids | The number of distinct `contact_ids` in this call — the count the user confirmed                                                                                                                                                                |
| `confirm`         | boolean         | Above 20 ids | `true` asserts the user saw the list or exact count and explicitly confirmed the archive                                                                                                                                                        |

Archiving more than 20 contacts in one call is rejected — nothing changes — unless it carries `confirm: true` and an `expected_count` equal to the number of distinct ids. Restoring is never gated. Archived contacts are hidden from default lists, search, and keep-in-touch reminders. Find them with `dex_filter_contacts` and `archived_only: true`.

**Refused on a Dex for Teams workspace connection,** for any number of contacts and for restoring too. Archive or restore one contact at a time with `dex_update_contact` and `is_archived` (`true` or `false`).

```json
{ "contact_ids": ["c1", "c2"], "archived": true }
```

```json
{ "contact_ids": ["c1", "...", "c25"], "confirm": true, "expected_count": 25 }
```

---

### dex_delete_contacts

Delete one or more contacts. Irreversible — confirm with the user and prefer `dex_archive_contacts` when recovery may matter.

| Parameter         | Type     | Required | Description                                                                                                                                                                                                                                     |
| ----------------- | -------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string   | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `contact_ids`     | string[] | Yes      | Contact IDs to delete (min 1)                                                                                                                                                                                                                   |

**Refused on a Dex for Teams workspace connection.** Delete workspace contacts in the Dex app, or archive one contact at a time with `dex_update_contact` and `is_archived: true`.

---

### dex_merge_contacts

Merge duplicate contacts. Dex automatically keeps the oldest record in each group, regardless of input order, combines data onto it, and deletes the others.

| Parameter           | Type       | Required | Description                                                                                                                                                                                                                                     |
| ------------------- | ---------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key`   | string     | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `contact_id_groups` | string[][] | Yes      | Groups of IDs to merge (each group min 2 IDs)                                                                                                                                                                                                   |

```json
{
  "contact_id_groups": [
    ["contact-id-1a", "contact-id-1b", "contact-id-1c"],
    ["contact-id-2a", "contact-id-2b"]
  ]
}
```

Read `mergedContactIds` from the result to identify the survivor; never infer it from input order.

**Refused on a Dex for Teams workspace connection.** Merge workspace contacts in the Dex app.

---

### dex_get_priority_tiers

Read the user's relationship-priority tiers and, optionally, the current priority of specific contacts. Tiers are numbered from 1 (highest); the defaults are 1 Top, 2 High, 3 Medium, 4 Low, 5 None, but users can rename them, so call this first and use the user's own labels. Personal Dex only.

| Parameter     | Type            | Required | Description                                                            |
| ------------- | --------------- | -------- | ---------------------------------------------------------------------- |
| `contact_ids` | string[] (UUID) | No       | Contacts whose current priority to return (1–100). Omit for tiers only |

Returns `tiers` (`tier_number` + `label`) and, when `contact_ids` is passed, `contacts` with `priority_tier` and `priority_label`. A contact without `priority_tier` has no priority set, which is different from the "None" tier.

```json
{ "contact_ids": ["contact-uuid-1"] }
```

---

### dex_set_contact_priority

Set or clear the relationship priority of up to 500 contacts in one call — the same field the Priority Map edits. Personal Dex only.

| Parameter         | Type                    | Required | Description                                                                                                                                                                                                                                     |
| ----------------- | ----------------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string                  | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `contact_ids`     | string[] (UUID)         | Yes      | Contact IDs to put in the tier (max 500 per call)                                                                                                                                                                                               |
| `tier`            | string, integer or null | Yes      | Applied to ALL of `contact_ids`: the user's tier label (case-insensitive) or `tier_number` from `dex_get_priority_tiers`, or `null` to clear                                                                                                    |

An unknown tier is refused and nothing changes. Every value overwrites each contact's current priority, so show the user which contacts go to which tier and get explicit confirmation first. Returns `requested`, `updated`, and `not_updated_ids` when some ids do not carry the tier afterwards.

```json
{ "contact_ids": ["contact-uuid-1", "contact-uuid-2"], "tier": "Inner circle" }
```

---

### dex_filter_contacts

Filter contacts with the same structured filters as Dex views. Conditions combine with AND. Use this instead of keyword search when the request specifies tags, groups, profile presence, dates, archived state, or custom fields.

| Parameter                                            | Type                          | Description                                                                                                                                                                                                                                          |
| ---------------------------------------------------- | ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `tags` / `exclude_tags`                              | string[]                      | Tag IDs or exact names to include or exclude                                                                                                                                                                                                         |
| `tags_match`                                         | enum                          | `any` (default) or `all`                                                                                                                                                                                                                             |
| `groups` / `exclude_groups`                          | string[]                      | Group IDs or exact names to include or exclude                                                                                                                                                                                                       |
| `groups_match`                                       | enum                          | `any` (default) or `all`                                                                                                                                                                                                                             |
| `name`                                               | string                        | Fuzzy name match                                                                                                                                                                                                                                     |
| `company`                                            | string                        | Fuzzy company match                                                                                                                                                                                                                                  |
| `job_title`                                          | string                        | Fuzzy job-title match                                                                                                                                                                                                                                |
| `education`                                          | string                        | Fuzzy education match                                                                                                                                                                                                                                |
| `description_contains`                               | string                        | Contact description contains text                                                                                                                                                                                                                    |
| `location`                                           | string                        | Fuzzy saved-location text match                                                                                                                                                                                                                      |
| `near`                                               | string                        | Real geographic proximity around a place. Personal Dex only                                                                                                                                                                                          |
| `radius_km`                                          | number                        | Positive radius around `near` in kilometers (default 50). Personal Dex only                                                                                                                                                                          |
| `has_linkedin`                                       | boolean                       | Require or exclude a LinkedIn profile                                                                                                                                                                                                                |
| `linkedin_company`                                   | string                        | LinkedIn work history contains company                                                                                                                                                                                                               |
| `linkedin_education`                                 | string                        | LinkedIn education history contains school                                                                                                                                                                                                           |
| `has_twitter` / `has_instagram`                      | boolean                       | Require or exclude social handles                                                                                                                                                                                                                    |
| `has_facebook` / `has_telegram`                      | boolean                       | Require or exclude social handles                                                                                                                                                                                                                    |
| `has_tiktok` / `has_youtube`                         | boolean                       | Require or exclude social handles                                                                                                                                                                                                                    |
| `has_email` / `has_phone`                            | boolean                       | Require or exclude contact methods                                                                                                                                                                                                                   |
| `starred`                                            | boolean                       | Filter by starred state. Personal Dex only                                                                                                                                                                                                           |
| `archived_only`                                      | boolean                       | `true` returns only archived contacts; default returns active contacts. Restore them with `dex_archive_contacts` and `archived: false`, or on a Dex for Teams workspace connection with `dex_update_contact` and `is_archived: false`, one at a time |
| `last_interaction_after` / `last_interaction_before` | ISO datetime                  | Bound the last interaction. Personal Dex only                                                                                                                                                                                                        |
| `created_after` / `created_before`                   | ISO datetime                  | Bound contact creation time                                                                                                                                                                                                                          |
| `has_frequency`                                      | boolean, enum or string       | Keep-in-touch cadence — see below                                                                                                                                                                                                                    |
| `priority_tier`                                      | integer, integer[] or boolean | Relationship priority — see below                                                                                                                                                                                                                    |
| `custom_fields`                                      | object[]                      | AND filters with `field_id`, `operator`, and optional `value`                                                                                                                                                                                        |
| `include_custom_fields`                              | boolean                       | Return each contact's custom-field values in the result (default false)                                                                                                                                                                              |
| `ids`                                                | string[]                      | Fetch only these contact IDs (1–100) instead of filtering                                                                                                                                                                                            |
| `limit`                                              | integer                       | Page size (default 50, max 200)                                                                                                                                                                                                                      |
| `cursor`                                             | string                        | Cursor from the previous response                                                                                                                                                                                                                    |
| `include_archived`                                   | boolean                       | Deprecated alias of `archived_only` — prefer `archived_only`                                                                                                                                                                                         |

Custom-field operators: `contains`, `eq`, `in`, `not_in`, `present`, `absent`, `gte`, and `lte`.

A `near` the geocoder can't place returns no items and a `warning`: the place wasn't found, which says nothing about who is there. Retry with a city or region name and a larger `radius_km`, or use `location` for a text match.

**`has_frequency` — the only way to select an audience by its cadence.** Pass the **boolean** for presence: `true` = contacts with any cadence set (this is "everyone who has one"), `false` = contacts with none. Pass a **string** to narrow to one lane: `"never"` (explicitly marked don't-keep-in-touch) or an exact interval — `"7 days"`, `"14 days"`, `"1 mon"`, `"42 days"`, `"3 mons"`, `"6 mons"`, `"1 year"`. Note `"unset"` is a `dex_set_keep_in_touch` **write** value, not a filter: to find the contacts you would unset, pass `true`. Use this to build the `contact_ids` for a bulk `dex_set_keep_in_touch`.

On a Dex for Teams workspace connection the cadence strings are refused. Pass `true` or `false` for a live **Team** cadence, or a **workspace frequency id** (the `frequency_id` that `dex_get_contact` shows under `keep_in_touch`, or that `dex_set_keep_in_touch` returns) for a Team cadence on that frequency. A contact with only a My cadence matches `false` there; find My cadences with `dex_get_contact` or `dex_list_upcoming_reminders_and_birthdays`. A frequency id is refused on Personal Dex.

**Personal Dex only:** `near`, `radius_km`, `starred`, `last_interaction_after`, `last_interaction_before` and `priority_tier`. A workspace connection refuses each of them; it never falls back to Personal data.

**`priority_tier` — select contacts by relationship priority.** Pass a `tier_number` from `dex_get_priority_tiers`, an array of tier numbers (any of them), `true` for contacts with any priority set, or `false` for contacts with none. Each result row carries its `priority_tier`. Personal Dex only.

**`ids`** is a bulk fetch, not a filter — an absent ID may be not found, not owned, **or archived**. The backend cannot mix archived and active in one query, so if the IDs may span both, run two calls: one with the default and one with `archived_only: true`.

```json
{
  "tags": ["Investor"],
  "company": "Google",
  "last_interaction_before": "2026-01-01T00:00:00Z",
  "limit": 50
}
```

---

### dex_add_related_contacts

Link one or more contacts to a contact as related contacts (e.g. family members, colleagues, people met through them).

| Parameter         | Type   | Required | Description                                                                                                                                                                                                                                     |
| ----------------- | ------ | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `contact_id`      | string | Yes      | The contact to link relations onto                                                                                                                                                                                                              |
| `contact_ids`     | array  | Yes      | Contact IDs to relate to `contact_id`                                                                                                                                                                                                           |

Relations are symmetric — linking A to B also links B to A — and carry no relationship label, so record the nature of the relationship in a note or the description instead. Resolve names to IDs with `dex_search_contacts` first. Related contacts appear in `dex_get_contact` under `related_contacts`. Re-linking an existing pair is a no-op.

```json
{
  "contact_id": "contact-uuid",
  "contact_ids": ["relative-uuid-1", "relative-uuid-2"]
}
```

---

### dex_remove_related_contacts

Unlink one or more related contacts from a contact.

| Parameter         | Type   | Required | Description                                                                                                                                                                                                                                     |
| ----------------- | ------ | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `contact_id`      | string | Yes      | The contact to unlink relations from                                                                                                                                                                                                            |
| `contact_ids`     | array  | Yes      | Contact IDs to unlink from `contact_id`                                                                                                                                                                                                         |

Relations are symmetric, so removing A↔B clears the link from both sides. The contacts themselves are not modified or deleted.

```json
{ "contact_id": "contact-uuid", "contact_ids": ["relative-uuid-1"] }
```

---

## Tags

### dex_list_tags

List all tags with optional pagination.

| Parameter | Type   | Required | Description                   |
| --------- | ------ | -------- | ----------------------------- |
| `cursor`  | string | No       | Pagination cursor             |
| `limit`   | number | No       | Results per page (default 10) |

**Returns:** `{ items: Tag[], has_more: boolean, next_cursor?: string }`

---

### dex_get_tag

Get a single tag by ID.

| Parameter | Type          | Required | Description |
| --------- | ------------- | -------- | ----------- |
| `tag_id`  | string (UUID) | Yes      | Tag ID      |

---

### dex_create_tag

Create a new tag.

| Parameter         | Type   | Required | Description                                                                                                                                                                                                                                     |
| ----------------- | ------ | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `name`            | string | Yes      | Tag name                                                                                                                                                                                                                                        |

```json
{ "name": "Investor" }
```

**Returns:** `{ tag }`. Tag names are unique regardless of letter case: when a tag with the same name already exists (e.g. "Design Partner" when you pass "design partner"), that tag is returned instead of a duplicate, with `existing: true` when its stored name differs in letter case from the one you passed. Repeating the exact name returns the same tag without the flag.

---

### dex_update_tag

Update an existing tag.

| Parameter         | Type          | Required | Description                                                                                                                                                                                                                                     |
| ----------------- | ------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string        | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `tag_id`          | string (UUID) | Yes      | Tag ID                                                                                                                                                                                                                                          |
| `name`            | string        | No       | New tag name                                                                                                                                                                                                                                    |

---

### dex_delete_tag

Delete a tag. Irreversible. **Refused on a Dex for Teams workspace connection:** delete workspace tags in the Dex app.

| Parameter         | Type          | Required | Description                                                                                                                                                                                                                                     |
| ----------------- | ------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string        | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `tag_id`          | string (UUID) | Yes      | Tag ID                                                                                                                                                                                                                                          |

---

### dex_add_tags_to_contacts

Add tags to contacts (bulk operation).

| Parameter         | Type            | Required | Description                                                                                                                                                                                                                                     |
| ----------------- | --------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string          | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `tag_ids`         | string[] (UUID) | Yes      | Tag IDs to add                                                                                                                                                                                                                                  |
| `contact_ids`     | string[] (UUID) | Yes      | Contact IDs to tag                                                                                                                                                                                                                              |

```json
{ "tag_ids": ["tag1"], "contact_ids": ["c1", "c2", "c3"] }
```

**Returns:** `tags` — every requested (contact, tag) pair that is tagged after the call, new or already linked, in request order (contacts as given, then tags as given) — and `affected`, the number of pairs in `tags`. So `affected` is NOT the number of links this call created: that is `added`, and `already_linked` counts the requested pairs that were linked before the call. A requested pair in neither was not tagged. `added` and `already_linked` are absent when the existing links could not be read first.

---

### dex_remove_tags_from_contacts

Remove tags from contacts (bulk operation).

| Parameter         | Type            | Required | Description                                                                                                                                                                                                                                     |
| ----------------- | --------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string          | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `tag_ids`         | string[] (UUID) | Yes      | Tag IDs to remove                                                                                                                                                                                                                               |
| `contact_ids`     | string[] (UUID) | Yes      | Contact IDs to untag                                                                                                                                                                                                                            |

---

## Groups

### dex_list_groups

List contact groups, most recent page first.

| Parameter | Type   | Required | Description                              |
| --------- | ------ | -------- | ---------------------------------------- |
| `cursor`  | string | No       | Pagination cursor from previous response |
| `limit`   | number | No       | Results per page (default 200)           |

**Returns:** `{ items: Group[], has_more: boolean, next_cursor?: string, count?: number }`

**This paginates.** The default of 200 covers most accounts in one call, but when `has_more` is true you must pass `next_cursor` back as `cursor` to get the rest — do not report a first page as the user's complete group list.

---

### dex_get_group

Get a single group by ID, with its direct sub-groups (`sub_groups`) and its counts (`_count.groups_contacts` active contacts, `_count.sub_groups`) — the same shape `dex_create_group` and `dex_update_group` return.

| Parameter  | Type          | Required | Description |
| ---------- | ------------- | -------- | ----------- |
| `group_id` | string (UUID) | Yes      | Group ID    |

---

### dex_create_group

Create a new contact group, optionally nested under an existing group. A group cannot be its own parent or ancestor.

| Parameter         | Type                 | Required | Description                                                                                                                                                                                                                                     |
| ----------------- | -------------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string               | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `name`            | string               | Yes      | Group name (max 100 chars)                                                                                                                                                                                                                      |
| `emoji`           | string               | No       | Emoji icon                                                                                                                                                                                                                                      |
| `description`     | string               | No       | Group description                                                                                                                                                                                                                               |
| `parent_id`       | string (UUID) / null | No       | Parent group; `null` creates it at the top level; omit if unknown                                                                                                                                                                               |

```json
{
  "name": "Startup Advisors",
  "emoji": "🚀",
  "description": "Advisory board members"
}
```

---

### dex_update_group

Update an existing group. Pass `parent_id` to nest it under another group, `parent_id: null` to move it to the top level, or omit `parent_id` to leave it unchanged. A group cannot be its own parent or ancestor. A top-level group reads back with no `parent_id` key.

| Parameter         | Type                 | Required | Description                                                                                                                                                                                                                                     |
| ----------------- | -------------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string               | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `group_id`        | string (UUID)        | Yes      | Group ID                                                                                                                                                                                                                                        |
| `name`            | string               | No       | New name                                                                                                                                                                                                                                        |
| `emoji`           | string               | No       | New emoji                                                                                                                                                                                                                                       |
| `description`     | string               | No       | New description                                                                                                                                                                                                                                 |
| `parent_id`       | string (UUID) / null | No       | New parent group; `null` moves it to top level                                                                                                                                                                                                  |

---

### dex_delete_group

Delete a group. Irreversible. **Refused on a Dex for Teams workspace connection:** delete workspace groups in the Dex app.

| Parameter         | Type          | Required | Description                                                                                                                                                                                                                                     |
| ----------------- | ------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string        | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `group_id`        | string (UUID) | Yes      | Group ID                                                                                                                                                                                                                                        |

---

### dex_add_contacts_to_group

Add contacts to a group (bulk operation).

| Parameter         | Type            | Required | Description                                                                                                                                                                                                                                     |
| ----------------- | --------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string          | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `group_id`        | string (UUID)   | Yes      | Group ID                                                                                                                                                                                                                                        |
| `contact_ids`     | string[] (UUID) | Yes      | Contact IDs to add                                                                                                                                                                                                                              |

```json
{ "group_id": "g1", "contact_ids": ["c1", "c2"] }
```

**Returns:** `result.added` (memberships this call created; `result.count` is the same number), `result.already_linked` (requested contacts that were already members; absent when the existing members could not be read first) and `result.remaining`. Any other processed ID matched no contact you can add. `result.remaining` is always present: retry the IDs in it to finish a partial write, and an empty list (`[]`) means every ID was processed.

---

### dex_remove_contacts_from_group

Remove contacts from a group (bulk operation).

| Parameter         | Type            | Required | Description                                                                                                                                                                                                                                     |
| ----------------- | --------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string          | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `group_id`        | string (UUID)   | Yes      | Group ID                                                                                                                                                                                                                                        |
| `contact_ids`     | string[] (UUID) | Yes      | Contact IDs to remove                                                                                                                                                                                                                           |

**Returns:** `removed` (IDs processed, including ones that were not members), `count` (memberships deleted) and `remaining`. `remaining` is always present: retry the IDs in it to finish a partial write, and an empty list (`[]`) means every ID was processed.

---

### dex_list_group_contacts

List contacts in a group with pagination.

| Parameter  | Type          | Required | Description                   |
| ---------- | ------------- | -------- | ----------------------------- |
| `group_id` | string (UUID) | Yes      | Group ID                      |
| `cursor`   | string        | No       | Pagination cursor             |
| `limit`    | number        | No       | Results per page (default 10) |

**Returns:** `{ items: Contact[], has_more: boolean, next_cursor?: string }`, each a lean contact row (see `dex_create_contact`).

---

## Notes

**Note rows.** Every note tool (and `dex_get_contact`'s `recent_notes`) returns `meeting_type` as the note type's name — the same as `meeting_types.name` when the note has a type, otherwise the legacy type label. It is kept for compatibility; prefer `meeting_type_id` / `meeting_types`. With `include_contacts: true`, `timeline_items_contacts` lists the linked contacts with their names, on reads and on `dex_create_note` / `dex_update_note` alike. Its `is_origin` marks the contact whose page the note was written on in the Dex app; notes created through these tools never set it, so it is `false` on all of their links.

### dex_list_notes

List notes on contact timelines with optional filtering by contact.

| Parameter          | Type                 | Required | Description                                          |
| ------------------ | -------------------- | -------- | ---------------------------------------------------- |
| `contact_id`       | string (UUID)        | No       | Filter by contact ID                                 |
| `start_date`       | date or ISO datetime | No       | Only notes on or after this bound, inclusive         |
| `end_date`         | date or ISO datetime | No       | Only notes on or before this bound, inclusive        |
| `cursor`           | string               | No       | Pagination cursor                                    |
| `limit`            | number               | No       | Results per page (default 10)                        |
| `include_contacts` | boolean              | No       | Include contacts linked to each note; off by default |

**Returns:** `{ items: Note[], has_more: boolean, next_cursor?: string }`

The date bounds filter on `event_time` — the timeline date the user sets freely — **not** on when the note was created. A bare `YYYY-MM-DD` covers that whole day in the account's own timezone; a full ISO datetime is used as the exact instant it names.

---

### dex_get_note

Get a single note by ID.

| Parameter          | Type          | Required | Description                                         |
| ------------------ | ------------- | -------- | --------------------------------------------------- |
| `note_id`          | string (UUID) | Yes      | Note ID                                             |
| `include_contacts` | boolean       | No       | Include contacts linked to the note; off by default |

---

### dex_list_note_types

List available note types (Meeting, Call, Coffee, Note, etc.). Call this before creating notes to pick the right type.

**Parameters:** None

**Returns:** Array of note types with `id`, `name`, and `emoji`.

---

### dex_create_note

Create a new note on a contact's timeline. Supports linking to one or multiple contacts.

| Parameter          | Type                    | Required | Description                                                                                                                                                                                                                        |
| ------------------ | ----------------------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `content`          | string                  | Yes      | Note content/body                                                                                                                                                                                                                  |
| `contact_id`       | string (UUID)           | No       | Associate note to a single contact                                                                                                                                                                                                 |
| `contact_ids`      | string[] (UUID)         | No       | Associate note to multiple contacts at once. Can be combined with `contact_id`.                                                                                                                                                    |
| `event_time`       | string (ISO 8601)       | No       | When the event occurred (defaults to now)                                                                                                                                                                                          |
| `note_type_id`     | string (UUID)           | No       | Note type ID from `dex_list_note_types` (falls back to "Note")                                                                                                                                                                     |
| `audience`         | `"shared" \| "private"` | No       | Workspace notes only: `"shared"` (every member, the default) or `"private"` (only you). Set `"private"` only when the user explicitly asks for a private note; otherwise omit it. Personal notes are always private and ignore it. |
| `include_contacts` | boolean                 | No       | Include linked contacts, with their names, in the returned note                                                                                                                                                                    |
| `idempotency_key`  | string                  | No       | Replay guard — reusing a key returns the FIRST result instead of creating a second note. **Requires `event_time`**                                                                                                                 |

**Retrying after a timeout:** pass the same `idempotency_key` you sent the first time and the server replays the original response rather than creating a duplicate note. Generate one key per logical note, not per attempt. The replay window is **24 hours**; after it the key is forgotten and the same call creates a new note.

**`event_time` is required whenever `idempotency_key` is present** — the call is rejected without it. A defaulted `event_time` would be "now" on each attempt, so the retry would carry a different body and defeat the replay. Decide the event time up front and send it on every attempt.

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

Update an existing note's `content` or `event_time`. Only those two can change: this tool cannot change the note type, the audience (shared or private) or the linked contacts, so tell the user when they ask for one of those.

| Parameter          | Type              | Required | Description                                                     |
| ------------------ | ----------------- | -------- | --------------------------------------------------------------- |
| `note_id`          | string (UUID)     | Yes      | Note ID                                                         |
| `content`          | string            | No       | New content                                                     |
| `event_time`       | string (ISO 8601) | No       | New event time                                                  |
| `include_contacts` | boolean           | No       | Include linked contacts, with their names, in the returned note |

---

### dex_delete_note

Delete a note. Irreversible.

| Parameter | Type          | Required | Description |
| --------- | ------------- | -------- | ----------- |
| `note_id` | string (UUID) | Yes      | Note ID     |

---

## Reminders

**Dates are judged in UTC.** "Today", "overdue" and `is_overdue` are decided by the calendar day in UTC, not the user's timezone.

### dex_list_upcoming_reminders_and_birthdays

What is coming up for the user inside a date window, in one call — the same three lists as the Dex homepage. Use this for "whose birthday is next week?", "who should I reach out to this week?" and "what do I have coming up?" instead of stitching together `dex_list_reminders` and a contact query.

| Parameter | Type                | Required | Description                                                                                                                                                                               |
| --------- | ------------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `from`    | string (YYYY-MM-DD) | No       | First day of the window, inclusive. Defaults to today in UTC — pass the user's local date when it may differ. It moves the window only: `is_overdue` and `due_on` are still judged in UTC |
| `days`    | integer             | No       | Window length in days, counting `from` as day one (default 7, max 92). 7 = the coming week, 30 = the coming month                                                                         |
| `kind`    | string              | No       | Dex for Teams workspace only: `"all"` (default), `"team"` or `"my"` — which keep-in-touch cadences to list. Refused on Personal Dex                                                       |

**Returns:** `{ window: { from, to }, birthdays: [], reminders: [], keep_in_touch: [] }`

Behavior worth knowing before you answer the user from it:

- **Birthdays** carry `date` (this year's occurrence), plus `birthday_year` and `turning_age` only when the year is actually known. A year-less birthday returns neither — do not infer an age.
- **Reminders** are the OPEN ones that come up inside the window, picked by that day (`due_on`). Recurring reminders appear on their next occurrence. Reminders **due before `from` are NOT included** — call `dex_list_reminders` with `is_overdue: true` for overdue ones. A reminder inside the window can still read `is_overdue: true` once its day is past in UTC, as one due on `from` does when `from` is the user's local date and UTC has already reached the next day.
- **`keep_in_touch`** DOES include contacts already overdue for a touch, flagged `is_overdue`, because Dex keeps showing them as due until the touch is logged (`dex_complete_keep_in_touch`).
- Archived contacts never appear. Birthdays the user already marked done this year are omitted.
- Fields whose value is null are omitted from each row, so a contact with no name comes back as `contact_id` alone — use `dex_get_contact` for the full record.
- Large windows are trimmed to fit the response budget: `reminders_truncated` / `keep_in_touch_truncated` flag a cut, and `_truncated.message` says what was left out and how to see it. The keep-in-touch list is everything due by the end of the window, overdue included, so a later `from` returns the same soonest contacts again: page the rest with `dex_filter_contacts` (`has_frequency: true`; on a workspace connection that covers Team cadences only) and its `next_cursor`, and read each one's due date with `dex_get_contact`. Dropped one-off reminders are reachable with `dex_list_reminders` (`is_complete: false` with `due_after` / `due_before`).

```json
{ "days": 30 }
```

---

### dex_list_reminders

List reminders/tasks with optional filtering by contact, completion status, overdue status and due-date range, plus sorting and pagination.

| Parameter     | Type                | Required | Description                                                                                                                                                                                                                                                                               |
| ------------- | ------------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `contact_id`  | string (UUID)       | No       | Filter reminders by associated contact                                                                                                                                                                                                                                                    |
| `is_complete` | boolean             | No       | `false` for open reminders, `true` for completed. Omit for all                                                                                                                                                                                                                            |
| `is_overdue`  | boolean             | No       | Filters on the due date alone, against today's date in UTC: `true` = due before today (UTC), `false` = due today (UTC) or later. Completed reminders match on their date too, although a completed row reads `is_overdue: false`; combine with `is_complete: false` for overdue open ones |
| `due_after`   | string (YYYY-MM-DD) | No       | Only reminders due on or after this date, inclusive                                                                                                                                                                                                                                       |
| `due_before`  | string (YYYY-MM-DD) | No       | Only reminders due on or before this date, inclusive                                                                                                                                                                                                                                      |
| `assignee_id` | string              | No       | Workspace connections only, a read filter: `me` (assigned to you), `none` (unassigned) or a `member_id` from `dex_list_workspace_members` (that member's). Refused on Personal                                                                                                            |
| `query`       | string              | No       | Case-insensitive substring match on the reminder text. Omit or leave blank for no text filter                                                                                                                                                                                             |
| `sort_by`     | enum                | No       | `due_at_date` (default), `created_at`, `last_completed_at`                                                                                                                                                                                                                                |
| `sort_order`  | enum                | No       | `asc` (default) or `desc`                                                                                                                                                                                                                                                                 |
| `cursor`      | string              | No       | Pagination cursor                                                                                                                                                                                                                                                                         |
| `limit`       | number              | No       | Results per page (default 10)                                                                                                                                                                                                                                                             |

**Returns:** `{ items: Reminder[], has_more: boolean, next_cursor?: string }`

**Reminder rows** — the same here as from `dex_get_reminder`, `dex_create_reminder` and `dex_update_reminder`:

- `reminders_contacts` lists the linked contacts as `[{ contact_id, contacts: { id, full_name } }]`; it is empty when the reminder is linked to none. `dex_get_contact` has each contact's full record.
- `is_overdue` is `true` when the reminder is still open and its due date is before today's date in UTC; it is always `false` once the reminder is complete.
- `assignee_id` (workspace connections) is the member it is assigned to. Nulls are omitted from rows, so a missing `assignee_id` means unassigned; it is always absent on Personal Dex.
- `recurrence` is absent on a one-off reminder. Workspace reminders never recur.

---

### dex_get_reminder

Get a single reminder by ID. The row has the shape described under `dex_list_reminders`.

| Parameter     | Type          | Required | Description |
| ------------- | ------------- | -------- | ----------- |
| `reminder_id` | string (UUID) | Yes      | Reminder ID |

---

### dex_create_reminder

Create a new reminder/task.

| Parameter         | Type                | Required | Description                                                                                                                                                                   |
| ----------------- | ------------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `due_at_date`     | string (YYYY-MM-DD) | Yes      | Due date                                                                                                                                                                      |
| `text`            | string              | No       | Reminder text (title/description — no separate title field)                                                                                                                   |
| `contact_id`      | string (UUID)       | No       | Associated contact                                                                                                                                                            |
| `recurrence`      | enum                | No       | `weekly`, `biweekly`, `monthly`, `quarterly`, `biannually`, `yearly`. Personal Dex only: workspace reminders don't recur, and a Dex for Teams workspace connection refuses it |
| `assignee_id`     | string or null      | No       | A `member_id` to assign. `null` = unassigned; omit to assign yourself. Workspace connections only                                                                             |
| `idempotency_key` | string              | No       | Replay guard — reusing a key returns the FIRST result instead of creating a second reminder                                                                                   |

**Retrying after a timeout:** pass the same `idempotency_key` you sent the first time and the server replays the original response rather than creating a duplicate. Generate one key per logical reminder, not per attempt. The replay window is **24 hours**; after it the key is forgotten and the same call creates a new reminder. Without a key, a retry creates a second row.

Unlike `dex_create_note`, this tool has no extra required field when a key is supplied — `due_at_date` is already mandatory, so the request body is stable across attempts on its own.

**Returns:** `{ reminder }`, with the row shape described under `dex_list_reminders` (`reminders_contacts` carries each linked contact's id and name).

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

| Parameter     | Type                | Required | Description                                                                              |
| ------------- | ------------------- | -------- | ---------------------------------------------------------------------------------------- |
| `reminder_id` | string (UUID)       | Yes      | Reminder ID                                                                              |
| `text`        | string              | No       | New text                                                                                 |
| `due_at_date` | string (YYYY-MM-DD) | No       | New due date                                                                             |
| `recurrence`  | enum                | No       | New recurrence. Personal Dex only: a Dex for Teams workspace connection refuses it       |
| `is_complete` | boolean             | No       | Mark complete/incomplete                                                                 |
| `assignee_id` | string or null      | No       | A `member_id` to reassign to; `null` unassigns; omit to keep. Workspace connections only |

```json
{ "reminder_id": "r1", "is_complete": true }
```

`assignee_id`: Workspace connections only: get ids from `dex_list_workspace_members`. A non-member or inactive member is refused by the API. Each assignment sends that member one push notification (bulk assignment sends one per reminder). It is refused on a Personal connection, and an email address is refused: find the member's `member_id` with `dex_list_workspace_members`.

**Returns:** `{ reminder }`, with the row shape described under `dex_list_reminders`.

---

### dex_delete_reminder

Delete a reminder. Irreversible.

| Parameter     | Type          | Required | Description |
| ------------- | ------------- | -------- | ----------- |
| `reminder_id` | string (UUID) | Yes      | Reminder ID |

---

## Custom Fields

### dex_list_custom_fields

List all custom field definitions.

**Parameters:** None

**Returns:** Array of custom field definitions with `id`, `name`, `field_type`, and `categories`.

---

### dex_create_custom_field

Create a new custom field definition. In a Dex for Teams workspace, only owners and admins can create field definitions.

| Parameter         | Type     | Required | Description                                                                                                                                                                                                                                     |
| ----------------- | -------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string   | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `name`            | string   | Yes      | Field name (max 100 chars)                                                                                                                                                                                                                      |
| `field_type`      | enum     | Yes      | `input` (free text), `autocomplete` (dropdown), `datepicker`                                                                                                                                                                                    |
| `categories`      | string[] | No       | Dropdown options (only for `autocomplete` type)                                                                                                                                                                                                 |

```json
{
  "name": "Deal Stage",
  "field_type": "autocomplete",
  "categories": [
    "Prospect",
    "Qualified",
    "Negotiation",
    "Closed Won",
    "Closed Lost"
  ]
}
```

---

### dex_update_custom_field

Update an existing custom field definition. In a Dex for Teams workspace, only owners and admins can edit field definitions.

| Parameter         | Type          | Required | Description                                                                                                                                                                                                                                     |
| ----------------- | ------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string        | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `custom_field_id` | string (UUID) | Yes      | Custom field ID                                                                                                                                                                                                                                 |
| `name`            | string        | No       | New name                                                                                                                                                                                                                                        |
| `field_type`      | enum          | No       | New type: `input`, `autocomplete`, `datepicker`                                                                                                                                                                                                 |
| `categories`      | string[]      | No       | New dropdown options                                                                                                                                                                                                                            |

---

### dex_delete_custom_field

Delete a custom field definition. Irreversible. **Refused on a Dex for Teams workspace connection:** delete workspace custom fields in the Dex app.

| Parameter         | Type          | Required | Description                                                                                                                                                                                                                                     |
| ----------------- | ------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string        | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `custom_field_id` | string (UUID) | Yes      | Custom field ID                                                                                                                                                                                                                                 |

---

### dex_set_custom_field_values

Batch-update custom field values on contacts.

| Parameter         | Type     | Required | Description                                                                                                                                                                                                                                     |
| ----------------- | -------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `idempotency_key` | string   | No       | Retry key (1–200 letters, digits, underscores, colons, dots, or hyphens). Reuse only for the same logical operation with identical arguments within 24 hours; use a new key for each new operation. Omission keeps random-per-attempt behavior. |
| `updates`         | object[] | Yes      | Array of value updates (min 1)                                                                                                                                                                                                                  |

Each update object:

| Field             | Type                | Description                                                                                                               |
| ----------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| `contact_id`      | string (UUID)       | Contact ID                                                                                                                |
| `custom_field_id` | string (UUID)       | Custom field ID                                                                                                           |
| `text_value`      | string              | Value for text/autocomplete fields                                                                                        |
| `date_value`      | string (YYYY-MM-DD) | Value for date fields                                                                                                     |
| `array_value`     | string[]            | Value for multi-select fields                                                                                             |
| `mode`            | enum                | `replace` (default) overwrites the stored value; `prepend` / `append` keep it and add the new text in front of / after it |
| `separator`       | string              | Joiner for `prepend` / `append` (defaults to a newline)                                                                   |

**`prepend` / `append` are atomic — do NOT read the current value first.** The server preserves the existing text and adds yours, so a read-modify-write is both unnecessary and racy. Array values prepend/append as a de-duplicated list; date fields support `replace` only.

Note this is why `dex_set_custom_field_values` is **not** idempotent: repeating an `append` call adds the text again.

```json
{
  "updates": [
    {
      "contact_id": "c1",
      "custom_field_id": "cf1",
      "text_value": "Enterprise"
    },
    { "contact_id": "c2", "custom_field_id": "cf1", "text_value": "Startup" },
    { "contact_id": "c3", "custom_field_id": "cf2", "date_value": "2026-01-15" }
  ]
}
```

---

## Calendar

Calendar tools operate live against all connected Google and Microsoft accounts. Events returned by list/get include the account `email` and `provider`. Reuse `email` as `account_email`; get/create/update/delete also accept `account_provider` to disambiguate one address connected under both providers.

All five calendar tools are **Personal Dex connection only**: a Dex for Teams workspace connection refuses them with `workspace_context_unsupported`.

### dex_list_calendar_events

List or search events across all connected calendars. Defaults to now through the next seven days. Personal Dex connection only (refused on a Dex for Teams workspace connection).

| Parameter | Type         | Required | Description                                                                                                                                                                                                                                                                                                                                         |
| --------- | ------------ | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `start`   | ISO datetime | No       | Range start with offset; defaults to now                                                                                                                                                                                                                                                                                                            |
| `end`     | ISO datetime | No       | Range end with offset; defaults to seven days after `start`                                                                                                                                                                                                                                                                                         |
| `query`   | string       | No       | Plain-text match across title, description, location, and attendees                                                                                                                                                                                                                                                                                 |
| `limit`   | integer      | No       | Max events PER connected calendar, not a total — with 2 accounts a limit of 3 can return 6 (default 50, max 250). Results are merged in chronological order. Providers truncate newest-first, so a small limit returns the LATEST events in the range, not the next ones — narrow `start`/`end` instead of relying on `limit` to mean "the next N". |

**Returns:** `{ items: CalendarEvent[], count: number, warnings?: string[], _truncated?: ... }` as a single batch without a cursor. `warnings` means some calendars failed and the results are incomplete, even if `items` is empty. If every calendar fails, the tool returns an error; do not interpret it as an empty schedule.

```json
{
  "start": "2026-08-01T00:00:00-05:00",
  "end": "2026-09-01T00:00:00-05:00",
  "query": "Acme"
}
```

---

### dex_get_calendar_event

Get one live provider event, including attendees, conferencing links, and recurrence flags. Personal Dex connection only (refused on a Dex for Teams workspace connection).

| Parameter          | Type   | Required | Description                                                          |
| ------------------ | ------ | -------- | -------------------------------------------------------------------- |
| `event_id`         | string | Yes      | Provider event ID                                                    |
| `account_email`    | string | No       | Connected account email; use the event's returned `email` when known |
| `account_provider` | enum   | No       | `GOOGLE` or `OFFICE365` to select the event's provider               |

This tool writes nothing: it opts out of the note-metadata refresh the API performs for other clients. When the same address is connected under both providers, pass `account_provider` from the event returned by `dex_list_calendar_events`.

---

### dex_create_calendar_event

Create a timed or all-day event on a connected calendar. Confirm before the call when attendees may receive invitations. Personal Dex connection only (refused on a Dex for Teams workspace connection).

| Parameter          | Type         | Required    | Description                                                                                                                           |
| ------------------ | ------------ | ----------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `summary`          | string       | Yes         | Event title                                                                                                                           |
| `description`      | string       | No          | Event description or notes                                                                                                            |
| `location`         | string       | No          | Event location                                                                                                                        |
| `attendees`        | email[]      | No          | Attendees to invite (max 100)                                                                                                         |
| `start_datetime`   | ISO datetime | Conditional | Timed-event start with explicit offset; requires `end_datetime`                                                                       |
| `end_datetime`     | ISO datetime | Conditional | Timed-event end with explicit offset; requires `start_datetime`                                                                       |
| `timezone`         | string       | No          | IANA timezone such as `America/Mexico_City`                                                                                           |
| `start_date`       | date         | Conditional | All-day start (`YYYY-MM-DD`)                                                                                                          |
| `end_date`         | date         | No          | Exclusive all-day end; defaults to the day after `start_date`                                                                         |
| `account_email`    | string       | No          | Target connected account; otherwise Dex selects a writable primary/fallback account                                                   |
| `account_provider` | enum         | No          | `GOOGLE` or `OFFICE365` when the same email exists under both                                                                         |
| `idempotency_key`  | string       | No          | Caller operation key (1–200 letters, digits, underscores, colons, dots, or hyphens); reuse only for identical retries within 24 hours |

Provide either the timed pair or `start_date`, never both forms. Supply a caller key from the first attempt to safely retry an operation. Use a new key for a new event, including an intended recreation after deletion; without a key, identical creations reuse the original response for 24 hours.

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

Update one provider event. At least one changed field is required. Personal Dex connection only (refused on a Dex for Teams workspace connection).

| Parameter                         | Type         | Required    | Description                                                                                                                           |
| --------------------------------- | ------------ | ----------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `event_id`                        | string       | Yes         | Provider event ID                                                                                                                     |
| `summary`                         | string       | No          | Replacement title                                                                                                                     |
| `description`                     | string       | No          | Replacement description                                                                                                               |
| `location`                        | string       | No          | Replacement location                                                                                                                  |
| `attendees`                       | email[]      | No          | Replacement attendee list; include everyone who should remain                                                                         |
| `start_datetime` / `end_datetime` | ISO datetime | Conditional | Replacement timed range; provide both                                                                                                 |
| `timezone`                        | string       | No          | IANA timezone                                                                                                                         |
| `start_date` / `end_date`         | date         | Conditional | Replacement all-day range; `end_date` is exclusive                                                                                    |
| `account_email`                   | string       | No          | Account that owns the event                                                                                                           |
| `account_provider`                | enum         | No          | `GOOGLE` or `OFFICE365` when needed to disambiguate                                                                                   |
| `idempotency_key`                 | string       | No          | Caller operation key (1–200 letters, digits, underscores, colons, dots, or hyphens); reuse only for identical retries within 24 hours |

For retries, supply `idempotency_key` from the first attempt and reuse it with identical arguments within 24 hours. Use a fresh key for every new edit, including changing back to a previous value. Without a key each update executes again.

Fetch the current event before changing attendees. Passing a recurring series ID updates the whole series. Confirm the replacement list, schedule, and recurring scope before calling.

This tool cannot move an event between connected accounts: `account_email` and `account_provider` identify the account that already owns `event_id`. To transfer an event, fetch the original, separately confirm creation on the target account, then separately confirm deletion from the source. Preserve the event details and warn that organizer identity, RSVP state, conferencing data, and provider notifications may change.

---

### dex_delete_calendar_event

Delete a provider event. This is irreversible and can cancel the meeting for all attendees. Personal Dex connection only (refused on a Dex for Teams workspace connection).

| Parameter          | Type   | Required | Description                                         |
| ------------------ | ------ | -------- | --------------------------------------------------- |
| `event_id`         | string | Yes      | Provider event ID                                   |
| `account_email`    | string | No       | Account that owns the event                         |
| `account_provider` | enum   | No       | `GOOGLE` or `OFFICE365` when needed to disambiguate |

Always confirm the event identity, account, and attendee impact.

---

## Email

### dex_search_emails

Search message metadata live across all connected Google and Microsoft mailboxes. The tool is read-only and cannot send email. Personal Dex connection only (refused on a Dex for Teams workspace connection).

| Parameter | Type         | Required | Description                                                                                                    |
| --------- | ------------ | -------- | -------------------------------------------------------------------------------------------------------------- |
| `query`   | string       | No       | Plain-text name, company, domain, or topic; omit for recent messages                                           |
| `folder`  | enum         | No       | `inbox` = received mail only (use for "my inbox"); `all` (default) spans the whole mailbox including sent mail |
| `after`   | ISO datetime | No       | Only messages after this time                                                                                  |
| `before`  | ISO datetime | No       | Only messages before this time                                                                                 |
| `cursor`  | string       | No       | `next_cursor` from the previous page, to continue a LISTING. Rejected when `query` is set                      |
| `limit`   | integer      | No       | Maximum messages per page (default 25, max 100)                                                                |

Without date bounds, results cover roughly the last six months. Provider operators such as `from:` and `to:` are neutralized. Results include sender, participants, subject, snippet, date, and provider link, but not full bodies.

**Only listings paginate.** With `query`, results are a single relevance-ranked page and passing `cursor` is rejected — narrow a search with dates or better keywords instead. When listing, prefer following `next_cursor` over widening the date range.

```json
{
  "query": "Acme partnership",
  "after": "2026-05-01T00:00:00Z",
  "limit": 50
}
```

---

## Research

### dex_research_contacts

A fresh run, including one after cache expiry or with `force: true`, replaces the stored research note and its finding statuses. Only populated contact fields such as LinkedIn and website are protected from automatic overwriting.

Run Dex Research on one or more contacts: a web search, page extraction, and an LLM summary produce a cited research note per contact plus structured findings. This is a **paid** action that takes a minute or more per contact (contacts run in parallel, so the call lasts as long as the slowest run). Confirm with the user before researching a large set, and chunk bigger sets into several calls.

| Parameter     | Type     | Required | Description                                                                          |
| ------------- | -------- | -------- | ------------------------------------------------------------------------------------ |
| `contact_ids` | string[] | Yes      | Contact IDs to research (max 5 per call; duplicates collapsed)                       |
| `force`       | boolean  | No       | Re-run even when a note under 30 days old is stored (a second paid run). Default off |

A contact researched within the last 30 days returns its cached note at no cost. Each entry in `items` carries an `outcome`; `error` and `in_progress` rows are listed before `ok` rows so a truncated response drops notes (still stored) rather than notices:

- `ok` — `research` holds the note: `one_line_summary` and `sections` (`current_focus`, `background`, `interests`) with `[[n]]` citation markers into `sources`, `identity_confidence`, and `fields` (linkedin / website / email / phone findings with `confidence`, `evidence`, and a `status`). `research.status` is `success` or `no_data_found` (with a `reason`). `applied` reports which **empty** `linkedin` / `website` fields the run filled in — **only high-confidence findings are auto-applied**, and existing values are never overwritten. Read each finding's own `status` rather than assuming: `auto_applied` (the run wrote it), `applied` (a human accepted it in the Dex UI), `already_present` (the contact held that exact value), or `pending` (not on the contact). A lower-confidence `linkedin`/`website` finding is `pending` just like every email and phone finding. Anything `pending` needs the user's confirmation before you apply it with `dex_update_contact`.
- `in_progress` — another request already holds that contact's run lock. Read it back later with `dex_get_contact_research`; do not run again.
- `error` — see `error`. A request that ended before the run finished may still complete server-side: check `dex_get_contact_research` in a minute or two and re-run only if nothing is stored.

Results are large. Research a few contacts per call to stay under the response limit; anything truncated is still stored and readable with `dex_get_contact_research`.

```json
{
  "contact_ids": ["c4f3…", "9a1b…"]
}
```

### dex_get_contact_research

Read the stored research note for one or more contacts without running anything. Free and fast — use it to check for existing research before paying for `dex_research_contacts`, to pick up a run that came back `in_progress`, or to re-read results a large run response truncated.

| Parameter     | Type     | Required | Description                                                 |
| ------------- | -------- | -------- | ----------------------------------------------------------- |
| `contact_ids` | string[] | Yes      | Contact IDs to read (max 10 per call; duplicates collapsed) |

Each entry carries `research` when the contact has been researched (same shape as above) and omits it otherwise; `found` counts the contacts with a stored note.

```json
{
  "contact_ids": ["c4f3…"]
}
```

---

## Workspaces

### dex_list_workspaces

List the Dex for Teams workspaces the user belongs to, with their role in each and whether API & MCP access is on, and say where this connection acts.

A connection acts in one place only: Personal Dex or one workspace. To work somewhere else:

- an **OAuth or device-code connection** connects again (for example `/mcp` in Claude Code) and picks Personal or another workspace on the Dex consent page;
- an **API key** acts where it was created, so use a key created for the other place in Dex under Settings → Dex API & MCP.

Naming another workspace with `?workspace=` is refused. A workspace only works when its owner or admin turned on API & MCP access (`api_access_enabled`). Viewers read; standard members, admins and owners read and write, and owners and admins can also create and edit custom-field definitions. Whatever the role, a workspace connection never deletes contacts, tags, groups or custom fields, merges contacts, or runs `dex_archive_contacts` (any number of contacts, archive or restore): archive or restore one contact at a time with `dex_update_contact` `is_archived`, and do the rest in the Dex app.

**Parameters:** None

**Returns:** `connection` — `{ kind: "personal" }` for Personal Dex, or `{ kind: "workspace", workspace_id }` — and `workspaces`: array of `id`, `name`, `slug`, `role`, `state`, `api_access_enabled` and, on the workspace this connection acts in, `current: true`.

---

### dex_list_workspace_members

List the active members of the connection's workspace, so a reminder can be assigned to one. Use a member's `member_id` as `assignee_id` on `dex_create_reminder`, `dex_update_reminder` and `dex_list_reminders`. Viewers can read but cannot edit or complete a reminder, so assigning one strands it; prefer owner, admin or standard members. Refused on a Personal connection.

| Parameter | Type   | Required | Description                                                                                              |
| --------- | ------ | -------- | -------------------------------------------------------------------------------------------------------- |
| `query`   | string | No       | Part of a name or email; case- and accent-insensitive substring match. Use it to find a specific member  |
| `limit`   | number | No       | Members per page, 1-50 (default 50)                                                                      |
| `cursor`  | string | No       | `next_cursor` from the previous page; pass the SAME `query` with it. A new query starts without a cursor |

**Returns:** `workspace_id`, `members`: array of `member_id` (the member's user id), `name`, `email`, `role` and `is_you` (true for the caller), `has_more` and, when `has_more` is true, `next_cursor`. A page can hold fewer than `limit` members when the response size limit is reached; `next_cursor` still resumes at the first member not returned.

---

## Error Handling

Common error patterns:

- **Professional subscription required**: 403 response. Inform user they need a Dex Professional plan and provide upgrade URL.
- **Not found**: Contact/tag/group/note/reminder ID doesn't exist. Ask user to search again.
- **Invalid date**: Date string couldn't be parsed. Ensure ISO 8601 format.
- **Calendar write scope missing**: Ask the user to grant calendar access for that account in Settings → Sync & Integrations.
- **Ambiguous calendar account**: Reuse the event's `email` and `provider` for get/update/delete; do not guess when one email exists under both providers.
- **Truncated response**: Response exceeded 25,000 chars. For a READ tool, use a smaller page for cursor tools or narrow the query/date range for single-batch tools. For a WRITE tool the write already completed and only the response was cut: never repeat the call (it would run the write again); read the omitted rows or fields back as `_truncated.message` says.
- **Refused on a Dex for Teams workspace connection**: Some tools and options are Personal Dex only (calendar, `dex_search_emails`, priority, and the options marked "Personal Dex only" above), and a few writes are never available over MCP in a workspace (deleting contacts, tags, groups or custom fields, merging contacts, `dex_archive_contacts`). The error says so, and for a refused tool names the alternative; nothing was read or changed, and nothing falls back to Personal data. Tell the user and use the alternative, or the Dex app.
