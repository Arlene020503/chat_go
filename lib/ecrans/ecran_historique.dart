// lib/ecrans/ecran_historique.dart
import 'package:flutter/material.dart';
import '../services/service_historique.dart';
import '../services/service_langue.dart';
import '../theme/theme_app.dart';

class EcranHistorique extends StatefulWidget {
  const EcranHistorique({super.key});

  @override
  State<EcranHistorique> createState() => _EcranHistoriqueState();
}

class _EcranHistoriqueState extends State<EcranHistorique> {
  List<Map<String, dynamic>> _historique = [];
  bool _chargement = true;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final data = await ServiceHistorique.obtenirHistorique();
    if (!mounted) return;
    setState(() {
      _historique = data;
      _chargement = false;
    });
  }

  Future<void> _effacerTout() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline, color: ThemeApp.vert),
        content: Text(
          ServiceLangue.texte("historique_effacer_question"),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(ServiceLangue.texte("annuler")),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(ServiceLangue.texte("historique_effacer")),
          ),
        ],
      ),
    );
    if (confirme != true) return;
    await ServiceHistorique.effacerHistorique();
    await _charger();
  }

  Future<void> _supprimer(int index) async {
    setState(() => _historique.removeAt(index));
    await ServiceHistorique.supprimerRecherche(index);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ServiceLangue.texte("historique_supprime"))),
    );
  }

  String _formaterDate(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return "";
    String deux(int v) => v.toString().padLeft(2, '0');
    return "${deux(date.day)}/${deux(date.month)}/${date.year} · ${deux(date.hour)}:${deux(date.minute)}";
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: ServiceLangue.langueNotifier,
      builder: (context, langueActuelle, _) {
        final secondaire = ThemeApp.texteSecondaire(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(ServiceLangue.texte("historique_titre")),
            actions: [
              if (_historique.isNotEmpty)
                IconButton(
                  tooltip: ServiceLangue.texte("historique_effacer"),
                  icon: const Icon(Icons.delete_sweep_outlined),
                  onPressed: _effacerTout,
                ),
            ],
          ),
          body: _chargement
              ? const Center(child: CircularProgressIndicator())
              : _historique.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: ThemeApp.vert.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.history,
                          size: 34,
                          color: ThemeApp.vert,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        ServiceLangue.texte("historique_vide"),
                        style: TextStyle(fontSize: 15, color: secondaire),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
                      child: Text(
                        ServiceLangue.texte("historique_aide"),
                        style: TextStyle(fontSize: 13, color: secondaire),
                      ),
                    ),
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (var i = 0; i < _historique.length; i++) ...[
                            if (i > 0) const Divider(indent: 56),
                            Dismissible(
                              key: ValueKey(
                                "${_historique[i]["date"]}-${_historique[i]["texte"]}",
                              ),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) => _supprimer(i),
                              background: Container(
                                color: Colors.red.withValues(alpha: 0.85),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                ),
                              ),
                              child: ListTile(
                                onTap: () => Navigator.pop(
                                  context,
                                  _historique[i]["texte"]?.toString(),
                                ),
                                leading: Icon(Icons.search, color: secondaire),
                                title: Text(
                                  _historique[i]["texte"]?.toString() ?? "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  _formaterDate(
                                    _historique[i]["date"]?.toString() ?? "",
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: secondaire,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.north_west,
                                  size: 18,
                                  color: secondaire,
                                ),
                              ),
                            ),
                          ],
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
