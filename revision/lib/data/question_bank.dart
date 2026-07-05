import '../models/question.dart';

class QuestionBank {
  // ── Categories ──
  static const List<QuizCategory> categories = [
    QuizCategory(
      id: 'rajasthan_gk',
      name: 'Rajasthan GK',
      icon: '🏰',
      questionCount: 15,
      description: 'राजस्थान सामान्य ज्ञान',
    ),
    QuizCategory(
      id: 'indian_history',
      name: 'Indian History',
      icon: '📜',
      questionCount: 15,
      description: 'भारतीय इतिहास',
    ),
    QuizCategory(
      id: 'art_culture',
      name: 'Art & Culture',
      icon: '🎨',
      questionCount: 15,
      description: 'कला एवं संस्कृति',
    ),
    QuizCategory(
      id: 'geography',
      name: 'Geography',
      icon: '🌍',
      questionCount: 15,
      description: 'भूगोल',
    ),
    QuizCategory(
      id: 'polity',
      name: 'Indian Polity',
      icon: '⚖️',
      questionCount: 15,
      description: 'भारतीय राजव्यवस्था',
    ),
    QuizCategory(
      id: 'science',
      name: 'Science',
      icon: '🔬',
      questionCount: 15,
      description: 'विज्ञान',
    ),
    QuizCategory(
      id: 'economy',
      name: 'Economy',
      icon: '📊',
      questionCount: 15,
      description: 'अर्थव्यवस्था',
    ),
    QuizCategory(
      id: 'hindi',
      name: 'Hindi Language',
      icon: '📝',
      questionCount: 15,
      description: 'हिंदी भाषा',
    ),
    QuizCategory(
      id: 'current_affairs',
      name: 'Current Affairs',
      icon: '📰',
      questionCount: 15,
      description: 'समसामयिकी',
    ),
  ];

  // ── Get questions for a category ──
  static List<Question> getQuestions(String categoryId) {
    switch (categoryId) {
      case 'rajasthan_gk':
        return _rajasthanGK;
      case 'indian_history':
        return _indianHistory;
      case 'art_culture':
        return _rajasthanGK;
      case 'geography':
        return _geography;
      case 'polity':
        return _polity;
      case 'science':
        return _science;
      case 'economy':
        return _economy;
      case 'hindi':
        return _hindi;
      case 'current_affairs':
        return _currentAffairs;
      default:
        return _rajasthanGK;
    }
  }

  // ── All questions for mixed mock test ──
  static List<Question> getMixedQuestions(int count) {
    final all = <Question>[
      ..._rajasthanGK,
      ..._indianHistory,
      ..._geography,
      ..._polity,
      ..._science,
      ..._economy,
      ..._hindi,
      ..._currentAffairs,
    ];
    all.shuffle();
    return all.take(count).toList();
  }

  // ─────────────────────────────────────────────
  // RAJASTHAN GK
  // ─────────────────────────────────────────────
  static final List<Question> _rajasthanGK = [
    const Question(
      id: 'rj1',
      question: 'राजस्थान का क्षेत्रफल भारत के कुल क्षेत्रफल का कितना प्रतिशत है?',
      options: ['8.40%', '10.41%', '12.50%', '9.56%'],
      correctIndex: 1,
      explanation: 'राजस्थान का क्षेत्रफल 3,42,239 वर्ग किमी है जो भारत के कुल क्षेत्रफल का 10.41% है।',
    ),
    const Question(
      id: 'rj2',
      question: 'राजस्थान की स्थापना कब हुई?',
      options: ['26 जनवरी 1950', '1 नवंबर 1956', '30 मार्च 1949', '15 अगस्त 1947'],
      correctIndex: 2,
      explanation: '30 मार्च 1949 को जोधपुर, जयपुर, जैसलमेर और बीकानेर रियासतों का विलय होकर वृहत् राजस्थान बना।',
    ),
    const Question(
      id: 'rj3',
      question: 'राजस्थान का सबसे बड़ा जिला (क्षेत्रफल) कौन सा है?',
      options: ['बाड़मेर', 'जैसलमेर', 'बीकानेर', 'जोधपुर'],
      correctIndex: 1,
      explanation: 'जैसलमेर राजस्थान का सबसे बड़ा जिला है जिसका क्षेत्रफल 38,401 वर्ग किमी है।',
    ),
    const Question(
      id: 'rj4',
      question: 'राजस्थान की सबसे लंबी नदी कौन सी है?',
      options: ['चम्बल', 'बनास', 'लूनी', 'माही'],
      correctIndex: 0,
      explanation: 'चम्बल नदी राजस्थान की सबसे लंबी नदी है जिसकी कुल लंबाई 966 किमी है।',
    ),
    const Question(
      id: 'rj5',
      question: 'हवा महल कहाँ स्थित है?',
      options: ['जोधपुर', 'उदयपुर', 'जयपुर', 'अजमेर'],
      correctIndex: 2,
      explanation: 'हवा महल जयपुर में स्थित है, इसे 1799 में महाराजा सवाई प्रताप सिंह ने बनवाया था।',
    ),
    const Question(
      id: 'rj6',
      question: 'राजस्थान का राज्य पक्षी कौन सा है?',
      options: ['मोर', 'गोडावण', 'कोयल', 'बाज'],
      correctIndex: 1,
      explanation: 'गोडावण (Great Indian Bustard) राजस्थान का राज्य पक्षी है।',
    ),
    const Question(
      id: 'rj7',
      question: 'मेवाड़ का प्रसिद्ध शासक महाराणा प्रताप का जन्म कहाँ हुआ?',
      options: ['चित्तौड़गढ़', 'कुंभलगढ़', 'उदयपुर', 'हल्दीघाटी'],
      correctIndex: 1,
      explanation: 'महाराणा प्रताप का जन्म 9 मई 1540 को कुंभलगढ़ दुर्ग में हुआ था।',
    ),
    const Question(
      id: 'rj8',
      question: 'राजस्थान का राज्य पशु कौन सा है?',
      options: ['शेर', 'ऊँट', 'चिंकारा', 'हिरण'],
      correctIndex: 2,
      explanation: 'चिंकारा (Indian Gazelle) राजस्थान का राज्य पशु है। ऊँट राज्य पशु 2014 में घोषित हुआ।',
    ),
    const Question(
      id: 'rj9',
      question: 'राजस्थान का सबसे छोटा जिला (क्षेत्रफल) कौन सा है?',
      options: ['धौलपुर', 'डूंगरपुर', 'प्रतापगढ़', 'दौसा'],
      correctIndex: 0,
      explanation: 'धौलपुर राजस्थान का सबसे छोटा जिला है जिसका क्षेत्रफल 3,034 वर्ग किमी है।',
    ),
    const Question(
      id: 'rj10',
      question: 'राजस्थान की राजधानी क्या है?',
      options: ['जोधपुर', 'उदयपुर', 'जयपुर', 'कोटा'],
      correctIndex: 2,
      explanation: 'जयपुर राजस्थान की राजधानी है। इसे Pink City भी कहते हैं।',
    ),
    const Question(
      id: 'rj11',
      question: 'राजस्थान में कुल कितने जिले हैं (2024)?',
      options: ['33', '36', '41', '50'],
      correctIndex: 3,
      explanation: 'राजस्थान में वर्तमान में 50 जिले हैं (2023 में 17 नए जिले बनाए गए)।',
    ),
    const Question(
      id: 'rj12',
      question: 'राजस्थान का राज्य फूल कौन सा है?',
      options: ['गुलाब', 'कमल', 'रोहिड़ा', 'गेंदा'],
      correctIndex: 2,
      explanation: 'रोहिड़ा (Tecomella undulata) राजस्थान का राज्य पुष्प है।',
    ),
    const Question(
      id: 'rj13',
      question: 'अजमेर शरीफ दरगाह किस सूफी संत की है?',
      options: ['निज़ामुद्दीन औलिया', 'बाबा फरीद', 'ख्वाजा मोइनुद्दीन चिश्ती', 'शेख सलीम चिश्ती'],
      correctIndex: 2,
      explanation: 'अजमेर शरीफ दरगाह ख्वाजा मोइनुद्दीन चिश्ती की दरगाह है।',
    ),
    const Question(
      id: 'rj14',
      question: 'राजस्थान का राज्य वृक्ष कौन सा है?',
      options: ['नीम', 'खेजड़ी', 'बरगद', 'पीपल'],
      correctIndex: 1,
      explanation: 'खेजड़ी (Prosopis cineraria) राजस्थान का राज्य वृक्ष है। इसे शमी भी कहते हैं।',
    ),
    const Question(
      id: 'rj15',
      question: 'राजस्थान की सबसे बड़ी खारे पानी की झील कौन सी है?',
      options: ['पुष्कर', 'सांभर', 'पचपदरा', 'डीडवाना'],
      correctIndex: 1,
      explanation: 'सांभर झील राजस्थान की सबसे बड़ी खारे पानी की झील है जो जयपुर जिले में स्थित है।',
    ),
  ];

  // ─────────────────────────────────────────────
  // INDIAN HISTORY
  // ─────────────────────────────────────────────
  static final List<Question> _indianHistory = [
    const Question(
      id: 'ih1',
      question: 'सिंधु घाटी सभ्यता की खोज किस वर्ष हुई?',
      options: ['1920', '1921', '1922', '1925'],
      correctIndex: 1,
      explanation: 'सिंधु घाटी सभ्यता की खोज 1921 में दयाराम साहनी ने हड़प्पा में की।',
    ),
    const Question(
      id: 'ih2',
      question: 'भारत में पहला मुगल शासक कौन था?',
      options: ['अकबर', 'हुमायूँ', 'बाबर', 'शाहजहाँ'],
      correctIndex: 2,
      explanation: 'बाबर (1526-1530) भारत में मुगल साम्राज्य का संस्थापक था।',
    ),
    const Question(
      id: 'ih3',
      question: 'पानीपत का प्रथम युद्ध कब हुआ?',
      options: ['1526', '1556', '1761', '1857'],
      correctIndex: 0,
      explanation: 'पानीपत का प्रथम युद्ध 1526 में बाबर और इब्राहिम लोदी के बीच हुआ।',
    ),
    const Question(
      id: 'ih4',
      question: 'भारत छोड़ो आंदोलन कब शुरू हुआ?',
      options: ['1930', '1940', '1942', '1947'],
      correctIndex: 2,
      explanation: '8 अगस्त 1942 को महात्मा गांधी ने भारत छोड़ो आंदोलन शुरू किया।',
    ),
    const Question(
      id: 'ih5',
      question: 'जलियांवाला बाग हत्याकांड कब हुआ?',
      options: ['13 अप्रैल 1919', '15 अगस्त 1919', '26 जनवरी 1920', '10 मार्च 1919'],
      correctIndex: 0,
      explanation: '13 अप्रैल 1919 को अमृतसर के जलियांवाला बाग में जनरल डायर ने गोलीबारी का आदेश दिया।',
    ),
    const Question(
      id: 'ih6',
      question: 'चंद्रगुप्त मौर्य के गुरु कौन थे?',
      options: ['वात्स्यायन', 'विष्णुगुप्त (चाणक्य)', 'पतंजलि', 'पाणिनि'],
      correctIndex: 1,
      explanation: 'चंद्रगुप्त मौर्य के गुरु विष्णुगुप्त (चाणक्य/कौटिल्य) थे जिन्होंने अर्थशास्त्र लिखा।',
    ),
    const Question(
      id: 'ih7',
      question: 'अशोक ने कलिंग युद्ध कब लड़ा?',
      options: ['261 ई.पू.', '321 ई.पू.', '232 ई.पू.', '185 ई.पू.'],
      correctIndex: 0,
      explanation: '261 ई.पू. में कलिंग युद्ध हुआ जिसके बाद अशोक ने बौद्ध धर्म अपनाया।',
    ),
    const Question(
      id: 'ih8',
      question: 'ताजमहल किसने बनवाया?',
      options: ['अकबर', 'जहाँगीर', 'शाहजहाँ', 'औरंगज़ेब'],
      correctIndex: 2,
      explanation: 'शाहजहाँ ने 1632-1653 के बीच अपनी पत्नी मुमताज़ महल की याद में ताजमहल बनवाया।',
    ),
    const Question(
      id: 'ih9',
      question: 'प्रथम भारतीय स्वतंत्रता संग्राम कब हुआ?',
      options: ['1847', '1857', '1867', '1877'],
      correctIndex: 1,
      explanation: '1857 का विद्रोह प्रथम भारतीय स्वतंत्रता संग्राम के रूप में जाना जाता है।',
    ),
    const Question(
      id: 'ih10',
      question: 'दांडी मार्च कब शुरू हुआ?',
      options: ['12 मार्च 1930', '26 जनवरी 1930', '8 अगस्त 1930', '15 अगस्त 1930'],
      correctIndex: 0,
      explanation: '12 मार्च 1930 को गांधीजी ने साबरमती आश्रम से दांडी तक नमक मार्च शुरू किया।',
    ),
    const Question(
      id: 'ih11',
      question: 'गुप्त वंश का संस्थापक कौन था?',
      options: ['चंद्रगुप्त I', 'श्रीगुप्त', 'समुद्रगुप्त', 'कुमारगुप्त'],
      correctIndex: 1,
      explanation: 'श्रीगुप्त (240-280 ई.) गुप्त वंश के संस्थापक माने जाते हैं।',
    ),
    const Question(
      id: 'ih12',
      question: 'हल्दीघाटी का युद्ध कब हुआ?',
      options: ['1556', '1576', '1600', '1615'],
      correctIndex: 1,
      explanation: '1576 में हल्दीघाटी का युद्ध महाराणा प्रताप और अकबर की सेना के बीच हुआ।',
    ),
    const Question(
      id: 'ih13',
      question: 'भारत की आज़ादी कब हुई?',
      options: ['26 जनवरी 1947', '15 अगस्त 1947', '15 अगस्त 1950', '26 जनवरी 1950'],
      correctIndex: 1,
      explanation: '15 अगस्त 1947 को भारत ब्रिटिश शासन से स्वतंत्र हुआ।',
    ),
    const Question(
      id: 'ih14',
      question: 'शिवाजी का राज्याभिषेक कब हुआ?',
      options: ['1674', '1680', '1664', '1670'],
      correctIndex: 0,
      explanation: '1674 में शिवाजी का राज्याभिषेक रायगढ़ दुर्ग में हुआ और उन्हें छत्रपति की उपाधि मिली।',
    ),
    const Question(
      id: 'ih15',
      question: 'वेदों की संख्या कितनी है?',
      options: ['3', '4', '5', '6'],
      correctIndex: 1,
      explanation: 'वेद 4 हैं — ऋग्वेद, यजुर्वेद, सामवेद और अथर्ववेद।',
    ),
  ];

  // ─────────────────────────────────────────────
  // GEOGRAPHY
  // ─────────────────────────────────────────────
  static final List<Question> _geography = [
    const Question(
      id: 'geo1',
      question: 'भारत का सबसे बड़ा राज्य (क्षेत्रफल) कौन सा है?',
      options: ['मध्य प्रदेश', 'महाराष्ट्र', 'राजस्थान', 'उत्तर प्रदेश'],
      correctIndex: 2,
      explanation: 'राजस्थान (3,42,239 वर्ग किमी) भारत का सबसे बड़ा राज्य है।',
    ),
    const Question(
      id: 'geo2',
      question: 'भारत की सबसे लंबी नदी कौन सी है?',
      options: ['यमुना', 'गोदावरी', 'गंगा', 'ब्रह्मपुत्र'],
      correctIndex: 2,
      explanation: 'गंगा नदी (2,525 किमी) भारत की सबसे लंबी नदी है।',
    ),
    const Question(
      id: 'geo3',
      question: 'भारत का सबसे ऊँचा पर्वत शिखर कौन सा है?',
      options: ['नंदा देवी', 'कंचनजंगा', 'K2 (गॉडविन ऑस्टिन)', 'माउंट एवरेस्ट'],
      correctIndex: 1,
      explanation: 'कंचनजंगा (8,586 मी) भारत का सबसे ऊँचा पर्वत शिखर है (एवरेस्ट नेपाल में है)।',
    ),
    const Question(
      id: 'geo4',
      question: 'कर्क रेखा भारत के कितने राज्यों से गुजरती है?',
      options: ['6', '7', '8', '9'],
      correctIndex: 2,
      explanation: 'कर्क रेखा भारत के 8 राज्यों — गुजरात, राजस्थान, MP, छत्तीसगढ़, झारखंड, पश्चिम बंगाल, त्रिपुरा, मिज़ोरम से गुजरती है।',
    ),
    const Question(
      id: 'geo5',
      question: 'भारत में कुल कितने राज्य हैं (2024)?',
      options: ['28', '29', '30', '31'],
      correctIndex: 0,
      explanation: 'भारत में वर्तमान में 28 राज्य और 8 केंद्र शासित प्रदेश हैं।',
    ),
    const Question(
      id: 'geo6',
      question: 'विश्व की सबसे ऊँची चोटी कौन सी है?',
      options: ['K2', 'कंचनजंगा', 'माउंट एवरेस्ट', 'मकालू'],
      correctIndex: 2,
      explanation: 'माउंट एवरेस्ट (8,848.86 मी) विश्व की सबसे ऊँची चोटी है।',
    ),
    const Question(
      id: 'geo7',
      question: 'भारत का सबसे बड़ा रेगिस्तान कौन सा है?',
      options: ['कच्छ का रण', 'थार रेगिस्तान', 'लद्दाख', 'स्पीति'],
      correctIndex: 1,
      explanation: 'थार रेगिस्तान भारत का सबसे बड़ा रेगिस्तान है जो राजस्थान में स्थित है।',
    ),
    const Question(
      id: 'geo8',
      question: 'भारत की सबसे बड़ी मीठे पानी की झील कौन सी है?',
      options: ['चिल्का', 'वूलर', 'डल', 'पुलिकट'],
      correctIndex: 1,
      explanation: 'वूलर झील (जम्मू-कश्मीर) भारत की सबसे बड़ी मीठे पानी की झील है।',
    ),
    const Question(
      id: 'geo9',
      question: 'अरावली पर्वतमाला की सबसे ऊँची चोटी कौन सी है?',
      options: ['सेर', 'जरगा', 'गुरु शिखर', 'अचलगढ़'],
      correctIndex: 2,
      explanation: 'गुरु शिखर (1,722 मी) अरावली की सबसे ऊँची चोटी है जो माउंट आबू में स्थित है।',
    ),
    const Question(
      id: 'geo10',
      question: 'भारत का सबसे लंबा समुद्र तट किस राज्य में है?',
      options: ['केरल', 'तमिलनाडु', 'गुजरात', 'महाराष्ट्र'],
      correctIndex: 2,
      explanation: 'गुजरात का समुद्र तट (1,600 किमी) भारत में सबसे लंबा है।',
    ),
    const Question(
      id: 'geo11',
      question: 'भारत में सबसे ज़्यादा वर्षा कहाँ होती है?',
      options: ['चेरापूंजी', 'मासिनराम', 'श्रीनगर', 'दार्जिलिंग'],
      correctIndex: 1,
      explanation: 'मासिनराम (मेघालय) भारत में सबसे अधिक वर्षा वाला स्थान है।',
    ),
    const Question(
      id: 'geo12',
      question: 'हिमालय की सबसे पूर्वी चोटी कौन सी है?',
      options: ['कंचनजंगा', 'नामचा बरवा', 'मकालू', 'नंगा पर्वत'],
      correctIndex: 1,
      explanation: 'नामचा बरवा (7,782 मी) हिमालय की सबसे पूर्वी चोटी है।',
    ),
    const Question(
      id: 'geo13',
      question: 'भारत की सबसे बड़ी कृत्रिम झील कौन सी है?',
      options: ['गोविंद सागर', 'नागार्जुन सागर', 'इंदिरा सागर', 'सरदार सरोवर'],
      correctIndex: 2,
      explanation: 'इंदिरा सागर (मध्य प्रदेश) भारत की सबसे बड़ी कृत्रिम झील है।',
    ),
    const Question(
      id: 'geo14',
      question: 'सुंदरबन डेल्टा किन नदियों से बनता है?',
      options: ['गंगा-यमुना', 'गंगा-ब्रह्मपुत्र', 'गंगा-महानदी', 'ब्रह्मपुत्र-मेघना'],
      correctIndex: 1,
      explanation: 'सुंदरबन डेल्टा गंगा और ब्रह्मपुत्र नदियों से बना विश्व का सबसे बड़ा डेल्टा है।',
    ),
    const Question(
      id: 'geo15',
      question: 'भारत का मानक समय किस देशांतर से निर्धारित होता है?',
      options: ['80°E', '82°30\'E', '84°E', '78°E'],
      correctIndex: 1,
      explanation: 'भारत का मानक समय 82°30\' पूर्वी देशांतर (इलाहाबाद के पास) से निर्धारित होता है।',
    ),
  ];

  // ─────────────────────────────────────────────
  // INDIAN POLITY
  // ─────────────────────────────────────────────
  static final List<Question> _polity = [
    const Question(
      id: 'pol1',
      question: 'भारतीय संविधान कब लागू हुआ?',
      options: ['15 अगस्त 1947', '26 नवंबर 1949', '26 जनवरी 1950', '30 जनवरी 1950'],
      correctIndex: 2,
      explanation: '26 जनवरी 1950 को भारतीय संविधान लागू हुआ, इसलिए इसे गणतंत्र दिवस कहते हैं।',
    ),
    const Question(
      id: 'pol2',
      question: 'भारतीय संविधान के निर्माता (Father) किसे कहा जाता है?',
      options: ['जवाहरलाल नेहरू', 'डॉ. बी. आर. अंबेडकर', 'महात्मा गांधी', 'सरदार पटेल'],
      correctIndex: 1,
      explanation: 'डॉ. बी. आर. अंबेडकर को भारतीय संविधान का पिता कहा जाता है।',
    ),
    const Question(
      id: 'pol3',
      question: 'लोकसभा में कुल कितनी सीटें हैं?',
      options: ['543', '545', '550', '552'],
      correctIndex: 1,
      explanation: 'लोकसभा में कुल 545 सीटें हैं (543 निर्वाचित + 2 एंग्लो-इंडियन मनोनीत)।',
    ),
    const Question(
      id: 'pol4',
      question: 'राज्यसभा के सदस्यों का कार्यकाल कितने वर्ष होता है?',
      options: ['4 वर्ष', '5 वर्ष', '6 वर्ष', 'आजीवन'],
      correctIndex: 2,
      explanation: 'राज्यसभा के सदस्यों का कार्यकाल 6 वर्ष होता है और हर 2 वर्ष में एक-तिहाई सदस्य सेवानिवृत्त होते हैं।',
    ),
    const Question(
      id: 'pol5',
      question: 'भारत के प्रथम राष्ट्रपति कौन थे?',
      options: ['डॉ. राजेंद्र प्रसाद', 'डॉ. सर्वपल्ली राधाकृष्णन', 'जवाहरलाल नेहरू', 'डॉ. ज़ाकिर हुसैन'],
      correctIndex: 0,
      explanation: 'डॉ. राजेंद्र प्रसाद भारत के प्रथम राष्ट्रपति थे (1950-1962)।',
    ),
    const Question(
      id: 'pol6',
      question: 'मौलिक अधिकार संविधान के किस भाग में हैं?',
      options: ['भाग I', 'भाग II', 'भाग III', 'भाग IV'],
      correctIndex: 2,
      explanation: 'मौलिक अधिकार भारतीय संविधान के भाग III (अनुच्छेद 12-35) में वर्णित हैं।',
    ),
    const Question(
      id: 'pol7',
      question: 'भारतीय संविधान में कुल कितने अनुच्छेद हैं (मूल)?',
      options: ['350', '395', '400', '448'],
      correctIndex: 1,
      explanation: 'मूल संविधान में 395 अनुच्छेद थे, वर्तमान में 448+ अनुच्छेद हैं।',
    ),
    const Question(
      id: 'pol8',
      question: 'भारत का सर्वोच्च न्यायालय कहाँ स्थित है?',
      options: ['मुंबई', 'कोलकाता', 'नई दिल्ली', 'चेन्नई'],
      correctIndex: 2,
      explanation: 'भारत का सर्वोच्च न्यायालय नई दिल्ली में स्थित है।',
    ),
    const Question(
      id: 'pol9',
      question: 'भारत में मतदान की न्यूनतम आयु क्या है?',
      options: ['16 वर्ष', '18 वर्ष', '21 वर्ष', '25 वर्ष'],
      correctIndex: 1,
      explanation: '61वें संविधान संशोधन (1989) द्वारा मतदान की आयु 21 से घटाकर 18 वर्ष की गई।',
    ),
    const Question(
      id: 'pol10',
      question: 'राज्यपाल की नियुक्ति कौन करता है?',
      options: ['प्रधानमंत्री', 'राष्ट्रपति', 'मुख्यमंत्री', 'उच्च न्यायालय'],
      correctIndex: 1,
      explanation: 'राज्यपाल की नियुक्ति राष्ट्रपति द्वारा अनुच्छेद 155 के तहत की जाती है।',
    ),
    const Question(
      id: 'pol11',
      question: 'संविधान सभा के अध्यक्ष कौन थे?',
      options: ['डॉ. अंबेडकर', 'डॉ. राजेंद्र प्रसाद', 'जवाहरलाल नेहरू', 'सच्चिदानंद सिन्हा'],
      correctIndex: 1,
      explanation: 'डॉ. राजेंद्र प्रसाद संविधान सभा के स्थायी अध्यक्ष थे।',
    ),
    const Question(
      id: 'pol12',
      question: '73वां संविधान संशोधन किससे संबंधित है?',
      options: ['नगरपालिका', 'पंचायती राज', 'GST', 'OBC आरक्षण'],
      correctIndex: 1,
      explanation: '73वां संविधान संशोधन (1992) पंचायती राज से संबंधित है।',
    ),
    const Question(
      id: 'pol13',
      question: 'भारत के मुख्य न्यायाधीश की नियुक्ति कौन करता है?',
      options: ['प्रधानमंत्री', 'राष्ट्रपति', 'संसद', 'विधि मंत्री'],
      correctIndex: 1,
      explanation: 'भारत के मुख्य न्यायाधीश की नियुक्ति राष्ट्रपति द्वारा की जाती है।',
    ),
    const Question(
      id: 'pol14',
      question: 'भारतीय संविधान को बनाने में कितना समय लगा?',
      options: ['2 वर्ष 11 महीने 17 दिन', '2 वर्ष 11 महीने 18 दिन', '3 वर्ष', '2 वर्ष 6 महीने'],
      correctIndex: 1,
      explanation: 'संविधान को बनने में 2 वर्ष, 11 महीने और 18 दिन लगे।',
    ),
    const Question(
      id: 'pol15',
      question: 'नीति निर्देशक तत्व किस देश से लिए गए हैं?',
      options: ['अमेरिका', 'ब्रिटेन', 'आयरलैंड', 'फ्रांस'],
      correctIndex: 2,
      explanation: 'नीति निर्देशक तत्व आयरलैंड के संविधान से प्रेरित हैं।',
    ),
  ];

  // ─────────────────────────────────────────────
  // SCIENCE
  // ─────────────────────────────────────────────
  static final List<Question> _science = [
    const Question(
      id: 'sci1',
      question: 'मानव शरीर में सबसे बड़ा अंग कौन सा है?',
      options: ['हृदय', 'यकृत (लीवर)', 'त्वचा', 'मस्तिष्क'],
      correctIndex: 2,
      explanation: 'त्वचा मानव शरीर का सबसे बड़ा अंग है।',
    ),
    const Question(
      id: 'sci2',
      question: 'प्रकाश की गति कितनी है?',
      options: ['3 × 10⁶ m/s', '3 × 10⁸ m/s', '3 × 10⁵ m/s', '3 × 10¹⁰ m/s'],
      correctIndex: 1,
      explanation: 'प्रकाश की गति लगभग 3 × 10⁸ m/s (3 लाख किमी/सेकंड) है।',
    ),
    const Question(
      id: 'sci3',
      question: 'DNA का पूरा नाम क्या है?',
      options: [
        'Deoxyribo Nucleic Acid',
        'Di Nucleic Acid',
        'Deoxyribo Natural Acid',
        'Dynamic Nucleic Acid'
      ],
      correctIndex: 0,
      explanation: 'DNA = Deoxyribonucleic Acid (डीऑक्सीराइबोन्यूक्लिक अम्ल)।',
    ),
    const Question(
      id: 'sci4',
      question: 'न्यूटन के गति के कितने नियम हैं?',
      options: ['2', '3', '4', '5'],
      correctIndex: 1,
      explanation: 'न्यूटन के गति के 3 नियम हैं — जड़त्व का नियम, गति का नियम, क्रिया-प्रतिक्रिया का नियम।',
    ),
    const Question(
      id: 'sci5',
      question: 'पानी का रासायनिक सूत्र क्या है?',
      options: ['H₂O₂', 'H₂O', 'HO₂', 'H₃O'],
      correctIndex: 1,
      explanation: 'पानी का रासायनिक सूत्र H₂O (दो हाइड्रोजन + एक ऑक्सीजन) है।',
    ),
    const Question(
      id: 'sci6',
      question: 'मानव शरीर में कुल कितनी हड्डियाँ होती हैं?',
      options: ['200', '206', '210', '215'],
      correctIndex: 1,
      explanation: 'वयस्क मानव शरीर में 206 हड्डियाँ होती हैं।',
    ),
    const Question(
      id: 'sci7',
      question: 'रक्त का pH मान कितना होता है?',
      options: ['6.8', '7.0', '7.4', '8.0'],
      correctIndex: 2,
      explanation: 'मानव रक्त का pH मान 7.35-7.45 (लगभग 7.4) होता है जो क्षारीय है।',
    ),
    const Question(
      id: 'sci8',
      question: 'विटामिन C का रासायनिक नाम क्या है?',
      options: ['रेटिनॉल', 'एस्कॉर्बिक एसिड', 'थायमिन', 'टोकोफ़ेरॉल'],
      correctIndex: 1,
      explanation: 'विटामिन C का रासायनिक नाम एस्कॉर्बिक एसिड है।',
    ),
    const Question(
      id: 'sci9',
      question: 'सोने का रासायनिक चिह्न क्या है?',
      options: ['Ag', 'Au', 'Fe', 'Cu'],
      correctIndex: 1,
      explanation: 'सोने का रासायनिक चिह्न Au (Aurum) है।',
    ),
    const Question(
      id: 'sci10',
      question: 'प्रकाश संश्लेषण में कौन सी गैस निकलती है?',
      options: ['CO₂', 'N₂', 'O₂', 'H₂'],
      correctIndex: 2,
      explanation: 'प्रकाश संश्लेषण में पौधे CO₂ लेकर O₂ (ऑक्सीजन) छोड़ते हैं।',
    ),
    const Question(
      id: 'sci11',
      question: 'मानव मस्तिष्क का वज़न लगभग कितना होता है?',
      options: ['1 kg', '1.4 kg', '2 kg', '2.5 kg'],
      correctIndex: 1,
      explanation: 'वयस्क मानव मस्तिष्क का वज़न लगभग 1.4 kg (1400 ग्राम) होता है।',
    ),
    const Question(
      id: 'sci12',
      question: 'आवर्त सारणी में कुल कितने तत्व हैं (2024)?',
      options: ['112', '118', '120', '108'],
      correctIndex: 1,
      explanation: 'आवर्त सारणी में वर्तमान में 118 तत्व हैं।',
    ),
    const Question(
      id: 'sci13',
      question: 'ध्वनि की गति हवा में कितनी होती है?',
      options: ['220 m/s', '332 m/s', '343 m/s', '440 m/s'],
      correctIndex: 2,
      explanation: 'ध्वनि की गति सामान्य तापमान (20°C) पर हवा में 343 m/s होती है।',
    ),
    const Question(
      id: 'sci14',
      question: 'लोहे का रासायनिक चिह्न क्या है?',
      options: ['Ir', 'Fe', 'Li', 'Lo'],
      correctIndex: 1,
      explanation: 'लोहे का रासायनिक चिह्न Fe (Ferrum) है।',
    ),
    const Question(
      id: 'sci15',
      question: 'RBC का जीवनकाल कितना होता है?',
      options: ['30 दिन', '60 दिन', '90 दिन', '120 दिन'],
      correctIndex: 3,
      explanation: 'लाल रक्त कणिकाओं (RBC) का जीवनकाल लगभग 120 दिन होता है।',
    ),
  ];

  // ─────────────────────────────────────────────
  // ECONOMY
  // ─────────────────────────────────────────────
  static final List<Question> _economy = [
    const Question(
      id: 'eco1',
      question: 'भारतीय रिज़र्व बैंक (RBI) की स्थापना कब हुई?',
      options: ['1930', '1935', '1947', '1950'],
      correctIndex: 1,
      explanation: 'RBI की स्थापना 1 अप्रैल 1935 को हुई। 1949 में इसका राष्ट्रीयकरण हुआ।',
    ),
    const Question(
      id: 'eco2',
      question: 'GST भारत में कब लागू हुआ?',
      options: ['1 अप्रैल 2017', '1 जुलाई 2017', '1 जनवरी 2018', '15 अगस्त 2017'],
      correctIndex: 1,
      explanation: '1 जुलाई 2017 को GST (Goods and Services Tax) भारत में लागू हुआ।',
    ),
    const Question(
      id: 'eco3',
      question: 'भारत की मुद्रा क्या है?',
      options: ['डॉलर', 'रुपया', 'यूरो', 'पाउंड'],
      correctIndex: 1,
      explanation: 'भारतीय रुपया (₹, INR) भारत की आधिकारिक मुद्रा है।',
    ),
    const Question(
      id: 'eco4',
      question: 'NITI आयोग का गठन कब हुआ?',
      options: ['1 जनवरी 2015', '15 मार्च 2015', '26 जनवरी 2015', '1 अप्रैल 2015'],
      correctIndex: 0,
      explanation: 'NITI आयोग (National Institution for Transforming India) का गठन 1 जनवरी 2015 को हुआ।',
    ),
    const Question(
      id: 'eco5',
      question: 'भारत में नोटबंदी कब हुई?',
      options: ['8 नवंबर 2016', '8 नवंबर 2015', '8 दिसंबर 2016', '26 जनवरी 2016'],
      correctIndex: 0,
      explanation: '8 नवंबर 2016 को ₹500 और ₹1000 के नोट बंद किए गए।',
    ),
    const Question(
      id: 'eco6',
      question: 'भारत का सबसे बड़ा बैंक कौन सा है?',
      options: ['PNB', 'BOB', 'SBI', 'HDFC'],
      correctIndex: 2,
      explanation: 'State Bank of India (SBI) भारत का सबसे बड़ा सार्वजनिक बैंक है।',
    ),
    const Question(
      id: 'eco7',
      question: 'पंचवर्षीय योजना का प्रारंभ कब हुआ?',
      options: ['1950', '1951', '1952', '1947'],
      correctIndex: 1,
      explanation: 'भारत की पहली पंचवर्षीय योजना 1951 में शुरू हुई।',
    ),
    const Question(
      id: 'eco8',
      question: 'RBI का मुख्यालय कहाँ है?',
      options: ['दिल्ली', 'मुंबई', 'कोलकाता', 'चेन्नई'],
      correctIndex: 1,
      explanation: 'RBI का मुख्यालय मुंबई में है।',
    ),
    const Question(
      id: 'eco9',
      question: 'भारत में हरित क्रांति के जनक कौन हैं?',
      options: ['वर्गीज कुरियन', 'एम.एस. स्वामीनाथन', 'नॉर्मन बोरलॉग', 'सी. सुब्रमण्यम'],
      correctIndex: 1,
      explanation: 'डॉ. एम.एस. स्वामीनाथन को भारत में हरित क्रांति का जनक कहा जाता है।',
    ),
    const Question(
      id: 'eco10',
      question: 'SEBI की स्थापना कब हुई?',
      options: ['1988', '1990', '1992', '1995'],
      correctIndex: 0,
      explanation: 'SEBI (Securities and Exchange Board of India) की स्थापना 12 अप्रैल 1988 को हुई।',
    ),
    const Question(
      id: 'eco11',
      question: 'भारत की GDP में सबसे बड़ा योगदान किस क्षेत्र का है?',
      options: ['कृषि', 'उद्योग', 'सेवा', 'खनन'],
      correctIndex: 2,
      explanation: 'सेवा क्षेत्र (Service Sector) भारत की GDP में सबसे बड़ा योगदान (50%+) देता है।',
    ),
    const Question(
      id: 'eco12',
      question: 'म्यूचुअल फंड का नियमन कौन करता है?',
      options: ['RBI', 'SEBI', 'IRDAI', 'NABARD'],
      correctIndex: 1,
      explanation: 'SEBI (Securities and Exchange Board of India) म्यूचुअल फंड का नियमन करता है।',
    ),
    const Question(
      id: 'eco13',
      question: 'भारत में श्वेत क्रांति के जनक कौन हैं?',
      options: ['एम.एस. स्वामीनाथन', 'वर्गीज कुरियन', 'सैम पित्रोदा', 'ए.पी.जे. अब्दुल कलाम'],
      correctIndex: 1,
      explanation: 'डॉ. वर्गीज कुरियन को भारत में श्वेत क्रांति (दुग्ध क्रांति) का जनक कहा जाता है।',
    ),
    const Question(
      id: 'eco14',
      question: 'UPI का पूरा नाम क्या है?',
      options: [
        'United Payment Interface',
        'Unified Payments Interface',
        'Universal Payment Integration',
        'Unified Payment Integration'
      ],
      correctIndex: 1,
      explanation: 'UPI = Unified Payments Interface, जो NPCI द्वारा विकसित है।',
    ),
    const Question(
      id: 'eco15',
      question: 'भारत का पहला बजट किसने पेश किया?',
      options: ['जवाहरलाल नेहरू', 'लियाकत अली खान', 'जेम्स विल्सन', 'आर.के. शनमुखम चेट्टी'],
      correctIndex: 3,
      explanation: 'स्वतंत्र भारत का पहला बजट आर.के. शनमुखम चेट्टी ने 26 नवंबर 1947 को पेश किया।',
    ),
  ];

  // ─────────────────────────────────────────────
  // HINDI LANGUAGE
  // ─────────────────────────────────────────────
  static final List<Question> _hindi = [
    const Question(
      id: 'hi1',
      question: '"सूर्य" का पर्यायवाची शब्द कौन सा है?',
      options: ['चंद्र', 'शशि', 'दिनकर', 'इंदु'],
      correctIndex: 2,
      explanation: 'सूर्य के पर्यायवाची — दिनकर, भास्कर, प्रभाकर, रवि, सूरज, आदित्य।',
    ),
    const Question(
      id: 'hi2',
      question: '"नीरज" का अर्थ क्या है?',
      options: ['जल', 'कमल', 'बादल', 'नदी'],
      correctIndex: 1,
      explanation: 'नीरज = नीर (पानी) + ज (जन्मा) = कमल (पानी में जन्मा)।',
    ),
    const Question(
      id: 'hi3',
      question: 'हिंदी में कुल कितने स्वर हैं?',
      options: ['10', '11', '13', '14'],
      correctIndex: 1,
      explanation: 'हिंदी वर्णमाला में 11 स्वर (अ, आ, इ, ई, उ, ऊ, ऋ, ए, ऐ, ओ, औ) हैं।',
    ),
    const Question(
      id: 'hi4',
      question: '"विद्यालय" में कौन सा समास है?',
      options: ['तत्पुरुष', 'द्वंद्व', 'बहुव्रीहि', 'कर्मधारय'],
      correctIndex: 0,
      explanation: 'विद्यालय = विद्या + आलय (विद्या के लिए आलय) — तत्पुरुष समास।',
    ),
    const Question(
      id: 'hi5',
      question: '"अनाथ" का विलोम शब्द क्या है?',
      options: ['सनाथ', 'अमीर', 'धनी', 'सुखी'],
      correctIndex: 0,
      explanation: 'अनाथ का विलोम सनाथ है।',
    ),
    const Question(
      id: 'hi6',
      question: '"रामचरितमानस" के रचयिता कौन हैं?',
      options: ['सूरदास', 'तुलसीदास', 'कबीरदास', 'रहीम'],
      correctIndex: 1,
      explanation: 'रामचरितमानस के रचयिता गोस्वामी तुलसीदास हैं।',
    ),
    const Question(
      id: 'hi7',
      question: '"घर" का बहुवचन क्या है?',
      options: ['घरों', 'घर', 'घरे', 'घरा'],
      correctIndex: 0,
      explanation: '"घर" का बहुवचन "घरों" (विभक्ति सहित) होता है।',
    ),
    const Question(
      id: 'hi8',
      question: '"उपसर्ग" का अर्थ क्या है?',
      options: [
        'शब्द के बाद जुड़ने वाला',
        'शब्द के पहले जुड़ने वाला',
        'मूल शब्द',
        'दो शब्दों का मेल'
      ],
      correctIndex: 1,
      explanation: 'उपसर्ग वे शब्दांश हैं जो किसी शब्द के पहले जुड़कर अर्थ बदल देते हैं।',
    ),
    const Question(
      id: 'hi9',
      question: 'हिंदी दिवस कब मनाया जाता है?',
      options: ['14 सितंबर', '15 अगस्त', '26 जनवरी', '2 अक्टूबर'],
      correctIndex: 0,
      explanation: '14 सितंबर को हिंदी दिवस मनाया जाता है। 1949 में इसी दिन हिंदी को राजभाषा का दर्जा मिला।',
    ),
    const Question(
      id: 'hi10',
      question: '"आँखों का तारा" मुहावरे का अर्थ क्या है?',
      options: ['आँख में दर्द', 'बहुत प्यारा', 'चमकीला', 'दूर का'],
      correctIndex: 1,
      explanation: '"आँखों का तारा" का अर्थ है — बहुत प्यारा, अत्यंत प्रिय।',
    ),
    const Question(
      id: 'hi11',
      question: '"वाक्य" के कितने अंग होते हैं?',
      options: ['2', '3', '4', '5'],
      correctIndex: 0,
      explanation: 'वाक्य के 2 अंग होते हैं — उद्देश्य (Subject) और विधेय (Predicate)।',
    ),
    const Question(
      id: 'hi12',
      question: '"निराशा" में कौन सा उपसर्ग है?',
      options: ['नि', 'निर्', 'निर', 'निरा'],
      correctIndex: 1,
      explanation: 'निराशा = निर् + आशा, यहाँ "निर्" उपसर्ग है।',
    ),
    const Question(
      id: 'hi13',
      question: 'संज्ञा के कितने भेद होते हैं?',
      options: ['3', '4', '5', '6'],
      correctIndex: 2,
      explanation: 'संज्ञा के 5 भेद — व्यक्तिवाचक, जातिवाचक, भाववाचक, समूहवाचक, द्रव्यवाचक।',
    ),
    const Question(
      id: 'hi14',
      question: '"जो सब कुछ जानता हो" के लिए एक शब्द क्या है?',
      options: ['सर्वज्ञ', 'अल्पज्ञ', 'बहुज्ञ', 'अज्ञ'],
      correctIndex: 0,
      explanation: '"जो सब कुछ जानता हो" = सर्वज्ञ (सर्व + ज्ञ)।',
    ),
    const Question(
      id: 'hi15',
      question: '"पंचतंत्र" के लेखक कौन हैं?',
      options: ['कालिदास', 'विष्णु शर्मा', 'भवभूति', 'बाणभट्ट'],
      correctIndex: 1,
      explanation: 'पंचतंत्र के लेखक विष्णु शर्मा हैं।',
    ),
  ];

  // ─────────────────────────────────────────────
  // CURRENT AFFAIRS
  // ─────────────────────────────────────────────
  static final List<Question> _currentAffairs = [
    const Question(
      id: 'ca1',
      question: 'चंद्रयान-3 कब लॉन्च हुआ?',
      options: ['14 जुलाई 2023', '23 अगस्त 2023', '14 जुलाई 2022', '15 अगस्त 2023'],
      correctIndex: 0,
      explanation: 'चंद्रयान-3 14 जुलाई 2023 को लॉन्च हुआ और 23 अगस्त 2023 को चंद्रमा पर उतरा।',
    ),
    const Question(
      id: 'ca2',
      question: 'G20 शिखर सम्मेलन 2023 कहाँ आयोजित हुआ?',
      options: ['मुंबई', 'नई दिल्ली', 'बैंगलोर', 'हैदराबाद'],
      correctIndex: 1,
      explanation: 'G20 शिखर सम्मेलन 2023 का आयोजन 9-10 सितंबर को नई दिल्ली में हुआ।',
    ),
    const Question(
      id: 'ca3',
      question: 'आदित्य-L1 मिशन किससे संबंधित है?',
      options: ['चंद्रमा', 'मंगल', 'सूर्य', 'शुक्र'],
      correctIndex: 2,
      explanation: 'आदित्य-L1 भारत का पहला सौर मिशन है जो सूर्य के अध्ययन के लिए लॉन्च हुआ।',
    ),
    const Question(
      id: 'ca4',
      question: 'UPI (Unified Payments Interface) किसने विकसित किया?',
      options: ['RBI', 'NPCI', 'SBI', 'SEBI'],
      correctIndex: 1,
      explanation: 'UPI को NPCI (National Payments Corporation of India) ने विकसित किया।',
    ),
    const Question(
      id: 'ca5',
      question: 'भारत का 28वां राज्य कौन सा है?',
      options: ['तेलंगाना', 'लद्दाख', 'झारखंड', 'उत्तराखंड'],
      correctIndex: 0,
      explanation: 'तेलंगाना (2 जून 2014) भारत का 28वां और नवीनतम राज्य है।',
    ),
    const Question(
      id: 'ca6',
      question: 'डिजिटल इंडिया कार्यक्रम कब शुरू हुआ?',
      options: ['1 जुलाई 2015', '15 अगस्त 2015', '26 जनवरी 2015', '2 अक्टूबर 2014'],
      correctIndex: 0,
      explanation: 'डिजिटल इंडिया कार्यक्रम 1 जुलाई 2015 को शुरू हुआ।',
    ),
    const Question(
      id: 'ca7',
      question: 'स्वच्छ भारत मिशन कब शुरू हुआ?',
      options: ['15 अगस्त 2014', '2 अक्टूबर 2014', '26 जनवरी 2015', '1 अप्रैल 2015'],
      correctIndex: 1,
      explanation: 'स्वच्छ भारत मिशन 2 अक्टूबर 2014 (गांधी जयंती) को शुरू हुआ।',
    ),
    const Question(
      id: 'ca8',
      question: 'ISRO का मुख्यालय कहाँ है?',
      options: ['दिल्ली', 'मुंबई', 'बैंगलोर', 'चेन्नई'],
      correctIndex: 2,
      explanation: 'ISRO (Indian Space Research Organisation) का मुख्यालय बैंगलोर में है।',
    ),
    const Question(
      id: 'ca9',
      question: 'प्रधानमंत्री जन धन योजना कब शुरू हुई?',
      options: ['15 अगस्त 2014', '28 अगस्त 2014', '2 अक्टूबर 2014', '26 जनवरी 2015'],
      correctIndex: 1,
      explanation: 'प्रधानमंत्री जन धन योजना 28 अगस्त 2014 को शुरू हुई।',
    ),
    const Question(
      id: 'ca10',
      question: 'भारत ने ICC क्रिकेट विश्व कप 2023 में कौन सा स्थान प्राप्त किया?',
      options: ['विजेता', 'उपविजेता', 'सेमीफाइनल', 'क्वार्टरफाइनल'],
      correctIndex: 1,
      explanation: 'भारत ICC विश्व कप 2023 में उपविजेता रहा, फाइनल में ऑस्ट्रेलिया ने जीता।',
    ),
    const Question(
      id: 'ca11',
      question: 'अनुच्छेद 370 कब हटाया गया?',
      options: ['5 अगस्त 2019', '15 अगस्त 2019', '26 जनवरी 2020', '2 अक्टूबर 2019'],
      correctIndex: 0,
      explanation: '5 अगस्त 2019 को अनुच्छेद 370 को हटाया गया और J&K को दो केंद्र शासित प्रदेशों में विभाजित किया गया।',
    ),
    const Question(
      id: 'ca12',
      question: 'आयुष्मान भारत योजना कब शुरू हुई?',
      options: ['23 सितंबर 2018', '15 अगस्त 2018', '2 अक्टूबर 2018', '1 अप्रैल 2018'],
      correctIndex: 0,
      explanation: 'आयुष्मान भारत - प्रधानमंत्री जन आरोग्य योजना 23 सितंबर 2018 को शुरू हुई।',
    ),
    const Question(
      id: 'ca13',
      question: 'मेक इन इंडिया कार्यक्रम कब शुरू हुआ?',
      options: ['15 अगस्त 2014', '25 सितंबर 2014', '2 अक्टूबर 2014', '26 जनवरी 2015'],
      correctIndex: 1,
      explanation: 'मेक इन इंडिया कार्यक्रम 25 सितंबर 2014 को शुरू हुआ।',
    ),
    const Question(
      id: 'ca14',
      question: 'भारत का पहला बुलेट ट्रेन प्रोजेक्ट कौन सा है?',
      options: [
        'दिल्ली-मुंबई',
        'मुंबई-अहमदाबाद',
        'दिल्ली-कोलकाता',
        'चेन्नई-बैंगलोर'
      ],
      correctIndex: 1,
      explanation: 'मुंबई-अहमदाबाद हाई-स्पीड रेल कॉरिडोर भारत का पहला बुलेट ट्रेन प्रोजेक्ट है।',
    ),
    const Question(
      id: 'ca15',
      question: 'CAA (नागरिकता संशोधन अधिनियम) कब पारित हुआ?',
      options: ['11 दिसंबर 2019', '5 अगस्त 2019', '26 जनवरी 2020', '15 अगस्त 2019'],
      correctIndex: 0,
      explanation: 'CAA (Citizenship Amendment Act) 11 दिसंबर 2019 को संसद में पारित हुआ।',
    ),
  ];
}
