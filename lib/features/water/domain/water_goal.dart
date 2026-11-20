/// One logged glass of water. Every tap on the Home water card is one glass.
const waterGlassMilliliters = 250;

/// Daily water goal in glasses, from EFSA's adequate intake for drinks
/// (≈ 80 % of total water: women 1,6 L, men 2,0 L) rounded to whole glasses:
/// women 6 glasses (1,5 L), men 8 glasses (2,0 L). Not user-editable.
/// Lành has no separate rule for pregnancy or breastfeeding.
int waterGoalGlasses({required bool female}) => female ? 6 : 8;
