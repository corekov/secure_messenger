class ErrorFormatter {
  static String formatBackendError(dynamic errorData) {
    if (errorData == null) return 'An unknown error occurred';
    
    if (errorData is Map) {
      if (errorData.containsKey('error')) {
        final errorString = errorData['error'].toString();
        
        // Handle Go validator output (e.g., Key: 'LoginRequest.Username' Error:Field validation for 'Username' failed on the 'required' tag)
        if (errorString.contains('failed on the \'required\' tag') || errorString.contains('Error:Field validation for')) {
          final List<String> missingFields = [];
          
          if (errorString.contains('\'Username\' failed')) {
            missingFields.add('Username is required');
          }
          if (errorString.contains('\'Password\' failed')) {
            missingFields.add('Password is required');
          }
          if (errorString.contains('\'Device_name\' failed') || errorString.contains('\'DeviceName\' failed')) {
            missingFields.add('Device name is required');
          }
          
          if (missingFields.isNotEmpty) {
            return missingFields.join('\n');
          }
          return 'Please fill in all required fields';
        }
        
        if (errorString == 'record not found' || errorString.contains('user not found') || errorString.contains('invalid credentials')) {
          return 'Invalid username or password';
        }
        
        if (errorString.contains('crypto/bcrypt')) {
          return 'Invalid password';
        }
        
        if (errorString.contains('unique constraint') || errorString.contains('duplicate key')) {
          return 'Username is already taken';
        }
        
        return errorString;
      }
      return errorData.toString();
    }
    
    return errorData.toString();
  }
}
