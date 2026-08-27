# Delphi Inspector

Delphi Inspector is a small, dependency-free VCL property-grid style component. It provides collapsible categories, Variant-backed property values, inline editing, and optional ellipsis buttons while retaining the native Windows/VCL visual character.

![Inspector using the Windows theme](Screenshot-1.png)
![Inspector using a VCL Style](Screenshot-3.png)

## Features

- Collapsible categories and keyboard navigation
- Editable `Variant` values (`Null` and `Empty` are displayed safely as blank text)
- Optional edit buttons for dialogs, pickers, or application-defined actions
- Drag-adjustable name/value splitter and vertical scrolling
- Selection, live-change, completed-change, button, and category events
- Buffered custom painting with VCL Styles support
- DPI-aware geometry while preserving the original 96-DPI defaults
- One self-contained source unit; no runtime dependencies beyond the VCL

## Requirements

The component targets modern Delphi versions with VCL support on Windows. It uses namespaced RTL/VCL units, class constructors, `CurrentPPI`, and inline variable declarations. Validate the unit with the oldest Delphi release you intend to support; no Delphi compiler is included in every development environment.

## Installation

1. Copy `Inspector.pas` into your project or a shared source directory.
2. Add its directory to the Delphi search path.
3. Add `Inspector` to a form unit's `uses` clause and create `TInspector` in code, **or** install the unit in a design-time package. The `Register` procedure adds it to the **ERDesigns** palette page.

No external package or library is required.

## Minimal usage

```pascal
var
  Category: TInspectorCategory;
  Item: TInspectorProperty;
begin
  Inspector1.BeginUpdate;
  try
    Category := Inspector1.Categories.Add;
    Category.Caption := 'General';

    Item := Category.Properties.Add;
    Item.Name := 'Caption';
    Item.Value := 'Example';

    Item := Category.Properties.Add;
    Item.Name := 'Color';
    Item.Value := 'clWindow';
    Item.EditButton := True;
  finally
    Inspector1.EndUpdate;
  end;
end;
```

See [`examples/InspectorDemo`](examples/InspectorDemo) for a minimal code-only VCL application containing editable and edit-button properties, an initially collapsed category, and event handlers.

For programmatic navigation, assign `Selected` and call `EnsureSelectedVisible`, or use
the typed `SelectedProperty` and `SelectedCategory` accessors. `ExpandAll` and
`CollapseAll` update every category in one buffered operation. The inspector also
publishes the usual VCL appearance, hint, popup-menu, keyboard, mouse, focus, and
visibility properties/events for convenient use at design time.

## Events

- `OnPropertySelect` — a property became selected.
- `OnPropertyChange` — inline text changed and was written to `Value`.
- `OnPropertyChanged` — the editor lost focus after an edit session.
- `OnPropertyButtonClick` — the ellipsis button was clicked.
- `OnCategorySelect`, `OnCategoryCollapse`, and `OnCategoryExpand` — category interaction notifications.

Editing intentionally writes display text back to the public `Variant` value, preserving the component's established behavior. Applications that need typed parsing can do so in the change events.

## Styling and customization

`CategoryOptions`, `PropertyOptions`, `GutterOptions`, and `Splitter` expose the original fonts, colors, dimensions, focus rectangle, cursor, and splitter position. System colors are resolved through VCL style services. Add any desired style to the host executable in Delphi and activate it normally with `TStyleManager`; the component needs no style-specific setup.

Dimensions retain their original meaning at 96 DPI and are scaled using the control's current PPI for per-monitor DPI scenarios. The inline editor and button are repositioned whenever layout or scrolling changes.

## Screenshots

The repository retains all original screenshots: [Windows 1](Screenshot-1.png), [Windows 2](Screenshot-2.png), [VCL Style 1](Screenshot-3.png), and [VCL Style 2](Screenshot-4.png).

## License and maintenance

The repository does not currently include a license file. Consequently, no license grant should be inferred; contact the repository owner before redistribution. The component is maintained as a compact reusable VCL control rather than a framework or component suite.
