## Weapon Type Formatting Fix

### Problem
Weapon types were displaying with underscores (e.g., "crossbow_hand", "battleaxe_two_handed") instead of readable, spaced names (e.g., "Crossbow Hand", "Battleaxe Two Handed").

### Solution Implemented

#### 1. Added Formatted Type Getter to Weapon Model
**File**: `lib/models/weapon_model.dart`
```dart
String get formattedType {
  // Convert underscore-separated names to readable format
  return type
      .split('_')
      .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
      .join(' ');
}
```

#### 2. Updated WeaponsViewModel
**File**: `lib/viewmodels/weapons_viewmodel.dart`
- Added `getAvailableFormattedTypes()` method for display purposes
- Added `getFormattedTypeForFilter()` method to convert formatted types back to raw types for filtering
- Maintains backward compatibility with existing filter logic

#### 3. Updated Weapons Screen UI
**File**: `lib/views/information/weapons_screen.dart`
- **Weapon Cards**: Now display `weapon.formattedType` instead of `weapon.type`
- **Detail Sheet**: Uses formatted type in weapon details
- **Filter Dialog**: Shows formatted types in radio buttons
- **Filter Display**: Shows formatted type in active filter chips
- **Helper Method**: Added `_getFormattedSelectedType()` for proper type mapping

### Examples of Transformations
- `crossbow_hand` → `Crossbow Hand`
- `longsword` → `Longsword`
- `battleaxe_two_handed` → `Battleaxe Two Handed`
- `dagger` → `Dagger`
- `warhammer_two_handed` → `Warhammer Two Handed`

### Testing
Created comprehensive test suite (`test/weapon_formatted_type_test.dart`) that verifies:
- ✅ Underscore conversion to spaces
- ✅ Proper capitalization of each word
- ✅ Handling of single-word types
- ✅ Graceful handling of empty types
- ✅ Multiple underscore separation

### Benefits
- **Better UX**: Users see readable, properly formatted weapon types
- **Consistent Display**: All type displays now use the same formatting
- **Backward Compatible**: Filter logic still works with raw type data
- **Maintainable**: Single source of truth for type formatting

### Files Modified
1. `lib/models/weapon_model.dart` - Added formattedType getter
2. `lib/viewmodels/weapons_viewmodel.dart` - Added formatted type methods
3. `lib/views/information/weapons_screen.dart` - Updated UI to use formatted types

The fix ensures that weapon types are displayed in a user-friendly format throughout the weapons screen while maintaining all existing functionality.
