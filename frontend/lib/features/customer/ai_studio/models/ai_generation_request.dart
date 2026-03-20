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
  String? generatedImageUrl;
  String? generatedImageBase64;
  final String? imageUrl;
  final String? imageBase64;

  AiGenerationRequest({
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
    this.generatedImageUrl,
    this.generatedImageBase64,
    this.imageUrl,
    this.imageBase64,
  });

  bool get isSketchMode => mode == 1;

  AiGenerationRequest copyWith({
    String? imageUrl,
    String? imageBase64,
  }) {
    return AiGenerationRequest(
      mode: mode,
      prompt: prompt,
      category: category,
      weight: weight,
      material: material,
      karat: karat,
      style: style,
      occasion: occasion,
      budget: budget,
      sketchPath: sketchPath,
      imageUrl: imageUrl ?? this.imageUrl,
      imageBase64: imageBase64 ?? this.imageBase64,
    );
  }
}