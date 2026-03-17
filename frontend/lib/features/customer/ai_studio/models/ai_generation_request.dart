class AiGenerationRequest {
  final int mode; // 0 = Text to Image, 1 = Sketch to Image
  final String prompt;
  final String category;
  final String weight;
  final String material;
  final String karat;
  final String style;
  final String occasion;
  final String budget;
  final String? sketchPath;

  const AiGenerationRequest({
    required this.mode,
    required this.prompt,
    required this.category,
    required this.weight,
    required this.material,
    required this.karat,
    required this.style,
    required this.occasion,
    required this.budget,
    this.sketchPath,
  });

  bool get isSketchMode => mode == 1;
}