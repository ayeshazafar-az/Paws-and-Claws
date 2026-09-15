import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../home/providers/animal_provider.dart';

class AIPetMatchmakerScreen extends ConsumerStatefulWidget {
  const AIPetMatchmakerScreen({super.key});

  @override
  ConsumerState<AIPetMatchmakerScreen> createState() =>
      _AIPetMatchmakerScreenState();
}

class _AIPetMatchmakerScreenState extends ConsumerState<AIPetMatchmakerScreen> {
  final _lifestyleController = TextEditingController();
  bool _isLoading = false;
  String? _aiResponse;

  void _findMatch() async {
    if (_lifestyleController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus(); // hide keyboard

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception(
          'Gemini API key not found. Please ensure GEMINI_API_KEY is in your .env file.',
        );
      }

      final animalsAsync = ref.read(allAnimalsProvider);
      final animals = animalsAsync.value ?? [];

      if (animals.isEmpty) {
        setState(() {
          _aiResponse =
              "There are no animals currently available for adoption right now!";
          _isLoading = false;
        });
        return;
      }

      // Filter to only available animals string format
      final animalData = animals
          .map((a) {
            return "ID: ${a.id}, Name: ${a.name}, Species: ${a.species}, Breed: ${a.breed ?? 'Unknown'}, Age: ${a.ageMonths} months, Description: ${a.description}";
          })
          .join("\n---\n");

      final prompt =
          """
You are 'Aura', an expert AI Pet Adoption Matchmaker for the Paws & Claws charity.
Use the following list of currently available rescue animals to find a match:
$animalData

The prospective adopter's lifestyle and living situation is described as:
${_lifestyleController.text}

Analyze the available rescues and select the absolute BEST single match for this adopter based on their lifestyle. 
Respond directly to the user in a warm, enthusiastic, and empathetic tone. 
Clearly state the name of the animal you are recommending and explain exactly why they are a perfect fit based on the user's description. Keep it concise (1-2 short paragraphs).
""";

      final model = GenerativeModel(model: 'gemini-3.6-flash', apiKey: apiKey);
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      setState(() {
        _aiResponse = response.text;
      });
    } catch (e) {
      setState(() {
        _aiResponse = "Error connecting to Artificial Intelligence: $e";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'AI Pet Matchmaker',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 60,
                      color: Colors.deepPurpleAccent.withOpacity(0.8),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Let Aura find your perfect match!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Describe your family, living situation, and activity level. Our Gemini AI will analyze all our current rescues to find your absolute best friend.',
                      style: TextStyle(color: Colors.grey[700], height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _lifestyleController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'e.g., I live in a quiet ground floor apartment. I work from home and love daily evening walks...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _isLoading ? null : _findMatch,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Consult AI Matchmaker',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),

                    if (_aiResponse != null && !_isLoading) ...[
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurpleAccent.withOpacity(0.1),
                              Colors.purpleAccent.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.deepPurpleAccent.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.psychology,
                                  color: Colors.deepPurple,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Aura AI Analysis',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32),
                            Text(
                              _aiResponse!,
                              style: TextStyle(
                                color: Colors.black87,
                                height: 1.6,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
