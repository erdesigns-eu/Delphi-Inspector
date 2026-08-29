object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Delphi Inspector Demo'
  ClientHeight = 380
  ClientWidth = 520
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 13
  object FStyleSelector: TComboBox
    Left = 0
    Top = 0
    Width = 520
    Height = 21
    Align = alTop
    Style = csDropDownList
    TabOrder = 0
    OnChange = StyleChanged
  end
  object FStatus: TLabel
    Left = 0
    Top = 352
    Width = 520
    Height = 28
    Align = alBottom
    AutoSize = False
    Caption = 'Select or edit a property.'
    Layout = tlCenter
    ExplicitTop = 351
  end
  object FInspector: TInspector
    Left = 0
    Top = 21
    Width = 520
    Height = 331
    Align = alClient
    TabOrder = 1
    OnPropertySelect = PropertySelected
    OnPropertyChange = PropertyChanging
    OnPropertyChanged = PropertyChanged
    OnPropertyButtonClick = PropertyButtonClick
    OnCategoryCollapse = CategoryCollapsed
    OnCategoryExpand = CategoryExpanded
  end
end
