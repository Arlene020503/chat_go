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
      fr: "Comment fonctionne Mes Prestataires ?",
      en: "How does Mes Prestataires work?",
      de: "Wie funktioniert Mes Prestataires?",
      es: "¿Cómo funciona Mes Prestataires?",
      zh: "Mes Prestataires 如何运作？",
    },
    "aide_reponse_1": {
      fr: "Décrivez simplement votre besoin dans le chat (ex. « je cherche un plombier à Cocody »). L'assistant cherche de vrais établissements sur OpenStreetMap, vous les présente avec leurs coordonnées, et les enregistre pour que la prochaine recherche soit instantanée.",
      en: "Just describe your need in the chat (e.g. “I'm looking for a plumber in Cocody”). The assistant searches real places on OpenStreetMap, shows them with their contact details, and saves them so your next search is instant.",
      de: "Beschreibe einfach deinen Bedarf im Chat (z. B. „Klempner in Cocody“). Der Assistent sucht echte Orte auf OpenStreetMap, zeigt sie mit Kontaktdaten und speichert sie für die nächste Suche.",
      es: "Describe tu necesidad en el chat (p. ej. «busco un fontanero en Cocody»). El asistente busca lugares reales en OpenStreetMap, te los muestra con sus datos y los guarda para la próxima búsqueda.",
      zh: "只需在聊天中描述需求（例如“Cocody 的水管工”）。助手会在 OpenStreetMap 上查找真实地点，显示联系方式，并保存以便下次立即回复。",
    },
    "aide_question_2": {
      fr: "Comment contacter un prestataire ?",
      en: "How do I contact a provider?",
      de: "Wie kontaktiere ich einen Anbieter?",
      es: "¿Cómo contacto a un prestador?",
      zh: "我如何联系服务提供商？",
    },
    "aide_reponse_2": {
      fr: "Chaque fiche propose « Appeler », « WhatsApp » (pour les numéros mobiles), « Itinéraire » vers l'adresse et, quand il existe, le site web ou la page Facebook de l'établissement.",
      en: "Each card offers “Call”, “WhatsApp” (for mobile numbers), “Directions” and, when available, the website or Facebook page.",
      de: "Jede Karte bietet „Anrufen“, „WhatsApp“ (für Mobilnummern), „Route“ und, falls vorhanden, die Webseite oder Facebook-Seite.",
      es: "Cada ficha ofrece «Llamar», «WhatsApp» (para móviles), «Ruta» y, si existe, el sitio web o la página de Facebook.",
      zh: "每张卡片提供“致电”、“WhatsApp”（手机号码）、“路线”，以及网站或 Facebook 页面（如有）。",
    },
    "aide_question_3": {
      fr: "D'où viennent les informations ?",
      en: "Where does the information come from?",
      de: "Woher stammen die Informationen?",
      es: "¿De dónde viene la información?",
      zh: "信息来自哪里？",
    },
    "aide_reponse_3": {
      fr: "Des données publiques et réelles d'OpenStreetMap pour les établissements, de Jumia et CoinAfrique pour les achats en ligne, et de Wikipédia pour les questions générales. Rien n'est inventé : si une information n'existe pas, l'assistant vous le dit.",
      en: "From real public OpenStreetMap data for places, Jumia and CoinAfrique for online shopping, and Wikipedia for general questions. Nothing is made up: if information doesn't exist, the assistant tells you.",
      de: "Aus echten öffentlichen OpenStreetMap-Daten, Jumia und CoinAfrique für Online-Käufe und Wikipedia für allgemeine Fragen. Nichts ist erfunden.",
      es: "De datos públicos reales de OpenStreetMap, de Jumia y CoinAfrique para compras en línea y de Wikipedia para preguntas generales. Nada es inventado.",
      zh: "来自 OpenStreetMap 的真实公开数据、Jumia 和 CoinAfrique 的网购信息以及维基百科。绝不编造信息。",
    },
    "aide_question_4": {
      fr: "L'application est-elle gratuite ?",
      en: "Is the app free?",
      de: "Ist die App kostenlos?",
      es: "¿La aplicación es gratuita?",
      zh: "该应用程序是免费的吗？",
    },
    "aide_reponse_4": {
      fr: "Oui, Mes Prestataires est entièrement gratuite à l'utilisation pour trouver des prestataires.",
      en: "Yes, Mes Prestataires is completely free to use for finding providers.",
      de: "Ja, Mes Prestataires ist vollständig kostenlos nutzbar, um Anbieter zu finden.",
      es: "Sí, Mes Prestataires es completamente gratuita para encontrar prestadores.",
      zh: "是的，Mes Prestataires 完全免费，可用于查找服务提供商。",
    },
    "aide_question_5": {
      fr: "Que faire si aucun prestataire ne correspond à ma demande ?",
      en: "What if no provider matches my request?",
      de: "Was ist, wenn kein Anbieter zu meiner Anfrage passt?",
      es: "¿Qué pasa si ningún prestador coincide con mi solicitud?",
      zh: "如果没有服务提供商符合我的请求怎么办？",
    },
    "aide_reponse_5": {
      fr: "L'assistant vous le dit franchement et vous propose un quartier voisin, une boutique en ligne ou une autre formulation.",
      en: "The assistant tells you honestly and suggests a nearby area, an online shop or another wording.",
      de: "Der Assistent sagt es dir ehrlich und schlägt ein Nachbarviertel, einen Online-Shop oder eine andere Formulierung vor.",
      es: "El asistente te lo dice con franqueza y te propone un barrio cercano, una tienda en línea u otra formulación.",
      zh: "助手会如实告知，并建议附近区域、网上商店或其他说法。",
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
      fr: "Mes Prestataires",
      en: "Mes Prestataires",
      de: "Mes Prestataires",
      es: "Mes Prestataires",
      zh: "Mes Prestataires",
    },
    "chat_message_bienvenue": {
      fr: "Bonjour ! Je suis votre assistant Mes Prestataires. Comment puis-je vous aider aujourd'hui ?",
      en: "Hello! I'm your Mes Prestataires assistant. How can I help you today?",
      de: "Hallo! Ich bin dein Mes-Prestataires-Assistent. Wie kann ich dir heute helfen?",
      es: "¡Hola! Soy tu asistente Mes Prestataires. ¿Cómo puedo ayudarte hoy?",
      zh: "你好！我是 Mes Prestataires 助手。今天我能帮您什么？",
    },
    "chat_placeholder": {
      fr: "Écrivez votre message…",
      en: "Write your message…",
      de: "Schreibe deine Nachricht…",
      es: "Escribe tu mensaje…",
      zh: "输入您的信息…",
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
    "ia_aucun": {
      fr: "Je n'ai rien trouvé de fiable pour cette demande. Reformulez avec un métier ou un produit (« plombier à Cocody », « acheter des chaussures »…), ou vérifiez votre connexion Internet.",
      en: "I couldn't find anything reliable for this request. Try a trade or a product (“plumber in Cocody”, “buy shoes”…), or check your Internet connection.",
      de: "Ich habe nichts Verlässliches gefunden. Versuche einen Beruf oder ein Produkt („Klempner in Cocody“, „Schuhe kaufen“…) oder prüfe deine Verbindung.",
      es: "No encontré nada fiable. Prueba con un oficio o un producto («fontanero en Cocody», «comprar zapatos»…) o revisa tu conexión.",
      zh: "没有找到可靠的结果。请尝试职业或商品（“Cocody 的水管工”“买鞋”……），或检查网络连接。",
    },
    "ia_salutation": {
      fr: "Bonjour 👋 Ravi de vous aider ! Dites-moi ce que vous cherchez — un plombier, une pharmacie, un restaurant, des chaussures… — et si vous voulez, le quartier (Cocody, Yopougon…).",
      en: "Hello 👋 Happy to help! Tell me what you're looking for — a plumber, a pharmacy, a restaurant, shoes… — and the area if you like (Cocody, Yopougon…).",
      de: "Hallo 👋 Gern helfe ich dir! Sag mir, was du suchst — einen Klempner, eine Apotheke, ein Restaurant, Schuhe… — und gern das Viertel (Cocody, Yopougon…).",
      es: "¡Hola 👋! Encantado de ayudarte. Dime qué buscas — un fontanero, una farmacia, un restaurante, zapatos… — y si quieres el barrio (Cocody, Yopougon…).",
      zh: "你好 👋 很高兴为您服务！告诉我您在找什么——水管工、药店、餐厅、鞋子……也可以说明区域（Cocody、Yopougon……）。",
    },
    "ia_merci": {
      fr: "Avec plaisir ! N'hésitez pas si vous cherchez autre chose.",
      en: "You're welcome! Let me know if you need anything else.",
      de: "Gern geschehen! Sag Bescheid, wenn du noch etwas suchst.",
      es: "¡Con gusto! Avísame si buscas otra cosa.",
      zh: "不客气！如果还需要找别的，请告诉我。",
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
    "carte_erreur_lien": {
      fr: "Impossible d'ouvrir ce lien sur cet appareil.",
      en: "Unable to open this link on this device.",
      de: "Dieser Link kann auf diesem Gerät nicht geöffnet werden.",
      es: "No se puede abrir este enlace en este dispositivo.",
      zh: "无法在此设备上打开此链接。",
    },

    // --- Splash et présentation ---
    "splash_chargement": {
      fr: "Chargement…",
      en: "Loading…",
      de: "Wird geladen…",
      es: "Cargando…",
      zh: "加载中…",
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
    "app_nom": {
      fr: "Mes Prestataires",
      en: "Mes Prestataires",
      de: "Mes Prestataires",
      es: "Mes Prestataires",
      zh: "Mes Prestataires",
    },
    "chat_statut_en_ligne": {
      fr: "Assistant en ligne",
      en: "Assistant online",
      de: "Assistent online",
      es: "Asistente en línea",
      zh: "助手在线",
    },
    "chat_statut_recherche": {
      fr: "Recherche en cours…",
      en: "Searching…",
      de: "Suche läuft…",
      es: "Buscando…",
      zh: "正在搜索…",
    },
    "chat_accueil_titre": {
      fr: "Que recherchez-vous aujourd'hui ?",
      en: "What are you looking for today?",
      de: "Was suchst du heute?",
      es: "¿Qué buscas hoy?",
      zh: "您今天在找什么？",
    },
    "chat_accueil_texte": {
      fr: "Décrivez votre besoin comme à un ami : je trouve les vrais prestataires et boutiques près de chez vous, avec leurs numéros quand ils existent.",
      en: "Describe what you need as you would to a friend: I find real providers and shops near you, with their phone numbers when available.",
      de: "Beschreibe deinen Bedarf wie einem Freund: Ich finde echte Anbieter und Geschäfte in deiner Nähe, mit Nummer, wenn vorhanden.",
      es: "Describe lo que necesitas como a un amigo: encuentro prestadores y tiendas reales cerca de ti, con su número cuando existe.",
      zh: "像对朋友一样描述您的需求：我会为您找到附近真实的服务商和商店，并尽可能提供电话号码。",
    },
    "chat_accueil_categories": {
      fr: "Catégories populaires",
      en: "Popular categories",
      de: "Beliebte Kategorien",
      es: "Categorías populares",
      zh: "热门类别",
    },
    "chat_nouvelle": {
      fr: "Nouvelle conversation",
      en: "New conversation",
      de: "Neues Gespräch",
      es: "Nueva conversación",
      zh: "新对话",
    },
    "chat_copie": {
      fr: "Message copié",
      en: "Message copied",
      de: "Nachricht kopiert",
      es: "Mensaje copiado",
      zh: "已复制消息",
    },
    "chat_resultats": {
      fr: "Résultats",
      en: "Results",
      de: "Ergebnisse",
      es: "Resultados",
      zh: "结果",
    },
    "chat_voir_tout": {
      fr: "Voir tout",
      en: "See all",
      de: "Alle ansehen",
      es: "Ver todo",
      zh: "查看全部",
    },
    "chat_liens": {
      fr: "À consulter en ligne",
      en: "Check online",
      de: "Online ansehen",
      es: "Ver en línea",
      zh: "在线查看",
    },
    "ia_salutation_soir": {
      fr: "Bonsoir 👋 Que puis-je trouver pour vous ce soir ? Un restaurant, une pharmacie, un hôtel… dites-le-moi simplement.",
      en: "Good evening 👋 What can I find for you tonight? A restaurant, a pharmacy, a hotel… just tell me.",
      de: "Guten Abend 👋 Was kann ich heute Abend für dich finden? Ein Restaurant, eine Apotheke, ein Hotel… sag es einfach.",
      es: "Buenas noches 👋 ¿Qué puedo encontrar para ti esta noche? Un restaurante, una farmacia, un hotel… dímelo.",
      zh: "晚上好 👋 今晚需要我帮您找什么？餐厅、药店、酒店……直接告诉我吧。",
    },
    "ia_presentation": {
      fr: "Je suis l'assistant de Mes Prestataires. Je trouve pour vous de vrais prestataires (plombiers, coiffeurs, mécaniciens, pharmacies…) et de vraies boutiques, à partir des données publiques d'OpenStreetMap, avec leurs numéros et WhatsApp quand ils existent. Je peux aussi vous orienter vers les boutiques en ligne ivoiriennes et répondre à vos questions générales grâce à Wikipédia.",
      en: "I'm the Mes Prestataires assistant. I find real providers (plumbers, hairdressers, mechanics, pharmacies…) and real shops from OpenStreetMap public data, with phone and WhatsApp when available. I can also point you to Ivorian online shops and answer general questions using Wikipedia.",
      de: "Ich bin der Assistent von Mes Prestataires. Ich finde echte Anbieter (Klempner, Friseure, Mechaniker, Apotheken…) und echte Geschäfte aus öffentlichen OpenStreetMap-Daten, mit Telefon und WhatsApp, wenn vorhanden. Ich verweise auch auf ivorische Online-Shops und beantworte allgemeine Fragen mit Wikipedia.",
      es: "Soy el asistente de Mes Prestataires. Encuentro prestadores reales (fontaneros, peluqueros, mecánicos, farmacias…) y tiendas reales a partir de los datos públicos de OpenStreetMap, con teléfono y WhatsApp cuando existen. También te oriento a tiendas en línea marfileñas y respondo preguntas generales con Wikipedia.",
      zh: "我是 Mes Prestataires 助手。我根据 OpenStreetMap 公开数据为您查找真实的服务商（水管工、理发师、修车、药店……）和真实商店，并在有时提供电话和 WhatsApp。我还可以推荐科特迪瓦的网上商店，并借助维基百科回答一般问题。",
    },
    "ia_ca_va": {
      fr: "Très bien, merci 😊 Et vous ? Dites-moi ce dont vous avez besoin, je m'en occupe.",
      en: "Very well, thank you 😊 And you? Tell me what you need, I'll take care of it.",
      de: "Sehr gut, danke 😊 Und dir? Sag mir, was du brauchst.",
      es: "Muy bien, gracias 😊 ¿Y tú? Dime qué necesitas.",
      zh: "很好，谢谢 😊 您呢？告诉我您需要什么。",
    },
    "ia_trouve": {
      fr: "J'ai trouvé **{n} résultat(s)** pour « {cat} » à **{ville}**.",
      en: "I found **{n} result(s)** for “{cat}” in **{ville}**.",
      de: "Ich habe **{n} Ergebnis(se)** für „{cat}“ in **{ville}** gefunden.",
      es: "Encontré **{n} resultado(s)** para «{cat}» en **{ville}**.",
      zh: "在 **{ville}** 为“{cat}”找到 **{n} 个结果**。",
    },
    "ia_joignables": {
      fr: "📞 Joignables par téléphone ou WhatsApp : **{tel}**. Je les ai placés en premier.",
      en: "📞 Reachable by phone or WhatsApp: **{tel}**. I've put them first.",
      de: "📞 Per Telefon oder WhatsApp erreichbar: **{tel}**. Ich habe sie nach vorne gestellt.",
      es: "📞 Contactables por teléfono o WhatsApp: **{tel}**. Los puse primero.",
      zh: "📞 其中 {tel} 个可通过电话或 WhatsApp 联系，已排在最前面。",
    },
    "ia_sans_numero": {
      fr: "Aucun n'a de numéro public pour l'instant, mais le bouton Itinéraire vous y emmène directement.",
      en: "None has a public phone number yet, but the Directions button takes you straight there.",
      de: "Noch keiner hat eine öffentliche Nummer, aber der Routen-Button bringt dich direkt hin.",
      es: "Ninguno tiene número público por ahora, pero el botón Ruta te lleva directamente.",
      zh: "目前都没有公开电话，但“路线”按钮可直接带您前往。",
    },
    "ia_numeros_en_cours": {
      fr: "⏳ Je vérifie encore en arrière-plan s'ils ont un numéro public. Refaites la même demande dans une minute : s'il en existe, ils apparaîtront.",
      en: "⏳ I'm still checking in the background whether they have a public number. Ask again in a minute: if any exist, they'll appear.",
      de: "⏳ Ich prüfe im Hintergrund, ob sie eine öffentliche Nummer haben. Frag in einer Minute noch einmal: Falls vorhanden, erscheinen sie.",
      es: "⏳ Sigo comprobando en segundo plano si tienen un número público. Vuelve a preguntar en un minuto: si existe, aparecerá.",
      zh: "⏳ 我正在后台核实是否有公开电话。一分钟后再问一次：如有，将会显示。",
    },
    "ia_sauvegarde": {
      fr: "Ces résultats sont enregistrés sur votre téléphone.",
      en: "These results are saved on your phone.",
      de: "Diese Ergebnisse sind auf deinem Handy gespeichert.",
      es: "Estos resultados quedan guardados en tu teléfono.",
      zh: "这些结果已保存在您的手机上。",
    },
    "ia_aussi_en_ligne": {
      fr: "🛒 Vous pouvez aussi commander en ligne via les boutiques ci-dessous.",
      en: "🛒 You can also order online from the shops below.",
      de: "🛒 Du kannst auch online in den Shops unten bestellen.",
      es: "🛒 También puedes pedir en línea en las tiendas de abajo.",
      zh: "🛒 您也可以通过下方的网上商店在线订购。",
    },
    "ia_boutiques_en_ligne": {
      fr: "🛒 Pour « {terme} », voici les vraies boutiques en ligne de Côte d'Ivoire où chercher et comparer les prix :",
      en: "🛒 For “{terme}”, here are real Ivorian online shops where you can search and compare prices:",
      de: "🛒 Für „{terme}“ findest du hier echte ivorische Online-Shops zum Suchen und Preisvergleich:",
      es: "🛒 Para «{terme}», aquí tienes tiendas en línea reales de Costa de Marfil para buscar y comparar precios:",
      zh: "🛒 关于“{terme}”，以下是科特迪瓦真实的网上商店，可搜索并比较价格：",
    },
    "ia_rien_categorie": {
      fr: "Je n'ai trouvé aucun établissement « {cat} » répertorié à {ville}. Essayez un quartier voisin :",
      en: "I couldn't find any “{cat}” listed in {ville}. Try a nearby area:",
      de: "Ich habe in {ville} kein „{cat}“ gefunden. Versuche ein Nachbarviertel:",
      es: "No encontré ningún «{cat}» en {ville}. Prueba un barrio cercano:",
      zh: "在 {ville} 没有找到“{cat}”。试试附近区域：",
    },
    "ia_page_suivante": {
      fr: "Voici {n} résultat(s) de plus 👇",
      en: "Here are {n} more result(s) 👇",
      de: "Hier sind {n} weitere Ergebnis(se) 👇",
      es: "Aquí tienes {n} resultado(s) más 👇",
      zh: "这里还有 {n} 个结果 👇",
    },
    "ia_fin_resultats": {
      fr: "C'est tout pour cette recherche. Voulez-vous essayer un autre quartier ?",
      en: "That's all for this search. Want to try another area?",
      de: "Das war alles. Möchtest du ein anderes Viertel versuchen?",
      es: "Eso es todo. ¿Quieres probar otro barrio?",
      zh: "这次搜索就这些。要试试其他区域吗？",
    },
    "suggestion_pharmacie": {
      fr: "Pharmacie à Cocody",
      en: "Pharmacy in Cocody",
      de: "Apotheke in Cocody",
      es: "Farmacia en Cocody",
      zh: "Cocody 药店",
    },
    "suggestion_restaurant": {
      fr: "Un bon restaurant",
      en: "A good restaurant",
      de: "Ein gutes Restaurant",
      es: "Un buen restaurante",
      zh: "好餐厅",
    },
    "suggestion_chaussures": {
      fr: "Acheter des chaussures",
      en: "Buy shoes",
      de: "Schuhe kaufen",
      es: "Comprar zapatos",
      zh: "买鞋",
    },
    "suggestion_plus": {
      fr: "Plus de résultats",
      en: "More results",
      de: "Mehr Ergebnisse",
      es: "Más resultados",
      zh: "更多结果",
    },
    "suggestion_ville": {
      fr: "À {ville}",
      en: "In {ville}",
      de: "In {ville}",
      es: "En {ville}",
      zh: "在 {ville}",
    },
    "lien_jumia": {
      fr: "Rechercher « {terme} » sur Jumia",
      en: "Search “{terme}” on Jumia",
      de: "„{terme}“ auf Jumia suchen",
      es: "Buscar «{terme}» en Jumia",
      zh: "在 Jumia 搜索“{terme}”",
    },
    "lien_coinafrique": {
      fr: "Annonces « {terme} » sur CoinAfrique",
      en: "“{terme}” listings on CoinAfrique",
      de: "„{terme}“-Anzeigen auf CoinAfrique",
      es: "Anuncios «{terme}» en CoinAfrique",
      zh: "CoinAfrique 上的“{terme}”信息",
    },
    "lien_article": {
      fr: "Lire l'article « {titre} »",
      en: "Read the article “{titre}”",
      de: "Artikel „{titre}“ lesen",
      es: "Leer el artículo «{titre}»",
      zh: "阅读文章“{titre}”",
    },
    "cat_Plomberie": {
      fr: "Plombier",
      en: "Plumber",
      de: "Klempner",
      es: "Fontanero",
      zh: "水管工",
    },
    "cat_Massage": {
      fr: "Massage",
      en: "Massage",
      de: "Massage",
      es: "Masaje",
      zh: "按摩",
    },
    "cat_Beauté": {
      fr: "Beauté",
      en: "Beauty",
      de: "Beauty",
      es: "Belleza",
      zh: "美容",
    },
    "cat_Restaurant": {
      fr: "Restaurant",
      en: "Restaurant",
      de: "Restaurant",
      es: "Restaurante",
      zh: "餐厅",
    },
    "cat_Coiffure": {
      fr: "Coiffure",
      en: "Hairdresser",
      de: "Friseur",
      es: "Peluquería",
      zh: "理发",
    },
    "cat_Électricité": {
      fr: "Électricien",
      en: "Electrician",
      de: "Elektriker",
      es: "Electricista",
      zh: "电工",
    },
    "cat_Mécanique": {
      fr: "Garage",
      en: "Mechanic",
      de: "Werkstatt",
      es: "Mecánico",
      zh: "修车",
    },
    "cat_Pharmacie": {
      fr: "Pharmacie",
      en: "Pharmacy",
      de: "Apotheke",
      es: "Farmacia",
      zh: "药店",
    },
    "cat_Santé": {
      fr: "Clinique",
      en: "Clinic",
      de: "Krankenhaus",
      es: "Médico",
      zh: "医院",
    },
    "cat_Couture": {
      fr: "Couture",
      en: "Tailor",
      de: "Schneider",
      es: "Sastre",
      zh: "裁缝",
    },
    "cat_Hôtel": {fr: "Hôtel", en: "Hotel", de: "Hotel", es: "Hotel", zh: "酒店"},
    "cat_Sport": {
      fr: "Salle de sport",
      en: "Gym",
      de: "Fitness",
      es: "Gimnasio",
      zh: "健身",
    },
    "cat_Banque": {fr: "Banque", en: "Bank", de: "Bank", es: "Banco", zh: "银行"},
    "cat_Boulangerie": {
      fr: "Boulangerie",
      en: "Bakery",
      de: "Bäckerei",
      es: "Panadería",
      zh: "面包",
    },
    "cat_Pressing": {
      fr: "Pressing",
      en: "Laundry",
      de: "Reinigung",
      es: "Lavandería",
      zh: "洗衣",
    },
    "cat_Station-service": {
      fr: "Station-service",
      en: "Fuel",
      de: "Tankstelle",
      es: "Gasolinera",
      zh: "加油",
    },
    "cat_Chaussures": {
      fr: "Chaussures",
      en: "Shoes",
      de: "Schuhe",
      es: "Zapatos",
      zh: "鞋",
    },
    "cat_Vêtements": {
      fr: "Vêtements",
      en: "Clothes",
      de: "Kleidung",
      es: "Ropa",
      zh: "衣服",
    },
    "cat_Téléphones": {
      fr: "Smartphone",
      en: "Smartphone",
      de: "Handy",
      es: "Móvil",
      zh: "手机",
    },
    "cat_Électronique": {
      fr: "Électronique",
      en: "Electronics",
      de: "Elektronik",
      es: "Electrónica",
      zh: "电子",
    },
    "cat_Supermarché": {
      fr: "Supermarché",
      en: "Supermarket",
      de: "Supermarkt",
      es: "Supermercado",
      zh: "超市",
    },
    "cat_Meubles": {
      fr: "Meubles",
      en: "Furniture",
      de: "Möbel",
      es: "Muebles",
      zh: "家具",
    },
    "cat_Bijoux": {
      fr: "Bijoux",
      en: "Jewelry",
      de: "Schmuck",
      es: "Joyas",
      zh: "珠宝",
    },
    "cat_Parfums": {
      fr: "Parfums",
      en: "Perfume",
      de: "Parfum",
      es: "Perfume",
      zh: "香水",
    },
    "cat_Livres": {
      fr: "Librairie",
      en: "Books",
      de: "Bücher",
      es: "Libros",
      zh: "书店",
    },
    "cat_Quincaillerie": {
      fr: "Quincaillerie",
      en: "Hardware",
      de: "Baumarkt",
      es: "Ferretería",
      zh: "五金",
    },
    "cat_Service": {
      fr: "Service",
      en: "Service",
      de: "Dienst",
      es: "Servicio",
      zh: "服务",
    },
    "carte_site": {
      fr: "Site web",
      en: "Website",
      de: "Webseite",
      es: "Sitio web",
      zh: "网站",
    },
    "carte_partager": {
      fr: "Partager",
      en: "Share",
      de: "Teilen",
      es: "Compartir",
      zh: "分享",
    },
    "carte_horaires": {
      fr: "Horaires",
      en: "Opening hours",
      de: "Öffnungszeiten",
      es: "Horario",
      zh: "营业时间",
    },
    "carte_pas_de_numero": {
      fr: "Numéro non communiqué",
      en: "No public number",
      de: "Keine öffentliche Nummer",
      es: "Número no disponible",
      zh: "未公开号码",
    },
    "carte_source": {
      fr: "Source : OpenStreetMap",
      en: "Source: OpenStreetMap",
      de: "Quelle: OpenStreetMap",
      es: "Fuente: OpenStreetMap",
      zh: "来源：OpenStreetMap",
    },
    "carte_partage_texte": {
      fr: "{nom}\n{adresse}\n{telephone}\nTrouvé avec l'application Mes Prestataires",
      en: "{nom}\n{adresse}\n{telephone}\nFound with the Mes Prestataires app",
      de: "{nom}\n{adresse}\n{telephone}\nGefunden mit der App Mes Prestataires",
      es: "{nom}\n{adresse}\n{telephone}\nEncontrado con la app Mes Prestataires",
      zh: "{nom}\n{adresse}\n{telephone}\n通过 Mes Prestataires 找到",
    },
    "parametres_section_preferences": {
      fr: "Préférences",
      en: "Preferences",
      de: "Einstellungen",
      es: "Preferencias",
      zh: "偏好",
    },
    "parametres_section_activite": {
      fr: "Activité",
      en: "Activity",
      de: "Aktivität",
      es: "Actividad",
      zh: "活动",
    },
    "parametres_section_apropos": {
      fr: "À propos",
      en: "About",
      de: "Über",
      es: "Acerca de",
      zh: "关于",
    },
    "parametres_sous_titre": {
      fr: "Votre assistant pour trouver les bons prestataires",
      en: "Your assistant to find the right providers",
      de: "Dein Assistent für die richtigen Anbieter",
      es: "Tu asistente para encontrar los prestadores adecuados",
      zh: "帮您找到合适服务商的助手",
    },
    "parametres_partage_texte": {
      fr: "Découvre Mes Prestataires, l'assistant qui te trouve les vrais prestataires et boutiques en Côte d'Ivoire, avec leurs numéros ! 📲",
      en: "Discover Mes Prestataires, the assistant that finds real providers and shops in Côte d'Ivoire, with their numbers! 📲",
      de: "Entdecke Mes Prestataires, den Assistenten, der echte Anbieter und Geschäfte in der Elfenbeinküste mit Nummern findet! 📲",
      es: "Descubre Mes Prestataires, el asistente que encuentra prestadores y tiendas reales en Costa de Marfil, ¡con sus números! 📲",
      zh: "发现 Mes Prestataires——帮您在科特迪瓦找到真实服务商和商店及其电话的助手！📲",
    },
    "parametres_version": {
      fr: "Version 1.0.0",
      en: "Version 1.0.0",
      de: "Version 1.0.0",
      es: "Versión 1.0.0",
      zh: "版本 1.0.0",
    },
    "historique_supprime": {
      fr: "Recherche supprimée",
      en: "Search deleted",
      de: "Suche gelöscht",
      es: "Búsqueda eliminada",
      zh: "已删除搜索",
    },
    "historique_aide": {
      fr: "Touchez une recherche pour la relancer",
      en: "Tap a search to run it again",
      de: "Tippe auf eine Suche, um sie erneut zu starten",
      es: "Toca una búsqueda para repetirla",
      zh: "点击搜索记录即可重新搜索",
    },
    "aide_sous_titre": {
      fr: "Questions fréquentes",
      en: "Frequently asked questions",
      de: "Häufige Fragen",
      es: "Preguntas frecuentes",
      zh: "常见问题",
    },
    "carte_adresse_inconnue": {
      fr: "Adresse non communiquée (voir l'itinéraire)",
      en: "Address not provided (see directions)",
      de: "Adresse nicht angegeben (siehe Route)",
      es: "Dirección no indicada (ver ruta)",
      zh: "未提供地址（请查看路线）",
    },
  };

  /// Fonction principale : donne le texte traduit pour une clé, selon la langue active
  static String texte(String cle) {
    final code = langueNotifier.value;
    return _traductions[cle]?[code] ?? _traductions[cle]?[fr] ?? cle;
  }

  /// Texte traduit avec des valeurs à insérer, ex: {"n": 3} remplace "{n}"
  static String texteAvec(String cle, Map<String, Object> valeurs) {
    var resultat = texte(cle);
    valeurs.forEach((nom, valeur) {
      resultat = resultat.replaceAll("{$nom}", "$valeur");
    });
    return resultat;
  }
}
