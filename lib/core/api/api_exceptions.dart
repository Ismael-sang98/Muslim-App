sealed class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException([super.message = 'Pas de connexion internet']);
}

class ServerException extends ApiException {
  final int statusCode;
  const ServerException(this.statusCode, [String message = 'Erreur serveur'])
      : super(message);
}

class BadRequestException extends ApiException {
  const BadRequestException([super.message = 'Requête invalide']);
}

class ApiTimeoutException extends ApiException {
  const ApiTimeoutException([super.message = 'Délai de connexion dépassé']);
}

class CacheException extends ApiException {
  const CacheException([super.message = 'Erreur de cache local']);
}

class DiyanetStructureException extends ApiException {
  const DiyanetStructureException([
    super.message = 'Structure Diyanet modifiée — mise à jour requise',
  ]);
}
