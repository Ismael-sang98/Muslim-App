// Source de vérité pour les éditions disponibles par langue.
// Les valeurs null signifient que la collection n'existe pas dans cette langue.

const List<String> hadithCollections = [
  'bukhari',
  'muslim',
  'abudawud',
  'ibnmajah',
  'nasai',
  'tirmidhi',
  'qudsi',
  'nawawi',
];

const Map<String, String> hadithCollectionNames = {
  'bukhari': 'Sahih al-Bukhari',
  'muslim': 'Sahih Muslim',
  'abudawud': 'Sunan Abu Dawud',
  'ibnmajah': 'Sunan Ibn Majah',
  'nasai': "Sunan an-Nasa'i",
  'tirmidhi': "Jami' at-Tirmidhi",
  'qudsi': 'Al-Hadith al-Qudsi',
  'nawawi': 'Riyad as-Salihin',
};

const Map<String, Map<String, String?>> _editions = {
  'tr': {
    'bukhari': 'tur-bukhari',
    'muslim': 'tur-muslim',
    'abudawud': 'tur-abudawud',
    'ibnmajah': 'tur-ibnmajah',
    'nasai': 'tur-nasai',
    'tirmidhi': 'tur-tirmidhi',
    'qudsi': null, // indisponible en turc
    'nawawi': null, // indisponible en turc
  },
  'en': {
    'bukhari': 'eng-bukhari',
    'muslim': 'eng-muslim',
    'abudawud': 'eng-abudawud',
    'ibnmajah': 'eng-ibnmajah',
    'nasai': 'eng-nasai',
    'tirmidhi': 'eng-tirmidhi',
    'qudsi': 'eng-qudsi',
    'nawawi': 'eng-nawawi',
  },
  'fr': {
    'bukhari': 'fra-bukhari',
    'muslim': 'fra-muslim',
    'abudawud': 'fra-abudawud',
    'ibnmajah': 'fra-ibnmajah',
    'nasai': 'fra-nasai',
    'tirmidhi': 'fra-tirmidhi',
    'qudsi': null, // indisponible en français
    'nawawi': null, // indisponible en français
  },
};

/// Retourne l'identifiant d'édition CDN pour [lang] + [collection].
/// Retourne null si la collection n'est pas disponible dans cette langue.
String? editionFor(String lang, String collection) =>
    _editions[lang]?[collection];

/// Retourne true si la collection est disponible pour au moins une langue.
bool collectionAvailableForAnyLang(String collection) =>
    hadithCollections.contains(collection);
