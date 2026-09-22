unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FileCtrl; 

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    SaveDialog1: TSaveDialog;
    procedure Button1Click(Sender: TObject);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

// Структура для хранения информации о файле в памяти
type
  TFileItem = record
    Name: string;
    Ext: string;
    Size: Integer;
    Offset: Integer;
  end;

// Перенесли функцию наверх, чтобы компилятор её видел заранее
function MoveDummy(Len, Max: Integer): Integer;
begin
  if Len > Max then Result := Max else Result := Len;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  WFile: File;
  SourceDir: string;
  SR: TSearchRec;
  Files: array of TFileItem;
  FileCount, i, j: Integer;
  
  // Переменные для подсчета типов файлов
  DistinctExts: array of string;
  ExtCounts: array of Integer;
  ExtCount: Integer;
  IsNewExt: Boolean;

  // Технические переменные для записи заголовка
  HeaderSize, Unk3, CurrentOffset: Integer;
  FileBuffer: array of Byte;
  RFile: File;
  FixStr: string;
  FullFileName: string; // ДОБАВИЛИ ПРОПУЩЕННУЮ ПЕРЕМЕННУЮ СЮДА
begin
  // 1. Выбираем папку с распакованными файлами
  SourceDir := '';
  {$WARN UNIT_PLATFORM OFF} // Отключает предупреждение о платформозависимости FileCtrl
  if not SelectDirectory('Выберите папку для упаковки', '', SourceDir) then Exit;
  SourceDir := IncludeTrailingPathDelimiter(SourceDir);

  // 2. Выбираем, куда сохранить готовый .pack файл
  SaveDialog1.Filter := 'Pack Files (*.pack)|*.pack';
  SaveDialog1.DefaultExt := 'pack';
  if not SaveDialog1.Execute then Exit;


  Memo1.Lines.Clear;
  Memo1.Lines.Add('Сканирование папки...');

  // 3. Собираем список всех файлов в папке
  FileCount := 0;
  ExtCount := 0;
  if FindFirst(SourceDir + '*.*', faAnyFile, SR) = 0 then
  begin
    repeat
      if (SR.Name <> '.') and (SR.Name <> '..') and ((SR.Attr and faDirectory) = 0) then
      begin
        Inc(FileCount);
        SetLength(Files, FileCount);
        
        Files[FileCount-1].Name := ChangeFileExt(SR.Name, ''); 
        Files[FileCount-1].Ext := LowerCase(Copy(ExtractFileExt(SR.Name), 2, MaxInt)); 
        Files[FileCount-1].Size := SR.Size;

        IsNewExt := True;
        for i := 0 to ExtCount - 1 do
        begin
          if DistinctExts[i] = Files[FileCount-1].Ext then
          begin
            Inc(ExtCounts[i]);
            IsNewExt := False;
            Break;
          end;
        end;

        if IsNewExt then
        begin
          Inc(ExtCount);
          SetLength(DistinctExts, ExtCount);
          SetLength(ExtCounts, ExtCount);
          DistinctExts[ExtCount-1] := Files[FileCount-1].Ext;
          ExtCounts[ExtCount-1] := 1;
        end;
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;

  if FileCount = 0 then
  begin
    Memo1.Lines.Add('Папка пуста! Нечего упаковывать.');
    Exit;
  end;

  // 4. Расчет смещений
  HeaderSize := 24; 
  Unk3 := HeaderSize + (ExtCount * 12); 
  CurrentOffset := Unk3 + (FileCount * 40); 

  for i := 0 to FileCount - 1 do
  begin
    Files[i].Offset := CurrentOffset;
    CurrentOffset := CurrentOffset + Files[i].Size; 
  end;

  // 5. Запись в .pack файл
  AssignFile(WFile, SaveDialog1.FileName);
  Rewrite(WFile, 1);

  FixStr := 'UWFPVF01';
  BlockWrite(WFile, PChar(FixStr)^, 8);
  BlockWrite(WFile, ExtCount, 4);
  BlockWrite(WFile, HeaderSize, 4);
  BlockWrite(WFile, FileCount, 4);
  BlockWrite(WFile, Unk3, 4);

  // Записываем таблицу типов файлов
  for i := 0 to ExtCount - 1 do
  begin
    FixStr := StringOfChar(#0, 4);
    Move(PChar(DistinctExts[i])^, PChar(FixStr)^, MoveDummy(Length(DistinctExts[i]), 4));
    BlockWrite(WFile, PChar(FixStr)^, 4); 
    
    j := 0; 
    BlockWrite(WFile, j, 4); 
    BlockWrite(WFile, ExtCounts[i], 4); 
  end;

  // Записываем таблицу файлов
  for i := 0 to FileCount - 1 do
  begin
    FixStr := StringOfChar(#0, 32);
    Move(PChar(Files[i].Name)^, PChar(FixStr)^, MoveDummy(Length(Files[i].Name), 32));
    
    BlockWrite(WFile, PChar(FixStr)^, 32); 
    BlockWrite(WFile, Files[i].Offset, 4); 
    BlockWrite(WFile, Files[i].Size, 4);   
  end;

  Memo1.Lines.Add('Запись данных файлов...');

  // Записываем бинарный контент
  for i := 0 to FileCount - 1 do
  begin
    FullFileName := SourceDir + Files[i].Name;
    if Files[i].Ext <> '' then 
      FullFileName := FullFileName + '.' + Files[i].Ext;

    AssignFile(RFile, FullFileName);
    Reset(RFile, 1);
    SetLength(FileBuffer, Files[i].Size);
    
    // ИСПРАВЛЕНО: Передаем первый элемент массива, чтобы не было конфликта типов
    if Files[i].Size > 0 then
      BlockRead(RFile, FileBuffer[0], Files[i].Size);
    CloseFile(RFile);

    if Files[i].Size > 0 then
      BlockWrite(WFile, FileBuffer[0], Files[i].Size);
      
    Memo1.Lines.Add('Запакован: ' + Files[i].Name + '.' + Files[i].Ext);
  end;

  CloseFile(WFile);
  Memo1.Lines.Add('--- ГОТОВО! Архив успешно создан ---');
end;

end.

