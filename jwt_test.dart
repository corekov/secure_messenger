import 'dart:convert';

void main() {
  final tokenPart = "eyJ1c2VyX2lkIjoiNmExYmYxNTEtZTBiMC00OTk0LTliMGMtZDk4Mzg4MzNlNGYxIiwiZGV2aWNlX2lkIjoiY2I1MDkwZjctYWEzZi00OGI4LTkzMmItOWU3YTliYzNiNWUxIiwiaXNzIjoiIiwic3ViIjoiIiwiYXVkIjpbXSwiZXhwIjoxNzQ4MTY0Njg4LCJuYmYiOjAsImlhdCI6MTc0ODE2MTA4OCwianRpIjoiY2JmOTMzOGYtZjlkZS00Y2E3LTgyYTctNWQwOGUyNTcyMTdhIn0";
  try {
    String normalized = base64Url.normalize(tokenPart);
    switch (normalized.length % 4) {
      case 2: normalized += '=='; break;
      case 3: normalized += '='; break;
    }
    print("Decoded: " + utf8.decode(base64Url.decode(normalized)));
  } catch (e) {
    print("Error: $e");
  }
}
