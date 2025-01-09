# User Information Form with Location Access

This Flutter application collects user information through a form and retrieves their current location to display the address. The app includes validation for user input and integrates geolocation functionality.

## Features
- **Form Validation**: Ensures the correctness of name, email, and phone number inputs.
- **Geolocation Access**: Retrieves and displays the user's current latitude, longitude, and address.
- **Notification**: Displays a local notification with the user's name and location details.
- **User-Friendly UI**: Designed with Flutter's Material components for a clean, intuitive interface.

## Technologies Used
- **Flutter**: Frontend framework for building the UI.
- **Geolocator Package**: For accessing the device's location.
- **Geocoding Package**: For reverse geocoding coordinates into a human-readable address.
- **Local Notifications**: For sending user notifications.

## Installation

1. **Clone the Repository**:
    ```bash
    git clone <https://github.com/kartik17k/location>
    ```

2. **Navigate to the Project Directory**:
    ```bash
    cd <Location>
    ```

3. **Install Dependencies**:
    ```bash
    flutter pub get
    ```

4. **Run the Application**:
    ```bash
    flutter run
    ```

## Folder Structure
- `lib/`
  - `main.dart`: Entry point of the application.
  - `service/`
    - `firestore.dart`: Handles Firestore integration for saving user data.
    - `localNotification.dart`: Configures and sends local notifications.
  - `theme/`
    - `color.dart`: Contains theme-related color definitions.
  - `pages/`
    - `home.dart`: The main screen for the user form and location retrieval.

## How It Works

1. **Form Input**:
   - Users provide their name, email, and phone number.
   - The input is validated to ensure correctness (e.g., valid email format, 10-digit phone number).

2. **Location Retrieval**:
   - On app start, the app checks for location permissions.
   - If permissions are granted, it fetches the user's current latitude and longitude.
   - The coordinates are reverse geocoded into an address.

3. **Form Submission**:
   - On form submission, the user details and location data are saved to Firestore.
   - A local notification is sent with a personalized message.

4. **Reset Functionality**:
   - Users can reset the form fields by clicking the reset button.

## Customization
- **Colors**:
  - The application's theme colors can be customized in `color.dart`.
- **Location Accuracy**:
  - Modify the accuracy of location retrieval in `_getCurrentPosition()`.
- **Notification Content**:
  - Adjust the notification message in `_submitForm()`.

## Dependencies
- `geolocator`: Location services.
- `geocoding`: Address retrieval.
- `flutter_local_notifications`: Local notification support.

## Screenshots
<p align="center">
  <img src="https://github.com/user-attachments/assets/bf188d2a-fc72-4ec1-891c-19b56b1fbd9c" alt="Screenshot 1" width="45%" />
  <img src="https://github.com/user-attachments/assets/a12015dd-dbd7-4651-bf2c-5e974e742aad" alt="Screenshot 2" width="45%" />
</p>

## Known Issues
- Ensure location services are enabled on the device.
- Grant location permissions to avoid errors.

## Future Enhancements
- Add persistent storage for user data.
- Allow users to edit submitted information.
- Implement light mode support.

## License
This project is licensed under the MIT License.
