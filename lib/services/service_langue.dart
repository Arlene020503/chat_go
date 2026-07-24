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
      fr: "Paramètres", en: "Settings", de: "Einstellungen", es: "Ajustes", zh: "设置",
    },
    "parametres_historique": {
      fr: "Historique des recherches", en: "Search history", de: "Suchverlauf",
      es: "Historial de búsqueda", zh: "搜索历史",
    },
    "parametres_apparence": {
      fr: "Apparence", en: "Appearance", de: "Erscheinungsbild", es: "Apariencia", zh: "外观",
    },
    "parametres_langue": {
      fr: "Langue", en: "Language", de: "Sprache", es: "Idioma", zh: "语言",
    },
    "parametres_partager": {
      fr: "Partager l'application", en: "Share the app", de: "App teilen",
      es: "Compartir la aplicación", zh: "分享应用",
    },
    "parametres_noter": {
      fr: "Noter l'application", en: "Rate the app", de: "App bewerten",
      es: "Calificar la aplicación", zh: "评价应用",
    },
    "parametres_aide": {
      fr: "Aide", en: "Help", de: "Hilfe", es: "Ayuda", zh: "帮助",
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
      fr: "Clair", en: "Light", de: "Hell", es: "Claro", zh: "浅色",
    },
    "apparence_sombre": {
      fr: "Sombre", en: "Dark", de: "Dunkel", es: "Oscuro", zh: "深色",
    },
    "apparence_systeme": {
      fr: "Système", en: "System", de: "System", es: "Sistema", zh: "系统",
    },

    // --- Écran Chat ---
    "chat_titre": {
      fr: "Chat&Go AI", en: "Chat&Go AI", de: "Chat&Go AI", es: "Chat&Go AI", zh: "Chat&Go AI",
    },
    "chat_message_bienvenue": {
      fr: "Hello!\nJe suis votre assistant Chat&Go. Comment puis-je vous aider aujourd'hui ?",
      en: "Hello!\nI'm your Chat&Go assistant. How can I help you today?",
      de: "Hallo!\nIch bin dein Chat&Go-Assistent. Wie kann ich dir heute helfen?",
      es: "¡Hola!\nSoy tu asistente Chat&Go. ¿Cómo puedo ayudarte hoy?",
      zh: "你好！\n我是您的 Chat&Go 助手。今天我能帮您什么？",
    },
    "chat_placeholder": {
      fr: "Écrivez votre message...", en: "Write your message...",
      de: "Schreibe deine Nachricht...", es: "Escribe tu mensaje...", zh: "输入您的信息...",
    },
    "chat_suggestion_plombier": {
      fr: "🔍 Je recherche un plombier", en: "🔍 I'm looking for a plumber",
      de: "🔍 Ich suche einen Klempner", es: "🔍 Busco un fontanero", zh: "🔍 我在找水管工",
    },
    "chat_suggestion_massage": {
      fr: "💆 Où je peux faire un massage", en: "💆 Where can I get a massage",
      de: "💆 Wo kann ich eine Massage bekommen", es: "💆 Dónde puedo darme un masaje",
      zh: "💆 我在哪里可以按摩",
    },
    "chat_suggestion_restaurant": {
      fr: "🍔 Je veux manger dans un restaurant", en: "🍔 I want to eat at a restaurant",
      de: "🍔 Ich möchte in einem Restaurant essen", es: "🍔 Quiero comer en un restaurante",
      zh: "🍔 我想在餐厅吃饭",
    },

    // --- Écran Aide ---
    "aide_titre": {
      fr: "Aide", en: "Help", de: "Hilfe", es: "Ayuda", zh: "帮助",
    },
    "aide_contacter_support": {
      fr: "Contacter le support", en: "Contact support", de: "Support kontaktieren",
      es: "Contactar con soporte", zh: "联系客服",
    },

    // --- Écran Historique ---
    "historique_titre": {
      fr: "Historique des recherches", en: "Search history", de: "Suchverlauf",
      es: "Historial de búsqueda", zh: "搜索历史",
    },
    "historique_vide": {
      fr: "Aucune recherche pour l'instant", en: "No searches yet",
      de: "Noch keine Suchanfragen", es: "Aún no hay búsquedas", zh: "暂无搜索记录",
    },
  };

  /// Fonction principale : donne le texte traduit pour une clé, selon la langue active
  static String texte(String cle) {
    final code = langueNotifier.value;
    return _traductions[cle]?[code] ?? _traductions[cle]?[fr] ?? cle;
  }
}