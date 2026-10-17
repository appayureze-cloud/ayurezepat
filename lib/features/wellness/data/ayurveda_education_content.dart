import '../domain/entities/ayurveda_article.dart';

/// Static, bundled general-wellness content. Deliberately generic and
/// lifestyle-focused (routine, diet, sleep, movement) rather than
/// condition-specific or dosage-specific claims - this app has no
/// clinician review pipeline for educational copy, so it stays in the
/// same "general information, not medical advice" register as the rest
/// of Astra's non-clinical content.
const kAyurvedaArticles = <AyurvedaArticle>[
  AyurvedaArticle(
    id: 'dinacharya-basics',
    title: 'What is a daily routine (dinacharya)?',
    category: 'Daily routine',
    summary: 'Ayurveda\'s traditional emphasis on a consistent daily rhythm.',
    body:
        'Dinacharya refers to a consistent daily routine: waking and sleeping '
        'at similar times, regular meals, and time set aside for movement '
        'and rest. The idea is consistency rather than any specific '
        'schedule - what matters most is picking a rhythm you can actually '
        'sustain.\n\nThis is general background information, not a '
        'prescribed regimen. If you have a specific health condition, talk '
        'to your doctor before changing your routine.',
  ),
  AyurvedaArticle(
    id: 'mindful-eating',
    title: 'Eating with attention',
    category: 'Diet',
    summary: 'Traditional guidance favors unhurried, regular mealtimes.',
    body: 'Ayurvedic tradition generally favors eating at regular times, '
        'without distraction, and stopping before feeling completely full. '
        'It also traditionally emphasizes favoring freshly prepared food '
        'over heavily processed food where practical.\n\nThis is general '
        'wellness information. It is not dietary advice for any specific '
        'condition (e.g. diabetes, kidney disease) - for those, follow your '
        'doctor or dietitian\'s guidance instead.',
  ),
  AyurvedaArticle(
    id: 'sleep-rhythm',
    title: 'Sleep and the day/night cycle',
    category: 'Sleep',
    summary:
        'Why a consistent sleep-wake time matters more than duration alone.',
    body: 'Keeping a consistent sleep and wake time is a recurring theme in '
        'both Ayurvedic tradition and modern sleep science. Most adults do '
        'better with 7-9 hours, but the exact number matters less than '
        'keeping it steady day to day.\n\nIf you are experiencing persistent '
        'insomnia, very irregular sleep, or daytime sleepiness that affects '
        'daily life, that is worth raising with a doctor rather than '
        'managing through routine changes alone.',
  ),
  AyurvedaArticle(
    id: 'gentle-movement',
    title: 'Movement, not just exercise',
    category: 'Movement',
    summary:
        'Short, regular movement is traditionally favored over occasional intense exertion.',
    body: 'Ayurvedic tradition generally favors movement that matches your '
        'current capacity - a daily walk, light stretching, or yoga - over '
        'occasional intense exertion. The right amount varies a lot by '
        'person, age and health status.\n\nIf you have a heart condition, '
        'joint problems, or are recovering from an illness or surgery, check '
        'with your doctor before starting or changing an exercise routine.',
  ),
  AyurvedaArticle(
    id: 'stress-relaxation',
    title: 'Making time to unwind',
    category: 'Relaxation',
    summary: 'Short daily breaks for calm, not just occasional rest.',
    body: 'Traditional practice emphasizes short, regular periods of calm - '
        'quiet time, breathing exercises, or a brief walk outdoors - over '
        'relying only on occasional long breaks or vacations to recover '
        'from stress.\n\nPersistent anxiety, low mood, or stress that '
        'interferes with daily functioning is a medical concern, not '
        'something to address through relaxation routines alone - please '
        'talk to a doctor or mental health professional.',
  ),
  AyurvedaArticle(
    id: 'seasonal-awareness',
    title: 'Noticing seasonal changes',
    category: 'Daily routine',
    summary: 'Adjusting routine gently as weather and seasons change.',
    body: 'Ayurvedic tradition encourages noticing how the body responds as '
        'seasons change - adjusting layers of clothing, hydration, and meal '
        'timing gradually rather than all at once. This is a general '
        'awareness practice, not a treatment for any seasonal illness '
        '(e.g. seasonal allergies, flu) - see a doctor for those.',
  ),
];
