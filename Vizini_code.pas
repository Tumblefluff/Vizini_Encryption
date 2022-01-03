unit Vizini_code;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, vcl.stdctrls, vcl.ExtCtrls, System.IOUtils,
  Vcl.Imaging.pngimage, system.inifiles, system.uitypes;

type
  TForm1 = class(TForm)
    Logo: TImage;
    Key_icon: TImage;
    File_icon: TImage;
    Password_icon: TImage;
    Label_Key: TLabel;
    Password: TEdit;
    Label_File: TLabel;
    Enc_Btn: TButton;
    Dec_Btn: TButton;
    Optional: TLabel;
    GetSrc: TFileOpenDialog;
    GetKey: TFileOpenDialog;
    SaveFile: TFileSaveDialog;
    LOL: TLabel;
    procedure Password_iconClick(Sender: TObject);
    procedure Key_iconClick(Sender: TObject);
    procedure File_iconClick(Sender: TObject);
    procedure Enc_BtnClick(Sender: TObject);
    procedure Dec_BtnClick(Sender: TObject);
    procedure Label_KeyClick(Sender: TObject);
    procedure Label_FileClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  SingleKey = array[0..255]of byte;
  Keyring = array[0..255]of singlekey;
  packet = record
    sf:string; //source file
    df:string; //destination file
    pw:string; //password
    key:keyring;  //send keys;
  end;

var
  Form1: TForm1;
  TheKey: keyring;
  keyFile: file of keyring;
  activeKey: singlekey;
  srcFile, dstFile: file of byte;
  dfname : string = '';
  lfname : string = '';
  sfname : string = '';
  kfname : string = '';
  temp1, temp2, temp3 : byte;
  Offset : uint64;
  shortoff : byte;  //wrapped offset number
//  Mode : byte; // 0 = original 1 = variant1 2 = variant2
  logfile,datfile : Textfile;
tempstring : string;
  sendme : packet;

implementation

{$R *.dfm}

procedure mode0_d(gotten: packet);  //Original Version - Decrypt
var
  pws : byte;
Begin
  assignfile(srcfile, gotten.sf);
  assignfile(dstfile, gotten.df);
  thekey := gotten.key;
  pws := length(gotten.pw);
  reset(srcfile);
  rewrite(dstfile);
  activekey := thekey[0];
  offset :=0;
  repeat
    read(srcfile, temp1);
    shortoff := offset mod 256;
    if pws>0 then temp3 := ord(gotten.pw[offset mod pws]) else temp3 :=0;
    temp2 := activekey[temp1 xor temp3];
    write(dstfile, temp2);
    activekey := thekey[temp1];
    offset := offset+1;
  until eof(srcfile);
  closefile(srcfile);
  closefile(dstfile);
End;

procedure mode0_e(gotten: packet);  //Original Version - Encrypt
var
  pws : byte;
Begin
  assignfile(srcfile, gotten.sf);
  assignfile(dstfile, gotten.df);
  thekey := gotten.key;
  pws := length(gotten.pw);
  reset(srcfile);
  rewrite(dstfile);
  activekey := thekey[0];
  offset :=0;
  repeat
    read(srcfile, temp1);
    shortoff := offset mod 256;
    if pws>0 then temp3 := ord(gotten.pw[offset mod pws]) else temp3 :=0;
    temp2 := activekey[temp1] xor temp3;
    write(dstfile, temp2);
    activekey := thekey[temp2];
    offset := offset+1;
  until eof(srcfile);
  closefile(srcfile);
  closefile(dstfile);
End;
{***
procedure mode1_d(gotten: packet);  //Variant 1 - Decrypt
var
  pws : byte;
Begin
  assignfile(srcfile, gotten.sf);
  assignfile(dstfile, gotten.df);
  thekey := gotten.key;
  pws := length(gotten.pw);
  reset(srcfile);
  rewrite(dstfile);
  activekey := thekey[0];
  offset :=0;
  repeat
    read(srcfile, temp1);
    shortoff := offset mod 256;
    if pws>0 then temp3 := ord(gotten.pw[offset mod pws]) else temp3 :=0;
    temp2 := activekey[(temp1) xor temp3];
    write(dstfile, temp2);
    activekey := thekey[((temp1+shortoff)mod 256)];
    offset := offset+1;
  until eof(srcfile);
  closefile(srcfile);
  closefile(dstfile);
End;

procedure mode1_e(gotten: packet);  //Variant 1 - Encrypt
var
  pws : byte;
Begin
  assignfile(srcfile, gotten.sf);
  assignfile(dstfile, gotten.df);
  thekey := gotten.key;
  pws := length(gotten.pw);
  reset(srcfile);
  rewrite(dstfile);
  activekey := thekey[0];
  offset :=0;
  repeat
    read(srcfile, temp1);
    shortoff := offset mod 256;
    if pws>0 then temp3 := ord(gotten.pw[offset mod pws]) else temp3 :=0;
    temp2 := activekey[temp1] xor temp3;
    write(dstfile, temp2);
    activekey := thekey[((temp2+shortoff)mod 256)];
    offset := offset+1;
  until eof(srcfile);
  closefile(srcfile);
  closefile(dstfile);
End;

procedure mode2_d(gotten: packet);  //Variant 2 - Decrypt
var
  pws : byte;
Begin
  assignfile(srcfile, gotten.sf);
  assignfile(dstfile, gotten.df);
  thekey := gotten.key;
  pws := length(gotten.pw);
  reset(srcfile);
  rewrite(dstfile);
  activekey := thekey[0];
  offset :=0;
  repeat
    read(srcfile, temp1);
    shortoff := offset mod 256;
    if pws>0 then temp3 := ord(gotten.pw[offset mod pws]) else temp3 :=0;
    temp2 := activekey[(temp1) xor temp3];
    write(dstfile, temp2);
    activekey := thekey[((temp1+256-shortoff)mod 256)];
    offset := offset+1;
  until eof(srcfile);
  closefile(srcfile);
  closefile(dstfile);
End;

procedure mode2_e(gotten: packet);  //Variant 2 - Encrypt
var
  pws : byte;
Begin
  assignfile(srcfile, gotten.sf);
  assignfile(dstfile, gotten.df);
  thekey := gotten.key;
  pws := length(gotten.pw);
  reset(srcfile);
  rewrite(dstfile);
  activekey := thekey[0];
  offset :=0;
  repeat
    read(srcfile, temp1);
    shortoff := offset mod 256;
    if pws>0 then temp3 := ord(gotten.pw[offset mod pws]) else temp3 :=0;
    temp2 := activekey[temp1] xor temp3;
    write(dstfile, temp2);
    activekey := thekey[((temp2+256-shortoff)mod 256)];
    offset := offset+1;
  until eof(srcfile);
  closefile(srcfile);
  closefile(dstfile);
End;

***}

procedure logit(polarity: string);
var
  ts, d, k, s, pw : string;
begin
  lfname := ChangeFileExt(Application.ExeName, '.LOG');
  assignfile(logfile, lfname);
  if fileexists(lfname) then
  begin
    reset(logfile);
    Append(logfile);
    writeln(logfile, '**************************************************');
  end else rewrite(logfile);
  pw:= form1.Password.Text;
  k:= TPath.GetFileName(form1.GetKey.FileName);
  s:= form1.GetSrc.FileName;
  d:= form1.savefile.FileName;
  if pw='' then tempstring := 'No Password' else tempstring := 'Password='+pw;
//  if mode=0 then modestring := 'Original' else modestring := 'Variant '+inttostr(mode);
  ts:= datetostr(now)+' @ '+timetostr(now);
//  writeln(logfile, ts + '|' + s + '|' + polarity + '|' + k + '|'+ tempstring);
  writeln(logfile, ts+' | Using Key | '+k);
  writeln(logfile, 'Input File | '+s);
  writeln(logfile, 'Output File | '+d);
  writeln(logfile, polarity+' | '+tempstring);
  closefile(logfile);
//decrypt
end;


procedure TForm1.Dec_BtnClick(Sender: TObject);   //decrypt
begin
  dfname := 'D_'+tpath.GetFileName(sfname);
  savefile.FileName := dfname;
  if savefile.Execute then
    begin
      sendme.pw := password.Text;
      assignFile(keyfile, kfname);
      reset(keyfile);
      read(keyfile, TheKey);
      read(keyfile, TheKey);
      closeFile(keyfile);
      sendme.key := thekey;
      sendme.sf := sfname;
      dfname := savefile.FileName;
      sendme.df := dfname;
      logit('Decrypt');
      mode0_d(sendme);
//      case mode of
//        0 : mode0_D(sendme);
//        1 : mode1_D(sendme);
//        2 : mode2_D(sendme);
//      end;
    end;
//decrypt
end;

procedure TForm1.Enc_BtnClick(Sender: TObject);   //encrypt
begin
  dfname := 'E_'+tpath.GetFileName(sfname);
  savefile.FileName := dfname;
  if savefile.Execute then
    begin
      sendme.pw := password.Text;
      assignFile(keyfile, kfname);
      reset(keyfile);
      read(keyfile, TheKey);
      closeFile(keyfile);
      sendme.key := thekey;
      sendme.sf := sfname;
      dfname := savefile.FileName;
      sendme.df := dfname;
      logit('Encrypt');
      mode0_e(sendme);
//      case mode of
//        0 : mode0_E(sendme);
//        1 : mode1_E(sendme);
//        2 : mode2_E(sendme);
//      end;
    end;
//encrypt
end;

procedure TForm1.File_iconClick(Sender: TObject); //select file
begin
  Getsrc.Execute;
  sfname := Getsrc.FileName;
  Label_File.Caption := TPath.GetFileName(sfname);
  if (sfname <> '') and (kfname <> '') then
    begin
      Enc_Btn.Enabled := True;
      Dec_Btn.Enabled := True;
    end;
  dfname := '';
end;

procedure TForm1.Key_iconClick(Sender: TObject);  //select Key
begin
  GetKey.DefaultFolder := extractfilepath(application.ExeName);
  if GetKey.Execute then
    begin
      kfname := getkey.FileName;
      Label_key.Caption := TPath.GetFileNameWithoutExtension(kfname);
    end;
  if (sfname <> '') and (kfname <> '') then
    begin
      Enc_Btn.Enabled := True;
      Dec_Btn.Enabled := True;
    end;
end;

procedure TForm1.Label_FileClick(Sender: TObject);
begin
  Getsrc.Execute;
  sfname := Getsrc.FileName;
  Label_File.Caption := TPath.GetFileName(sfname);
  if (sfname <> '') and (kfname <> '') then
    begin
      Enc_Btn.Enabled := True;
      Dec_Btn.Enabled := True;
    end;
  dfname := '';
end;

procedure TForm1.Label_KeyClick(Sender: TObject);
begin
  GetKey.DefaultFolder := extractfilepath(application.ExeName);
  if GetKey.Execute then
    begin
      kfname := getkey.FileName;
      Label_key.Caption := TPath.GetFileNameWithoutExtension(kfname);
    end;
  if (sfname <> '') and (kfname <> '') then
    begin
      Enc_Btn.Enabled := True;
      Dec_Btn.Enabled := True;
    end;
end;

procedure TForm1.Password_iconClick(Sender: TObject); //generate random password
const
  pullme: array[0..89] of char = ('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
  '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
  ' ','-','_','(',')','!','@','#','$','%','^','&','*','+','=','?',',','.','<','>','/','\','[',']','{','}','|','~') ;
var
  tempstring : String;
  workinglength, templength : byte;
begin
  templength:= 12+random(29);
  tempstring:='';
  for workinglength := 0 to templength do tempstring:=tempstring+pullme[random(90)];
  Password.Text := tempstring;
end;

end.
