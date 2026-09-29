/// Source of an image being evaluated.
enum ImageOrigin {
  camera('Cámara'),
  gallery('Galería');

  const ImageOrigin(this.label);

  final String label;
}
