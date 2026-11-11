// lib/services/service_langue.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceLangue {
  static const String _cle = "langue_app";

  // Codes de langue supportés
  static const String fr = "fr";
  static const String en = "en";
  static const String de = "de";
  static const String es = "es";
  static const String zh = "zh";

  static final ValueNotifier<String> langueNotifier = ValueNotifier(fr);

  /// À appeler au démarrage de l'app pour recharger la langue sauvegardée
  static Future<void> chargerLangueSauvegardee() async {
    final prefs = await SharedPreferences.getInstance();
    langueNotifier.value = prefs.getString(_cle) ?? fr;
  }

  /// Change la langue active et la sauvegarde immédiatement
  static Future<void> changerLangue(String code) async {
    langueNotifier.value = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cle, code);
  }

  /// Nom lisible de chaque langue, dans SA PROPRE langue (convention habituelle)
  static String nomAffichage(String code) {
    switch (code) {
      case en:
        return "English";
      case de:
        return "Deutsch";
      case es:
        return "Español";
      case zh:
        return "中文";
      default:
        return "Français";
    }
  }

  /// Petit drapeau emoji pour chaque langue
  static String drapeau(String code) {
    switch (code) {
      case en:
        return "🇬🇧";
      case de:
        return "🇩🇪";
      case es:
        return "🇪🇸";
      case zh:
        return "🇨🇳";
      default:
        return "🇫🇷";
    }
  }

  /// Dictionnaire central de toutes les traductions de l'interface.
  /// Chaque clé (ex: "parametres_titre") a une traduction dans les 5 langues.
  static final Map<String, Map<String, String>> _traductions = {
    // --- Écran Paramètres ---
    "parametres_titre": {
      fr: "Paramètres",
      en: "Settings",
      de: "Einstellungen",
      es: "Ajustes",
      zh: "设置",
    },
    "parametres_historique": {
      fr: "Historique des recherches",
      en: "Search history",
      de: "Suchverlauf",
      es: "Historial de búsqueda",
      zh: "搜索历史",
    },
    "parametres_apparence": {
      fr: "Apparence",
      en: "Appearance",
      de: "Erscheinungsbild",
      es: "Apariencia",
      zh: "外观",
    },
    "parametres_langue": {
      fr: "Langue",
      en: "Language",
      de: "Sprache",
      es: "Idioma",
      zh: "语言",
    },
    "parametres_partager": {
      fr: "Partager l'application",
      en: "Share the app",
      de: "App teilen",
      es: "Compartir la aplicación",
      zh: "分享应用",
    },
    "parametres_noter": {
      fr: "Noter l'application",
      en: "Rate the app",
      de: "App bewerten",
      es: "Calificar la aplicación",
      zh: "评价应用",
    },
    "parametres_aide": {
      fr: "Aide",
      en: "Help",
      de: "Hilfe",
      es: "Ayuda",
      zh: "帮助",
    },
    "aide_question_1": {
      fr: "Comment fonctionne Chat&Go ?",
      en: "How does Chat&Go work?",
      de: "Wie funktioniert Chat&Go?",
      es: "¿Cómo funciona Chat&Go?",
      zh: "Chat&Go 如何运行？",
    },
    "aide_reponse_1": {
      fr: "Décris simplement ton besoin dans le chat (ex: \"je cherche un plombier\"), et notre assistant IA te propose les prestataires disponibles correspondants, avec leurs coordonnées.",
      en: "Just describe your need in the chat (e.g. \"I'm looking for a plumber\"), and our AI assistant will suggest matching providers with their contact details.",
      de: "Beschreibe einfach deinen Bedarf im Chat (z. B. \"ich suche einen Klempner\"), und unser KI-Assistent schlägt dir passende Anbieter mit Kontaktdaten vor.",
      es: "Describe simplemente tu necesidad en el chat (por ejemplo: \"busco un fontanero\"), y nuestro asistente IA te propondrá prestadores disponibles con sus datos de contacto.",
      zh: "只需在聊天中描述您的需求（例如：\"我在找一个水管工\"），我们的人工智能助手会为您推荐符合条件的服务提供商及其联系方式。",
    },
    "aide_question_2": {
      fr: "Comment contacter un prestataire ?",
      en: "How do I contact a provider?",
      de: "Wie kontaktiere ich einen Anbieter?",
      es: "¿Cómo contacto a un prestador?",
      zh: "我如何联系服务提供商？",
    },
    "aide_reponse_2": {
      fr: "Sur chaque carte prestataire proposée, deux boutons sont disponibles : \"Appeler\" pour lancer un appel direct, et \"WhatsApp\" pour ouvrir une conversation.",
      en: "On each provider card, two buttons are available: \"Call\" to start a direct call and \"WhatsApp\" to open a chat.",
      de: "Auf jeder Anbieterkarte stehen zwei Schaltflächen zur Verfügung: \"Anrufen\" für einen direkten Anruf und \"WhatsApp\" zum Öffnen eines Chats.",
      es: "En cada tarjeta de prestador encontrarás dos botones: \"Llamar\" para iniciar una llamada directa y \"WhatsApp\" para abrir una conversación.",
      zh: "在每个服务提供商卡片上有两个按钮：\"呼叫\"用于直接拨号，\"WhatsApp\"用于打开对话。",
    },
    "aide_question_3": {
      fr: "Les prestataires sont-ils vérifiés ?",
      en: "Are the providers verified?",
      de: "Sind die Anbieter verifiziert?",
      es: "¿Los prestadores están verificados?",
      zh: "提供者是否经过验证？",
    },
    "aide_reponse_3": {
      fr: "Chaque prestataire affiché provient de notre base de données. Les avis et notes affichés reflètent les retours des utilisateurs.",
      en: "Each provider shown comes from our database. Displayed ratings and reviews reflect user feedback.",
      de: "Jeder angezeigte Anbieter stammt aus unserer Datenbank. Angezeigte Bewertungen spiegeln das Feedback der Nutzer wider.",
      es: "Cada prestador mostrado proviene de nuestra base de datos. Las valoraciones reflejan el feedback de los usuarios.",
      zh: "显示的每个服务提供商都来自我们的数据库。所显示的评分和评论反映用户反馈。",
    },
    "aide_question_4": {
      fr: "L'application est-elle gratuite ?",
      en: "Is the app free?",
      de: "Ist die App kostenlos?",
      es: "¿La aplicación es gratuita?",
      zh: "该应用程序是免费的吗？",
    },
    "aide_reponse_4": {
      fr: "Oui, Chat&Go est entièrement gratuite à l'utilisation pour trouver des prestataires.",
      en: "Yes, Chat&Go is completely free to use for finding providers.",
      de: "Ja, Chat&Go ist vollständig kostenlos nutzbar, um Anbieter zu finden.",
      es: "Sí, Chat&Go es completamente gratuita para encontrar prestadores.",
      zh: "是的，Chat&Go 完全免费，可用于查找服务提供商。",
    },
    "aide_question_5": {
      fr: "Que faire si aucun prestataire ne correspond à ma demande ?",
      en: "What if no provider matches my request?",
      de: "Was ist, wenn kein Anbieter zu meiner Anfrage passt?",
      es: "¿Qué pasa si ningún prestador coincide con mi solicitud?",
      zh: "如果没有服务提供商符合我的请求怎么办？",
    },
    "aide_reponse_5": {
      fr: "L'assistant te le signalera et pourra te proposer une catégorie proche disponible dans notre base.",
      en: "The assistant will let you know and may suggest a nearby category available in our database.",
      de: "Der Assistent wird dich informieren und kann dir eine ähnliche Kategorie aus unserer Datenbank vorschlagen.",
      es: "El asistente te lo indicará y podrá proponerte una categoría cercana disponible en nuestra base.",
      zh: "助手会告知你，并可能推荐我们数据库中可用的相关类别。",
    },
    "apparence_clair": {
      fr: "Clair",
      en: "Light",
      de: "Hell",
      es: "Claro",
      zh: "浅色",
    },
    "apparence_sombre": {
      fr: "Sombre",
      en: "Dark",
      de: "Dunkel",
      es: "Oscuro",
      zh: "深色",
    },
    "apparence_systeme": {
      fr: "Système",
      en: "System",
      de: "System",
      es: "Sistema",
      zh: "系统",
    },

    // --- Écran Chat ---
    "chat_titre": {
      fr: "Chat&Go AI",
      en: "Chat&Go AI",
      de: "Chat&Go AI",
      es: "Chat&Go AI",
      zh: "Chat&Go AI",
    },
    "chat_message_bienvenue": {
      fr: "Hello!\nJe suis votre assistant Chat&Go. Comment puis-je vous aider aujourd'hui ?",
      en: "Hello!\nI'm your Chat&Go assistant. How can I help you today?",
      de: "Hallo!\nIch bin dein Chat&Go-Assistent. Wie kann ich dir heute helfen?",
      es: "¡Hola!\nSoy tu asistente Chat&Go. ¿Cómo puedo ayudarte hoy?",
      zh: "你好！\n我是您的 Chat&Go 助手。今天我能帮您什么？",
    },
    "chat_placeholder": {
      fr: "Écrivez votre message...",
      en: "Write your message...",
      de: "Schreibe deine Nachricht...",
      es: "Escribe tu mensaje...",
      zh: "输入您的信息...",
    },
    "chat_suggestion_plombier": {
      fr: "🔍 Je recherche un plombier",
      en: "🔍 I'm looking for a plumber",
      de: "🔍 Ich suche einen Klempner",
      es: "🔍 Busco un fontanero",
      zh: "🔍 我在找水管工",
    },
    "chat_suggestion_massage": {
      fr: "💆 Où je peux faire un massage",
      en: "💆 Where can I get a massage",
      de: "💆 Wo kann ich eine Massage bekommen",
      es: "💆 Dónde puedo darme un masaje",
      zh: "💆 我在哪里可以按摩",
    },
    "chat_suggestion_restaurant": {
      fr: "🍔 Je veux manger dans un restaurant",
      en: "🍔 I want to eat at a restaurant",
      de: "🍔 Ich möchte in einem Restaurant essen",
      es: "🍔 Quiero comer en un restaurante",
      zh: "🍔 我想在餐厅吃饭",
    },

    // --- Écran Aide ---
    "aide_titre": {fr: "Aide", en: "Help", de: "Hilfe", es: "Ayuda", zh: "帮助"},
    "aide_contacter_support": {
      fr: "Contacter le support",
      en: "Contact support",
      de: "Support kontaktieren",
      es: "Contactar con soporte",
      zh: "联系客服",
    },

    // --- Écran Historique ---
    "historique_titre": {
      fr: "Historique des recherches",
      en: "Search history",
      de: "Suchverlauf",
      es: "Historial de búsqueda",
      zh: "搜索历史",
    },
    "historique_vide": {
      fr: "Aucune recherche pour l'instant",
      en: "No searches yet",
      de: "Noch keine Suchanfragen",
      es: "Aún no hay búsquedas",
      zh: "暂无搜索记录",
    },
    "historique_effacer_question": {
      fr: "Effacer tout l'historique ?",
      en: "Clear all history?",
      de: "Gesamten Verlauf löschen?",
      es: "¿Borrar todo el historial?",
      zh: "清除所有历史记录？",
    },
    "historique_effacer": {
      fr: "Effacer",
      en: "Clear",
      de: "Löschen",
      es: "Borrar",
      zh: "清除",
    },
    "annuler": {
      fr: "Annuler",
      en: "Cancel",
      de: "Abbrechen",
      es: "Cancelar",
      zh: "取消",
    },

    // --- Réponses de l'assistant ---
    "ia_resultats": {
      fr: "Voici les prestataires disponibles près de chez vous.",
      en: "Here are the providers available near you.",
      de: "Hier sind die verfügbaren Anbieter in deiner Nähe.",
      es: "Estos son los prestadores disponibles cerca de ti.",
      zh: "以下是您附近可用的服务提供商。",
    },
    "ia_internet": {
      fr: "Je n'avais pas cette information, je l'ai recherchée sur Internet et sauvegardée pour vos prochaines recherches.",
      en: "I didn't have this information, so I searched the Internet and saved it for your next searches.",
      de: "Ich hatte diese Information nicht, also habe ich im Internet gesucht und sie für deine nächsten Suchen gespeichert.",
      es: "No tenía esta información, así que la busqué en Internet y la guardé para tus próximas búsquedas.",
      zh: "我没有这条信息，已在网上搜索并保存，方便您下次查找。",
    },
    "ia_aucun": {
      fr: "Je n'ai trouvé aucun prestataire. Essayez par exemple « plombier à Cocody », « restaurant », « coiffeur » ou « pharmacie », ou vérifiez votre connexion Internet.",
      en: "I couldn't find any provider. Try for example \"plumber in Cocody\", \"restaurant\", \"hairdresser\" or \"pharmacy\", or check your Internet connection.",
      de: "Ich habe keinen Anbieter gefunden. Versuche z. B. \"Klempner in Cocody\", \"Restaurant\", \"Friseur\" oder \"Apotheke\", oder prüfe deine Internetverbindung.",
      es: "No encontré ningún prestador. Prueba por ejemplo \"fontanero en Cocody\", \"restaurante\", \"peluquería\" o \"farmacia\", o revisa tu conexión a Internet.",
      zh: "没有找到服务提供商。请尝试“水管工”、“餐厅”、“理发”或“药店”，或检查您的网络连接。",
    },
    "ia_salutation": {
      fr: "Bonjour ! Dites-moi ce que vous cherchez : un plombier, un restaurant, un coiffeur, une pharmacie… et éventuellement la ville.",
      en: "Hello! Tell me what you're looking for: a plumber, a restaurant, a hairdresser, a pharmacy… and optionally the city.",
      de: "Hallo! Sag mir, was du suchst: einen Klempner, ein Restaurant, einen Friseur, eine Apotheke… und optional die Stadt.",
      es: "¡Hola! Dime qué buscas: un fontanero, un restaurante, una peluquería, una farmacia… y si quieres la ciudad.",
      zh: "你好！告诉我您在找什么：水管工、餐厅、理发店、药店……也可以说明城市。",
    },
    "ia_merci": {
      fr: "Avec plaisir ! N'hésitez pas si vous cherchez autre chose.",
      en: "You're welcome! Let me know if you need anything else.",
      de: "Gern geschehen! Sag Bescheid, wenn du noch etwas suchst.",
      es: "¡Con gusto! Avísame si buscas otra cosa.",
      zh: "不客气！如果还需要找别的，请告诉我。",
    },
    "ia_internet_sans_numero": {
      fr: "J'ai trouvé ces adresses sur Internet et je les ai sauvegardées, mais elles n'ont pas de numéro public. Utilisez le bouton Itinéraire pour vous y rendre.",
      en: "I found these places on the Internet and saved them, but they have no public phone number. Use the Directions button to get there.",
      de: "Ich habe diese Orte im Internet gefunden und gespeichert, aber sie haben keine öffentliche Nummer. Nutze den Routen-Button.",
      es: "Encontré estos lugares en Internet y los guardé, pero no tienen número público. Usa el botón Ruta para llegar.",
      zh: "我在网上找到了这些地点并已保存，但它们没有公开电话。请使用“路线”按钮前往。",
    },
    "ia_internet_numeros_en_cours": {
      fr: "Voici déjà des adresses trouvées sur Internet. Je continue de chercher leurs numéros en arrière-plan : refaites la même demande dans une minute pour les voir.",
      en: "Here are some places found on the Internet. I'm still looking for their phone numbers in the background: ask again in a minute to see them.",
      de: "Hier sind schon einige Orte aus dem Internet. Ich suche im Hintergrund weiter nach Nummern: frag in einer Minute noch einmal.",
      es: "Aquí tienes lugares encontrados en Internet. Sigo buscando sus números en segundo plano: vuelve a preguntar en un minuto.",
      zh: "这些是在网上找到的地点。我正在后台继续查找电话号码：一分钟后再问一次即可看到。",
    },
    "ia_description_internet": {
      fr: "Résultat trouvé sur Internet (OpenStreetMap).",
      en: "Result found on the Internet (OpenStreetMap).",
      de: "Im Internet gefundenes Ergebnis (OpenStreetMap).",
      es: "Resultado encontrado en Internet (OpenStreetMap).",
      zh: "来自互联网的结果（OpenStreetMap）。",
    },
    "chat_ecrit": {
      fr: "L'assistant recherche…",
      en: "The assistant is searching…",
      de: "Der Assistent sucht…",
      es: "El asistente está buscando…",
      zh: "助手正在搜索…",
    },

    // --- Carte prestataire ---
    "carte_appeler": {
      fr: "Appeler",
      en: "Call",
      de: "Anrufen",
      es: "Llamar",
      zh: "致电",
    },
    "carte_itineraire": {
      fr: "Itinéraire",
      en: "Directions",
      de: "Route",
      es: "Ruta",
      zh: "路线",
    },
    "carte_ouvert": {
      fr: "Ouvert maintenant",
      en: "Open now",
      de: "Jetzt geöffnet",
      es: "Abierto ahora",
      zh: "营业中",
    },
    "carte_ferme": {
      fr: "Fermé",
      en: "Closed",
      de: "Geschlossen",
      es: "Cerrado",
      zh: "已关闭",
    },
    "carte_horaires_inconnus": {
      fr: "Horaires non renseignés",
      en: "Opening hours unknown",
      de: "Öffnungszeiten unbekannt",
      es: "Horario no disponible",
      zh: "营业时间未知",
    },
    "carte_erreur_lien": {
      fr: "Impossible d'ouvrir ce lien sur cet appareil.",
      en: "Unable to open this link on this device.",
      de: "Dieser Link kann auf diesem Gerät nicht geöffnet werden.",
      es: "No se puede abrir este enlace en este dispositivo.",
      zh: "无法在此设备上打开此链接。",
    },

    // --- Splash et présentation ---
    "splash_chargement": {
      fr: "Chargement en cours...",
      en: "Loading...",
      de: "Wird geladen...",
      es: "Cargando...",
      zh: "加载中...",
    },
    "intro_passer": {
      fr: "Passer",
      en: "Skip",
      de: "Überspringen",
      es: "Omitir",
      zh: "跳过",
    },
    "intro_suivant": {
      fr: "Suivant",
      en: "Next",
      de: "Weiter",
      es: "Siguiente",
      zh: "下一步",
    },
    "intro_commencer": {
      fr: "Commencer",
      en: "Get started",
      de: "Loslegen",
      es: "Empezar",
      zh: "开始",
    },
    "intro_titre_1": {
      fr: "Trouvez rapidement le bon prestataire",
      en: "Quickly find the right provider",
      de: "Finde schnell den richtigen Anbieter",
      es: "Encuentra rápido al prestador adecuado",
      zh: "快速找到合适的服务提供商",
    },
    "intro_description_1": {
      fr: "Décrivez votre besoin et notre IA s'occupe du reste.",
      en: "Describe what you need and our AI takes care of the rest.",
      de: "Beschreibe deinen Bedarf und unsere KI erledigt den Rest.",
      es: "Describe lo que necesitas y nuestra IA se encarga del resto.",
      zh: "描述您的需求，其余的交给我们的人工智能。",
    },
    "intro_titre_2": {
      fr: "Contactez en 1 clic",
      en: "Get in touch in 1 tap",
      de: "Kontakt mit 1 Klick",
      es: "Contacta en 1 clic",
      zh: "一键联系",
    },
    "intro_description_2": {
      fr: "Appelez directement ou discutez sur WhatsApp avec le prestataire sélectionné.",
      en: "Call directly or chat on WhatsApp with the selected provider.",
      de: "Ruf direkt an oder schreibe per WhatsApp mit dem gewählten Anbieter.",
      es: "Llama directamente o chatea por WhatsApp con el prestador seleccionado.",
      zh: "直接致电或通过 WhatsApp 与所选服务提供商聊天。",
    },
  };

  /// Fonction principale : donne le texte traduit pour une clé, selon la langue active
  static String texte(String cle) {
    final code = langueNotifier.value;
    return _traductions[cle]?[code] ?? _traductions[cle]?[fr] ?? cle;
  }
}
