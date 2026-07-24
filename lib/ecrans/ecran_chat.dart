import 'package:flutter/material.dart';
import 'ecran_parametres.dart';
import '../services/service_ia.dart';
import '../modeles/prestataire.dart';
import '../widgets/carte_prestataire.dart';
import '../services/service_historique.dart';
import '../services/service_langue.dart';

class EcranChat extends StatefulWidget {
  const EcranChat({super.key});

  @override
  State<EcranChat> createState() => _EcranChatState();
}

class _EcranChatState extends State<EcranChat> {
  // On garde une liste de messages "bruts" ; le tout premier message
  // (bienvenue) est marqué spécialement pour être retraduit dynamiquement
  final List<Map<String, dynamic>> _messages = [
    {
      'text': null, // null = message de bienvenue, traduit à l'affichage
      'isUser': false,
      'time': '',
      'prestataires': <Prestataire>[],
      'estBienvenue': true,
    }
  ];
  final TextEditingController _textController = TextEditingController();

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': text.trim(),
        'isUser': true,
        'time': _formatTime(DateTime.now()),
        'prestataires': <Prestataire>[],
        'estBienvenue': false,
      });
    });
    _textController.clear();

    // Sauvegarde dans l'historique
    await ServiceHistorique.ajouterRecherche(text.trim());

    final reponse = await ServiceIA.envoyerMessage(text.trim());

    setState(() {
      _messages.add({
        'text': reponse.message,
        'isUser': false,
        'time': _formatTime(DateTime.now()),
        'prestataires': reponse.prestataires,
        'estBienvenue': false,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final estSombre = Theme.of(context).brightness == Brightness.dark;

    // Tout l'écran se reconstruit dès que la langue change
    return ValueListenableBuilder<String>(
      valueListenable: ServiceLangue.langueNotifier,
      builder: (context, langueActuelle, _) {
        final suggestions = [
          ServiceLangue.texte("chat_suggestion_plombier"),
          ServiceLangue.texte("chat_suggestion_massage"),
          ServiceLangue.texte("chat_suggestion_restaurant"),
        ];

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.settings_outlined, color: estSombre ? Colors.white : Colors.black87),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EcranParametres()),
                );
              },
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ServiceLangue.texte("chat_titre"),
                  style: TextStyle(
                    color: estSombre ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.verified, color: Colors.green[estSombre ? 400 : 700], size: 18),
              ],
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(
                color: estSombre ? Colors.grey[850] : Colors.grey[200],
                height: 1.0,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isUser = msg['isUser'] as bool;
                    final estBienvenue = msg['estBienvenue'] as bool? ?? false;
                    final prestataires = msg['prestataires'] as List<Prestataire>? ?? [];

                    // Le texte affiché : traduit dynamiquement si c'est le message de bienvenue,
                    // sinon le texte tel quel (message utilisateur ou réponse déjà générée par l'IA)
                    final texteAffiche = estBienvenue
                        ? ServiceLangue.texte("chat_message_bienvenue")
                        : (msg['text'] as String? ?? '');

                    return Column(
                      crossAxisAlignment:
                          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? const Color(0xFF00A859)
                                  : (estSombre ? const Color(0xFF262D31) : Colors.grey[200]),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  texteAffiche,
                                  style: TextStyle(
                                    color: isUser
                                        ? Colors.white
                                        : (estSombre ? Colors.white70 : Colors.black87),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    msg['time'] as String? ?? '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isUser
                                          ? Colors.white70
                                          : (estSombre ? Colors.white38 : Colors.black54),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (prestataires.isNotEmpty)
                          SizedBox(
                            height: 320,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: prestataires.length,
                              padding: const EdgeInsets.only(left: 16, bottom: 8),
                              itemBuilder: (context, i) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: CartePrestataire(prestataire: prestataires[i]),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              if (_messages.length == 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: suggestions.map((suggestion) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            side: BorderSide(
                              color: estSombre ? Colors.grey[700]! : Colors.grey[300]!,
                            ),
                            shape:
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          // On retire l'emoji + l'espace du début avant d'envoyer le message
                          onPressed: () => _sendMessage(suggestion.substring(2).trim()),
                          child: Text(
                            suggestion,
                            style: TextStyle(
                              color: estSombre ? Colors.white70 : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0, top: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        style: TextStyle(color: estSombre ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: ServiceLangue.texte("chat_placeholder"),
                          hintStyle: TextStyle(
                            color: estSombre ? Colors.white38 : Colors.black38,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          filled: true,
                          fillColor: estSombre ? const Color(0xFF1E1E1E) : Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                              color: estSombre ? Colors.grey[700]! : Colors.grey[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                              color: estSombre ? Colors.grey[500]! : Colors.grey[400]!,
                            ),
                          ),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      backgroundColor: const Color(0xFF00A859),
                      radius: 24,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_upward, color: Colors.white),
                        onPressed: () => _sendMessage(_textController.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}