# Onboarding UX research

## Product decision
The onboarding should answer “what do these numbers mean?” immediately after the user enters body data, and should reduce target-entry effort without hiding user control. The feedback is informational and non-diagnostic. Adults can use a conservative starter suggestion; ages 13–19 keep the existing growth-guidance path and do not receive an automatic numeric target.

## Evidence and UX implications

- Progressive disclosure reduces cognitive load by showing the next useful decision first and revealing detail when it is needed. The Body screen therefore keeps the form focused and places a compact insight card directly below it; the Target screen shows a short set of suggestions before the editable fields. [Nielsen Norman Group: Four Principles to Reduce Cognitive Load](https://www.nngroup.com/articles/4-principles-reduce-cognitive-load/), [Progressive Disclosure](https://www.nngroup.com/articles/progressive-disclosure/)
- Mobile form guidance is clearest when labels persist, supporting text sits beside the relevant field, and validation is shown inline. The existing `ProfileNumberField` keeps persistent labels, unit suffixes and field-level errors; the new cards use the same spacing and token system. [Material Design 3 text fields](https://m3.material.io/components/text-fields/overview), [Think with Google mobile app design guide](https://www.thinkwithgoogle.com/_qs/documents/2544/Principles-of-Mobile-App-Design-_Download-the-Complete-Guide.pdf)
- The Sleek Target reference uses large tap targets with a title, resulting weight/date, pace summary and a visible selection affordance. Flutter mirrors this with accessible squircle tiles, a clear manual fallback, and an estimate card that remains editable below.
- BMI is a screening reference. Adults use CDC categories; ages 13–19 use BMI-for-age thresholds by age and sex. The copy avoids diagnosis and keeps teen numeric targets out of the flow. [CDC adult BMI categories](https://www.cdc.gov/bmi/adult-calculator/bmi-categories.html), [CDC child and teen BMI](https://www.cdc.gov/bmi/child-teen-calculator/)
- Adult loss suggestions are intentionally 5% and 10% milestones because NIDDK describes an initial 5–10% weight-loss goal over about six months. The pace estimate remains governed by the existing 0.5 kg/week default and 1 kg/week upper guardrail. [NIDDK safe weight-loss program](https://www.niddk.nih.gov/health-information/weight-management/choosing-a-safe-successful-weight-loss-program), [CDC gradual weight loss](https://www.cdc.gov/healthy-weight-growth/losing-weight/index.html)

## Implementation guardrails

- Suggestions are generated only for adults and are derived from the current weight; a loss suggestion is clamped to the existing BMI 18.5 floor.
- Selecting a suggestion fills the target field and computes an expected date; the user can still edit the number or date.
- The custom action clears the suggested target and date.
- The insight card updates from controller changes and sex selection, and its teen copy uses age-and-sex reference language.
- Layout keeps content scrollable, builds the target form as one grouped sliver so off-screen fields remain reachable by accessibility and test scrolling, and uses wrapping rather than fixed horizontal rows at large text sizes.
