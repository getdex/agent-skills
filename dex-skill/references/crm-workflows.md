# CRM Workflows & Relationship Management

Best practices for being an effective personal CRM assistant with Dex. These patterns help users nurture professional relationships systematically.

## Table of Contents

- [Meeting Prep Workflow](#meeting-prep-workflow)
- [Post-Meeting Follow-Up](#post-meeting-follow-up)
- [Calendar Coordination](#calendar-coordination)
- [Correspondence Research](#correspondence-research)
- [Contact Organization Strategy](#contact-organization-strategy)
- [Note-Taking Best Practices](#note-taking-best-practices)
- [Follow-Up Cadences](#follow-up-cadences)
- [Network Nurturing Patterns](#network-nurturing-patterns)
- [Bulk Operations](#bulk-operations)

---

## Meeting Prep Workflow

When a user says "I have a meeting with X" or "Prep me for a call with X":

1. **Search** for the contact by name
2. **Get full details** with `include_notes: true` for recent interaction history
3. **Check reminders** to find any pending follow-ups related to this contact
4. **Fetch the calendar event** when the user wants live attendee, conferencing, or recurrence details
5. **Search recent correspondence** when email context would improve the brief
6. **Synthesize a brief** covering:
   - Who they are (role, company, relationship context)
   - Last interaction (when, what was discussed)
   - Pending items (action items from last meeting, open reminders)
   - Shared context (groups in common, tags, custom field data)
   - Meeting logistics and attendees, when requested
   - Relevant recent email threads, identified as snippets rather than full bodies
   - Suggested talking points based on history

**Example output format:**

```
## Meeting Brief: Jane Doe
VP Engineering at Acme Corp | Tagged: Investor, YC Batch

**Last Contact:** Feb 15 — Coffee meeting
- Discussed their Series A timeline (targeting Q3)
- You offered to intro them to your LP contacts

**Pending:**
- Reminder (Mar 1): Send LP intro email
- Open action: Share your fundraising deck

**Suggested Topics:**
- Follow up on LP intro status
- Ask about Q3 fundraising progress
- Discuss technical partnership opportunity
```

---

## Post-Meeting Follow-Up

After a user logs a meeting or says "I just met with X":

1. **Create a note** on the contact's timeline with:
   - Appropriate note type (Meeting, Call, Coffee, etc.)
   - `event_time` set to when the meeting happened
   - Content capturing key discussion points and action items
2. **Create reminders** for any follow-up actions
3. **Update contact details** if new info was shared (new role, company change, etc.)
4. **Apply tags/groups** if the relationship context changed
5. **Complete keep-in-touch cadence** with `dex_complete_keep_in_touch` only when the interaction actually occurred

---

## Calendar Coordination

Use calendar tools as an external-state workflow:

1. List or search events across connected accounts
2. Reuse the event's returned `email` as `account_email`; for create/update/delete, also use `account_provider` when one address exists under both providers
3. Confirm the exact event, account, schedule, and attendee impact before a write
4. For updates, fetch current state first because `attendees` replaces the full list
5. State clearly when a recurring-series ID will affect every occurrence

For timed events, provide both endpoints with explicit offsets and an IANA timezone. For all-day events, remember that `end_date` is exclusive. Creating an event may send invitations; deleting an organized event may cancel it for everyone.

`dex_update_calendar_event` cannot move an event to a different connected account. A cross-account transfer is a two-write workflow: fetch the original, confirm and create a faithful replacement on the target account, then separately confirm deletion of the original. Warn that organizer identity, attendee RSVP state, conferencing data, and provider notifications may not carry over unchanged.

---

## Correspondence Research

Use `dex_search_emails` to find live message metadata across connected Google and Microsoft accounts:

- Search with plain names, companies, domains, or topics
- Add explicit `after` and `before` bounds for recency-sensitive questions
- Do not use provider operators such as `from:` or `to:`
- Describe results as metadata and snippets, not full message bodies
- Do not offer to send email; Dex only searches correspondence

---

## Contact Organization Strategy

Guide users toward a consistent organizational system:

### Tags — Use for Attributes and Contexts

Tags are flat labels that cut across groups. Effective tag patterns:

- **How you met**: "Conference 2026", "LinkedIn", "Warm Intro", "College"
- **Professional role**: "Investor", "Founder", "Engineer", "Designer"
- **Relationship quality**: "Close Friend", "Acquaintance", "Dormant"
- **Action-oriented**: "Needs Follow-up", "Potential Hire", "Reference"

### Groups — Use for Relationship Clusters

Groups represent collections of related contacts. Effective group patterns:

- **Organizations**: "Acme Corp Team", "YC W26 Batch"
- **Personal circles**: "Book Club", "Running Group", "Dinner Crew"
- **Project-based**: "Board Members", "Advisory Council", "Launch Partners"
- **Networking**: "SF Tech Scene", "NYC Finance"

### Custom Fields — Use for Structured Data

When users track specific data points across contacts:

- **Pipeline tracking**: "Deal Stage" (autocomplete: Prospect → Closed)
- **Dates**: "Last Contract Date", "Anniversary" (datepicker)
- **Categories**: "Expertise Area", "Investment Focus" (autocomplete)
- **Free text**: "Referral Source", "Internal Notes" (input)

---

## Note-Taking Best Practices

Effective CRM notes capture information that future-you will need:

### Structure

```
[Key discussion points]
[Decisions made]
[Action items — who owes what]
[Personal context worth remembering]
```

### What to Capture

- **Action items** with clear ownership ("I will send the deck by Friday")
- **Decisions made** ("Agreed to move forward with Option B")
- **Personal context** ("Mentioned daughter starting college in fall")
- **Relationship signals** ("Seemed excited about collaboration", "Mentioned they're job hunting")
- **Next steps** ("Reconnect after their board meeting in April")

### What to Skip

- Information already in the contact record (job title, company — update the contact instead)
- Trivial logistics ("Met at Starbucks on 5th Ave")
- Verbatim transcripts — summarize the key points

### Note Types

Always use the most specific note type available:

- **Meeting** — In-person or video meetings
- **Call** — Phone or voice calls
- **Coffee** — Informal catch-ups
- **Note** — General observations, research notes, or async context

---

## Follow-Up Cadences

Help users establish systematic follow-up patterns:

### Suggested Cadences by Relationship Type

| Relationship | Cadence | `keep_in_touch` value |
|-------------|---------|-----------------------|
| Close professional contacts | Every 2-4 weeks | `14 days` or `1 mon` |
| Active networking contacts | Monthly | `1 mon` |
| Investors / Board members | Monthly | `1 mon` |
| Dormant but valuable | Quarterly | `3 mons` |
| Seasonal (holidays, birthdays) | Yearly | `1 year` |

### Setting Up Relationship Cadence

When a user wants to "stay in touch" with someone:

1. Ask how often they want to check in
2. Set `dex_update_contact.keep_in_touch` to the matching Dex interval
3. After a real interaction, use `dex_complete_keep_in_touch` so the cadence resets
4. Use `snooze_days` only to defer without recording a touch

Use `never` when the user explicitly does not want cadence reminders and `unset` to clear the cadence choice.

### Setting Up a Recurring Task

Use a recurring reminder when the user is tracking a specific repeated action rather than a general relationship cadence:

1. Ask how often the task should repeat
2. Create a reminder with the appropriate `recurrence`
3. Set `due_at_date` to the next desired due date
4. Link it to the contact with `contact_id` when applicable

**Example** (`dex_create_reminder`):
```json
{
  "text": "Monthly check-in — see how the product launch went",
  "due_at_date": "2026-04-01",
  "contact_id": "c1",
  "recurrence": "monthly"
}
```

---

## Network Nurturing Patterns

### The "Touch Base" Flow

When a user wants to re-engage dormant contacts:

1. Use `dex_filter_contacts` with `last_interaction_before` and any requested tag, group, company, or location criteria
2. Page through all matching contacts
3. Review contacts with no recorded interaction separately because date bounds exclude them
4. For each, check existing notes for context
5. Suggest a personalized reason to reach out based on their history

For cleanup requests, do not equate inactivity with “clearly stale.” Review open reminders, starred status, active opportunity/context signals, and—when useful—recent email/calendar metadata. Present exact archive and retain lists with reasons, then obtain confirmation before `dex_archive_contacts` or cadence changes. Never substitute `dex_delete_contacts` for a request to archive.

### The "Batch Organize" Flow

When a user wants to organize their CRM:

1. List all existing tags and groups to understand current structure
2. Filter contacts by category, company, tag, group, or custom field
3. Create new tags/groups as needed
4. Bulk assign using `dex_add_tags_to_contacts` / `dex_add_contacts_to_group`

### The "Duplicate Cleanup" Flow

When a user suspects duplicates:

1. Search by name fragments to find potential duplicates
2. Get full details of suspected duplicates to compare
3. Present differences to the user
4. Merge with user confirmation
5. Read `mergedContactIds` from the response because Dex keeps the oldest record, not the first input ID

---

## Bulk Operations

Several tools support batch operations for efficiency:

- **Tags**: `dex_add_tags_to_contacts` / `dex_remove_tags_from_contacts` — apply or remove tags on multiple contacts at once
- **Groups**: `dex_add_contacts_to_group` / `dex_remove_contacts_from_group` — manage group membership in bulk
- **Custom Fields**: `dex_set_custom_field_values` — set field values on multiple contacts
- **Create**: `dex_create_contact` — create up to 100 contacts per call
- **Archive/Restore**: `dex_archive_contacts` — reversibly change up to 500 contacts per call
- **Delete**: `dex_delete_contacts` — remove multiple contacts
- **Merge**: `dex_merge_contacts` — merge multiple duplicate groups simultaneously

When performing bulk operations, resolve current IDs, show the intended count and delta, process within tool limits, and explicitly confirm destructive operations. Prefer archive over delete when the user may need recovery.
