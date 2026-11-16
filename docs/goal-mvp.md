# Goal MVP

The first MVP stores one active goal locally on the device. The feature supports four goal types from the design flow.

- `lose` stores current weight, target weight, and an optional schedule.
- `gain` stores current weight, target weight, and an optional schedule.
- `maintain` stores an optional reference weight without using it as a target.
- `logOnly` stores no weight or schedule.

An optional schedule is represented by either an ISO-8601 `targetDate`, an integer `targetWeeks`, or neither. The repository writes one versioned JSON object under `lanh.goal.v1` through `SharedPreferencesAsync`. The UI and domain layer depend on `GoalRepository`, so storage can move to a database later without changing the goal flow.

The app validates direction before review. A lose goal must have a target below current weight. A gain goal must have a target above current weight. Dates must be in the future and week counts must be positive.
