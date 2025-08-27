# Annonce Page Updates

## Tasks to Complete:

1. **Username Display**: ✓ Already implemented - retrieves and displays username
2. **Restrict "Voir Plus" Button**: Add logic to restrict the "Voir Plus" button based on user status or other conditions
3. **Photo Handling**: Improve CircleAvatar to use colors that match the green theme instead of hardcoded grey/white
4. **Style Consistency**: Apply the same styling to culture type as the quantity field

## Implementation Details:

### Photo Handling:
- Replace hardcoded grey background with colors that complement the green theme
- Use a color palette that works well with AppColors.primaryGreen
- Generate background color based on user's first letter for consistency

### Button Restriction:
- Add logic to disable "Voir Plus" button based on:
  - User authentication status
  - Announcement status (validé vs pending)
  - User permissions

### Style Consistency:
- Apply the same text styling to typeCultureLibelle as the quantity field
- Use consistent colors and font weights

## Colors for Avatar Backgrounds:
- Create a list of colors that complement the green theme
- Use colors like: light green, teal, olive, sage green, etc.
- Generate color based on first letter for consistency
