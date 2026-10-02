# XP, Levels, and Workout Celebration Specification

**Status:** Implemented on `codex/xp-levels-celebrations`; awaiting device feel/timing validation

**Initial scope:** XP, levels, exercise effort tiers, failed-attempt handling, and satisfying feedback for starting and completing exercises and workout sessions

## 1. Purpose

The app should make beginning and finishing a workout feel immediately rewarding without adding friction once the user is already exercising.

The first gamification phase will:

- give clear, satisfying feedback when a workout starts;
- acknowledge completed exercises without interrupting workout flow;
- award more XP for exercises the user identifies as more physically demanding;
- recognize failed early attempts without treating them as completed performance history;
- award durable XP for meaningful workout actions;
- show a high-impact end-of-workout celebration;
- provide permanent level progression with no punishment or reset;
- create a foundation for later workout receipts, progressive statistics, and real-life rewards.

The primary motivation problem happens before arriving at the gym. This phase uses the existing **Start Workout** button but does not yet implement arrival detection, but the level and XP progress created here should later be previewable from home as a reason to go.

## 2. Product principles

### Reward action, not optimization

A short workout is a valid workout. XP should acknowledge showing up and following through without strongly incentivizing excessive volume, heavier weights, or longer sessions.

### Fast feedback, minimal interruption

Starting a workout and completing an exercise should feel responsive but should not add dialogs that the user must dismiss. The largest celebration belongs at the start of the session, recognizing that showing up is the hardest part.

### Permanent progress

Lifetime XP and levels never decrease. Missed days do not remove progress. Streaks and decaying momentum are outside the initial scope.

### Honest and deterministic

The same action earns the same base XP. Variable rewards may be considered later, but the initial system should be understandable and testable.

### Protect the meaning of workout history

An abandoned exercise attempt can still represent real effort and earn partial XP, but it must not move the exercise to the bottom, update its priority, become the displayed previous performance, or influence future weight suggestions.

### Accessible by default

Celebrations must work in light and dark themes, respect reduced-motion settings, remain understandable without sound, and expose useful screen-reader labels.

## 3. Terminology

- **Set recorded:** A completed or failed set attempt persisted with a stable ID. Every recorded set earns its tier-adjusted partial XP.
- **Successful set:** A recorded set eligible for performance history when its exercise attempt is completed.
- **Exercise attempt:** One continuous attempt at an exercise within a workout session. It ends as completed or abandoned.
- **Exercise completed:** The user completed every intended set for an exercise or the chosen alternative within a group.
- **Exercise abandoned:** The user reports an early failed set and ends that exercise for the current attempt.
- **Exercise XP tier:** A user-selected `accessory`, `standard`, or `demanding` classification controlling per-set and exercise-completion XP.
- **Non-empty session:** A session containing at least one logged set or recorded abandoned attempt.
- **Completion-bonus eligible workout:** A session containing at least one completed exercise. An effort-only session can retain partial XP without receiving the workout-completion bonus.
- **Explicit completion:** The user presses the end-workout control and confirms completion.
- **Automatic completion:** The four-hour session timeout ends the workout.
- **Session XP:** XP earned by events belonging to one workout session.
- **Lifetime XP:** The sum of all awarded XP. It never decreases.
- **Level:** A value derived from lifetime XP rather than stored independently.

## 4. Initial user experience

### 4.1 Starting a workout

When the user presses **Start Workout**:

1. Start the session immediately using the existing `WorkoutSessionManager`.
2. Play a compact, non-blocking start celebration around the button rather than opening a modal.
3. Morph the button into its active state with a spring animation.
4. Trigger one crisp medium haptic pulse when enabled.
5. Briefly display a green radial wash, glow, and small programmatic particle burst.
6. Animate in a bold **Workout Started** label that settles into a compact session strip showing:
   - elapsed workout time;
   - XP banked during this session;
   - the current lifetime level.
7. Show a short message such as **First set is all that matters**.

The strongest moment should finish in roughly 400–700 ms, with the session strip settling by 900 ms. It must not prevent the user from opening an exercise immediately. The start celebration should feel more substantial than ordinary button feedback but clearly smaller than exercise completion, level-up, or workout completion.

Starting a workout does not itself award XP. This prevents empty-session farming while keeping the start interaction satisfying.

### 4.2 Logging a set

After a successful set is persisted:

- provide a crisp haptic tick;
- animate the set row into a completed/check state with a short color pulse;
- add the tier-adjusted set XP to the session counter with a visible rise-and-fade label such as `+2 XP`;
- briefly pulse the session XP total as it increases;
- continue the existing focus, superset, and rest-timer behavior without another tap.

This feedback is the partial XP reward. It should be satisfying enough to make each set feel acknowledged, while remaining smaller than exercise and workout completion. The primary motion should complete in less than 500 ms and must not delay the next-set flow.

A failed set recorded through the failure flow earns the same tier-adjusted set XP. Its feedback uses an effort-oriented state such as **Effort counted · +2 XP** rather than a completion checkmark.

### 4.3 Completing an exercise

When an exercise is genuinely complete, including the selected alternative or an exercise within a superset:

- transition its card to a completed/check state;
- show the tier-adjusted completion XP beside the card or session counter;
- use a success haptic distinct from the set haptic;
- delay card reordering only long enough for the state change to be legible, with a target of 250–400 ms;
- move the completed item to the bottom using the existing list behavior.

Completing a round within a superset is not exercise completion and must not award completion XP. Each exercise actually completed within a superset awards its own tier-adjusted completion XP; there is no additional whole-superset XP bonus in the initial version.

### 4.4 Abandoning an exercise after an early failed set

The exercise detail view must provide a visible secondary action such as **Couldn’t finish this set**. It opens a compact bottom sheet with:

- **Try again or adjust weight** — close the sheet without changing the attempt;
- **End exercise for today** — abandon the attempt and return to the exercise list;
- **End workout for today** — abandon the attempt and continue directly to the session-ending flow.

When the user abandons an exercise:

1. Record the failed set and mark the current exercise attempt as abandoned.
2. Preserve the entered weight and rep count in the attempt record for auditing and a future private receipt.
3. Exclude every set belonging to that abandoned attempt from previous-performance displays, priority/freshness calculations, personal records, and weight suggestions.
4. Do not invoke the existing exercise-completed callback.
5. Do not move the exercise or its group to the bottom of the list.
6. Award the failed set its normal tier-adjusted set XP when the failure is recorded.
7. Preserve all set XP earned during that attempt, even though those sets are ignored by performance-history features.
8. Do not award any separate abandonment bonus or exercise-completion XP.

If the user reopens the unchanged exercise during the same workout, start a new attempt. A later successful attempt may earn its normal set and completion XP. Each persisted set outcome must have an idempotent event key so retries or repeated callbacks cannot award the same set twice.

An attempt abandoned within a superset must not advance or complete the superset. The superset stays in its existing list position.

### 4.5 Ending a workout

When the user presses **End Workout**:

1. If the session contains no recorded sets or abandoned attempts, offer **Discard empty workout** instead of awarding XP.
2. If the session contains only abandoned attempts or abandoned exercise history, preserve partial XP but do not award the workout-completion bonus.
3. If the session contains at least one completed exercise, show a short confirmation that avoids accidental termination and award the completion bonus.
4. Persist the end state and any completion event before displaying the summary.
5. Stop timers and close the active session through `WorkoutSessionManager`.
6. Present the workout celebration or effort summary.

The celebration contains:

- programmatically drawn confetti with no image assets;
- optional haptic and sound cues;
- an animated session-XP count-up;
- an XP breakdown;
- the current level and progress toward the next level;
- a distinct level-up moment when a threshold was crossed;
- a **Done** action returning to the exercise list;
- a reserved space for the later workout receipt.

Example:

```text
WORKOUT COMPLETE

+94 XP

7 sets logged             +14
4 exercises completed     +40
Workout completed         +40

LEVEL 6
███████████░░░░░░░  135 / 225
```

If reduced motion is enabled, replace confetti and count-up effects with a static success state and a light haptic.

For an effort-only session, use the same durable XP summary with gentler copy such as **Session ended — the effort still counts**. Show the partial XP and level progress without the workout-completion bonus. The initial version should use a restrained particle effect rather than the full completion burst.

### 4.6 Automatically ended workouts

An automatic four-hour timeout must preserve XP already earned from logged sets, completed exercises, and abandoned attempts. It does not award the explicit workout-completion bonus.

On the next app launch, show a non-blocking summary explaining that the previous session was automatically closed and how much XP was preserved. Do not show full confetti for an automatic timeout.

### 4.7 Creating and editing exercise XP tiers

Exercise creation must include an **XP effort tier** selector:

- **Accessory** — examples include rotator-cuff work and bicep curls;
- **Standard** — the default for most exercises;
- **Demanding** — examples include squats, deadlifts, and chest press.

The examples are suggestions only. The user controls the tier because difficulty is personal and can change with equipment, injuries, or training style.

Add an edit-exercise flow reachable from the existing exercise options. The initial edit flow must allow changing the XP effort tier. Exercise renaming is intentionally excluded until exercises have stable IDs, because performance history is currently keyed by exercise name.

Existing exercises loaded from the phone or imported JSON do not have this field. They must migrate safely by defaulting to `standard`. The user can reclassify them over time; a bulk tier editor can be considered later. Changing a tier affects future awards only and never rewrites the immutable XP ledger.

## 5. XP model

### Recommended initial values

| XP tier | Recorded set | Exercise completion |
|---|---:|---:|
| Accessory | 1 | 5 |
| Standard | 2 | 10 |
| Demanding | 3 | 15 |

A recorded set earns the same set XP whether it was successful or failed. Failure changes how the attempt affects training history, not whether the effort receives partial credit.

The explicit workout-completion bonus is a fixed **40 XP** and requires at least one completed exercise. It is not multiplied by exercise tier.

Examples:

- One standard exercise with three sets: `6 + 10 + 40 = 56 XP`
- One demanding exercise with three sets: `9 + 15 + 40 = 64 XP`
- Four standard exercises with three sets each: `24 + 40 + 40 = 104 XP`
- A demanding exercise abandoned on its first failed set: `3 XP`
- One successful standard set followed by a failed second set: `2 + 2 = 4 XP`; the attempt is excluded from performance history.

### Guardrails

- XP is awarded from persisted domain events, not button taps or animations.
- Every XP event has a stable unique key so retrying a callback cannot duplicate XP.
- Editing an already logged set does not award the set XP again.
- Reopening a completed exercise does not award its completion XP again during the same session.
- Replaying persistence or UI callbacks for the same set-attempt ID cannot award XP twice.
- Retrying a failed set creates a new set-attempt ID because it represents additional real effort and may earn its own set XP.
- An abandoned attempt retains all per-set XP but receives no abandonment or completion bonus and is excluded from performance history.
- No XP is based on weight, total volume, fatigue score, workout duration, or personal records in the initial version.
- Exercise tier is explicitly user-selected and is not inferred from weight or exercise name.
- XP values must be centralized and versioned so they can be tuned without scattering constants through widgets.

## 6. Level system

### Initial curve

The first levels should arrive quickly, then gradually require more work:

```text
XP needed for the next level = 100 + 25 × (current level - 1)
```

| Level reached | XP for that level | Cumulative lifetime XP |
|---:|---:|---:|
| 2 | 100 | 100 |
| 3 | 125 | 225 |
| 4 | 150 | 375 |
| 5 | 175 | 550 |
| 6 | 200 | 750 |
| 10 | 300 | 1,800 |

Level 1 begins at zero XP. There is no initial level cap.

The level is derived from lifetime XP. It should not be persisted separately, avoiding disagreement between the stored level and XP total.

### Level-up behavior

When session XP crosses one or more thresholds:

- count up to the threshold;
- pause briefly;
- show **Level Up** with a stronger haptic and confetti burst;
- continue counting any remaining XP into the new level;
- correctly handle sessions that cross multiple levels.

Titles, cosmetics, and unlocks are not required for the initial level system.

## 7. Persistence and domain model

### Workout sessions

The current session manager stores the active session ID and start time in `SharedPreferences`, while set history lives in Drift. Durable gamification needs a canonical workout-session record in Drift.

Add a `workout_sessions` table with at least:

- `session_id` — stable UUID primary key;
- `started_at`;
- `ended_at`, nullable while active;
- `end_reason` — `explicit`, `automatic`, or `discarded`;
- `xp_rules_version`;
- `completion_summary_seen_at`, nullable.

The session manager remains responsible for active runtime state, but session start/end transitions should also update this table.

### Exercise metadata and migration

Add `xpTier` to the persisted `Exercise` JSON model with the values `accessory`, `standard`, and `demanding`. `Exercise.fromJson` must default missing or unknown values to `standard`, preserving all existing phone and imported exercises.

Add a stable UUID `exerciseId` to the persisted `Exercise` JSON model. Existing exercises without an ID receive one during migration and persist it during the next normal save. New history, attempt, and XP records reference this ID while also capturing the exercise name as a display snapshot. Exercise identity must not depend on a mutable or duplicated name.

The import/export format must include the tier for newly exported exercises while remaining able to import older backups without it.

### Exercise attempts

Add an `exercise_attempts` table with at least:

- `attempt_id` — stable UUID primary key;
- `session_id`;
- `exercise_id`;
- `exercise_name` — display snapshot captured when the attempt begins;
- `group_id` and `superset_id`, nullable context captured at attempt time;
- `status` — `active`, `completed`, or `abandoned`;
- `started_at` and `ended_at`.

Add a `set_attempts` table with at least:

- `set_attempt_id` — stable UUID primary key;
- `attempt_id` — parent exercise attempt;
- `planned_set_index`;
- `outcome` — `completed` or `failed`;
- `weight` and `reps` as entered;
- `history_entry_id`, nullable for a failed set;
- `recorded_at`.

Persist a successful set attempt, its history entry, and its XP event transactionally. Persist a failed set attempt and its XP event transactionally without creating a performance-history entry.

Add a nullable `attempt_id` to new history entries. Existing history rows with no attempt ID are treated as completed legacy history.

Create an attempt lazily when the first set is successfully logged or when the user reports a failed set. Merely opening and closing an exercise must not create an attempt record. Subsequent sets for the same open exercise flow use that attempt ID until it is completed or abandoned.

Queries powering **Last**, suggestions, priorities, and personal records must include completed attempts and legacy rows while excluding rows attached to abandoned attempts. This filtering should live in database/repository methods rather than individual widgets.

If the app restarts with an unfinished exercise attempt, mark that attempt abandoned during recovery. Preserve its recorded set XP, but keep its performance rows excluded just like an explicitly abandoned attempt.

### XP ledger

Add an append-only `xp_events` table with:

- `id`;
- `event_key`, unique;
- `session_id`;
- `event_type` — `set_completed`, `set_failed`, `exercise_completed`, or `workout_completed`;
- `exercise_id`, nullable;
- `exercise_name`, nullable;
- `xp_amount`;
- `rules_version`;
- `created_at`.

Recommended event keys:

- `set:<setAttemptId>`
- `exercise:<attemptId>`
- `workout:<sessionId>`

Lifetime and session XP can be calculated from the ledger. If aggregation later becomes a performance concern, add a cached total with reconciliation rather than replacing the ledger.

### Service boundary

Create a focused gamification service responsible for:

- XP rule values and versioning;
- tier-aware award calculations;
- idempotent event awards;
- session and lifetime XP queries;
- level calculations;
- detecting crossed level thresholds;
- producing the XP breakdown consumed by UI widgets.

Widgets should request awards through this service and display returned results. They should not calculate or persist XP directly.

## 8. UI components

Prefer built-in Flutter drawing, Material icons, typography, color, haptics, and existing animation primitives. No custom art pipeline is required.

Proposed components:

- `SessionProgressStrip` — elapsed time, session XP, and level;
- `WorkoutStartCelebration` — button morph, radial wash, small particle burst, and session-strip entrance;
- `XpGainIndicator` — small rise-and-fade gain label;
- `SetCompletionFeedback` — successful check pulse or failed-set effort state;
- `ExerciseCompletionState` — transient completed-card treatment;
- `FailedSetSheet` — retry, abandon exercise, or end workout actions;
- `ExerciseXpTierSelector` — creation/edit control with plain-language examples;
- `WorkoutCompletionSheet` or route — final XP celebration and breakdown;
- `LevelProgressBar` — reusable current/next-level indicator;
- `ConfettiOverlay` — lightweight programmatic particle effect with reduced-motion fallback.

The completion experience should be implemented as a dedicated route or full-screen sheet rather than a snackbar, because it is the primary payoff moment.

## 9. Edge cases

- Repeated taps on a logging or completion control must not duplicate XP.
- A database write failure must show an error and award no XP for that event.
- App termination during the celebration must not lose or duplicate XP; persistence happens first.
- A restored active workout must show the correct session XP.
- Unfinished exercise attempts discovered after an app restart are recovered as abandoned; their set XP remains and their performance history stays excluded.
- An imported history record must not retroactively create XP in the initial version.
- Deleting history does not silently change lifetime XP. A future explicit full-data reset may clear both.
- Completing one alternative within a group awards one logical completion event.
- Each completed exercise selected within a superset earns its tier completion XP; rounds and the superset container earn no extra XP.
- Abandoning an exercise excludes all rows from that attempt from previous-performance and suggestion queries.
- An abandoned exercise stays in its current list position and does not advance a superset.
- Retrying an abandoned exercise creates a new attempt without duplicating any previously persisted set XP event.
- Changing an exercise tier never changes historical XP events.
- Older local and imported exercises without a tier load as `standard`.
- Merely opening an exercise creates no attempt, XP, or history.
- A failed set explicitly recorded by the user earns its tier set XP even when zero reps were completed.
- Adding or removing sets during a workout must not duplicate previously awarded set events.
- If the app crosses midnight or a week boundary, XP remains attached to the session ID rather than UI calendar state.
- Celebration overlays must not obscure an active error or leave navigation in a broken state.

## 10. Analytics and tuning without external tracking

No external analytics dependency is required. The local ledger is sufficient to answer initial tuning questions:

- average session XP;
- typical workouts per level;
- distribution of set, exercise, and workout-completion XP;
- distribution of exercise tiers and successful versus failed set XP;
- number of automatic versus explicit session endings;
- whether the level curve becomes noticeably slow.

Any future UI that surfaces these statistics should use plain language and avoid implying clinical or population-level comparisons.

## 11. Acceptance criteria

### Functional

- A persisted successful or failed set awards exactly 1, 2, or 3 XP once according to its exercise tier.
- A completed exercise awards exactly 5, 10, or 15 XP once according to its tier.
- Abandoning an exercise awards no separate bonus; its recorded sets retain their XP.
- Explicitly ending a workout with at least one completed exercise awards exactly 40 XP once.
- Empty or automatically ended sessions do not receive the explicit completion bonus.
- Effort-only sessions preserve partial XP without receiving the explicit completion bonus.
- Abandoned attempts do not update previous performance, suggestions, priority, personal records, or list order.
- Existing exercises and old backups without an XP tier load as `standard`.
- Existing exercises and old backups without an exercise ID receive a stable UUID that is persisted on the next normal save.
- Session XP and lifetime XP survive app restarts.
- Level and next-level progress are derived correctly from lifetime XP.
- Crossing multiple levels in one session is handled correctly.
- Existing standard, alternative, and superset workout flows continue to work.

### Experience

- Starting a workout plays a satisfying micro-celebration with a button morph, radial wash, small particle burst, and haptic feedback without blocking navigation.
- Every successfully persisted or failed-recorded set shows immediate XP feedback without adding a required tap.
- Set feedback is clearly smaller than exercise completion, level-up, and workout-completion feedback.
- Reporting a failed set provides clear retry, abandon-exercise, and end-workout choices.
- An effort-only session receives supportive, non-punitive feedback without presenting it as a completed workout.
- Explicit workout completion produces a visually distinct celebration and XP breakdown.
- The experience works in light and dark themes.
- Reduced-motion mode removes particle and count-up animation without hiding information.
- Haptics and sound can be disabled independently in settings.

### Quality

- XP awarding and level calculations have unit tests, including idempotency and boundary cases.
- Session lifecycle tests cover explicit end, empty discard, automatic timeout, and restart recovery.
- Attempt tests cover early failure, failed-set XP, ignored history, list position, retry, and per-set XP idempotency.
- Migration tests cover existing exercise JSON and old import files without `xpTier`.
- Widget tests cover start feedback, exercise-completion feedback, normal celebration, level-up, and reduced motion.
- `flutter analyze`, `flutter test`, and an Android debug build pass.

## 12. Recommended implementation slices

1. **Persistence foundation**
   - Add exercise-tier metadata and backward-compatible JSON migration.
   - Add workout-session, exercise-attempt, set-attempt, and XP-event tables.
   - Add the gamification service and unit tests.
   - Update performance-history queries to exclude abandoned attempts.
   - Connect session start/end, attempt lifecycle, and successful/failed set recording.

2. **Exercise creation, editing, and failure flow**
   - Add the XP tier selector to exercise creation.
   - Add the tier-focused edit-exercise flow for existing exercises.
   - Add the failed-set sheet and abandon/retry behavior.
   - Verify ignored history, list order, and partial XP.

3. **In-workout feedback**
   - Add the session progress strip.
   - Add set XP and exercise-completion feedback.
   - Verify standard, grouped, and superset behavior.

4. **Completion celebration**
   - Add explicit empty-workout handling.
   - Add the effort-only session summary.
   - Add the completion route, XP breakdown, level bar, and confetti.
   - Add reduced-motion, haptic, and sound settings.

5. **Hardening**
   - Test restart recovery, idempotency, automatic timeout, and failure paths.
   - Tune timing and XP values through personal use.

## 13. Decisions to confirm before implementation

The recommended defaults are included so implementation can proceed once reviewed:

- **Completion-bonus threshold:** At least one completed exercise; abandoned-attempt-only sessions retain partial XP but receive no 40-XP bonus.
- **XP tiers:** Accessory awards `1/5`, standard `2/10`, and demanding `3/15` for recorded-set/exercise-completion events.
- **Existing exercise migration:** Missing tiers default to `standard` and can be changed through the edit flow.
- **Exercise identity:** Add stable UUIDs now; use them for relationships and retain names only as display snapshots.
- **Edit scope:** The first edit flow changes XP tier only; safe renaming waits for stable exercise IDs.
- **Abandon semantics:** The entire attempt is excluded from performance history and list movement, while every recorded set retains its tier-adjusted partial XP. There is no separate abandonment bonus.
- **Crash recovery:** Unfinished attempts are marked abandoned on restart with earned set XP preserved.
- **Superset completion XP:** Each completed exercise in the superset earns its own tier-adjusted completion XP; the container earns no extra bonus.
- **Workout completion XP:** A fixed 40 XP for eligible explicitly completed workouts.
- **Level curve:** Next level costs `100 + 25 × (level - 1)` XP.
- **Automatic timeout:** Preserve earned XP, award no completion bonus, and show a quiet summary next launch.
- **Celebration form:** Dedicated full-screen sheet or route with programmatic confetti.
- **Sound:** Off by default initially; haptics on when system settings allow.

## 14. Future gamification TODO

These ideas are intentionally preserved but excluded from the initial implementation:

### Progressive statistics and workout receipt

- [ ] Add an end-of-workout receipt with duration, sets, exercises, session XP, and notable progress.
- [ ] Show exercise progress such as weight PR, rep PR, estimated one-rep max, volume trend, and frequency.
- [ ] Add body-part assignments for exercises.
- [ ] Show body-part sets, frequency, recency, and four-week trends.
- [ ] Avoid combining raw weight across unrelated exercises into misleading body-part comparisons.
- [ ] Highlight personal records beyond weight, including consistency and returning after a break.

### Real-life rewards

- [ ] Let the user define a current real-life reward and its required XP.
- [ ] Show reward progress on the home screen and workout-completion screen.
- [ ] Archive claimed rewards and allow selection of the next reward.
- [ ] Decide whether reward progress spends XP or tracks a separate non-decreasing milestone counter.
- [ ] Keep reward definitions private and local by default.

### Motivation before leaving home

- [ ] Preview the next level, selected reward, and useful progressive stat on the home screen.
- [ ] Add a one-tap **Start Gym Quest** flow focused on leaving home rather than planning the workout.
- [ ] Consider manual, geofence, gym Wi-Fi, or Bluetooth arrival confirmation.
- [ ] Reward arrival separately from workout completion only after deciding how to prevent accidental check-ins.
- [ ] Add a minimum-viable-workout mode where arriving or completing a very short workout still counts as success.

### Longer-term progression

- [ ] Add forgiving weekly consistency goals instead of brittle daily streaks.
- [ ] Consider a slowly decaying momentum meter that never erases lifetime progress.
- [ ] Add comeback achievements and arrival-based achievements.
- [ ] Consider transparent variable XP bonuses with a guaranteed maximum interval and no monetary wagering.
- [ ] Consider streak shields or other utility rewards if a weekly consistency system exists.
- [ ] Add optional text-based level titles using existing typography and Material icons.
- [ ] Add a bulk XP-tier editor if classifying existing exercises individually is tedious.

### Focus and time support

- [ ] Add a one-next-action workout mode that visually emphasizes only the current set and next step.
- [ ] Improve time-blindness support with stronger visual rest progress, halfway cues, and ready-now controls.
- [ ] Allow all celebratory sound, haptic, and motion effects to be configured independently.

### Explicitly excluded patterns

- [ ] Do not add monetary gambling or wagering.
- [ ] Do not use deceptive near-misses or losses disguised as wins.
- [ ] Do not erase lifetime progress after inactivity.
- [ ] Do not punish short workouts or encourage unsafe volume for additional XP.
