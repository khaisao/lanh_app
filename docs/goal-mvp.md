# Goal MVP

The first MVP stores one active goal locally on the device. The feature supports four goal types from the design flow.

- `lose` stores current weight, target weight, and an optional schedule.
- `gain` stores current weight, target weight, and an optional schedule.
- `maintain` stores an optional reference weight without using it as a target.
- `logOnly` stores no weight or schedule.

An optional schedule is represented by either an ISO-8601 `targetDate`, an integer `targetWeeks`, or neither. The repository writes one versioned JSON object under `lanh.goal.v1` through `SharedPreferencesAsync`. The UI and domain layer depend on `GoalRepository`, so storage can move to a database later without changing the goal flow.

The app validates direction before review. A lose goal must have a target below current weight. A gain goal must have a target above current weight. Dates must be in the future and week counts must be positive.

## Age-aware weight guidance

The onboarding accepts people from age 13. Adults use a gradual planning pace: loss defaults to 0.5 kg/week and dates that imply more than 1 kg/week are rejected; gain uses a conservative 0.25% body-weight/week reference and warns above 0.5%/week. The target date picker starts at the earliest date allowed by that pace.

People aged 13–19 do not receive an automatic kg/week target. The app calculates an age- and sex-specific BMI-for-age status from CDC 2000 LMS reference rows at the midpoint of each age year, then shows non-stigmatizing growth guidance. Numeric target weight and target date are omitted for this group; the saved goal keeps the intent (gain, lose or maintain) and current weight so the user can continue to the rest of the app.

BMI-for-age is a screening reference, not a diagnosis. Underweight, overweight and obesity guidance for teens should be discussed with a trusted adult and a qualified health professional. Pregnancy, unintentional weight loss, medication effects and medical conditions are outside the automatic planning policy.

## Onboarding feedback and suggestions

While body details are entered, the setup screen shows a live BMI reference card with a plain-language status. Adults use the CDC screening bands; ages 13–19 use the age- and sex-specific reference status and an explanatory note. The card is informational and does not diagnose.

Adult lose and gain flows show suggested milestones before the manual target fields. Lose suggestions start at 5% and 10% milestones; gain suggests a gradual 5% increase. Tapping a suggestion fills the editable target and calculates a planning date, while the user can change the target, choose another date, or clear the suggestion. Teen flows keep guidance-only content without numeric target controls.
