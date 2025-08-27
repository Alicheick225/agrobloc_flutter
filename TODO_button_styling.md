# Button Styling Implementation Plan

## Steps to Complete:
1. [x] Add state variables to track clicked buttons
2. [x] Create click handler functions for each button
3. [x] Update button styles to use conditional styling
4. [ ] Test the implementation

## Current State:
- Buttons: White background with green text by default
- When clicked: Green background with white text (inverse colors)

## Files Modified:
- lib/core/features/Agrobloc/presentations/widgets/producteurs/homes/annoncePage.dart

## Implementation Details:
- Added `_selectedButtonIndex` state variable to track which button is selected
- Updated each button's `onPressed` to set the selected index
- Modified button styles to use conditional colors:
  - Default: White background, green text
  - Clicked: Green background, white text
- Only one button can be selected at a time
