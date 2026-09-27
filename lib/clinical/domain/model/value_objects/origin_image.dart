/// Source of an image being evaluated.
enum ImageOrigin {
  camera('Camera'),
  gallery('Gallery');

  const ImageOrigin(this.label);

  final String label;
}
