# Goal MVP

The first MVP stores one active goal locally on the device. The feature supports four goal types from the design flow.

- `lose` stores current weight, target weight, and an optional schedule.
- `gain` stores current weight, target weight, and an optional schedule.
- `maintain` stores an optional reference weight without using it as a target.
- `logOnly` stores no weight or schedule.

An optional schedule is represented by either an ISO-8601 `targetDate`, an integer `targetWeeks`, or neither. The repository writes one versioned JSON object under `lanh.goal.v1` through `SharedPreferencesAsync`. The UI and domain layer depend on `GoalRepository`, so storage can move to a database later without changing the goal flow.

The app validates direction before review. A lose goal must have a target below current weight. A gain goal must have a target above current weight. Dates must be in the future and week counts must be positive.

## Age-aware weight guidance

The onboarding accepts people from age 13 and plausible values only (height 100–250 cm, weight 25–350 kg, age up to 120). Adults (20+) get a numeric plan from [`goal_policy.dart`](../lib/features/profile_setup/domain/goal_policy.dart):

| Rule | Value | Source |
| --- | --- | --- |
| Loss suggestions | 5%, 7% and 10% of current weight, whole kg | NIH/NHLBI obesity guidance: 5–10% is the meaningful first goal; 7% is the Diabetes Prevention Program goal (Knowler et al., NEJM 2002) |
| Gentle loss pace (no date) | 10% of baseline over 26 weeks (≈0.38%/week) | [NHLBI guideline](https://www.nhlbi.nih.gov/health/educational/lose_wt/guidelines.htm): about 10% in six months |
| Common loss pace | 0.5–1 kg/week | [NHS obesity treatment](https://www.nhs.uk/conditions/obesity/treatment/), CDC 1–2 lb/week |
| Loss upper guard | lower of 1 kg/week and 1% body weight/week | NHS/CDC; Helms et al., JISSN 2014 |
| Adult BMI reading | underweight < 18.5, normal 18.5–22.9, overweight 23–24.9, obesity ≥ 25 | WHO WPRO/IASO/IOTF Asia-Pacific (2000); WHO Expert Consultation, Lancet 2004;363:157-63 |
| Loss floor | never below BMI 18.5 for the height | WHO adult BMI classification |
| Gain suggestions | +5%, +7% and +10% (same steps as loss; no trial sets a gain step), never above BMI 22.9 | Top of the WHO normal range for Asian adults |
| Gain pace | 0.25%/week gentle, 0.5%/week upper guard | Iraki et al., Sports 2019 |
| Resting energy | Mifflin‑St Jeor; tends to overestimate in Asian samples, so the lower PAL is used in each band | Mifflin et al., Am J Clin Nutr 1990 |
| Activity level (PAL) | Mostly sitting 1.40, mixed 1.55, on feet most of the day 1.75, physical work 2.00, unknown 1.40 (range 1.40–1.75) | [FAO/WHO/UNU 2004](https://www.fao.org/4/y5686e/y5686e07.htm) bands 1.40–1.69 / 1.70–1.99 / 2.00–2.40; NASEM 2023 DRI for Energy |
| Daily budget | energy used − kg/week × 7,700 ÷ 7 (loss); + surplus capped at 500 kcal (gain); energy used (maintain) | Wishnofsky 7,700 kcal/kg, valid for early change only (Hall et al., Lancet 2011) |
| Energy floor | never below resting energy, nor 1,200 kcal (women) / 1,500 kcal (men); loss pace and earliest date are capped so the budget stays at the floor, and no loss plan is offered when the floor leaves under 0.1 kg/week | [NHLBI eating plan](https://www.nhlbi.nih.gov/health/educational/lose_wt/eat/calories) |

A chosen date faster than the upper guard is refused; the date picker starts at the earliest safe date. Without a date the gentle pace gives a projected date only, and no deadline is saved. When the current weight already sits at the BMI bound, the Target step explains why there is no target and suggests Maintain.

People aged 13–19 do not receive an automatic kg/week target. The app calculates an age- and sex-specific BMI-for-age status from CDC 2000 LMS reference rows at the midpoint of each age year, then shows non-stigmatizing growth guidance. Numeric target weight and target date are omitted for this group; the saved goal keeps the intent (gain, lose or maintain) and current weight so the user can continue to the rest of the app.

BMI-for-age is a screening reference, not a diagnosis. Underweight, overweight and obesity guidance for teens should be discussed with a trusted adult and a qualified health professional. Pregnancy, unintentional weight loss, medication effects and medical conditions are outside the automatic planning policy.

## Onboarding feedback and suggestions

The BMI ring card appears below the inputs only once age, height, weight and sex are all filled and plausible, so nothing being edited moves. It waits 350 ms after the last change, grows open with a fade, small rise and scale (480 ms, ease-out-quart), then the ring sweeps from empty while the number counts up (1.1 s). The open uses `Align.heightFactor` with a clip only while animating, so the settled card keeps its full glass shadow and the status fades in as it settles; clearing a value closes it after 700 ms. Reduce Motion shows and hides it instantly. When the keyboard is down the page scrolls the card into view. Adults use the WHO cut-offs for Asian adults (18.5 / 23 / 25) from [`body_metrics.dart`](../lib/features/profile_setup/domain/body_metrics.dart), and the card names that scale. These are lower than the international 25 / 30 because WHO found health risk rising from BMI 23 in Asian populations (Lancet 2004;363:157-63). Ages 13–19 use the age- and sex-specific reference status. The ring is a fixed display scale up to BMI 30, not a cut-off. The card is informational and does not diagnose.

The flow is Goal → Body → Activity → Target → Review. The back button and step progress stay pinned at the top; only the step content scrolls. Activity sits before the Target so each plan can show its daily kcal and respect the energy floor. The Activity step lists five answers with examples and, for adults, an energy card ("Cơ thể bạn dùng khoảng … kcal/ngày", a range for the unknown answer) from [`energy_estimate.dart`](../lib/features/profile_setup/domain/energy_estimate.dart). Sex is preselected as male and changes with one tap. Adult women see an optional "pregnant or breastfeeding" switch on the Body step; it is never saved, and it turns off the kcal estimate and the numeric target.

The Target step (Profile Setup Target) has two modes. "Theo gợi ý của Lành" preselects the 5% plan and shows the 7% and 10% plans, each with pace, weeks, projected date and daily kcal; switching to "Tự chọn" starts from the selected plan's target. "Tự chọn" picks a whole-kg target from chips limited to the healthy range, an optional date, and a live plan estimate. Plan cards and the estimate card show "≈ … kcal/ngày". When the floor slows the gentle plan, a note says so; when it leaves no room for a loss, the step explains why and suggests Maintain. Maintain, ages 13–19 and pregnancy skip this step; teens read growth guidance on the Activity step instead.

Confirming the last step opens the plan sheet (Sleek: Plan Ready, Plan Ready Gain, Plan Ready Maintain, Plan Ready No Kcal) instead of a text review. Loss shows "Mỗi ngày nên nạp" with the budget, and an energy bar of the body's use split into "Nạp" and a striped "Bớt"; gain shows the body's use plus a gold "Thêm"; maintain shows a full bar "Bằng mức cơ thể dùng"; ages 13–19 and pregnancy show "Theo dõi, không đếm kcal" and no number. kcal values use the 50-kcal display step and the parts add up (Nạp + Bớt = Cơ thể dùng). A plan whose rounded budget equals the body's use is shown as maintain. Three icon tiles follow (target, kg per week, expected date; or weight, activity, BMI; or goal, weight, activity). "Bắt đầu" saves the profile with exactly the shown budget (`daily_energy_kcal`, schema v2 adds the nullable column without touching existing rows); "Chỉnh lại", a drag down or a tap outside keeps every answer. Today then reads "0 / 1.600 kcal · Còn 1.600 kcal", shows a first-meal card while the day's journal is empty, and pulses a halo behind the log-meal action. The estimate is not re-run automatically yet.

When no healthy target exists for the goal (BMI bound or energy floor), the Target step offers "Chuyển sang Giữ cân", which keeps the answers and finishes from the Activity step.

Number fields accept whole ages (≤3 digits) and weights/heights with up to three digits, one separator (comma or dot) and one decimal; malformed text is refused as typed. Age and height move the keyboard to the next field.