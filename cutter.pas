unit cutter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage;

const
  rando: array[0..64] of char = ('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
                                 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
                                 '0','1','2','3','4','5','6','7','8','9','-','_',' ');
  ext: string[3] = 'keÿ';

type
  TForm1 = class(TForm)
    Input_Name: TEdit;
    Input_Qty: TEdit;
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Image1: TImage;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  singlekey = array [0..255] of byte;
  keyring = array [0..255] of singlekey;

var
  Form1: TForm1;
  keyset_f, keyset_b : keyring;                  //keyset_f = for encryption | keyset_b = for decryption
  finalproduct : file of keyring;                //keyring file
  tempstring : string;                           //filename
  blank_key, wip_key, fin_key : singlekey;       //blank_key = content matches index | wip_key = key being cut | fin_key = finished key
  xx1,xx2,sh1,sh2,sh3,kc : byte;                 //sh1-sh3 for shuffling | kc = key count


implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);   //start
begin
  if not (Input_Name.Text='') then
    begin
      xx1:=StrToIntDef(Input_Qty.Text, 1);
      if xx1<1 then xx1:=1;
      for xx2 := 1 to xx1 do
      begin
        if xx1=1 then tempstring:=Input_Name.Text+'.'+ext else tempstring:=Input_Name.Text+' ['+IntToStr(xx2)+']'+'.'+ext;
        assignfile(finalproduct, tempstring);
        for sh1 := 0 to 255 do
          begin
            blank_key[sh1] := sh1;
          end;
        for kc := 0 to 255 do
          begin
            wip_key := blank_key;
            for sh1 := 0 to 255 do
              begin
                sh2 := random(256);
                sh3 := wip_key[sh1];
                wip_key[sh1] :=wip_key[sh2];
                wip_key[sh2] := sh3;
              end;
            for sh1 := 0 to 255 do
              begin
                sh2 := random(256);
                sh3 := wip_key[sh1];
                wip_key[sh1] :=wip_key[sh2];
                wip_key[sh2] := sh3;
              end;
            keyset_f[kc] := wip_key;
          end;
          //encryption key finished.
        for kc := 0 to 255 do
          begin
            fin_key := keyset_f[kc];
            for sh1 := 0 to 255 do
              begin
                sh2 := fin_key[sh1];
                wip_key[sh2] := sh1;
              end;
            keyset_b[kc] := wip_key;
          end;
        //decryption key finished.
        rewrite (finalproduct);
        write (finalproduct, keyset_f);
        write (finalproduct, keyset_b);
        closefile (finalproduct);
      end;
    end
      else
    begin
      xx1:=0;
    end;
end;

procedure TForm1.Label1Click(Sender: TObject);    //Random Name
begin
  sh1:=5+random(16);
  tempstring:='';
  for sh2 := 0 to sh1 do tempstring:=tempstring+rando[random(65)];
  Input_Name.Text:=tempstring;
end;

end.
