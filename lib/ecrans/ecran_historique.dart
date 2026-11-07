// lib/ecrans/ecran_historique.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/service_historique.dart';
import '../services/service_langue.dart';

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
        content: Text(ServiceLangue.texte("historique_effacer_question")),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(ServiceLangue.texte("annuler")),
          ),
          TextButton(
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

  String _formaterDate(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return "";
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} - ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: ServiceLangue.langueNotifier,
      builder: (context, langueActuelle, _) {
        final estSombre = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: estSombre ? Colors.white : Colors.black87,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              ServiceLangue.texte("historique_titre"),
              style: GoogleFonts.roboto(
                color: estSombre ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            actions: [
              if (_historique.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: estSombre ? Colors.white : Colors.black87,
                  ),
                  onPressed: _effacerTout,
                ),
            ],
          ),
          body: _chargement
              ? const Center(child: CircularProgressIndicator())
              : _historique.isEmpty
              ? Center(
                  child: Text(
                    ServiceLangue.texte("historique_vide"),
                    style: GoogleFonts.roboto(
                      color: estSombre ? Colors.white54 : Colors.black45,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: _historique.length,
                  separatorBuilder: (_, _) => Divider(
                    color: estSombre ? Colors.grey[800] : Colors.grey[200],
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final item = _historique[index];
                    return ListTile(
                      onTap: () =>
                          Navigator.pop(context, item["texte"]?.toString()),
                      trailing: Icon(
                        Icons.north_west,
                        size: 18,
                        color: estSombre ? Colors.white38 : Colors.black38,
                      ),
                      leading: Icon(
                        Icons.history,
                        color: estSombre ? Colors.white54 : Colors.black45,
                      ),
                      title: Text(
                        item["texte"]?.toString() ?? "",
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: estSombre ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        _formaterDate(item["date"]?.toString() ?? ""),
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: estSombre ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
