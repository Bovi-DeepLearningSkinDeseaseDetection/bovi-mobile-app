/// Origen de la imagen evaluada

enum OrigenImagen {
  camara('Camara'),
  galeria('Galería');

  const OrigenImagen(this.etiqueta);
  final String etiqueta;
}