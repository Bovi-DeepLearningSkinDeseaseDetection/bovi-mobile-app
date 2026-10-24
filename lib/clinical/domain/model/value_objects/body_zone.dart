/// Body zone where the lesion was photographed (HU15).
enum BodyZone {
  head('Cabeza'),
  neck('Cuello'),
  back('Lomo'),
  flank('Flanco'),
  legs('Patas'),
  udder('Ubre'),
  other('Otra');

  const BodyZone(this.label);

  final String label;
}
