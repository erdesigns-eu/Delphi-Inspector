unit Main;

interface

uses
  System.Classes, System.SysUtils, System.Variants, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  Vcl.Themes, Inspector;

type
  /// <summary>Minimal, code-only demonstration form for TInspector.</summary>
  TMainForm = class(TForm)
  private
    FInspector: TInspector;
    FStatus: TLabel;
    FStyleSelector: TComboBox;
    /// <summary>Applies a VCL Style selected from the styles linked into the host.</summary>
    procedure StyleChanged(Sender: TObject);
    /// <summary>Reports selection changes below the inspector.</summary>
    procedure PropertySelected(const AProperty: TInspectorProperty);
    /// <summary>Reports completed inline edits below the inspector.</summary>
    procedure PropertyChanged(const AProperty: TInspectorProperty);
    /// <summary>Reports live inline edits below the inspector.</summary>
    procedure PropertyChanging(const AProperty: TInspectorProperty);
    /// <summary>Demonstrates handling an edit-button property.</summary>
    procedure PropertyButtonClick(const AProperty: TInspectorProperty);
    /// <summary>Reports that a category was collapsed.</summary>
    procedure CategoryCollapsed(const ACategory: TInspectorCategory);
    /// <summary>Reports that a category was expanded.</summary>
    procedure CategoryExpanded(const ACategory: TInspectorCategory);
    /// <summary>Adds one property to a category.</summary>
    procedure AddProperty(const ACategory: TInspectorCategory; const AName: string;
      const AValue: Variant; const AEditorKind: TInspectorEditorKind = iekText;
      const AEditButton: Boolean = False);
  public
    /// <summary>Creates and populates the demonstration UI.</summary>
    constructor Create(AOwner: TComponent); override;
  end;

var
  MainForm: TMainForm;

implementation

uses
  Vcl.Dialogs;

constructor TMainForm.Create(AOwner: TComponent);
var
  Category: TInspectorCategory;
  InspectorProperty: TInspectorProperty;
  StyleName: string;
begin
  inherited CreateNew(AOwner);
  Caption := 'Delphi Inspector Demo';
  ClientWidth := 520;
  ClientHeight := 380;
  Position := poScreenCenter;

  FStatus := TLabel.Create(Self);
  FStatus.Parent := Self;
  FStatus.Align := alBottom;
  FStatus.Height := 28;
  FStatus.Caption := 'Select or edit a property.';

  FStyleSelector := TComboBox.Create(Self);
  FStyleSelector.Parent := Self;
  FStyleSelector.Align := alTop;
  FStyleSelector.Style := csDropDownList;
  for StyleName in TStyleManager.StyleNames do
    FStyleSelector.Items.Add(StyleName);
  FStyleSelector.ItemIndex := FStyleSelector.Items.IndexOf(
    TStyleManager.ActiveStyle.Name);
  FStyleSelector.OnChange := StyleChanged;

  FInspector := TInspector.Create(Self);
  FInspector.Parent := Self;
  FInspector.Align := alClient;
  FInspector.OnPropertySelect := PropertySelected;
  FInspector.OnPropertyChange := PropertyChanging;
  FInspector.OnPropertyChanged := PropertyChanged;
  FInspector.OnPropertyButtonClick := PropertyButtonClick;
  FInspector.OnCategoryCollapse := CategoryCollapsed;
  FInspector.OnCategoryExpand := CategoryExpanded;

  FInspector.BeginUpdate;
  try
    Category := FInspector.Categories.Add;
    Category.Caption := 'Appearance';
    AddProperty(Category, 'Caption', 'Inspector demo');
    AddProperty(Category, 'Enabled', True, iekBoolean);
    AddProperty(Category, 'Opacity', 85.5, iekNumber);
    AddProperty(Category, 'Created', Date, iekDate);
    AddProperty(Category, 'Accent color', 'Blue', iekText, True);

    InspectorProperty := Category.Properties.Add;
    InspectorProperty.Name := 'Alignment';
    InspectorProperty.EditorKind := iekDropDown;
    InspectorProperty.DropDownItems.Add('Left');
    InspectorProperty.DropDownItems.Add('Center');
    InspectorProperty.DropDownItems.Add('Right');
    InspectorProperty.Value := 'Left';

    Category := FInspector.Categories.Add;
    Category.Caption := 'Layout (collapsed initially)';
    Category.Collapsed := True;
    AddProperty(Category, 'Width', 520);
    AddProperty(Category, 'Height', 380);
  finally
    FInspector.EndUpdate;
  end;
end;

procedure TMainForm.StyleChanged(Sender: TObject);
begin
  if FStyleSelector.ItemIndex >= 0 then
    TStyleManager.TrySetStyle(FStyleSelector.Items[FStyleSelector.ItemIndex]);
end;

procedure TMainForm.AddProperty(const ACategory: TInspectorCategory;
  const AName: string; const AValue: Variant;
  const AEditorKind: TInspectorEditorKind; const AEditButton: Boolean);
var
  InspectorProperty: TInspectorProperty;
begin
  InspectorProperty := ACategory.Properties.Add;
  InspectorProperty.Name := AName;
  InspectorProperty.Value := AValue;
  InspectorProperty.EditorKind := AEditorKind;
  InspectorProperty.EditButton := AEditButton;
end;

procedure TMainForm.PropertySelected(const AProperty: TInspectorProperty);
begin
  FStatus.Caption := 'Selected: ' + AProperty.Name;
end;

procedure TMainForm.PropertyChanged(const AProperty: TInspectorProperty);
begin
  FStatus.Caption := 'Changed: ' + AProperty.Name;
end;

procedure TMainForm.PropertyChanging(const AProperty: TInspectorProperty);
begin
  FStatus.Caption := 'Editing: ' + AProperty.Name + ' = ' +
    VarToStr(AProperty.Value);
end;

procedure TMainForm.PropertyButtonClick(const AProperty: TInspectorProperty);
var
  NewValue: string;
begin
  NewValue := VarToStr(AProperty.Value);
  if InputQuery('Edit ' + AProperty.Name, 'Value', NewValue) then
    AProperty.Value := NewValue;
end;

procedure TMainForm.CategoryCollapsed(const ACategory: TInspectorCategory);
begin
  FStatus.Caption := 'Collapsed: ' + ACategory.Caption;
end;

procedure TMainForm.CategoryExpanded(const ACategory: TInspectorCategory);
begin
  FStatus.Caption := 'Expanded: ' + ACategory.Caption;
end;

end.
