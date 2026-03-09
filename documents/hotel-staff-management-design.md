# Hotel Flexible Staff Management System — Product Design Notes

> A running record of design decisions, screen structures, and feature considerations discussed during planning.

---

## 1. System Overview

A software platform for hotels to manage flexible / part-time staff for events such as wedding dinners, conferences, and corporate events. The ops manager has three channels to source staff for an event:

1. **In-house flexible staff** — staff already in the hotel's database
2. **HR agencies** — third-party agencies with their own staff rosters
3. **External referrals** — word-of-mouth, where in-house staff refer friends via a unique link

---

## 2. User Roles

### Hotel Side

| Role | Purpose |
|---|---|
| System Admin | Account setup, user management, system-wide configuration, agency linkage management |
| HR / Approving Manager | Reviews and approves or rejects events before invitations go out |
| Ops Manager | Primary power user — creates events, manages the full staffing invitation flow |
| In-House Flexible Staff | Responds to invitations, views confirmed shifts, can share referral links |

**Notes:**
- The approving manager is a distinct role from the system admin — their primary interface is the approval queue, not system configuration
- In smaller hotels, an ops manager may also be the approving manager. In this case, events they create are **automatically approved** (see Approval Routing section)
- External referral applicants are **not users** — they interact via a public URL and submit a form only. Their data lives in the event's referral tab

### Agency Side

| Role | Purpose |
|---|---|
| Agency Admin | Manages the agency's account, staff roster, and hotel connection relationships |
| Agency Manager | Receives staffing requests, assigns staff, submits candidate lists |

**Notes on Agency Flexible Staff:**
Two models are possible. **Model A (recommended for v1)** — agency staff are managed by the agency manager and never log into the system directly; they exist as profiles in the agency roster. **Model B** — agency staff get limited portal access to view and acknowledge confirmed assignments. Model A is simpler to build and reflects how most agencies operate. Model B could be introduced in a later phase.

---

## 3. Approval Routing

A dedicated **Approval Routing** configuration page, managed by the System Admin, maps each ops manager to their designated approving manager.

### How It Works
- Each ops manager has one assigned approving manager
- When an event is submitted, the system automatically notifies the correct approver — no manual selection required by the ops manager
- If the event creator is also their own designated approving manager, the event is **automatically approved** and logged accordingly in the audit trail (e.g. "Auto-approved — creator has approving authority")

### Key Considerations
- **Temporary delegates** — admins can assign a delegate for an approving manager who is on leave, so events don't get stuck in an empty queue
- **Escalation rule** — if an event sits unapproved for X days before the event date, it escalates to the system admin or a configured fallback approver
- **Visibility** — ops managers should be able to see who their assigned approving manager is

---

## 4. Hotel–Agency Connection Flow

The connection between a hotel and an agency is a **two-sided handshake** — neither side can unilaterally impose a relationship on the other.

### Option A — Hotel Initiates (Primary Flow)
1. Hotel System Admin searches for an agency by name or unique agency ID
2. Sends a connection request with an optional note
3. Agency Admin receives a notification and reviews the request
4. Agency Admin accepts or declines
5. Once accepted, both parties see each other in their respective linked lists and staffing requests can begin flowing

### Option B — Invite by Email (For Agencies Not Yet on the Platform)
1. Hotel System Admin sends an email invitation with a signup link
2. Agency registers and creates their account and roster
3. Connection is pre-associated to the inviting hotel, but Agency Admin still confirms before it is fully active

### Connection States

| State | Meaning |
|---|---|
| Pending | Hotel sent request, agency has not responded |
| Active | Both sides confirmed — requests can flow |
| Declined | Agency rejected the request |
| Suspended | Either party temporarily paused the relationship |
| Terminated | Connection permanently closed by either party |

### Key Considerations
- **Termination is non-destructive** — past event records and placement history are preserved; only future requests are blocked
- **Suspension** is a softer tool for pausing without ending the relationship (e.g. during disputes or seasonal slowdowns)
- **Connection management is admin-only** on the hotel side — ops managers cannot modify agency relationships
- The model supports **many-to-many** — one hotel can link to multiple agencies, and one agency can serve multiple hotels
- Both sides have visibility into placement history, response rates, and relationship status

---

## 5. Required Screens

### Authentication & Shared
- Login screen (shared across all roles, with role-based redirection after login)
- Notification centre / inbox

### Ops Manager Screens
- **Dashboard** — upcoming events, vacancy fill rates, pending approvals, alerts for understaffed roles
- **Event List** — all events with status indicators (Draft, Pending Approval, Approved, Ongoing, Completed)
- **Create / Edit Event** — multi-step wizard (see Section 6)
- **Event Details Page** — primary working screen once an event is approved (see Section 7)
- **Staff Directory** — searchable/filterable list of in-house flexible staff with availability, role profiles, and past event history
- **Agency Management** — linked agencies, send staffing requests, view and action submitted candidate lists
- **Referral Management** — generate and manage external referral URLs, view applicants and their referring staff member
- **Role Templates** — create and manage reusable role sets for common event types (see Section 8)
- **Approval Routing** *(admin-level)* — map ops managers to their approving managers

### Approving Manager Screens
- Pending approvals list
- Event approval detail view — review roles, headcounts, and timings; approve or reject with comments

### In-House Flexible Staff Screens
- Personal dashboard — upcoming confirmed shifts, pending invitations
- Invitation response page (via event URL) — event summary, eligible role(s) with timings, accept / decline CTA; shows waitlisted state if role is already filled
- Shift history

### Agency Screens
- Agency dashboard — incoming staffing requests
- Request detail view — role requirements, headcount needed; option to decline or submit a candidate list
- Candidate submission form — add staff profiles, assign to roles

### External Referral Applicant Screens (Public-facing, no login required)
- Referral landing page (unique URL per event) — event overview, available roles with timings, simple application form
- Application confirmation page

---

## 6. Create Event Flow — Multi-Step Wizard

A three-step wizard is recommended over a single long page. The information clusters are cognitively separate, and the approval gate at the end maps naturally to a final step rather than just a save button.

### Step 1 — Event Basics
- Event name, event type (wedding dinner, conference, corporate event, etc.)
- Event date, venue, internal reference number
- Event time, setup time, and teardown time (staff shifts often cover these windows)
- Brief description or internal notes

### Step 2 — Roles & Requirements
The most complex step — deserves its own dedicated screen.

For each role, the ops manager specifies:
- Role name
- Number of vacancies
- Shift start and end time
- Dress code
- Specific requirements or notes

**Design details:**
- Should feel like a lightweight table editor — easy to add, reorder, and delete rows
- A **"Start from a template"** option at the top allows pre-populating from a saved role set (see Section 8)
- A persistent **summary panel** (e.g. right side) shows a running tally: total roles, total vacancies, earliest shift start, latest shift end — gives a sanity check without scrolling

### Step 3 — Review & Submit for Approval
- Read-only summary of all entered information
- Once submitted, the event is locked from major edits until approved or sent back
- Ops manager confirms and submits here, triggering a notification to the assigned approving manager

### General Wizard Considerations
- **Save as draft at every step** — the ops manager should never lose work if interrupted
- **Non-linear navigation** — she should be able to jump back to earlier steps freely via a clickable step indicator
- **Step-level validation** — errors are caught per step, not only on final submit
- Once approved, the event moves into the **invitation phase** managed from the Event Details Page — this is a separate flow, not part of event creation

---

## 7. Event Details Page

The primary operational screen for managing a live event. Structured around a persistent header and tabbed content.

### Header (Always Visible)
Event name, date, venue, event type, overall fill status (e.g. 14/20 roles filled), approval status badge, and contextual quick action buttons based on current stage.

### Tab 1 — Overview
- Event description and key logistics (setup time, event time, teardown)
- Internal ops briefing notes
- Approval trail — who approved, when, and any comments

### Tab 2 — Roles & Vacancies
Core operational tab. For each role:
- Role name, required headcount, start time, end time
- Fill count vs total (e.g. 3/5 filled)
- Breakdown by sourcing channel — how many confirmed from in-house, agency, and referral
- Waiting list count
- Quick actions: invite more in-house staff, send agency request for this role

### Tab 3 — Staff (In-House)
- Invited in-house staff listed per role
- Each entry: name, invitation status (Invited, Accepted, Declined, Waitlisted), time of response
- Ability to manually remove a confirmed staff member or promote from waitlist
- Button to send new invitations

### Tab 4 — Agencies
- Agency requests raised, per role
- Each request shows: agency name, date sent, status (Pending, Declined, Submitted)
- When submitted, expand to see candidate list — accept or reject individuals
- Accepted agency candidates appear in the confirmed staff count

### Tab 5 — Referrals
- Toggle to activate the referral URL for this event
- Display the unique referral link with copy/share button
- Table of external applicants: name, contact, role applied for, referring staff member, status (Pending Review, Accepted, Rejected)

### Tab 6 — Communications
- Log of all invitations sent, agency requests, and system notifications for this event
- Ability to send a broadcast message to all confirmed staff (e.g. last-minute briefing updates)

### Tab 7 — Audit Log
- Timestamped history of every action taken on this event
- Covers: approval, invitations sent, acceptances, declines, agency requests, URL generation, status changes
- Records the acting user for every entry

---

## 8. Role Templates

A **Role Templates** management page allows ops managers to create and reuse role configurations for common event types, reducing setup time for recurring events.

### What a Template Contains
- Template name and event type tag
- A list of roles, each with: role name, default headcount, suggested shift duration (relative offsets, not absolute times), dress code, and requirements
- Creator, creation date, and visibility (shared across the ops team, or personal)

**Note:** Absolute timings are not stored in templates since event times vary. Relative offsets (e.g. "event start − 1hr") or blank timing fields that get filled in during Step 2 are more appropriate.

### Integration Into Event Creation
In Step 2 of the wizard, a prominent **"Start from a template"** option pre-populates the role list. The ops manager can freely edit the result — the template is a starting point, never a constraint.

### Key Considerations
- **Templates and events are decoupled** — once applied, the event's roles are a detached copy. Updating a template does not affect past or active events
- **"Save as template" from a completed event** — ops managers should be able to save a finalised role configuration as a new template. Good templates tend to emerge from real events
- **Deprecation** — templates can be marked as outdated so they don't appear as active suggestions
- **Access control** — template creation and editing may be restricted to senior ops managers or admins to prevent template sprawl

---

## 9. In-House Flexible Staff — Role Profiles

Each in-house flexible staff member has a **role profile**: a set of roles they are qualified to perform (e.g. Waiter, Bartender, Bellboy, Registration Staff, Setup Crew, AV Support). This is not self-declared — it is assigned and maintained by the ops manager or system admin, reflecting verified capability.

### How It Affects Invitation Logic
A staff member is eligible for an event invitation if **at least one of their assigned roles matches a vacancy in the event**. The system uses this to filter the staff directory when the ops manager is planning invitations.

### What the Staff Member Sees
When they open the invitation URL, they see only the roles they are eligible for — with respective timings and vacancies. If multiple roles match their profile, they see all of them and can choose their preference.

**Multiple roles in the same event:** A staff member can accept more than one role in the same event, provided the shifts do not overlap. For example, a staff member could sign up as Morning Crew (8am–2pm) and separately as an Evening Waiter (6pm–11pm) if both match their role profile. The system should validate for timing conflicts and block overlapping acceptances. This also means that for roles with very long windows (e.g. 8am–midnight), the ops manager should split them into sub-roles (e.g. Morning Crew, Evening Crew) at the role definition stage rather than expecting staff to commit to the full window.

**Multi-day events:** When a staff member accepts a role for a multi-day event, they are committing to **all days** of that role. Partial-day availability across a multi-day event is handled at the role definition level — each day is created as a separate role entry with its own vacancy count and shift timing (Option A). This reuses the existing role and invitation structure without added complexity.

### Waitlist Nuance
A staff member is waitlisted for a **specific role**, not the event generally. If their preferred role fills up but another role they are eligible for still has vacancies, the system can proactively prompt them to switch their acceptance rather than remain waitlisted.

### Invitation Targeting
The ops manager should be able to either:
- Invite a staff member for a **specific role**, or
- Invite them and **let them self-select** from their eligible roles

Both modes are useful depending on the ops manager's needs.

### Role History vs Role Profile
The system should distinguish between:
- **Roles assigned** — what the staff member is tagged as capable of
- **Roles worked** — what they have actually done across past events

A staff member tagged as a Bartender but with only Waiter shifts in their history is a different consideration from someone with 20 bartending events. Both views should be accessible to the ops manager.

---

## 10. Invitation Response — Status Lifecycle & Withdrawals

### Full Status Lifecycle

A staff member's invitation status for a given role can move through the following states:

| Status | Meaning |
|---|---|
| Invited | Invitation sent, no response yet |
| Accepted | Staff confirmed their slot |
| Declined | Staff declined the invitation upfront |
| Withdrawn | Staff accepted but later cancelled |
| Waitlisted | Staff accepted but the role was already full |
| Waitlist Promoted | Was waitlisted, promoted to a confirmed slot |
| No Response | Invitation expired with no action taken |

**Withdrawn** is distinct from **Declined** — it reflects a commitment that was made and later broken, which carries different implications for reliability tracking.

### What Happens When Someone Withdraws

1. Their slot is freed and the confirmed count for that role decreases
2. The ops manager is automatically notified of the reopened vacancy
3. **Waitlist promotion is triggered** — the next waitlisted staff member for that role is notified and offered the slot. Whether this is automatic or requires the ops manager to confirm is a design choice: automatic is faster; manual gives the ops manager more control, especially close to the event date
4. The withdrawal is logged in the audit trail with a timestamp and reason

### Withdrawal Reason

When withdrawing, staff select a reason from a simple dropdown: personal emergency, scheduling conflict, health reasons, or other. This is captured for the ops manager's awareness and feeds into longer-term reliability reporting.

### Late Withdrawals

A withdrawal flagged as **late** (e.g. within 48–72 hours of the event) is recorded distinctly in the staff member's history. This gives the ops manager useful signal when deciding whether to prioritise or deprioritise that person for future invitations.

---

## 11. Sourcing Priority and Flow



The typical invitation flow is sequential — in-house first, then agencies, then referrals — but the system should support running all three channels in parallel if needed. Locking the ops manager into a strict sequence would slow things down in time-sensitive situations.

### Typical Flow
1. Ops manager creates event and gets approval
2. Sends invitations to eligible in-house flexible staff
3. Staff accept or decline; accepted staff fill vacancies; late acceptors are waitlisted
4. For unfilled vacancies, ops manager sends a staffing request to one or more linked agencies
5. Agencies submit candidate lists; ops manager reviews and accepts or rejects individual candidates
6. For remaining vacancies, ops manager activates the referral URL and asks in-house staff to share it
7. External applicants apply; ops manager reviews and accepts or rejects from the Referrals tab

### The Two Event URLs
- **In-house URL** — requires authentication; only accessible to registered in-house flexible staff
- **Referral URL** — public-facing but token-based; unique per event, can be deactivated, and traces applicants back to the event and the referring staff member

---

## 12. Attendance — Security Check-In & Clock-Out

### Security Check-In Screen

A dedicated kiosk or tablet interface at the hotel entrance, operated by the security guard — not the staff member. The UI should be minimal: an identity number input field and a search button, nothing else.

**On a successful match**, the system displays:
- Staff photo, name, and identity number (for visual verification by the guard)
- Event name, role, and shift timing for today
- A prominent **Clock In** button

The guard verifies the person matches the photo and confirms the clock-in.

**Edge cases to handle:**

| Scenario | System Behaviour |
|---|---|
| Multiple events on the same day | Display all matching events; guard selects the correct one before clocking in |
| Arriving early | Soft warning shown ("Shift starts at 6:00pm, current time is 3:45pm — proceed?") — guard can still permit entry |
| Arriving late | Late arrival flagged visually on the record; entry still permitted |
| No match found | Clear error state: "No event found for this identity number today." Guard does not permit entry. Fallback contact shown (e.g. ops manager's number) for legitimate edge cases like last-minute additions |

---

### Clock-Out

Staff clock out via the security counter on exit, mirroring the clock-in process. This is the default and most controlled method.

A **self-service fallback** is available — staff can clock out via the same event URL used to accept their invitation, from their phone. Self-service clock-outs are flagged distinctly in the attendance record for ops manager awareness.

---

### End Event — The Authoritative Close

When the event is fully wrapped up, the ops manager triggers **End Event** from the event details page. This is a deliberate manual action — not an automated timer — making it the single authoritative boundary for the event.

**Before confirming**, the system shows a guard rail screen listing any staff still clocked in:

> *"3 staff members are still clocked in and will be auto clocked out at their scheduled shift end times. Do you want to proceed?"*

This gives the ops manager one last chance to notice if someone is legitimately still working before closing the event.

**On confirmation:**
- Staff still clocked in are **auto clocked out at their scheduled shift end time** — not at the time the ops manager hits the button, since she may be completing administrative tasks after the last person has left
- All auto clock-outs are flagged distinctly in the attendance record
- The event status changes from **Ongoing** to **Completed**
- The ops manager is shown a summary of all auto clock-outs that occurred, so she knows who to follow up with if needed

**Staff who worked late** are unaffected by End Event — they would have already clocked out via security or self-service before the ops manager triggers the close. End Event only acts on those who forgot to clock out.

**If the ops manager forgets to end the event**, the system sends a reminder notification the morning after the event date: *"Event X from yesterday has not been ended. Please review attendance and close the event."*

---

### Attendance Record Per Staff Per Shift

Each record captures:

| Field | Details |
|---|---|
| Scheduled start / end | As defined in the role |
| Actual clock-in | Timestamp and method (security kiosk) |
| Actual clock-out | Timestamp and method (security kiosk / self-service / auto via End Event) |
| Late arrival flag | If clock-in was after scheduled start |
| Auto clock-out flag | If closed by End Event rather than manual clock-out |
| Ops manager adjustment | Any manual correction, with reason and timestamp |

Manual adjustments by the ops manager are always logged in the audit trail — covering cases where a staff member's actual hours differed from what was recorded, or where a dispute needs to be resolved.

---

## 13. Event Status Lifecycle

### Status Table

| Status | Triggered By | Meaning |
|---|---|---|
| **Draft** | Ops manager saves without submitting | Event is being built, not yet submitted for approval. Editable in full |
| **Pending Approval** | Ops manager submits the event | Submitted and awaiting the approving manager's decision. Locked from major edits |
| **Rejected** | Approving manager rejects | Sent back to ops manager with comments. Returns to an editable state |
| **Approved** | Approving manager approves / auto-approved | Cleared to proceed. Invitation flow can now begin |
| **Invitation Open** | Ops manager begins sending invitations | Active staffing phase — invitations going out across one or more sourcing channels |
| **Fully Staffed** | System detects all vacancies filled | All roles have met their required headcount. Ops manager can still manage the waitlist |
| **Ongoing** | Event date begins (auto, based on date) | The event is happening. Check-in and clock-out are active |
| **Ended** | Ops manager triggers End Event | Event wrapped up. Attendance records closed, auto clock-outs applied |
| **Cancelled** | Ops manager or approving manager cancels | Event called off at any point before Ongoing. All confirmed staff notified |

### Visual Flow

```
Draft → Pending Approval → Rejected ↩ (back to Draft)
                         ↓
                      Approved → Invitation Open → Fully Staffed*
                                                         ↓
                                                      Ongoing
                                                         ↓
                                                       Ended

At any point before Ongoing → Cancelled
```

*Fully Staffed is a soft state — the event continues through the flow regardless*

### Key Design Considerations

- **Rejected returns to editable** — it is effectively "back to Draft with comments" rather than a terminal state. The ops manager addresses the feedback and resubmits
- **Approved and Invitation Open are kept separate** — there may be a deliberate gap between approval and when the ops manager is ready to start sending invitations. Approved means cleared to proceed; Invitation Open means actively staffing
- **Fully Staffed is informational, not a gate** — roles can reopen at any time due to withdrawals, so this status does not lock anything down. It is a visual indicator only
- **Ongoing is system-triggered** — flips automatically when the event date arrives. The ops manager does not need to manually start the event. Clock-in becomes active from this point
- **Cancelled carries context** — a cancellation reason and the stage at which it occurred should be captured, even if the displayed status is simply Cancelled. A pre-approval cancellation is very different from a last-minute one the day before the event
- **Ended and Cancelled are the only true terminal states** — both are read-only once reached, with full history preserved

---

*Document last updated: reflecting all design discussions to date. To be continued as planning progresses.*
