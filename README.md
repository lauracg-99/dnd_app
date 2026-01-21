# D&D Character Manager App

A comprehensive Flutter mobile application for managing Dungeons & Dragons 5th Edition characters, spells, and game references.

## 🎯 Features

### Character Management
- **Complete Character Creation**: Create new D&D 5E characters with all essential attributes
- **Advanced Character Editing**: Comprehensive character sheet with tabbed interface
- **Persistent Storage**: Characters are saved locally and persist between app sessions
- **Character Search & Filtering**: Find characters quickly with search and class-based filters
- **Custom Character Images**: Add personal images to character profiles

#### Character Attributes Supported:
- **Basic Info**: Name, Level, Class, Subclass, Race, Background
- **Ability Scores**: Strength, Dexterity, Constitution, Intelligence, Wisdom, Charisma
- **Health & Combat**: HP (max/current/temp), Hit Dice, Armor Class, Speed, Death Saves
- **Skills & Saving Throws**: Complete skill check system and saving throw modifiers
- **Spellcasting**: Spell slots, prepared spells, spell list management
- **Equipment**: Items, money, languages
- **Character Development**: Backstory, quick guide, feat notes
- **Roleplaying Elements**: Character pillars (gimmick, quirk, wants, needs, conflict)
- **Appearance**: Height, age, eye color, additional details, custom images

### Spell Database
- **540+ D&D Spells**: Comprehensive spell database from official sources
- **Advanced Search**: Find spells by name, class, level, school, and more
- **Detailed Spell Information**: 
  - Casting time, range, duration
  - Components (V, S, M)
  - Ritual capabilities
  - Class availability
  - Full descriptions
- **Filter System**: Filter by level, school, class, and casting components

### Game Reference Library
- **Feats Database**: 148+ character feats with prerequisites and descriptions
- **Classes Guide**: 16 D&D classes with features and progression information
- **Races Compendium**: 101+ races with traits and abilities
- **Backgrounds Library**: 91+ character backgrounds with features
- **Equipment Database**: Items and equipment reference

### User Interface
- **Modern Material Design**: Clean, intuitive interface following Material 3 guidelines
- **Bottom Navigation**: Easy switching between Characters, Spells, and Information
- **Tabbed Character Sheets**: Organized character information in logical tabs
- **Enhanced Mobile Experience**: 
  - Keyboard navigation with next/previous buttons
  - Custom keyboard actions for form fields
  - Responsive design for all screen sizes
- **Search & Filter**: Advanced search capabilities across all data types

## 🛠 Technology Stack

### Core Framework
- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language
- **Provider**: State management solution

### Key Dependencies
- **path_provider**: Local file system access for character storage
- **image_picker**: Camera and gallery access for character images
- **keyboard_actions**: Enhanced keyboard navigation for forms
- **flutter_launcher_icons**: App icon generation

### Data Management
- **Local Storage**: Characters stored locally using file system
- **JSON Data**: Game reference data (spells, feats, classes, races, backgrounds)
- **Memory Caching**: Efficient data loading and caching
- **Cross-Platform Storage**: Adaptive storage for mobile, desktop, and web

## 📱 Platform Support

- **iOS**: Native iOS app with full feature support
- **Android**: Native Android app with full feature support  
- **Web**: Web version with memory-based storage
- **Desktop**: Windows, macOS, and Linux support

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.7.0)
- Dart SDK
- Android Studio / Xcode for mobile development

### Installation

1. Clone the repository:
```bash
git clone https://github.com/lauracg-99/dnd_app.git
cd dnd_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Build for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web
```

## 📊 App Structure

### Core Components
- **Models**: Data structures for characters, spells, feats, classes, races, backgrounds
- **Services**: Business logic for data management and storage
- **ViewModels**: State management using Provider pattern
- **Views**: UI screens and components
- **Assets**: Game reference data in JSON format

### Data Sources
The app includes comprehensive D&D 5E reference data:
- **540 Spells**: From cantrips to 9th level spells
- **148 Feats**: Character customization options
- **16 Classes**: All official D&D classes
- **101 Races**: Including subraces and variants
- **91 Backgrounds**: Character backstory options

## 🧪 Testing

The app includes comprehensive test coverage:
- **Unit Tests**: Model validation and business logic
- **Widget Tests**: UI component testing
- **Integration Tests**: Complete user flows

Run tests:
```bash
flutter test
```

## 🔧 Development

### Code Style
- Follows Flutter/Dart conventions
- Material 3 design principles
- Provider pattern for state management
- Clean architecture with separated concerns

### Key Features Implementation
- **Character Service**: Handles character persistence and retrieval
- **Storage Abstraction**: Works across platforms (file system, memory)
- **Image Management**: Custom character image handling
- **Form Navigation**: Enhanced keyboard experience with keyboard_actions
- **Search Architecture**: Efficient filtering and search across large datasets

## 📈 Future Enhancements

- [ ] Cloud synchronization for characters
- [ ] Character export/import functionality
- [ ] Spell management integration with character sheets
- [ ] Dice roller integration
- [ ] Initiative tracker
- [ ] Campaign management features
- [ ] Multi-language support

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Dungeons & Dragons 5th Edition rules and content
- Flutter community and contributors
- Open-source D&D data sources

---

**Built with ❤️ for D&D enthusiasts**

