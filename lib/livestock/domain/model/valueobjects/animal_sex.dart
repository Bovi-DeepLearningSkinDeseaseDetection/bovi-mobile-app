/// Sex of a registered animal (HU15).
enum AnimalSex {
  female('Hembra'),
  male('Macho');

  const AnimalSex(this.label);

  final String label;
}
