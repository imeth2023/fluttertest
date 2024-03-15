// Importing the shared_preferences package
import 'package:shared_preferences/shared_preferences.dart';

// Defining a class named PreferencesService
class PreferencesService {
  // A method to save the theme preference
  Future<void> saveThemePreference(bool isDarkMode) async {
    // Getting an instance of SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // Saving the isDarkMode value to SharedPreferences
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  // A method to get the theme preference
  Future<bool> getThemePreference() async {
    // Getting an instance of SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // Returning the isDarkMode value from SharedPreferences, defaulting to false if it's null
    return prefs.getBool('isDarkMode') ?? false;
  }
}
