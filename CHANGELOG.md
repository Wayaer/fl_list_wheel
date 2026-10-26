# Changelog

## 1.0.0

First stable release, built on Flutter 3.47 / Dart 3.13.

### Added

- `FlPickerPresenter` / `FlBottomSheetPickerPresenter` / `FlPickerSession`: one global presenter now opens the sheet and
  installs a session so confirm/cancel closes the correct route. Every `show()` also accepts a per-call `presenter`.
- Chinese API documentation for all public widgets, parameters and typedefs.
- A complete English usage guide in `README.md`, including presenter options, per-call presenters, inline
  `FlPickerSession` usage, migration notes and a web demo link.
- A responsive example gallery covering every picker, with inline previews, themed bottom sheets and result panels.
  The `Presentation` demo shows the global presenter, a custom Cupertino presenter and an inline dialog session.

### Improved

- Material and custom wheels now use `FixedExtentScrollPhysics` by default, so they snap to whole items like
  `CupertinoPicker`. Pass another `physics` to `FlWheelOptions` to opt out.
- `FlListWheelState` clamps the initial item, keeps the current selection when the parent rebuilds, only disposes the
  controller it created itself, and applies `initialItem` changes after the controller attaches.
- `FlSingleListPicker` keeps its initial selection when confirming without interaction, ignores out-of-range or duplicated
  initial indices, and re-clamps them when `itemCount` changes.
- `FlMultiListWheelPicker` keeps selections across rebuilds, clamps out-of-range positions and supports horizontal
  scrolling.
- `FlMultiListLinkagePicker` honours the initial `value` and clamps positions against the current data.
- `FlMultiListWheelLinkagePicker` only resets when `value` changes, keeps column keys stable, resets lower columns when a
  parent column changes, and notifies `onChanged` synchronously before rebuilding child columns.
- `FlPickerSubject` allows `backgroundColor` and `decoration` together (`decoration` wins), uses a 1:3:1 header layout and
  closes through the `FlPickerSession` installed by the presenter.
- `FlDateTimePicker` centers each number/unit pair as a compact group, so two-column time pickers no longer spread the
  columns and their unit labels across the full sheet width.
- `DateTimePicker` computes days in month without DST issues, clamps the day index when the month changes and guards
  controller jumps that are not attached yet.
- `FlSingleListWheelPicker` owns and disposes its controller; the constructor is now `const`. Its `itemWidth` is
  honoured, an out-of-range `initialIndex` is clamped, and confirming an empty `itemCount` returns `null`.
- `FlSingleListPicker` in single-choice mode keeps at most one initial selection, and `FlSingleListPickerOptions` gains
  an `itemExtent` for fixed-height rows.
- `FlMultiListWheelLinkagePicker` rebuilds child columns after the current frame instead of a fixed 50 ms delay.
- `FlMultiListLinkagePicker` gains an `itemExtent` for fixed-height rows.
- `FlPickerSubject` merges the theme text style instead of replacing it, marks the cancel/confirm areas as buttons for
  screen readers, and aligns them with `AlignmentDirectional` for RTL layouts.
- `FlListWheel.presenter` can be cleared together with the global wheel options via the new `FlListWheel.reset()`.
- `FlDatePicker` reports the initial value through `onChanged` after the first frame, matching `FlDateTimePicker`, and
  asserts in debug mode when the range exceeds 200 years.
- The iOS example app is named `FlListWheel` on the home screen.
- Example wheels use a taller item extent and smaller text so labels are not clipped while scrolling.

### Changed

- All public classes, typedefs and extensions now use the `Fl` prefix, for example `FlDatePicker`,
  `FlDateTimePicker`, `FlPickerOptions`, `FlWheelOptions`, `FlSingleListPicker`, `FlPickerPresenter`,
  `FlPickerSession`, `FlSelectIndexedChangedFunction` and `FlDatePickerExtension`, so they are easy to recognise
  and less likely to clash with other packages. Update your type references when upgrading.
- `FlWheelOptions.merge` no longer copies `isCupertino` from the overriding options: a plain `FlWheelOptions(...)` used
  to tweak a single wheel silently switched the global Cupertino style to Material. Change the style globally via
  `FlListWheel.wheelOptions` (or construct a complete `FlWheelOptions`) instead.
- `FlListWheel.showPicker` is now `async`, so a missing presenter surfaces as a failed `Future` instead of a
  synchronous throw.
- `FlListWheel.onNotification` now returns the callback's result, so returning `true` stops the notification from
  bubbling.
- `FlPickerSubjectTapCallback` returns `T?`; returning `null` treats the result as "no selectable value". Existing
  implementations that return `T` keep working.
- Removed unused APIs: `PickerStatelessWidget`, `DatePickerUnitBuilder`, `FlDatePickerUnit.getLength()`,
  `FlDateTimePickerUnit.length`, `FlPickerLinkageItem.toMap()` and `FlSelectIndexedChanged`.

### Fixed

- `FlDatePicker` confirmation could read a stale position when the sheet was dismissed right after scrolling.
- `FlDatePicker` without a year column showed duplicate months such as multiple `01` when the range crossed years.
- `FlDatePicker` could not select a `defaultDate` in a later year, or in the first month of a year.
- `FlDatePicker` day generation is DST-safe, and the result is built from the selected date instead of parsed text
  (fixes `dual: false`).
- `DateTime.getDaysForRange` iterates calendar days instead of adding 24-hour durations.
- `FlDateTimePicker` clamps the confirmed time into `[startDate, endDate]`, so hiding the month column can no longer
  return an out-of-range value.
- `FlSingleListPicker` no longer reports an out-of-range index after `itemCount` shrinks; selection state now has a
  single source of truth.
- `FlMultiListWheelPicker` returns `null` when any column has `itemCount: 0`, because no valid index exists for that
  column.
- `FlDatePicker` rebuilds its options when `itemBuilder` changes, instead of keeping the old labels.
- `FlListWheel` scroll callbacks report the real item index with or without a controller.
- `FlPickerSubject` no longer falls back to Flutter's debug text style (monospace with a yellow underline) when a custom
  presenter such as `showCupertinoModalPopup` provides no Material text context.
- `FlCustomPicker.show()` is generic (`FlCustomPicker<T>`), so the confirmed value keeps its type.

### Compatibility

- Requires Flutter 3.47 or newer and Dart 3.13.
- `FlListWheel.push` / `FlListWheel.pop` were removed. Assign
  `FlListWheel.presenter = FlBottomSheetPickerPresenter(...)` once instead; `.show()` still works without a `BuildContext`.
- `flutter_lints` 6, a 120-column formatter and `always_use_package_imports` in both the package and the example.

## 0.0.4

- Migrated to Flutter 3.47 / Dart 3.13, upgraded `flutter_lints` to 6 and rewrote the example as a responsive gallery.
- Various picker fixes and lifecycle improvements; see the 1.0.0 notes above for the consolidated list.

## 0.0.3

- Update version.

## 0.0.2

- Change the `padding` of `FlPickerOptions` to `titlePadding`.

## 0.0.1

- Initialization package.
