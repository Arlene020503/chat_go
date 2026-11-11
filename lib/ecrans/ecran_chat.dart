import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ecran_historique.dart';
import 'ecran_parametres.dart';
import 'ecran_presentation.dart';
import '../modeles/prestataire.dart';
import '../services/service_historique.dart';
import '../services/service_ia.dart';
import '../services/service_langue.dart';
import '../theme/theme_app.dart';
import '../widgets/avatar_marque.dart';
import '../widgets/carte_prestataire.dart';
import '../widgets/indicateur_frappe.dart';
import '../widgets/texte_riche.dart';

class _Message {
  final String texte;
  final bool utilisateur;
  final DateTime heure;
  final List<Prestataire> prestataires;
  final List<LienExterne> liens;
  final List<String> suggestions;

  _Message({
    required this.texte,
    required this.utilisateur,
    this.prestataires = const [],
    this.liens = const [],
    this.suggestions = const [],
  }) : heure = DateTime.now();
}

class EcranChat extends StatefulWidget {
  const EcranChat({super.key});

  @override
  State<EcranChat> createState() => _EcranChatState();
}

class _EcranChatState extends State<EcranChat> {
  final List<_Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _enAttente = false;

  // Catégories proposées sur l'écran d'accueil
  static const List<(String, IconData)> _categoriesAccueil = [
    ("Pharmacie", Icons.local_pharmacy_outlined),
    ("Restaurant", Icons.restaurant_outlined),
    ("Coiffure", Icons.content_cut),
    ("Beauté", Icons.face_retouching_natural),
    ("Plomberie", Icons.plumbing),
    ("Mécanique", Icons.car_repair),
    ("Hôtel", Icons.hotel_outlined),
    ("Chaussures", Icons.shopping_bag_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _textController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _defilerEnBas() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _ouvrir(Widget ecran) async {
    // Les paramètres et l'historique renvoient une recherche à relancer
    final recherche = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => ecran),
    );
    if (recherche != null && mounted) _envoyer(recherche);
  }

  /// Flèche retour : quitte la conversation, ou revient à la présentation
  void _retour() {
    if (_messages.isNotEmpty) {
      _nouvelleConversation();
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const EcranPresentation()),
    );
  }

  void _nouvelleConversation() {
    ServiceIA.reinitialiserConversation();
    setState(() => _messages.clear());
  }

  Future<void> _envoyer(String texte) async {
    final message = texte.trim();
    if (message.isEmpty || _enAttente) return;

    setState(() {
      _enAttente = true;
      _messages.add(_Message(texte: message, utilisateur: true));
    });
    _textController.clear();
    _defilerEnBas();

    await ServiceHistorique.ajouterRecherche(message);

    ReponseChat reponse;
    try {
      reponse = await ServiceIA.envoyerMessage(message);
    } catch (_) {
      reponse = ReponseChat(
        message: ServiceLangue.texte("ia_aucun"),
        prestataires: [],
      );
    }
    if (!mounted) return;

    setState(() {
      _enAttente = false;
      _messages.add(
        _Message(
          texte: reponse.message,
          utilisateur: false,
          prestataires: reponse.prestataires,
          liens: reponse.liens,
          suggestions: reponse.suggestions,
        ),
      );
    });
    _defilerEnBas();
  }

  @override
  Widget build(BuildContext context) {
    // Tout l'écran se reconstruit dès que la langue change
    return ValueListenableBuilder<String>(
      valueListenable: ServiceLangue.langueNotifier,
      builder: (context, langueActuelle, _) {
        // Retour Android pendant une conversation : on revient à l'accueil du chat
        return PopScope(
          canPop: _messages.isEmpty,
          onPopInvokedWithResult: (aQuitte, _) {
            if (!aQuitte && !_enAttente) _nouvelleConversation();
          },
          child: Scaffold(
            appBar: _construireEntete(context),
            body: Column(
              children: [
                Expanded(
                  child: _messages.isEmpty
                      ? _construireAccueil(context)
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          itemCount: _messages.length + (_enAttente ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _messages.length) {
                              return const _LigneAssistant(
                                child: IndicateurFrappe(),
                              );
                            }
                            final message = _messages[index];
                            final dernier =
                                index == _messages.length - 1 && !_enAttente;
                            return message.utilisateur
                                ? _BulleUtilisateur(message: message)
                                : _ReponseAssistant(
                                    message: message,
                                    afficherSuggestions: dernier,
                                    onSuggestion: _envoyer,
                                  );
                          },
                        ),
                ),
                _construireSaisie(context),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _construireEntete(BuildContext context) {
    final secondaire = ThemeApp.texteSecondaire(context);
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: _enAttente ? null : _retour,
      ),
      title: Row(
        children: [
          const AvatarMarque(taille: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ServiceLangue.texte("app_nom"),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _enAttente ? Colors.amber : ThemeApp.vertVif,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        ServiceLangue.texte(
                          _enAttente
                              ? "chat_statut_recherche"
                              : "chat_statut_en_ligne",
                        ),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: secondaire),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (_messages.isNotEmpty)
          IconButton(
            tooltip: ServiceLangue.texte("chat_nouvelle"),
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: _enAttente ? null : _nouvelleConversation,
          ),
        IconButton(
          tooltip: ServiceLangue.texte("historique_titre"),
          icon: const Icon(Icons.history),
          onPressed: () => _ouvrir(const EcranHistorique()),
        ),
        IconButton(
          tooltip: ServiceLangue.texte("parametres_titre"),
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => _ouvrir(const EcranParametres()),
        ),
        const SizedBox(width: 4),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(),
      ),
    );
  }

  Widget _construireAccueil(BuildContext context) {
    final secondaire = ThemeApp.texteSecondaire(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
      children: [
        const Center(child: AvatarMarque(taille: 72)),
        const SizedBox(height: 20),
        Text(
          ServiceLangue.texte("chat_accueil_titre"),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Text(
          ServiceLangue.texte("chat_accueil_texte"),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.5, height: 1.5, color: secondaire),
        ),
        const SizedBox(height: 28),
        Text(
          ServiceLangue.texte("chat_accueil_categories").toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
            color: secondaire,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.7,
          children: [
            for (final (nom, icone) in _categoriesAccueil)
              _TuileCategorie(
                icone: icone,
                libelle: ServiceLangue.texte("cat_$nom"),
                onTap: () => _envoyer(ServiceLangue.texte("cat_$nom")),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (final cle in [
              "suggestion_pharmacie",
              "suggestion_restaurant",
              "suggestion_chaussures",
            ])
              ActionChip(
                avatar: const Icon(
                  Icons.north_east,
                  size: 16,
                  color: ThemeApp.vert,
                ),
                label: Text(ServiceLangue.texte(cle)),
                onPressed: () => _envoyer(ServiceLangue.texte(cle)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _construireSaisie(BuildContext context) {
    final peutEnvoyer = _textController.text.trim().isNotEmpty && !_enAttente;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: ThemeApp.bordure(context))),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onSubmitted: _envoyer,
                decoration: InputDecoration(
                  hintText: ServiceLangue.texte("chat_placeholder"),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: peutEnvoyer ? ThemeApp.vert : ThemeApp.bordure(context),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_upward_rounded),
                color: Colors.white,
                onPressed: peutEnvoyer
                    ? () => _envoyer(_textController.text)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TuileCategorie extends StatelessWidget {
  final IconData icone;
  final String libelle;
  final VoidCallback onTap;
  const _TuileCategorie({
    required this.icone,
    required this.libelle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ThemeApp.surfaceDouce(context),
      borderRadius: BorderRadius.circular(ThemeApp.rayon),
      child: InkWell(
        borderRadius: BorderRadius.circular(ThemeApp.rayon),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: ThemeApp.vert.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icone, color: ThemeApp.vert, size: 21),
              ),
              const SizedBox(height: 8),
              Text(
                libelle,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _heure(DateTime t) =>
    "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";

void _copier(BuildContext context, String texte) {
  Clipboard.setData(ClipboardData(text: texte.replaceAll("**", "")));
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(ServiceLangue.texte("chat_copie"))));
}

class _BulleUtilisateur extends StatelessWidget {
  final _Message message;
  const _BulleUtilisateur({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10, left: 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onLongPress: () => _copier(context, message.texte),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: const BoxDecoration(
                color: ThemeApp.vert,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: Text(
                message.texte,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _heure(message.heure),
            style: TextStyle(
              fontSize: 11,
              color: ThemeApp.texteSecondaire(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar de l'assistant + contenu aligné à sa droite
class _LigneAssistant extends StatelessWidget {
  final Widget child;
  const _LigneAssistant({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AvatarMarque(taille: 30),
          const SizedBox(width: 8),
          Flexible(child: child),
        ],
      ),
    );
  }
}

class _ReponseAssistant extends StatelessWidget {
  final _Message message;
  final bool afficherSuggestions;
  final ValueChanged<String> onSuggestion;
  const _ReponseAssistant({
    required this.message,
    required this.afficherSuggestions,
    required this.onSuggestion,
  });

  void _voirTout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (context, controleur) => ListView.separated(
          controller: controleur,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: message.prestataires.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) =>
              CartePrestataire(prestataire: message.prestataires[i]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final secondaire = ThemeApp.texteSecondaire(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LigneAssistant(
          child: Padding(
            padding: const EdgeInsets.only(right: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: () => _copier(context, message.texte),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeApp.surfaceDouce(context),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: TexteRiche(
                      message.texte,
                      style: const TextStyle(fontSize: 15, height: 1.45),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _heure(message.heure),
                  style: TextStyle(fontSize: 11, color: secondaire),
                ),
              ],
            ),
          ),
        ),
        if (message.prestataires.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(38, 4, 0, 6),
            child: Row(
              children: [
                Text(
                  "${ServiceLangue.texte("chat_resultats")} · ${message.prestataires.length}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _voirTout(context),
                  child: Text(ServiceLangue.texte("chat_voir_tout")),
                ),
              ],
            ),
          ),
          SizedBox(
            height: CartePrestataire.hauteurCompacte,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 38, bottom: 4),
              itemCount: message.prestataires.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) => CartePrestataire(
                prestataire: message.prestataires[i],
                compacte: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (message.liens.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(38, 4, 0, 8),
            child: Column(
              children: [
                for (final lien in message.liens) _TuileLien(lien: lien),
              ],
            ),
          ),
        if (afficherSuggestions && message.suggestions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(38, 2, 0, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final suggestion in message.suggestions)
                  ActionChip(
                    label: Text(suggestion),
                    onPressed: () => onSuggestion(suggestion),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TuileLien extends StatelessWidget {
  final LienExterne lien;
  const _TuileLien({required this.lien});

  Future<void> _ouvrir(BuildContext context) async {
    final messager = ScaffoldMessenger.of(context);
    var ouvert = false;
    try {
      ouvert = await launchUrl(
        Uri.parse(lien.url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
    if (!ouvert) {
      messager.showSnackBar(
        SnackBar(content: Text(ServiceLangue.texte("carte_erreur_lien"))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = lien.type == "article";
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: () => _ouvrir(context),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ThemeApp.vert.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              article ? Icons.menu_book_outlined : Icons.storefront_outlined,
              color: ThemeApp.vert,
              size: 21,
            ),
          ),
          title: Text(
            lien.titre,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          subtitle: Text(
            lien.sousTitre,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              color: ThemeApp.texteSecondaire(context),
            ),
          ),
          trailing: Icon(
            Icons.open_in_new,
            size: 18,
            color: ThemeApp.texteSecondaire(context),
          ),
        ),
      ),
    );
  }
}
