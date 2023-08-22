{*******************************************************}
{                                                       }
{           TInspector                                  }
{           Author: Ernst Reidinga                      }
{                                                       }
{           Inspector like component with categories,   }
{           inline editor and button. VCL Styles        }
{           are supported.                              }
{                                                       }
{           Version: 1.0                                }
{           Date   : 22/08/2023                         }
{                                                       }
{           Version History:                            }
{           - 1.0.0.0                                   }
{                                                       }
{*******************************************************}

unit Inspector;

interface

uses
  WinApi.Windows, WinApi.Messages, System.SysUtils, System.Classes, Vcl.Controls,
  Vcl.Themes, Vcl.Graphics, System.Types, Vcl.StdCtrls;

const
  MinimalHeight = 16;
  MinimalWidth  = 16;

const
  CategoryHeight = 22;
  CategoryColor  = clBtnFace;

const
  PropertyHeight = 20;

const
  GutterWidth  = 18;
  GutterColor  = clBtnFace;

const
  SplitterColor  = clBtnFace;
  SplitterCursor = crSizeWE;
  SplitterLeft   = 130;

const
  TextOffset  = 2;
  ButtonWidth = 20;

type
  TInspectorProperty = class;
  TInspectorCategory = class;

  TInspectorPropertyEvent = procedure(const &Property: TInspectorProperty) of object;
  TInspectorCategoryEvent = procedure(const Category: TInspectorCategory) of object;

  TInspectorPropertyEdit = class(TCustomEdit)
  private
    FInspectorProperty: TInspectorProperty;
  public
    constructor Create(AOwner: TComponent); override;
    property InspectorProperty: TInspectorProperty read FInspectorProperty write FInspectorProperty;
  public
    procedure UpdateEditHeight;
    procedure UpdateEditorPosition(const Rect: TRect);
    procedure SetEditorActive(const Rect: TRect; const Value: string);
    procedure SetEditorInActive;
  end;

  TInspectorPropertyEditButton = class(TButton)
  public
    procedure UpdateEditorPosition(const Rect: TRect);
    procedure SetEditorActive(const Rect: TRect);
    procedure SetEditorInActive;
  end;

  TInspectorProperty = class(TCollectionItem)
  private
    FName: string;
    FValue: Variant;
    FEditButton: Boolean;
    FTag: Integer;

    FRect: TRect;
    FSelectRect: TRect;
    FEditorRect: TRect;
    procedure SetName(const Name: string);
    procedure SetValue(const Value: Variant);
    procedure SetEditButton(const Button: Boolean);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;

    property Rect: TRect read FRect write FRect;
    property SelectRect: TRect read FSelectRect write FSelectRect;
    property EditorRect: TRect read FEditorRect write FEditorRect;
  published
    property Name: string read FName write SetName;
    property Value: Variant read FValue write SetValue;
    property EditButton: Boolean read FEditButton write SetEditButton default False;
    property Tag: Integer read FTag write FTag;
  end;

  TInspectorPropertyCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;

    function GetItem(Index: Integer): TInspectorProperty;
    procedure SetItem(Index: Integer; Value: TInspectorProperty);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    function Add: TInspectorProperty;
    procedure Assign(Source: TPersistent); override;

    property Items[Index: Integer]: TInspectorProperty read GetItem write SetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TInspectorCategory = class(TCollectionItem)
  private
    FCaption: TCaption;
    FCollapsed: Boolean;
    FProperties: TInspectorPropertyCollection;
    FRect: TRect;
    FCollapseRect: TRect;

    procedure SetCaption(const Caption: TCaption);
    procedure SetCollapsed(Collapsed: Boolean);
  protected
    procedure PropertiesChanged(Sender: TObject);
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    property Rect: TRect read FRect write FRect;
    property CollapseRect: TRect read FCollapseRect write FCollapseRect;
  published
    property Caption: TCaption read FCaption write SetCaption;
    property Collapsed: Boolean read FCollapsed write SetCollapsed default False;
    property Properties: TInspectorPropertyCollection read FProperties write FProperties;
  end;

  TInspectorCategoryCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;

    function GetItem(Index: Integer): TInspectorCategory;
    procedure SetItem(Index: Integer; Value: TInspectorCategory);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    function Add: TInspectorCategory;
    procedure Assign(Source: TPersistent); override;

    property Items[Index: Integer]: TInspectorCategory read GetItem write SetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TInspectorCategoryOptions = class(TPersistent)
  private
    FOnChange: TNotifyEvent;
    FHeight: Integer;
    FColor: TColor;
    FShowFocusRect: Boolean;
    FFont: TFont;

    procedure SetHeight(Height: Integer);
    procedure SetColor(Color: TColor);
    procedure SetShowFocusRect(Show: Boolean);
  protected
    procedure FontChanged(Sender: TObject);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
  published
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Height: Integer read FHeight write SetHeight default CategoryHeight;
    property Color: TColor read FColor write SetColor default CategoryColor;
    property ShowFocusRect: Boolean read FShowFocusRect write SetShowFocusRect default True;
    property Font: TFont read FFont write FFont;
  end;

  TInspectorPropertyOptions = class(TPersistent)
  private
    FOnChange: TNotifyEvent;
    FHeight: Integer;
    FFont: TFont;

    procedure SetHeight(Height: Integer);
  protected
    procedure FontChanged(Sender: TObject);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
  published
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Height: Integer read FHeight write SetHeight default PropertyHeight;
    property Font: TFont read FFont write FFont;
  end;

  TInspectorGutterOptions = class(TPersistent)
  private
    FOnChange: TNotifyEvent;
    FWidth: Integer;
    FColor: TColor;

    procedure SetWidth(Width: Integer);
    procedure SetColor(Color: TColor);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
  published
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Width: Integer read FWidth write SetWidth default GutterWidth;
    property Color: TColor read FColor write SetColor default GutterColor;
  end;

  TInspectorSplitter = class(TPersistent)
  private
    FOnChange: TNotifyEvent;
    FColor: TColor;
    FCursor: TCursor;
    FLeft: Integer;
    FRect: TRect;

    procedure SetColor(Color: TColor);
    procedure SetCursor(Cursor: TCursor);
    procedure SetLeft(Left: Integer);
  public
    public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    property Rect: TRect read FRect write FRect;
  published
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Color: TColor read FColor write SetColor default SplitterColor;
    property Cursor: TCursor read FCursor write SetCursor default SplitterCursor;
    property Left: Integer read FLeft write SetLeft default SplitterLeft;
  end;

  TInspector = class(TCustomControl)
  private
    class constructor Create;
    class destructor Destroy;
  private
    FOnPropertySelect      : TInspectorPropertyEvent;
    FOnPropertyChange      : TInspectorPropertyEvent;
    FOnPropertyChanged     : TInspectorPropertyEvent;
    FOnPropertyButtonClick : TInspectorPropertyEvent;

    FOnCategorySelect   : TInspectorCategoryEvent;
    FOnCategoryCollapse : TInspectorCategoryEvent;
    FOnCategoryExpand   : TInspectorCategoryEvent;

    FBuffer       : TBitmap;
    FItemBuffer   : TBitmap;
    FUpdateRect   : TRect;
    FOldScrollPos : Integer;
    FScrollPos    : Integer;
    FUpdateCount  : Integer;
    FOldHeight    : Integer;

    FSplitterMouseDown: Boolean;
    FSelectedMouseDown: Boolean;
    FSelected: TCollectionItem;

    FCategories: TInspectorCategoryCollection;
    FCategoryOptions: TInspectorCategoryOptions;
    FPropertyOptions: TInspectorPropertyOptions;
    FGutterOptions: TInspectorGutterOptions;
    FSplitter: TInspectorSplitter;

    FInspectorEditActive: Boolean;
    FInspectorEditButtonActive: Boolean;
    FInspectorEdit: TInspectorPropertyEdit;
    FInspectorEditButton: TInspectorPropertyEditButton;

    procedure SetSelected(const Item: TCollectionItem);
    procedure OnPropertyEditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OnPropertyEditorExit(Sender: TObject);
    procedure OnPropertyEditorChange(Sender: TObject);
    procedure OnPropertyEditorButtonClick(Sender: TObject);

    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMEraseBkGnd(var Msg: TWMEraseBkGnd); message WM_ERASEBKGND;
    procedure WMPaletteChanged(var Message: TMessage); message WM_PALETTECHANGED;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMGetDLGCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMSysColorChange(var Message: TMessage); message CM_SYSCOLORCHANGE;
  protected
    procedure CategoriesChanged(Sender: TObject);
    procedure OptionsChanged(Sender: TObject);
    procedure UpdateRects;
    procedure UpdateBuffer;

    procedure UpdateStyleElements; override;
    procedure WndProc(var Message: TMessage); override;
    procedure ScrollPosUpdated;
    function ScrollOffsetRect(const Rect: TRect): TRect;

    procedure Paint; override;
    procedure CreateParams(var Params: TCreateParams); override;

    procedure SelectPrevious;
    procedure SelectNext;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X: Integer; Y: Integer); override;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    procedure DblClick; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    procedure Repaint; override;
    procedure BeginUpdate; virtual;
    procedure EndUpdate; virtual;
    procedure Clear; virtual;

    property Selected: TCollectionItem read FSelected write SetSelected;
  published
    property OnPropertySelect: TInspectorPropertyEvent read FOnPropertySelect write FOnPropertySelect;
    property OnPropertyChange: TInspectorPropertyEvent read FOnPropertyChange write FOnPropertyChange;
    property OnPropertyChanged: TInspectorPropertyEvent read FOnPropertyChanged write FOnPropertyChanged;
    property OnPropertyButtonClick: TInspectorPropertyEvent read FOnPropertyButtonClick write FOnPropertyButtonClick;

    property OnCategorySelect: TInspectorCategoryEvent read FOnCategorySelect write FOnCategorySelect;
    property OnCategoryCollapse: TInspectorCategoryEvent read FOnCategoryCollapse write FOnCategoryCollapse;
    property OnCategoryExpand: TInspectorCategoryEvent read FOnCategoryExpand write FOnCategoryExpand;

    property Categories: TInspectorCategoryCollection read FCategories write FCategories;
    property CategoryOptions: TInspectorCategoryOptions read FCategoryOptions write FCategoryOptions;
    property PropertyOptions: TInspectorPropertyOptions read FPropertyOptions write FPropertyOptions;

    property GutterOptions: TInspectorGutterOptions read FGutterOptions write FGutterOptions;
    property Splitter: TInspectorSplitter read FSplitter write FSplitter;

    property Align;
    property Anchors;
    property Enabled;
    property TabStop default True;
  end;

procedure Register;

implementation

uses Vcl.Forms, System.Math;

procedure Register;
begin
  RegisterComponents('ERDesigns', [TInspector]);
end;

constructor TInspectorPropertyEdit.Create(AOwner: TComponent);
begin
  inherited Create(Aowner);
  BorderStyle := bsNone;
  UpdateEditHeight;
end;

procedure TInspectorPropertyEdit.UpdateEditHeight;
var
  DC: HDC;
  SaveFont: HFont;
  Metrics: TTextMetric;
begin
  DC := GetDC(0);
  try
    SaveFont := SelectObject(DC, Font.Handle);
    GetTextMetrics(DC, Metrics);
    SelectObject(DC, SaveFont);
  finally
    ReleaseDC(0, DC);
  end;
  Height := Metrics.tmHeight;
end;

procedure TInspectorPropertyEdit.UpdateEditorPosition(const Rect: TRect);
begin
  var RectCenter := Rect.Top + (Rect.Height div 2);
  var EditCenter := Height div 2;
  var NewTop := RectCenter - EditCenter;
  if (Top <> NewTop) then Top := NewTop;
  if (Rect.Left <> Left) then Left := Rect.Left;
  if (Rect.Width <> Width) then Width := Rect.Right - Rect.Left;
end;

procedure TInspectorPropertyEdit.SetEditorActive(const Rect: TRect; const Value: string);
begin
  if Assigned(OnExit) then OnExit(Self);
  Text := Value;
  SelectAll;
  UpdateEditorPosition(Rect);
  Visible := True;
  SetFocus;
end;

procedure TInspectorPropertyEdit.SetEditorInActive;
begin
  Visible := False;
end;

procedure TInspectorPropertyEditButton.UpdateEditorPosition(const Rect: TRect);
begin
  var RectCenter := Rect.Top + (Rect.Height div 2);
  var ButtonCenter := Height div 2;
  var NewLeft := Rect.Right - Width + TextOffset;
  var NewTop  := RectCenter - ButtonCenter + 1;
  if (Left <> NewLeft) then Left := NewLeft;
  if (Top <> NewTop) then Top := NewTop;
end;

procedure TInspectorPropertyEditButton.SetEditorActive(const Rect: TRect);
begin
  UpdateEditorPosition(Rect);
  Visible := True;
end;

procedure TInspectorPropertyEditButton.SetEditorInActive;
begin
  Visible := False;
end;

constructor TInspectorProperty.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FName := '';
  FValue := '';
end;

procedure TInspectorProperty.Assign(Source: TPersistent);
begin
  if (Source <> nil) and (Source is TInspectorProperty) then
  begin
    FName       := (Source as TInspectorProperty).Name;
    FValue      := (Source as TInspectorProperty).Value;
    FEditButton := (Source as TInspectorProperty).EditButton;
    FTag        := (Source as TInspectorProperty).Tag;
  end;
end;

procedure TInspectorProperty.SetName(const Name: string);
begin
  FName := Name;
  Changed(False);
end;

procedure TInspectorProperty.SetValue(const Value: Variant);
begin
  FValue := Value;
  Changed(False);
end;

procedure TInspectorProperty.SetEditButton(const Button: Boolean);
begin
  FEditButton := Button;
  Changed(False);
end;

function TInspectorProperty.GetDisplayName: string;
begin
  if (FName <> '') then
    Result := FName
  else
    Result := inherited;
end;

function TInspectorPropertyCollection.GetItem(Index: Integer): TInspectorProperty;
begin
  Result := inherited GetItem(Index) as TInspectorProperty;
end;

procedure TInspectorPropertyCollection.SetItem(Index: Integer; Value: TInspectorProperty);
begin
  inherited SetItem(Index, Value);
end;

function TInspectorPropertyCollection.Add: TInspectorProperty;
begin
  Result := TInspectorProperty(inherited Add);
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TInspectorPropertyCollection.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TInspectorPropertyCollection.Assign(Source: TPersistent);
var
  LI   : TInspectorPropertyCollection;
  Loop : Integer;
begin
  if (Source is TInspectorPropertyCollection)  then
  begin
    LI := TInspectorPropertyCollection(Source);
    Clear;
    for Loop := 0 to LI.Count - 1 do Add.Assign(LI.Items[Loop]);
  end else
    inherited;
  if Assigned(FOnChange) then FOnChange(Self);
end;

constructor TInspectorCategory.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FCaption := Format('Category %d', [Index]);
  FCollapsed := False;
  FProperties := TInspectorPropertyCollection.Create(Self, TInspectorProperty);
  FProperties.OnChange := PropertiesChanged;
end;

destructor TInspectorCategory.Destroy;
begin
  FProperties.Free;
  inherited Destroy;
end;

procedure TInspectorCategory.Assign(Source: TPersistent);
begin
  if (Source <> nil) and (Source is TInspectorCategory) then
  begin
    FCaption   := (Source as TInspectorCategory).Caption;
    FCollapsed := (Source as TInspectorCategory).Collapsed;
    FProperties.Assign((Source as TInspectorCategory).Properties);
  end;
end;

procedure TInspectorCategory.SetCaption(const Caption: TCaption);
begin
  if (FCaption <> Caption) then
  begin
    FCaption := Caption;
    Changed(False);
  end;
end;

procedure TInspectorCategory.SetCollapsed(Collapsed: Boolean);
begin
  if (FCollapsed <> Collapsed) then
  begin
    FCollapsed := Collapsed;
    Changed(False);
  end;
end;

procedure TInspectorCategory.PropertiesChanged(Sender: TObject);
begin
  Changed(False);
end;

function TInspectorCategory.GetDisplayName: string;
begin
  if (FCaption <> '') then
    Result := FCaption
  else
    Result := inherited;
end;

function TInspectorCategoryCollection.GetItem(Index: Integer): TInspectorCategory;
begin
  Result := inherited GetItem(Index) as TInspectorCategory;
end;

procedure TInspectorCategoryCollection.SetItem(Index: Integer; Value: TInspectorCategory);
begin
  inherited SetItem(Index, Value);
end;

function TInspectorCategoryCollection.Add: TInspectorCategory;
begin
  Result := TInspectorCategory(inherited Add);
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TInspectorCategoryCollection.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TInspectorCategoryCollection.Assign(Source: TPersistent);
var
  LI   : TInspectorCategoryCollection;
  Loop : Integer;
begin
  if (Source is TInspectorCategoryCollection)  then
  begin
    LI := TInspectorCategoryCollection(Source);
    Clear;
    for Loop := 0 to LI.Count - 1 do Add.Assign(LI.Items[Loop]);
  end else
    inherited;
  if Assigned(FOnChange) then FOnChange(Self);
end;

constructor TInspectorCategoryOptions.Create;
begin
  inherited Create;

  FHeight := CategoryHeight;
  FColor  := CategoryColor;
  FShowFocusRect := True;
  FFont := TFont.Create;
  FFont.OnChange := FontChanged;
end;

destructor TInspectorCategoryOptions.Destroy;
begin
  FFont.Free;
  inherited Destroy;
end;

procedure TInspectorCategoryOptions.Assign(Source: TPersistent);
begin
  inherited;
  if (Source is TInspectorCategoryOptions) then
  begin
    FHeight        := (Source as TInspectorCategoryOptions).Height;
    FColor         := (Source as TInspectorCategoryOptions).Color;
    FShowFocusRect := (Source as TInspectorCategoryOptions).ShowFocusRect;
    FFont.Assign((Source as TInspectorCategoryOptions).Font);
  end;
end;

procedure TInspectorCategoryOptions.FontChanged(Sender: TObject);
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TInspectorCategoryOptions.SetHeight(Height: Integer);
begin
  if (FHeight <> Height) and (Height >= MinimalHeight) then
  begin
    FHeight := Height;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TInspectorCategoryOptions.SetColor(Color: TColor);
begin
  if (FColor <> Color) then
  begin
    FColor := Color;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TInspectorCategoryOptions.SetShowFocusRect(Show: Boolean);
begin
  if (FShowFocusRect <> Show) then
  begin
    FShowFocusRect := Show;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

constructor TInspectorPropertyOptions.Create;
begin
  inherited Create;

  FHeight := PropertyHeight;
  FFont := TFont.Create;
  FFont.OnChange := FontChanged;
end;

destructor TInspectorPropertyOptions.Destroy;
begin
  FFont.Free;
  inherited Destroy;
end;

procedure TInspectorPropertyOptions.Assign(Source: TPersistent);
begin
  inherited;
  if (Source is TInspectorPropertyOptions) then
  begin
    FHeight := (Source as TInspectorPropertyOptions).Height;
    FFont.Assign((Source as TInspectorPropertyOptions).Font);
  end;
end;

procedure TInspectorPropertyOptions.FontChanged(Sender: TObject);
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TInspectorPropertyOptions.SetHeight(Height: Integer);
begin
  if (FHeight <> Height) and (Height >= MinimalHeight) then
  begin
    FHeight := Height;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

constructor TInspectorGutterOptions.Create;
begin
  inherited Create;

  FWidth  := GutterWidth;
  FColor  := GutterColor;
end;

destructor TInspectorGutterOptions.Destroy;
begin
  inherited Destroy;
end;

procedure TInspectorGutterOptions.Assign(Source: TPersistent);
begin
  inherited;
  if (Source is TInspectorGutterOptions) then
  begin
    FWidth  := (Source as TInspectorGutterOptions).Width;
    FColor  := (Source as TInspectorGutterOptions).Color;
  end;
end;

procedure TInspectorGutterOptions.SetWidth(Width: Integer);
begin
  if (FWidth <> Width) and (Width >= MinimalWidth) then
  begin
    FWidth := Width;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TInspectorGutterOptions.SetColor(Color: TColor);
begin
  if (FColor <> Color) then
  begin
    FColor := Color;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

constructor TInspectorSplitter.Create;
begin
  inherited Create;

  FColor  := SplitterColor;
  FCursor := SplitterCursor;
  FLeft   := SplitterLeft;
end;

destructor TInspectorSplitter.Destroy;
begin
  inherited Destroy;
end;

procedure TInspectorSplitter.Assign(Source: TPersistent);
begin
  inherited;
  if (Source is TInspectorSplitter) then
  begin
    FColor  := (Source as TInspectorSplitter).Color;
    FCursor := (Source as TInspectorSplitter).Cursor;
    FLeft   := (Source as TInspectorSplitter).Left;
  end;
end;

procedure TInspectorSplitter.SetColor(Color: TColor);
begin
  if (FColor <> Color) then
  begin
    FColor := Color;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TInspectorSplitter.SetCursor(Cursor: TCursor);
begin
  if (FCursor <> Cursor) then
  begin
    FCursor := Cursor;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TInspectorSplitter.SetLeft(Left: Integer);
begin
  if (FLeft <> Left) and (Left >= 0) then
  begin
    FLeft := Left;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

class constructor TInspector.Create;
begin
  TCustomStyleEngine.RegisterStyleHook(TInspector, TScrollingStyleHook);
end;

class destructor TInspector.Destroy;
begin
  TCustomStyleEngine.UnRegisterStyleHook(TInspector, TScrollingStyleHook);
end;

constructor TInspector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csCaptureMouse, csClickEvents, csDoubleClicks, csReplicatable];
  Color := clWindow;
  TabStop := True;

  FBuffer := TBitmap.Create;
  FBuffer.PixelFormat := pf32bit;
  FItemBuffer := TBitmap.Create;
  FItemBuffer.PixelFormat := pf32Bit;

  FUpdateCount := -1;
  FScrollPos   := 0;

  FCategories := TInspectorCategoryCollection.Create(Self, TInspectorCategory);
  Fcategories.OnChange := CategoriesChanged;

  FCategoryOptions := TInspectorCategoryOptions.Create;
  FCategoryOptions.OnChange := OptionsChanged;
  FPropertyOptions := TInspectorPropertyOptions.Create;
  FPropertyOptions.OnChange := OptionsChanged;
  FGutterOptions := TInspectorGutterOptions.Create;
  FGutterOptions.OnChange := OptionsChanged;
  FSplitter := TInspectorSplitter.Create;
  FSplitter.OnChange := OptionsChanged;

  FInspectorEdit := TInspectorPropertyEdit.Create(Self);
  FInspectorEdit.Font.Assign(PropertyOptions.Font);
  FInspectorEdit.Top := -100;
  FInspectorEdit.Parent  := Self;
  FInspectorEdit.Visible := False;
  FInspectorEdit.OnKeyDown := OnPropertyEditorKeyDown;
  FInspectorEdit.OnExit    := OnPropertyEditorExit;
  FInspectorEdit.OnChange  := OnPropertyEditorChange;

  FInspectorEditButton := TInspectorPropertyEditButton.Create(Self);
  FInspectorEditButton.Font.Assign(PropertyOptions.Font);
  FInspectorEditButton.Top := -100;
  FInspectorEditButton.Width  := ButtonWidth;
  FInspectorEditButton.Height := PropertyOptions.Height - 2;
  FInspectorEditButton.Caption := '…';
  FInspectorEditButton.Parent  := Self;
  FInspectorEditButton.Visible := False;
  FInspectorEditButton.OnClick := OnPropertyEditorButtonClick;
end;

destructor TInspector.Destroy;
begin
  FBuffer.Free;
  FItemBuffer.Free;
  FCategories.Free;
  FCategoryOptions.Free;
  FPropertyOptions.Free;
  FGutterOptions.Free;
  FSplitter.Free;

  FInspectorEdit.Free;
  FInspectorEditButton.Free;

  inherited Destroy;
end;

procedure TInspector.Assign(Source: TPersistent);
begin
  inherited;
  if (Source is TInspector) then
  begin
    FCategories.Assign((Source as TInspector).Categories);
    FCategoryOptions.Assign((Source as TInspector).CategoryOptions);
    FPropertyOptions.Assign((Source as TInspector).PropertyOptions);
    FGutterOptions.Assign((Source as TInspector).GutterOptions);
    FSplitter.Assign((Source as TInspector).Splitter);
  end;
end;

procedure TInspector.Repaint;
begin
  UpdateRects;
  UpdateBuffer;
  Invalidate;
end;

procedure TInspector.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TInspector.EndUpdate;
begin
  Dec(FUpdateCount);
  if (FUpdateCount <= -1) then
  begin
    UpdateRects;
    UpdateBuffer;
    Invalidate;
  end;
end;

procedure TInspector.Clear;
begin
  FCategories.Clear;
  FScrollPos := 0;
  ScrollPosUpdated;
end;

procedure TInspector.CategoriesChanged(Sender: TObject);
begin
  if (FItemBuffer.Height < ClientHeight) and (FScrollPos > 0) then
  begin
    FScrollPos := 0;
    ScrollPosUpdated;
    Exit;
  end;
  UpdateRects;
  UpdateBuffer;
  Invalidate;
end;

procedure TInspector.OptionsChanged(Sender: TObject);
begin
  FInspectorEdit.Font.Assign(PropertyOptions.Font);
  FInspectorEditButton.Font.Assign(PropertyOptions.Font);
  FInspectorEditButton.Height := PropertyOptions.Height - 2;
  UpdateRects;
  UpdateBuffer;
  Invalidate;
end;

procedure TInspector.UpdateRects;

  function CategoryTextRectOffset(const Rect: TRect): TRect;
  begin
    Result := TRect.Create(Rect);
    Result.Left := Result.Left + TextOffset;
  end;

  function PropertyTextRectOffset(const Rect: TRect): TRect;
  begin
    Result := TRect.Create(Rect);
    Result.Left  := Result.Left + TextOffset;
    Result.Right := Splitter.Left;
  end;

  function PropertyValueRectOffset(const Rect: TRect): TRect;
  begin
    Result := TRect.Create(Rect);
    Result.Left  := Result.Left + TextOffset;
  end;

  procedure FillItemBufferBackground;
  var
    S : TCustomStyleServices;
    D : TThemedElementDetails;
    C : TColor;
  begin
    S := StyleServices(Self);
    if (Enabled and Focused) then
      D := S.GetElementDetails(tcTransparentBackgroundFocused)
    else
    if (Enabled and not Focused) then
      D := S.GetElementDetails(tcTransparentBackgroundNormal)
    else
    if not Enabled then
      D := S.GetElementDetails(tcTransparentBackgroundDisabled);
    if not S.GetElementColor(D, ecFillColor, C) then C := S.GetSystemColor(clWindow);
    with FItemBuffer.Canvas do
    begin
      Brush.Color := C;
      Brush.Style := bsSolid;
      FillRect(TRect.Create(0, 0, FItemBuffer.Width, FItemBuffer.Height));
    end;
  end;

  procedure DrawCategory(const Category: TInspectorCategory);
  var
    S : TCustomStyleServices;
  begin
    S := StyleServices(Self);
    with FItemBuffer.Canvas do
    begin
      Brush.Color := S.GetSystemColor(CategoryOptions.Color);
      Font.Assign(CategoryOptions.Font);
      Font.Color := S.GetSystemColor(CategoryOptions.Font.Color);
      FillRect(Category.Rect);
      var CaptionRect := CategoryTextRectOffset(Category.Rect);
      DrawText(FItemBuffer.Canvas.Handle, Category.Caption, Length(Category.Caption), CaptionRect, DT_SINGLELINE or DT_VCENTER or DT_LEFT or DT_END_ELLIPSIS);
      if CategoryOptions.ShowFocusRect and (Selected = Category) and Focused then
      begin
        var FocusRect := CategoryTextRectOffset(Category.Rect);
        DrawText(FItemBuffer.Canvas.Handle, Category.Caption, Length(Category.Caption), FocusRect, DT_SINGLELINE or DT_VCENTER or DT_LEFT or DT_END_ELLIPSIS or DT_CALCRECT);
        FocusRect.Top := FocusRect.Top + 4;
        InflateRect(FocusRect, 2, 2);
        DrawFocusRect(FocusRect);
      end;
    end;
  end;

  procedure DrawProperty(const &Property: TInspectorProperty);
  var
    S : TCustomStyleServices;
  begin
    S := StyleServices(Self);
    with FItemBuffer.Canvas do
    begin
      // Property name
      if (Selected = &Property) then
      begin
        Brush.Style := bsSolid;
        Font.Assign(PropertyOptions.Font);
        Brush.Color := S.GetSystemColor(clHighlight);
        FillRect(&Property.SelectRect);
        Font.Color := S.GetSystemColor(clHighlightText);
        Brush.Style := bsClear;
        var NameRect := PropertyTextRectOffset(&Property.SelectRect);
        DrawText(FItemBuffer.Canvas.Handle, &Property.Name, Length(&Property.Name), NameRect, DT_SINGLELINE or DT_VCENTER or DT_LEFT);
      end else
      begin
        Brush.Style := bsClear;
        Font.Assign(PropertyOptions.Font);
        Font.Color := S.GetSystemColor(PropertyOptions.Font.Color);
        var NameRect := PropertyTextRectOffset(&Property.SelectRect);
        DrawText(FItemBuffer.Canvas.Handle, &Property.Name, Length(&Property.Name), NameRect, DT_SINGLELINE or DT_VCENTER or DT_LEFT);
      end;

      Brush.Style := bsClear;
      Font.Assign(PropertyOptions.Font);
      Font.Color := S.GetSystemColor(PropertyOptions.Font.Color);

      // Property value
      var ValueRect := PropertyValueRectOffset(&Property.EditorRect);
      var PropertyValue := &Property.Value;
      DrawText(FItemBuffer.Canvas.Handle, PropertyValue, Length(PropertyValue), ValueRect, DT_SINGLELINE or DT_VCENTER or DT_LEFT);

      Pen.Color := S.GetSystemColor(Splitter.Color);
      Pen.Style := psSolid;
      // Bottom border
      MoveTo(&Property.Rect.Left, &Property.Rect.Bottom);
      LineTo(&Property.Rect.Right, &Property.Rect.Bottom);
      // Splitter
      MoveTo(Splitter.Left, &Property.Rect.Top);
      LineTo(Splitter.Left, &Property.Rect.Bottom);
    end;
  end;

var
  ItemsWidth, TotalHeight, Category, &Property, PropertyHeight: Integer;
begin
  // Items Width
  ItemsWidth := (ClientWidth - 2) - GutterOptions.Width;
  if ItemsWidth < 0 then itemsWidth := 0;
  // Total Height
  TotalHeight := 0;

  // Loop over categories
  for Category := 0 to Categories.Count -1 do
  begin
    Categories.Items[Category].Rect := TRect.Create(
      0,
      TotalHeight,
      ItemsWidth,
      TotalHeight + CategoryOptions.Height
    );
    Inc(TotalHeight, CategoryOptions.Height);
    // Loop over properties
    for &Property := 0 to Categories.Items[Category].Properties.Count -1 do
    begin
      if not Categories.Items[Category].Collapsed then
        PropertyHeight := PropertyOptions.Height
      else
        propertyHeight := 0;
      
      Categories.Items[Category].Properties.Items[&Property].Rect := TRect.Create(
        0,
        TotalHeight,
        ClientWidth,
        TotalHeight + PropertyHeight
      );
      Categories.Items[Category].Properties.Items[&Property].SelectRect := TRect.Create(
        0,
        TotalHeight,
        Splitter.Left,
        TotalHeight + PropertyHeight
      );
      Categories.Items[Category].Properties.Items[&Property].EditorRect := TRect.Create(
        Splitter.Left + 1,
        TotalHeight,
        ItemsWidth - TextOffset,
        TotalHeight + PropertyHeight
      );
      if not Categories.Items[Category].Collapsed then Inc(TotalHeight, PropertyOptions.Height);
    end;
  end;

  // Add 1 px for last item.
  Inc(TotalHeight, 1);

  // Update ItemBuffer dimensions
  FItemBuffer.SetSize(ItemsWidth, TotalHeight);

  // Fill ItemBuffer background
  FillItemBufferBackground;

  // Draw categories
  for Category := 0 to Categories.Count -1 do
  begin
    DrawCategory(Categories.Items[Category]);
    // Draw properties
    if not Categories.Items[Category].Collapsed then
    for &Property := 0 to Categories.Items[Category].Properties.Count -1 do
    DrawProperty(Categories.Items[Category].Properties.Items[&Property]);
  end;

  // Update splitter rect
  var SplitterCenter := 1 + GutterOptions.Width + Splitter.Left;
  Splitter.Rect := TRect.Create(
    SplitterCenter - 2,
    ClientRect.Top + 1,
    SplitterCenter + 2,
    ClientRect.Bottom - 1
  );
end;

procedure TInspector.UpdateBuffer;

  function BorderExcludedClientRect: TRect;
  begin
    Result := ClientRect;
    InflateRect(Result, -1, -1);
  end;

  procedure DrawControlBackground;
  var
    S : TCustomStyleServices;
    D : TThemedElementDetails;
  begin
    S := StyleServices(Self);
    with FBuffer.Canvas do
    begin
      if Enabled then
        D := S.GetElementDetails(tcTransparentBackgroundNormal)
      else
        D := S.GetElementDetails(tcTransparentBackgroundDisabled);
      S.DrawElement(FBuffer.Canvas.Handle, D, ClientRect);
    end;
  end;

  procedure DrawControlBorder;
  var
    S : TCustomStyleServices;
    D : TThemedElementDetails;
  begin
    S := StyleServices(Self);
    with FBuffer.Canvas do
    begin
      if Enabled then
        D := S.GetElementDetails(tcBorderNormal)
      else
        D := S.GetElementDetails(tcBorderDisabled);
      S.DrawElement(FBuffer.Canvas.Handle, D, ClientRect);
    end;
  end;

  procedure DrawCategoryButton(const Category: TInspectorCategory);
  var
    S : TCustomStyleServices;
    D : TThemedElementDetails;
  begin
    S := StyleServices(Self);
    with FBuffer.Canvas do
    begin
      if Category.Collapsed then
        D := S.GetElementDetails(tcbCategoryGlyphClosed)
      else
        D := S.GetElementDetails(tcbCategoryGlyphOpened);
      var CategoryTop  := (Category.Rect.Top + 2) - FScrollPos;
      Category.CollapseRect := TRect.Create(
        2,
        CategoryTop,
        GutterOptions.Width,
        CategoryTop + CategoryOptions.Height
      );
      S.DrawElement(FBuffer.Canvas.Handle, D, Category.CollapseRect);
    end;
  end;

  procedure DrawGutter;
  var
    S : TCustomStyleServices;
    R : TRect;
    I : Integer;
  begin
    S := StyleServices(Self);
    with FBuffer.Canvas do
    begin
      Brush.Color := S.GetSystemColor(GutterOptions.Color);
      Brush.Style := bsSolid;
      R := TRect.Create(1, 1, GutterOptions.Width + 1, ClientHeight - 2);
      FillRect(R);
      for I := 0 to Categories.Count -1 do
      DrawCategoryButton(Categories.Items[I]);
    end;
  end;
var
  H : HRGN;
  R : TRect;
begin
  // Dont redraw when we are updating
  if (FUpdateCount > -1) then Exit;
  // We need a handle to start painting
  if not HandleAllocated then Exit;

  // Update buffer dimensions
  if (FBuffer.Width <> ClientWidth) or (FBuffer.Height <> ClientHeight) then
    FBuffer.SetSize(ClientWidth, ClientHeight);

  // Draw Background
  DrawControlBackground;
  // Draw Border
  DrawControlBorder;

  // CREATE CLIPRECT REGION TO PREVENT DRAWING OVER THE BORDER
  R := BorderExcludedClientRect;
  H := CreateRectRgn(R.Left, R.Top, R.Right, R.Bottom);
  SelectClipRgn(FBuffer.Canvas.Handle, H);

  // Draw Gutter
  DrawGutter;

  // Draw categories and items..
  with FBuffer.Canvas do
  begin
    // Draw 1px (border) left and 1px (border) + ScrollPos top.
    Draw(GutterOptions.Width + 1, 1 - FScrollPos, FItemBuffer);
  end;

  // REMOVE CLIPRECT
  SelectClipRgn(FBuffer.Canvas.Handle, HRGN(nil));
  DeleteObject(H);
end;

procedure TInspector.UpdateStyleElements;
begin
  inherited;
  UpdateRects;
  UpdateBuffer;
  Invalidate;
end;

procedure TInspector.WndProc(var Message: TMessage);
var
  SI : TScrollInfo;
begin
  case Message.Msg of
    WM_GETDLGCODE:
      Message.Result := Message.Result or DLGC_WANTARROWS or DLGC_WANTALLKEYS;
    WM_KEYDOWN:
    begin
      case Message.wParam of
        VK_PRIOR:
          Perform(WM_VSCROLL, SB_PAGEUP, 0);
        VK_NEXT:
          Perform(WM_VSCROLL, SB_PAGEDOWN, 0);
      end;
    end;
    WM_VSCROLL:
    begin
      case Message.WParamLo of
        SB_TOP:
        begin
          FScrollPos := 0;
          ScrollPosUpdated;
        end;
        SB_BOTTOM:
        begin
          FScrollPos := FItemBuffer.Height - ClientHeight;
          ScrollPosUpdated;
        end;
        SB_LINEUP:
        begin
          dec(FScrollPos, PropertyOptions.Height);
          ScrollPosUpdated;
        end;
        SB_LINEDOWN:
        begin
          Inc(FScrollPos, PropertyOptions.Height);
          ScrollPosUpdated;
        end;
        SB_THUMBTRACK:
        begin
          if FInspectorEdit.Visible then FInspectorEdit.SetEditorInActive;
          if FInspectorEditButton.Visible then FInspectorEditButton.SetEditorInActive;
          ZeroMemory(@SI, sizeof(SI));
          SI.cbSize := Sizeof(SI);
          SI.fMask := SIF_TRACKPOS;
          if GetScrollInfo(Handle, SB_VERT, SI) then
          begin
            FScrollPos := SI.nTrackPos;
            ScrollPosUpdated;
            ScrollPosUpdated;
          end;
        end;
      end;
      Message.Result := 0;
    end;
  end;
  inherited;
end;

procedure TInspector.ScrollPosUpdated;
begin
  FScrollPos := EnsureRange(FScrollPos, 0, FItemBuffer.Height - ClientHeight);
  if FOldScrollPos <> FScrollPos then
  begin
    FOldScrollPos := FScrollPos;
    UpdateRects;
    UpdateBuffer;
    Invalidate;
  end;
end;

function TInspector.ScrollOffsetRect(const Rect: TRect): TRect;
begin
  Result := TRect.Create(Rect);
  OffsetRect(Result, 0, -FScrollPos);
end;

procedure TInspector.Paint;

  function OffsetEditorRect(const Rect: TRect): TRect;
  begin
    Result := TRect.Create(Rect);
    Result.Width := Result.Width - TextOffset;
    OffsetRect(Result, GutterOptions.Width + TextOffset + 1, 0);
  end;

var
  X, Y : Integer;
  W, H : Integer;
  S    : TScrollInfo;
begin
  // Update the old height if it is changed
  // this is used in the WM_SIZE to update the scroll position.
  if (FOldHeight <> height) then FOldHeight := Height;

  X := FUpdateRect.Left;
  Y := FUpdateRect.Top;
  W := FUpdateRect.Right - FUpdateRect.Left;
  H := FUpdateRect.Bottom - FUpdateRect.Top;

  S.cbSize := Sizeof(S);
  S.fMask  := SIF_ALL;
  S.nMin   := 0;
  S.nMax   := FItemBuffer.Height;
  S.nPage  := ClientHeight;
  S.nPos   := FScrollPos;
  S.nTrackPos := S.nPos;

  SetScrollInfo(Handle, SB_VERT, S, True);

  // Draw Buffer to canvas
  if (W <> 0) and (H <> 0) then
    BitBlt(Canvas.Handle, X, Y, W, H, FBuffer.Canvas.Handle, X,  Y, SRCCOPY)
  else
    BitBlt(Canvas.Handle, 0, 0, ClientWidth, ClientHeight, FBuffer.Canvas.Handle, X,  Y, SRCCOPY);

  // Update position of editor
  if (Selected is TInspectorProperty) then
  begin
    var &Property := (Selected as TInspectorProperty);
    if FInspectorEdit.Visible then
      FInspectorEdit.UpdateEditorPosition(ScrollOffsetRect(OffsetEditorRect(&Property.EditorRect)));
    // Button
    if FInspectorEditButton.Visible then
      FInspectorEditButton.UpdateEditorPosition(ScrollOffsetRect(OffsetEditorRect(&Property.EditorRect)));
  end;
end;

procedure TInspector.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or WS_VSCROLL;
  Params.Style := Params.Style and not (CS_HREDRAW or CS_VREDRAW);
end;

procedure TInspector.SelectPrevious;

  procedure UpdateScrollPosition;
  begin
    if (Selected <> nil) then
    begin
      // Category
      if (Selected is TInspectorCategory) then
      begin
        if ScrollOffsetRect((Selected as TInspectorCategory).Rect).Top < 0 then
        begin
          Dec(FScrollPos, CategoryOptions.Height);
          ScrollPosUpdated;
          Exit;
        end;
      end;
      // Property
      if (Selected is TInspectorProperty) then
      begin
        if ScrollOffsetRect((Selected as TInspectorProperty).Rect).Top < 0 then
        begin
          Dec(FScrollPos, PropertyOptions.Height);
          ScrollPosUpdated;
          Exit;
        end;
      end;
    end;
    Repaint;
  end;

var
  C, P: Integer;
begin
  // Ignore if no item is selected
  if (Selected = nil) then Exit;

  // If category is selected
  if (Selected is TInspectorCategory) then
  begin
    for C := Categories.Count -1 downto 0 do
    if Categories.Items[C] = Selected then
    begin
      // If this is not the first category and the previous category is not collapsed and has properties, select the last property of the previous category
      if (C > 0) and (not Categories.Items[C - 1].Collapsed) and (Categories.Items[C - 1].Properties.count > 0) then
      begin
        var LastProperty := Categories.Items[C - 1].Properties.Count -1;
        Selected := Categories.Items[C - 1].Properties.Items[LastProperty];
        UpdateScrollPosition;
        Exit;
      end;
      // If this is not the first category and the previous category is collapsed or has no properties, select the previous category
      if (C > 0) and (Categories.Items[C - 1].Collapsed or ((Categories.Items[C - 1].Properties.count = 0))) then
      begin
        Selected := Categories.Items[C - 1];
        UpdateScrollPosition;
        Exit;
      end;
    end;
  end;

  // If property is selected
  if (Selected is TInspectorProperty) then
  begin
    for C := Categories.Count -1 downto 0 do
    for P := Categories.Items[C].Properties.Count -1 downto 0 do
    if Categories.Items[C].Properties.Items[P] = Selected then
    begin
      // If this is not the first property, select the previous property
      if (P > 0) then
      begin
        Selected := Categories.Items[C].Properties.Items[P - 1];
        UpdateScrollPosition;
        Exit;
      end;
      // If this is the first property, select the category
      if (P = 0) then
      begin
        Selected := Categories.Items[C];
        UpdateScrollPosition;
        Exit;
      end;
    end;
  end;
end;

procedure TInspector.SelectNext;

  procedure UpdateScrollPosition;
  begin
    if (Selected <> nil) then
    begin
      // Category
      if (Selected is TInspectorCategory) then
      begin
        if ScrollOffsetRect((Selected as TInspectorCategory).Rect).Bottom > ClientHeight then
        begin
          Inc(FScrollPos, CategoryOptions.Height);
          ScrollPosUpdated;
          Exit;
        end;
      end;
      // Property
      if (Selected is TInspectorProperty) then
      begin
        if ScrollOffsetRect((Selected as TInspectorProperty).Rect).Bottom > ClientHeight then
        begin
          Inc(FScrollPos, PropertyOptions.Height);
          ScrollPosUpdated;
          Exit;
        end;
      end;
    end;
    Repaint;
  end;

var
  C, P: Integer;
begin
  // Ignore if no item is selected
  if (Selected = nil) then Exit;

  // If category is selected
  if (Selected is TInspectorCategory) then
  begin
    for C := 0 to Categories.Count -1 do
    if Categories.Items[C] = Selected then
    begin
      // If the category is not collapsed and there are properties in this category, select the first property
      if (not Categories.Items[C].Collapsed) and (Categories.Items[C].Properties.Count > 0) then
      begin
        Selected := Categories.Items[C].Properties.Items[0];
        UpdateScrollPosition;
        Exit;
      end;
      // If this is not the last category, then select the next category
      if C < Categories.Count -1 then
      begin
        Selected := Categories.Items[C + 1];
        UpdateScrollPosition;
        Exit;
      end;
    end;
  end;

  // If property is selected
  if (Selected is TInspectorProperty) then
  begin
    for C := 0 to Categories.Count -1 do
    for P := 0 to Categories.Items[C].Properties.Count -1 do
    begin
      // If this is not the last property in the category, select the next property
      if (Categories.Items[C].Properties.Items[P] = Selected) and (P < Categories.Items[C].Properties.Count -1) then
      begin
        Selected := Categories.Items[C].Properties.Items[P + 1];
        UpdateScrollPosition;
        Exit;
      end;
      // If this is the last property in the category and this is not the last category, select the next category
      if (Categories.Items[C].Properties.Items[P] = Selected) and (P = Categories.Items[C].Properties.Count -1) and (C < Categories.Count -1) then
      begin
        Selected := Categories.Items[C + 1];
        UpdateScrollPosition;
        Exit;
      end;
    end;
  end;
end;

procedure TInspector.MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
var
  C, P: Integer;
begin
  if not Enabled then Exit;
  if not Focused and CanFocus then SetFocus;

  // Reset selected
  if (Selected <> nil) then
  begin
    Selected := nil;
    Repaint;
  end;

  // Reset selected mousedown
  if FSelectedMouseDown then FSelectedMouseDown := False;

  // Start dragging splitter
  if PtInRect(Splitter.Rect, Point(X, Y)) then
  begin
    SetCursor(Screen.Cursors[Splitter.Cursor]);
    FSplitterMouseDown := True;
    Exit;
  end else
    FSplitterMouseDown := False;

   // Collapse / Expand category
  for C := 0 to Categories.Count -1 do
  if PtInRect(Categories.Items[C].CollapseRect, Point(X, Y)) then
  begin
    Selected := Categories.Items[C];
    Categories.Items[C].Collapsed := not Categories.Items[C].Collapsed;

    if Categories.Items[C].Collapsed and Assigned(OnCategoryCollapse) then
      OnCategoryCollapse(Categories.Items[C]);
    if not Categories.Items[C].Collapsed and Assigned(OnCategoryExpand) then
      OnCategoryExpand(Categories.Items[C]);

    Exit;
  end;

  // Select property
  for C := 0 to Categories.Count -1 do
  for P := 0 to Categories.Items[C].Properties.Count -1 do
  if PtInRect(ScrollOffsetRect(Categories.Items[C].Properties.Items[P].Rect), Point(X, Y)) then
  begin
    Selected := Categories.Items[C].Properties.Items[P];
    FSelectedMouseDown := True;
    Repaint;
    Exit;
  end;

  // Select category
  for C := 0 to Categories.Count -1 do
  if PtInRect(ScrollOffsetRect(Categories.Items[C].Rect), Point(X, Y)) then
  begin
    Selected := Categories.Items[C];
    FSelectedMouseDown := True;
    Repaint;
    Exit;
  end;

  inherited;
end;

procedure TInspector.MouseUp(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer);
begin
  if FSplitterMouseDown then
  begin
    FSplitterMouseDown := False;
    //if Assigned(OnSplitterMoved) then OnSplitterMoved(Self);
  end;
  if FSelectedMouseDown then
  begin
    FSelectedMouseDown := False;
  end;
  inherited;
end;

procedure TInspector.MouseMove(Shift: TShiftState; X: Integer; Y: Integer);
var
  C, P: Integer;
begin
  if not Enabled then Exit;

  // We are dragging the splitter
  if FSplitterMouseDown then
  begin
    Splitter.Left := X - (1 + GutterOptions.Width);
  end;

  // Mouse is over splitter
  if not FSplitterMouseDown and PtInRect(Splitter.Rect, Point(X, Y)) then
  begin
    SetCursor(Screen.Cursors[Splitter.Cursor]);
    Exit;
  end;

  //
  if FSelectedMouseDown then
  begin
    for C := 0 to Categories.Count -1 do
    begin
      if PtInRect(ScrollOffsetRect(Categories.Items[C].Rect), Point(X, Y)) and (Selected <> Categories.Items[C]) then
      begin
        Selected := Categories.Items[C];
        Repaint;
        Exit;
      end else
      for P := 0 to Categories.Items[C].Properties.Count -1 do
      if PtInRect(ScrollOffsetRect(Categories.Items[C].Properties.Items[P].Rect), Point(X, Y)) and (Selected <> Categories.Items[C].Properties.Items[P]) then
      begin
        Selected := Categories.Items[C].Properties.Items[P];
        Repaint;
        Exit;
      end;
    end;
  end;

  inherited;
end;

function TInspector.DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  if (csDesigning in ComponentState) then
  begin
    Result := inherited;
    Exit;
  end;
  Result := True;
  if (ssCtrl in Shift) then
  begin
    SelectNext;
  end else
  if (FItemBuffer.Height > ClientHeight) then
  begin
    Inc(FScrollPos, PropertyOptions.Height);
    ScrollPosUpdated;
  end;
  inherited;
end;

function TInspector.DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  if (csDesigning in ComponentState) then
  begin
    Result := inherited;
    Exit;
  end;
  Result := True;
  if (ssCtrl in Shift) then
  begin
    SelectPrevious;
  end else
  if (FItemBuffer.Height > ClientHeight) then
  begin
    Dec(FScrollPos, PropertyOptions.Height);
    ScrollPosUpdated;
  end;
  inherited;
end;

procedure TInspector.DblClick;
var
  Category: Integer;
  MousePosition: TPoint;
  MouseButton: TMouseButton;
begin
  inherited DblClick;

  // Get mouse position
  MousePosition := ScreenToClient(Mouse.CursorPos);

  // Get mousebutton
  if GetKeyState(VK_LBUTTON) < 0 then
    MouseButton := mbLeft
  else if GetKeyState(VK_RBUTTON) < 0 then
    MouseButton := mbRight
  else if GetKeyState(VK_MBUTTON) < 0 then
    MouseButton := mbMiddle
  else
    MouseButton := mbLeft;

  // Collapse / Expand category
  if MouseButton = mbLeft then
  for Category := 0 to Categories.Count -1 do
  if PtInRect(Categories.Items[Category].Rect, MousePosition) then
  begin
    Categories.Items[Category].Collapsed := not Categories.Items[Category].Collapsed;
    Break;
  end;
end;

procedure TInspector.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if not Enabled then Exit;

  case Key of

    // Key up
    VK_UP:
    begin
      SelectPrevious;
      Exit;
    end;

    // Key down
    VK_DOWN:
    begin
      SelectNext;
      Exit;
    end;

    // Key left
    VK_LEFT:
    begin
      if Selected is TInspectorCategory then
      (Selected as TInspectorCategory).Collapsed := True;
      Exit;
    end;

    // Key right
    VK_RIGHT:
    begin
      if Selected is TInspectorCategory then
      (Selected as TInspectorCategory).Collapsed := False;
      Exit;
    end;

    // HOME
    VK_HOME:
    if (Categories.Count > 0) then
    begin
      Selected := Categories.Items[0];
      Repaint;
      Exit;
    end;

    // END
    VK_END:
    if (Categories.Count > 0) then
    begin
      var LastCategory := Categories.Count -1;
      if Categories.Items[LastCategory].Properties.Count > 0 then
      begin
        var LastProperty := Categories.Items[LastCategory].Properties.Count -1;
        Selected := Categories.Items[LastCategory].Properties.Items[LastProperty];
        Repaint;
        Exit;
      end else
      begin
        Selected := Categories.Items[LastCategory];
        Repaint;
        Exit;
      end;
    end;

    // Escape
    VK_ESCAPE:
    if (Selected <> nil) then
    begin
      Selected := nil;
      Repaint;
      Exit;
    end;

  end;
end;

procedure TInspector.SetSelected(const Item: TCollectionItem);

  function OffsetEditorRect(const Rect: TRect): TRect;
  begin
    Result := TRect.Create(Rect);
    Result.Width := Result.Width - TextOffset;
    OffsetRect(Result, GutterOptions.Width + TextOffset + 1, 0);
  end;

begin
  FSelected := Item;

  if (Item = nil) or (Item is TInspectorCategory) then
  begin
    FInspectorEdit.SetEditorInActive;
    FInspectorEditActive := False;
    FInspectorEditButton.SetEditorInActive;
    FInspectorEditButtonActive := False;

    if (Item is TInspectorCategory) and Assigned(OnCategorySelect) then
      OnCategorySelect(Selected as TInspectorCategory);

    if CanFocus then SetFocus;
    Exit;
  end;

  if (Item is TInspectorProperty) then
  begin
    var &Property := (Item as TInspectorProperty);
    var EditorRect := OffsetEditorRect(&Property.EditorRect);

    if Assigned(OnPropertySelect) then OnPropertySelect(Item as TInspectorProperty);

    if &Property.EditButton then
    begin
      EditorRect.Right := EditorRect.Right - ButtonWidth;
      FInspectorEditButton.SetEditorActive(OffsetEditorRect(&Property.EditorRect));
      FInspectorEditButtonActive := True;
    end else
    begin
      FInspectorEditButton.SetEditorInActive;
      FInspectorEditButtonActive := False;
    end;

    FInspectorEdit.SetEditorInActive;
    FInspectorEdit.InspectorProperty := &Property;
    FInspectorEdit.SetEditorActive(EditorRect, &Property.Value);
    FInspectorEditActive := True;
  end;
end;

procedure TInspector.OnPropertyEditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key in [VK_UP, VK_DOWN, VK_HOME, VK_END] then
  begin
    KeyDown(Key, Shift);
    Key := 0;
  end else
    inherited;
end;

procedure TInspector.OnPropertyEditorExit(Sender: TObject);
begin
  if (FInspectorEdit.InspectorProperty <> nil) then
  if Assigned(OnPropertyChanged) then OnPropertyChanged(FInspectorEdit.InspectorProperty);
end;

procedure TInspector.OnPropertyEditorChange(Sender: TObject);
begin
  if (Selected is TInspectorProperty) then
  begin
    (Selected as TInspectorProperty).Value := FInspectorEdit.Text;
    if Assigned(OnPropertyChange) then OnPropertyChange(Selected as TInspectorProperty);
  end;
end;

procedure TInspector.OnPropertyEditorButtonClick(Sender: TObject);
begin
  if (Selected is TInspectorProperty) then
  if Assigned(OnPropertyButtonClick) then OnPropertyButtonClick(Selected as TInspectorProperty);
end;

procedure TInspector.WMPaint(var Msg: TWMPaint);
begin
  GetUpdateRect(Handle, FUpdateRect, False);
  inherited;
end;

procedure TInspector.WMSize(var Message: TWMSize);
begin
  inherited;
  // If the height is bigger than the old height, update the scroll position.
  if (FScrollPos > 0) and (Height > FOldHeight) then
  begin
    FScrollPos := FScrollPos - (Height - FOldHeight);
    ScrollPosUpdated;
  end else

  // Else just recalculate the rects, and redraw.
  begin
    UpdateRects;
    UpdateBuffer;
    Invalidate;
  end;
end;

procedure TInspector.WMEraseBkGnd(var Msg: TWMEraseBkgnd);
begin
  // Draw Buffer to control canvas
  BitBlt(Msg.DC, 0, 0, ClientWidth, ClientHeight, FBuffer.Canvas.Handle, 0, 0, SRCCOPY);
  Msg.Result := 1;
end;

procedure TInspector.WMPaletteChanged(var Message: TMessage);
begin
  inherited;
  UpdateRects;
  UpdateBuffer;
  Invalidate;
end;

procedure TInspector.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  Repaint;
end;

procedure TInspector.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  Repaint;
end;

procedure TInspector.WMGetDLGCode(var Message: TWMNoParams);
begin
  Message.Result := Message.Result or DLGC_WANTCHARS or
    DLGC_WANTARROWS or DLGC_WANTTAB or DLGC_WANTALLKEYS;
end;

procedure TInspector.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  Repaint;
end;

procedure TInspector.CMFontChanged(var Message: TMessage);
begin
  inherited;
  Repaint;
end;

procedure TInspector.CMSysColorChange(var Message: TMessage);
begin
  inherited;
  Repaint;
end;

end.
