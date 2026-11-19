import 'profile.dart';

enum TeenBmiStatus { underweight, healthy, overweight, obesity }

final class TeenBmiReference {
  const TeenBmiReference({
    required this.ageYears,
    required this.sex,
    required this.l,
    required this.m,
    required this.s,
    required this.p5,
    required this.p85,
    required this.p95,
  });

  final int ageYears;
  final ProfileSex sex;
  final double l;
  final double m;
  final double s;
  final double p5;
  final double p85;
  final double p95;
}

/// CDC 2000 BMI-for-age LMS reference at the midpoint of each age year.
/// Source: https://www.cdc.gov/growthcharts/cdc-data-files.htm
///
/// Sex 1/2 in the CDC file maps to male/female here. The app only asks for
/// whole years, so the midpoint row avoids pretending to know the user's
/// exact birth month.
const teenBmiReferences = <TeenBmiReference>[
  TeenBmiReference(
    ageYears: 13,
    sex: ProfileSex.male,
    l: -2.277017201,
    m: 18.81201584,
    s: 0.134879611,
    p5: 15.71971118,
    p85: 22.25973057,
    p95: 25.62255542,
  ),
  TeenBmiReference(
    ageYears: 14,
    sex: ProfileSex.male,
    l: -2.179425674,
    m: 19.50672885,
    s: 0.135308594,
    p5: 16.26979755,
    p85: 23.06061552,
    p95: 26.45091448,
  ),
  TeenBmiReference(
    ageYears: 15,
    sex: ProfileSex.male,
    l: -2.085574403,
    m: 20.20858236,
    s: 0.134718085,
    p5: 16.84323264,
    p85: 23.83459013,
    p95: 27.20682538,
  ),
  TeenBmiReference(
    ageYears: 16,
    sex: ProfileSex.male,
    l: -1.993150137,
    m: 20.90294449,
    s: 0.1336202,
    p5: 17.41995236,
    p85: 24.58032971,
    p95: 27.91225209,
  ),
  TeenBmiReference(
    ageYears: 17,
    sex: ProfileSex.male,
    l: -1.908831065,
    m: 21.57417053,
    s: 0.132584784,
    p5: 17.97833773,
    p85: 25.30172632,
    p95: 28.60329919,
  ),
  TeenBmiReference(
    ageYears: 18,
    sex: ProfileSex.male,
    l: -1.849323204,
    m: 22.20541249,
    s: 0.132248993,
    p5: 18.49520062,
    p85: 26.00822631,
    p95: 29.33030127,
  ),
  TeenBmiReference(
    ageYears: 19,
    sex: ProfileSex.male,
    l: -1.833400825,
    m: 22.7798953,
    s: 0.133338999,
    p5: 18.9448942,
    p85: 26.71557609,
    p95: 30.15706484,
  ),
  TeenBmiReference(
    ageYears: 13,
    sex: ProfileSex.female,
    l: -1.9610997,
    m: 19.04811118,
    s: 0.151176355,
    p5: 15.55572457,
    p85: 22.96953922,
    p95: 26.78861781,
  ),
  TeenBmiReference(
    ageYears: 14,
    sex: ProfileSex.female,
    l: -2.002014224,
    m: 19.64746266,
    s: 0.151009595,
    p5: 16.05992392,
    p85: 23.70570337,
    p95: 27.70078892,
  ),
  TeenBmiReference(
    ageYears: 15,
    sex: ProfileSex.female,
    l: -2.074459502,
    m: 20.19980767,
    s: 0.14984254,
    p5: 16.55358366,
    p85: 24.36436993,
    p95: 28.52601678,
  ),
  TeenBmiReference(
    ageYears: 16,
    sex: ProfileSex.female,
    l: -2.167044578,
    m: 20.6891237,
    s: 0.148349348,
    p5: 17.00880162,
    p85: 24.94355805,
    p95: 29.27780966,
  ),
  TeenBmiReference(
    ageYears: 17,
    sex: ProfileSex.female,
    l: -2.26238209,
    m: 21.10163241,
    s: 0.147323144,
    p5: 17.39427286,
    p85: 25.44895346,
    p95: 29.98109225,
  ),
  TeenBmiReference(
    ageYears: 18,
    sex: ProfileSex.female,
    l: -2.336038473,
    m: 21.42548351,
    s: 0.147689289,
    p5: 17.67537444,
    p85: 25.89392241,
    p95: 30.67259539,
  ),
  TeenBmiReference(
    ageYears: 19,
    sex: ProfileSex.female,
    l: -2.358980464,
    m: 21.65006126,
    s: 0.150520734,
    p5: 17.81455755,
    p85: 26.29911039,
    p95: 31.40153631,
  ),
];

TeenBmiReference? teenBmiReference(int ageYears, ProfileSex sex) {
  for (final reference in teenBmiReferences) {
    if (reference.ageYears == ageYears && reference.sex == sex) {
      return reference;
    }
  }
  return null;
}

double? teenBmi({
  required int ageYears,
  required ProfileSex sex,
  required double heightCm,
  required double weightKg,
}) {
  if (ageYears < 13 || ageYears > 19 || heightCm <= 0 || weightKg <= 0) {
    return null;
  }
  final heightM = heightCm / 100;
  return weightKg / (heightM * heightM);
}

TeenBmiStatus? teenBmiStatus({
  required int ageYears,
  required ProfileSex sex,
  required double heightCm,
  required double weightKg,
}) {
  final bmi = teenBmi(
    ageYears: ageYears,
    sex: sex,
    heightCm: heightCm,
    weightKg: weightKg,
  );
  final reference = teenBmiReference(ageYears, sex);
  if (bmi == null || reference == null) return null;
  if (bmi < reference.p5) return TeenBmiStatus.underweight;
  if (bmi < reference.p85) return TeenBmiStatus.healthy;
  if (bmi < reference.p95) return TeenBmiStatus.overweight;
  return TeenBmiStatus.obesity;
}
