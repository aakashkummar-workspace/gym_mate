# Gymate — Complete Feature Review Document

**Version:** 1.0  
**Date:** April 6, 2026  
**App:** Gymate - Modern Fitness Workout Tracker  
**Platform:** Flutter (iOS / Android)  
**Build Status:** Compiles with 0 errors

---

## Project Statistics

| Metric | Value |
|---|---|
| Total Dart files | 49 |
| Total lines of code | ~7,300 |
| Data models | 9 with Hive adapters |
| Repository methods | 52 across 6 repositories |
| Riverpod providers | 15+ |
| UI screens | 12 |
| Predefined exercises | 40 across 9 muscle groups |
| Navigation routes | 7 main paths |
| Enums | 5 |

---

## Architecture Overview

```
lib/
├── main.dart                                    (58 lines)
├── core/
│   ├── constants/
│   │   ├── app_constants.dart                   (5 enums, defaults, Hive box names)
│   │   └── exercise_database.dart               (40 exercises with 9 fields each)
│   ├── router/app_router.dart                   (GoRouter + StatefulShellRoute)
│   ├── theme/app_theme.dart                     (327 lines — 3D dark theme)
│   └── utils/helpers.dart                       (15 utility functions)
├── data/
│   ├── datasources/hive_service.dart            (9 adapters, 6 Hive boxes)
│   ├── models/ (9 models)
│   └── repositories/ (6 implementations)
├── domain/
│   └── repositories/ (6 abstract interfaces)
└── presentation/
    ├── providers/ (7 provider files)
    └── screens/ (12 screen files)
```

**Design Pattern:** Clean Architecture — Domain / Data / Presentation layers  
**State Management:** Riverpod (StateNotifier + FutureProvider)  
**Local Storage:** Hive offline-first NoSQL  
**Navigation:** GoRouter with 4-tab StatefulShellRoute  
**Theme:** Material 3, dark-only, neon green (#00E676) accents  
**Charts:** fl_chart (LineChart, BarChart)  
**Animations:** flutter_animate  
**Fonts:** Google Fonts (Inter)

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (latest stable) |
| State Management | flutter_riverpod |
| Local Database | Hive + hive_flutter |
| Navigation | go_router |
| Charts | fl_chart |
| Animations | flutter_animate |
| Fonts | google_fonts (Inter) |
| Date Formatting | intl |
| ID Generation | uuid |

---

## Data Models — All 9

### ExerciseModel (Hive TypeId: 0)
| Field | Type | Description |
|---|---|---|
| id | String | Unique identifier |
| name | String | Exercise name |
| muscleGroup | String | Primary muscle group |
| secondaryMuscleGroup | String | Secondary/synergist muscle |
| equipment | String | Equipment type |
| difficulty | String | beginner / intermediate / advanced |
| defaultSets | int | Default set count |
| defaultReps | int | Default rep count |
| defaultWeight | double | Default weight (kg) |
| defaultTimerSeconds | int | Per-exercise timer duration |
| description | String | Exercise instructions |
| isCustom | bool | Is user-created |
| createdAt | DateTime | Creation timestamp |

### TemplateExerciseModel (Hive TypeId: 1)
| Field | Type | Description |
|---|---|---|
| exerciseId | String | Reference to exercise |
| name | String | Exercise name snapshot |
| muscleGroup | String | Muscle group snapshot |
| equipment | String | Equipment snapshot |
| sets | int | Sets in template |
| reps | int | Reps in template |
| weight | double | Weight in template |
| restSeconds | int | Rest time between sets |
| timerSeconds | int | Per-exercise timer |
| order | int | Position in template |
| notes | String | Exercise-specific notes |

### TemplateModel (Hive TypeId: 2)
| Field | Type | Description |
|---|---|---|
| id | String | Unique identifier |
| name | String | Template name |
| description | String | Workout description |
| exercises | List&lt;TemplateExerciseModel&gt; | Ordered exercise list |
| createdAt | DateTime | Creation time |
| updatedAt | DateTime | Last modified time |
| colorIndex | int | Color palette index (0-7) |
| isArchived | bool | Archive flag |

### SessionSetModel (Hive TypeId: 3)
| Field | Type | Description |
|---|---|---|
| setNumber | int | Set number (1-indexed) |
| targetReps | int | Target reps from template |
| actualReps | int | Actually performed reps |
| targetWeight | double | Target weight from template |
| actualWeight | double | Actually used weight |
| isCompleted | bool | Completion flag |
| completedAt | DateTime? | Completion timestamp |

### SessionExerciseModel (Hive TypeId: 4)
| Field | Type | Description |
|---|---|---|
| exerciseId | String | Reference to exercise |
| name | String | Exercise name |
| muscleGroup | String | Muscle group |
| equipment | String | Equipment |
| sets | List&lt;SessionSetModel&gt; | Completed sets |
| restSeconds | int | Rest timer |
| timerSeconds | int | Exercise timer |
| order | int | Position in session |
| notes | String | Session notes |
| isCompleted | bool | All sets done (mutable) |

### SessionModel (Hive TypeId: 5)
| Field | Type | Description |
|---|---|---|
| id | String | Unique identifier |
| templateId | String | Template reference |
| templateName | String | Template name snapshot |
| scheduledDate | DateTime | Planned date |
| startedAt | DateTime? | Start time |
| completedAt | DateTime? | End time |
| exercises | List&lt;SessionExerciseModel&gt; | Exercise list |
| status | String | scheduled / inProgress / completed / skipped |
| notes | String | Session notes |
| *completionPercentage* | *double (getter)* | *Percentage of sets completed* |
| *totalVolume* | *double (getter)* | *Sum of weight x reps for completed sets* |
| *duration* | *Duration? (getter)* | *Duration from start to end* |

### ScheduleModel (Hive TypeId: 6)
| Field | Type | Description |
|---|---|---|
| id | String | Unique identifier |
| templateId | String | Template reference |
| templateName | String | Template name snapshot |
| dayOfWeek | int? | 1=Mon to 7=Sun (for weekly) |
| specificDate | DateTime? | One-time date |
| recurrenceType | String | once / weekly / alternateDay / everyXDays / custom |
| customDays | List&lt;int&gt; | Days of week for custom schedule |
| repeatEveryXDays | int | Interval for everyXDays type |
| isActive | bool | Enable flag |
| createdAt | DateTime | Creation time |

**Method:** `appliesTo(DateTime date)` — Check if schedule applies to a specific date

### UserProfileModel (Hive TypeId: 7)
| Field | Type | Description |
|---|---|---|
| id | String | User identifier |
| name | String | User's name |
| goal | String | Fitness goal |
| experienceLevel | String | Training level |
| splitPreference | String | Preferred split type |
| onboardingCompleted | bool | Onboarding flag |
| createdAt | DateTime | Profile creation time |

### PersonalRecordModel (Hive TypeId: 8)
| Field | Type | Description |
|---|---|---|
| id | String | Unique identifier |
| exerciseId | String | Exercise reference |
| exerciseName | String | Exercise name snapshot |
| weight | double | Record weight |
| reps | int | Reps at that weight |
| volume | double | Weight x reps |
| date | DateTime | Record date |

---

## Exercise Database

**Total Exercises:** 40

### By Muscle Group:

| Muscle Group | Count | Exercises |
|---|---|---|
| Chest | 5 | Barbell Bench Press, Incline Dumbbell Press, Cable Fly, Push-Ups, Dumbbell Fly |
| Back | 5 | Deadlift, Barbell Row, Pull-Ups, Lat Pulldown, Seated Cable Row |
| Shoulders | 5 | Overhead Press, Lateral Raise, Front Raise, Face Pull, Arnold Press |
| Biceps | 4 | Barbell Curl, Dumbbell Curl, Hammer Curl, Cable Curl |
| Triceps | 4 | Tricep Pushdown, Overhead Tricep Extension, Close Grip Bench Press, Dips |
| Legs | 8 | Barbell Squat, Leg Press, Romanian Deadlift, Walking Lunges, Leg Extension, Leg Curl, Calf Raises, Bulgarian Split Squat |
| Core | 5 | Plank, Cable Crunch, Hanging Leg Raise, Russian Twist, Ab Wheel Rollout |
| Cardio | 4 | Treadmill Run, Rowing Machine, Jump Rope, Burpees |

### By Difficulty:
- **Beginner:** ~21 exercises
- **Intermediate:** ~13 exercises
- **Advanced:** ~6 exercises (Deadlift, Barbell Squat, etc.)

### Each Exercise Contains:
- ID, Name, Primary Muscle, Secondary Muscle, Equipment, Difficulty
- Default Sets, Default Reps, Default Weight, Default Timer (for timed exercises)
- Description/Instructions

### Secondary Muscle Groups (Compound Movements):
- Bench Press → Triceps
- Deadlift → Legs
- Barbell Row → Biceps
- Overhead Press → Triceps
- Pull-Ups → Biceps
- Barbell Squat → Core
- And more...

---

## Enums Defined

| Enum | Values |
|---|---|
| MuscleGroup | chest, back, shoulders, biceps, triceps, legs, core, cardio, fullBody |
| Equipment | barbell, dumbbell, machine, cable, bodyweight, kettlebell, bands |
| Difficulty | beginner, intermediate, advanced |
| FitnessGoal | muscleGain, fatLoss, strength, endurance |
| SplitType | ppl, broSplit, upperLower, fullBody, custom |

---

## Feature-by-Feature Breakdown

### 1. Workout Library (529 lines)

**File:** `lib/presentation/screens/library/workout_library_screen.dart`

**Features:**
- 40 predefined exercises auto-seeded on first launch
- **3-tier filtering system:**
  - Muscle group filter chips (All, Chest, Back, Shoulders, Biceps, Triceps, Legs, Core, Cardio, Full Body)
  - Equipment filter chips (All, Barbell, Dumbbell, Machine, Cable, Bodyweight, Kettlebell, Bands)
  - Difficulty filter chips (Beginner = green, Intermediate = amber, Advanced = red)
- Real-time search across name, primary muscle, secondary muscle, equipment
- Combined filter logic (all filters apply simultaneously)
- Exercise cards showing:
  - Muscle group icon with color coding
  - Exercise name
  - "Primary · Secondary · Equipment" subtitle
  - Difficulty badge with color
- Exercise detail bottom sheet:
  - All badges (muscle, secondary, equipment, difficulty)
  - Default sets × reps @ weight
  - Timer display if defaultTimerSeconds > 0
  - Description/instructions
- Custom exercise creation form:
  - Name, muscle group, equipment, difficulty dropdowns
  - Sets, reps, weight, timer inputs
  - Description field
- Floating action button for adding custom exercises

---

### 2. Template System (938 lines across 3 screens)

**Files:**
- `lib/presentation/screens/templates/templates_screen.dart` (241 lines)
- `lib/presentation/screens/templates/create_template_screen.dart` (503 lines)
- `lib/presentation/screens/templates/template_detail_screen.dart` (194 lines)

**Templates List Screen:**
- List of all active (non-archived) templates
- 3D colored cards with template color indicator
- Exercise count + muscle group tags
- Popup menu with 5 actions:
  - **Edit** — navigate to edit screen
  - **Rename** — dialog with pre-filled text field
  - **Duplicate** — creates copy with "(Copy)" suffix
  - **Archive** — moves to archived with snackbar confirmation
  - **Delete** — confirmation dialog
- "View Archived" button in AppBar
  - Bottom sheet listing archived templates
  - Unarchive button per template
- Empty state with guidance + create button
- FAB for new template creation

**Create/Edit Template Screen:**
- Template name input (large, bold)
- Description field (optional)
- Color picker (8 colors)
- Exercise list with **drag-and-drop reorder** (ReorderableListView)
- Per-exercise controls (all tap-based):
  - Sets (+/- buttons)
  - Reps (+/- buttons)
  - Weight (+/- with 2.5kg steps)
  - Rest timer (+/- with 15s steps)
  - Exercise timer (shown if > 0, +/- with 15s steps)
- Delete exercise button
- Add exercise via searchable bottom sheet picker
- Exercises inherit defaults from exercise database (including timer)
- Validation: name required, at least 1 exercise

**Template Detail Screen:**
- Template header with color strip
- Description display
- Stats row: exercise count, estimated duration, total sets
- Exercise list with:
  - Muscle group icon + color
  - Name, sets × reps @ weight
  - Rest timer badge
  - Exercise timer badge (if applicable)
- Bottom action bar:
  - "Schedule" — navigates to calendar
  - "Start Workout" — creates session and navigates to execution

---

### 3. Calendar Scheduling (498 lines)

**File:** `lib/presentation/screens/calendar/calendar_screen.dart`

**3 Calendar Views (toggle in AppBar):**

**Month View:**
- Month/year header with left/right navigation arrows
- Day-of-week headers (M T W T F S S)
- Grid of day cells
- Today: green border highlight
- Selected day: green fill with black text
- Tap to select and show sessions

**Week View:**
- Date range header with navigation arrows
- 7-day horizontal strip
- Each day shows: day name + date number
- Selected day: green fill
- Today: green border
- Compact, gym-friendly layout

**Day View:**
- Large date header (day name + full date)
- Previous/next day navigation
- "TODAY" badge if applicable
- Full session detail below

**Sessions for Selected Date:**
- List of all sessions (supports multiple per day)
- Each session card: template name, exercise count, status badge
- Tap to navigate to session execution
- Empty state: "No workouts scheduled" + guidance

**Add Workout Flow (bottom sheet):**
- Template selector dropdown
- 4 recurrence options:
  - **One Time** — just this date
  - **Weekly** — repeats on this day of week
  - **Every X Days** — configurable interval (default 3, +/- controls)
  - **Custom** — multi-select day-of-week chips (Mon-Sun)
- Creates ScheduleModel + SessionModel on confirm
- Auto-refreshes session list

---

### 4. Workout Session Execution (706 lines — largest screen)

**File:** `lib/presentation/screens/session/workout_session_screen.dart`

**This is the most critical screen in the entire app.**

**Top Bar:**
- Close button with "End workout?" confirmation dialog
- Template name
- Elapsed timer (HH:MM:SS, updates every second)
- Circular completion percentage ring

**Exercise Cards (expandable):**
- Collapsed: muscle icon, exercise name, "X/Y sets done"
- Green border when all sets completed
- Auto-detect completion (all sets done → green check)

**Expanded Set Tracking:**
- Column headers: SET | WEIGHT | REPS | ✓
- Per set row:
  - Set number (bold)
  - Weight stepper: -/+ buttons (2.5kg tap, 5kg long-press)
  - Reps stepper: -/+ buttons (1 tap, 5 long-press)
  - Completion checkbox (green fill on complete)
- Completed set rows get green tint
- "Add Set" button below last set

**Exercise Timer (for timed exercises):**
- Countdown timer with circular progress
- "Skip" button
- Triggers on tap
- Haptic feedback on complete

**Rest Timer (between sets):**
- Configurable per exercise (from template restSeconds)
- Countdown display with large numbers
- Circular progress ring
- "Skip" button
- Haptic feedback on finish

**Complete Workout:**
- Bottom bar: "Complete Workout X%" button
- Enabled only when at least 1 set completed
- Confirmation dialog
- On complete:
  - Sets status = 'completed'
  - Records completedAt timestamp
  - Checks all exercises for personal records
  - Shows completion summary

**Completion Summary:**
- Trophy icon with glow animation
- "Workout Complete!" heading
- Duration | Volume | Sets completed
- "Back to Home" button

**Critical Design Rule:**
- Session data stored independently from template
- Template = structure (never modified during session)
- Session = actual performed values (actualReps, actualWeight)
- All controls are TAP-BASED (no keyboard during workout)

---

### 5. Analytics Dashboard (635 lines)

**File:** `lib/presentation/screens/analytics/analytics_screen.dart`

**Summary Cards (top row):**
- Streak: fire icon + consecutive days count
- Completion: percentage of scheduled sessions completed (30 days)
- Workouts: total completed session count

**Exercise Progress Section:**
- Dropdown to select any exercise from database
- When selected, shows:

**Weight Progression Chart (fl_chart LineChart):**
- X-axis: dates (last 10 sessions)
- Y-axis: max weight per session
- Curved green line with gradient fill
- Interactive touch tooltips
- Dark theme styling

**Volume Progression Chart (fl_chart BarChart):**
- X-axis: dates
- Y-axis: total volume (weight × reps)
- Coral-colored bars with rounded tops
- Dark theme styling

**Personal Records Section:**
- Trophy icon header
- List of weight PRs for selected exercise
- Each record: weight × reps, date, volume
- Empty state: "Complete workouts to set PRs!"

**Workout Frequency Chart (fl_chart BarChart):**
- "Last 30 days" subtitle
- 7 bars: Mon through Sun
- Green bars showing workout count per day
- Helps users see their training distribution

**Muscle Group Heat Map:**
- "Based on completed workouts" subtitle
- Grid of muscle group tiles (3 per row)
- Each tile:
  - Muscle group icon
  - Group name
  - Session count
  - Color intensity = proportional to training frequency
  - More workouts → brighter, more opaque color
- Uses muscleGroupColor for each group

**Recent Workouts:**
- Chronological list of completed sessions
- Each entry: template name, date, volume, duration
- Green check badge

---

### 6. Onboarding Flow (412 lines)

**File:** `lib/presentation/screens/onboarding/onboarding_screen.dart`

**5-Step PageView:**

| Step | Screen | Content |
|---|---|---|
| 1 | Welcome | GYMATE logo + "Your Personal Workout Companion" + Get Started button |
| 2 | Goal | 4 selectable cards: Muscle Gain, Fat Loss, Strength, Endurance |
| 3 | Level | 3 selectable cards: Beginner, Intermediate, Advanced |
| 4 | Split | 5 selectable cards: PPL, Bro Split, Upper/Lower, Full Body, Custom |
| 5 | Ready | Summary of selections + "Generate & Start" button |

**Progress Indicator:**
- 5-segment progress bar at top
- Active segments fill green
- Smooth animation on step change

**Selection Cards:**
- 3D dark cards with icon, label, description
- Selected: green glow border + green tint + check badge
- Animated entry (fadeIn + slideX)

**Auto-Generate Starter Templates:**

| Split | Templates Generated |
|---|---|
| PPL | Push Day (6 exercises), Pull Day (6), Leg Day (6) |
| Bro Split | Chest Day (5), Back Day (5), Shoulder Day (5), Arm Day (5), Leg Day (5) |
| Upper/Lower | Upper Body (6), Lower Body (6) |
| Full Body | Full Body A (5), Full Body B (5) |
| Custom | No templates generated |

Each template uses real exercise IDs from the database with appropriate default sets/reps/weight.

---

### 7. Home Screen (520 lines)

**File:** `lib/presentation/screens/home/home_screen.dart`

**Top Bar:**
- Time-based greeting ("Good Morning/Afternoon/Evening")
- User name from profile
- Profile avatar icon

**Stats Row (3D cards):**
- Workout streak (fire icon, orange glow)
- Completion rate (check icon, green glow)

**"YOUR WEEK" Section:**
- Swipeable horizontal day cards (PageView)
- 7 days: 3 past + today + 3 future
- ViewportFraction: 0.82 (peek effect)
- Scale + opacity animation on swipe
- Each card shows:
  - Day name (Today/Tomorrow/Yesterday or day)
  - Date
  - TODAY badge (green)
  - Template name if scheduled
  - Exercise count + muscle group tags
  - Progress bar
  - "Tap to start" / "X% done" / "Completed" status
  - Rest Day state with icon

**Quick Action Buttons:**
- Quick Start (bolt icon, green)
- Templates (grid icon, purple)
- History (clock icon, coral)

---

### 8. Navigation Shell (139 lines)

**File:** `lib/presentation/screens/home/app_shell.dart`

**Floating Bottom Navigation Bar:**
- 24px margin from screen edges
- Rounded 24px corners
- Dark card background with subtle border
- Shadow for floating 3D effect
- 4 tabs: Home, Library, Calendar, Stats
- Active tab: green pill with icon + label
- Inactive tab: grey icon only
- Smooth animated transitions

---

## Routing Map

```
/onboarding                          → OnboardingScreen
/                                    → HomeScreen (Tab 0)
/library                             → WorkoutLibraryScreen (Tab 1)
/calendar                            → CalendarScreen (Tab 2)
/analytics                           → AnalyticsScreen (Tab 3)
/templates                           → TemplatesScreen
/templates/create                    → CreateTemplateScreen (new)
/templates/:id                       → TemplateDetailScreen
/templates/:id/edit                  → CreateTemplateScreen (edit mode)
/session/:id                         → WorkoutSessionScreen
```

---

## Repository Methods (52 total)

### ExerciseRepository (10 methods)
1. getAllExercises()
2. getExerciseById(String id)
3. addExercise(ExerciseModel)
4. updateExercise(ExerciseModel)
5. deleteExercise(String id)
6. searchExercises(String query)
7. filterByMuscleGroup(String)
8. filterByEquipment(String)
9. filterByDifficulty(String)
10. seedDefaultExercises()

### TemplateRepository (10 methods)
1. getAllTemplates() — excludes archived
2. getTemplateById(String id)
3. addTemplate(TemplateModel)
4. updateTemplate(TemplateModel)
5. deleteTemplate(String id)
6. duplicateTemplate(String id)
7. renameTemplate(String id, String newName)
8. archiveTemplate(String id)
9. unarchiveTemplate(String id)
10. getArchivedTemplates()

### SessionRepository (9 methods)
1. getAllSessions()
2. getSessionById(String id)
3. createSessionFromTemplate(TemplateModel, DateTime)
4. updateSession(SessionModel)
5. deleteSession(String id)
6. getSessionsByDate(DateTime)
7. getSessionsInRange(DateTime start, DateTime end)
8. getCompletedSessions()
9. getSessionsByExercise(String exerciseId)

### ScheduleRepository (6 methods)
1. getAllSchedules()
2. addSchedule(ScheduleModel)
3. updateSchedule(ScheduleModel)
4. deleteSchedule(String id)
5. getSchedulesForDay(int dayOfWeek)
6. getSchedulesForDate(DateTime)

### UserRepository (4 methods)
1. getUserProfile()
2. saveUserProfile(UserProfileModel)
3. isOnboardingCompleted()
4. completeOnboarding()

### AnalyticsRepository (7 methods)
1. getPersonalRecords(String exerciseId)
2. checkAndUpdatePersonalRecord(exerciseId, name, weight, reps, date)
3. getWeightProgression(String exerciseId, {lastNSessions})
4. getVolumeProgression(String exerciseId, {lastNSessions})
5. getWorkoutStreak()
6. getWorkoutFrequency({lastNDays})
7. getCompletionRate({lastNDays})

---

## Riverpod Providers (15+)

### Repository Providers (6)
- exerciseRepositoryProvider
- templateRepositoryProvider
- sessionRepositoryProvider
- scheduleRepositoryProvider
- userRepositoryProvider
- analyticsRepositoryProvider

### StateNotifier Providers (4)
- exerciseListProvider (ExerciseListNotifier)
- templateListProvider (TemplateListNotifier)
- activeSessionProvider (ActiveSessionNotifier)
- scheduleListProvider (ScheduleNotifier)
- onboardingProvider (OnboardingNotifier)

### FutureProviders (6)
- userProfileProvider
- onboardingCompletedProvider
- sessionsForDateProvider(DateTime) — family
- allSessionsProvider
- completedSessionsProvider
- weightProgressionProvider(String) — family
- volumeProgressionProvider(String) — family
- workoutStreakProvider
- completionRateProvider
- personalRecordsProvider(String) — family
- workoutFrequencyProvider

### State Providers (3)
- exerciseSearchQueryProvider
- selectedMuscleGroupProvider
- selectedEquipmentProvider
- selectedDateProvider
- selectedTemplateProvider

---

## UI Theme — Dark 3D Minimalist

### Color Palette

| Token | Hex | Usage |
|---|---|---|
| primary | #00E676 | Neon green — buttons, accents, active states |
| primaryDark | #00C853 | Darker green variant |
| secondary | #FF6B6B | Coral — streak fire, warnings |
| accent | #7C4DFF | Purple — tertiary accent |
| background | #000000 | Pure black — scaffold |
| surface | #0D0D0D | Slightly lighter black |
| card | #141414 | Card backgrounds |
| cardLight | #1A1A1A | Elevated cards |
| cardBorder | #2A2A2A | Subtle 0.5px borders |
| success | #00E676 | Green — completion |
| warning | #FFC107 | Amber — intermediate |
| error | #FF5252 | Red — delete, advanced |
| textPrimary | #FFFFFF | White text |
| textSecondary | #8E8E93 | Grey text |
| textHint | #48484A | Dark grey hints |

### Template Colors (8)
Neon Green, Coral, Purple, Orange, Light Blue, Pink, Cyan, Yellow

### 3D Card Styles (4 types)
- **card3D** — Base: 20px radius, black shadow (blur 20, offset 8), white inner highlight
- **card3DColored(color)** — Gradient tint + colored glow shadow
- **card3DElevated** — Deeper shadows (blur 30, offset 12) for hero cards
- **glassCard** — White 5% alpha, frosted glass effect

### Typography
- **Font:** Google Fonts Inter
- **Display:** 34px, weight 800, letter-spacing -1.2
- **Headline:** 24px, weight 700
- **Body:** 16px, weight 400
- **Label Small:** 10px, weight 500, letter-spacing 1.2

---

## Critical Design Rules

1. **Template ≠ Session** — Templates are blueprints that NEVER change during workouts. Sessions store actualReps/actualWeight independently.

2. **Tap-Only Controls** — All workout interactions use +/- buttons. No keyboard input during sessions. Long-press for fast increments.

3. **Offline-First** — All data stored locally via Hive. No network dependency.

4. **One-Hand Usability** — Large touch targets (minimum 44px), thumb-reachable controls.

5. **Hive Backward Compatibility** — New model fields use `fields.containsKey()` for safe migration from older data.

---

## What's NOT Built (Future Phases)

### Phase 2 — Social Features
| Feature | Status |
|---|---|
| Friends module (add/search/accept/reject) | Not started |
| Friend profiles (streak, PRs, templates) | Not started |
| Template sharing via link | Not started |
| Template sharing via QR code | Not started |
| Template sharing to friends | Not started |
| Social feed | Not started |
| Compare progress with friends | Not started |

### Phase 3 — Advanced Features
| Feature | Status |
|---|---|
| AI progressive overload suggestions | Not started |
| Recovery score / muscle recovery | Not started |
| Apple Health / Google Fit integration | Not started |
| Smart watch companion | Not started |
| Coach mode (trainer assigns remotely) | Not started |
| Light mode theme | Not started |

---

## Build Information

**APK Location:** `build/app/outputs/flutter-apk/app-debug.apk`

**Build Command:**
```bash
flutter build apk --debug    # Debug build
flutter build apk --release  # Release build (optimized)
```

**Analysis:** 0 errors, 0 warnings (info-only: deprecated `value` on DropdownButtonFormField)

---

*Generated for Gymate v1.0 — April 2026*
