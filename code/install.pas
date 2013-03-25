program installit;
(********************************************************************
    This file is part of Ironseed.

    Ironseed is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Ironseed is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Ironseed.  If not, see <http://www.gnu.org/licenses/>.
********************************************************************)

{$M 4000,0,0}
{
  Installation Unit for IronSeed

  Copyright 1994

  Channel 7
  Destiny: Virtual

}


uses dos, crt, win, getcpu, mcp, Det_SB, Det_PAS, Det_ARIA, DetGUS, emhm;

var
 i,j: integer;
 sc: tsoundcard;
 target: string[50];
 doit: boolean;

function fastkeypressed: boolean; assembler;
asm
 push ds
 mov ax, 40h
 mov ds, ax
 cli
 mov ax, [1Ah]
 cmp ax, [1Ch]
 sti
 mov ax, 0
 jz @nopress
 inc ax
@nopress:
 pop ds
end;

function testvga : boolean; assembler;
asm
 mov ax, 1A00h
  int 10h
 cmp al, 1Ah
 jne @@nope
 mov ax, 1
 jmp @@done
@@nope:
 mov ax, 0
@@done:
end;

function testmouse: boolean; assembler;
asm
 mov ax, 0
  int 33h
end;

procedure getconfiguration(y: integer);
var str1: string[19];
begin
 window(25,y,54,y+7);
 fillwin(' ',$00);
 framewin('System Configuration',doubleframe,$09,$01);
 writestr(2,1,'CPU:',$08);
 writestr(2,2,'Sound:',$08);
 writestr(2,3,'VGA:',$08);
 writestr(2,4,'Mouse:',$08);
 writestr(2,5,'EMS (1 Mb):',$08);
 writestr(2,6,'TEMP Dir.:',$08);
 i:=getcputype;
 if i and 4>0 then str1:='486'
  else if i and 2>0 then str1:='386'
  else if i and 1>0 then str1:='286'
  else str1:='???';
 writestr(25,1,str1,$0F);
 if testvga then str1:='Yes' else str1:=' No';
 writestr(25,3,str1,$0F);
 if testmouse then str1:='Yes' else str1:=' No';
 writestr(25,4,str1,$0F);
 if emsinit(1024,1024)=0 then str1:='Yes' else str1:=' No';
 writestr(25,5,str1,$0F);
 str1:=getenv('TEMP');
 writestr(28-length(str1),6,str1,$0F);
 i:=detectGUS(@sc);
 if i<>0 then i:=detectPAS(@sc);
 if i<>0 then i:=detectSB16(@sc);
 if i<>0 then i:=detectAria(@sc);
 if i<>0 then i:=detectSBPro(@sc);
 if i<>0 then i:=detectSB(@sc);
 if i=0 then
  case sc.id of
   ID_SB:      str1:='       SoundBlaster';
   ID_SBPro:   str1:='   SoundBlaster Pro';
   ID_SB16:    str1:='    SoundBlaster 16';
   ID_ARIA:    str1:='               Aria';
   ID_PAS:     str1:='  ProAudio Spectrum';
   ID_PASplus: str1:=' ProAudio Spectrum+';
   ID_PAS16:   str1:='ProAudio Spectrum16';
   ID_GUS:     str1:='  Gravis UltraSound';
   else        str1:='  Sound Card Error!';
  end
 else str1:='               None';
 writestr(9,2,str1,$0F);
end;

procedure titlemessage;
begin
 window(20,2,59,6);
 framewin('',singleframe,$09,$01);
 fillwin(' ',$00);
 writestr(15,1,'Channel 7',magenta);
 writestr(11,2,'Destiny : Virtual',lightblue);
end;

function readname: boolean;
var cur: integer;
    ans: char;
    done: boolean;
begin
 cur:=50;
 while target[cur]=' ' do dec(cur);
 if cur<50 then inc(cur);
 done:=false;
 ans:=' ';
 repeat
  gotoxy(1,1);
  write(target);
  gotoxy(cur,1);
  ans:=readkey;
  case upcase(ans) of
   #0:
    begin
     ans:=readkey;
     case ans of
      #77:if cur<50 then inc(cur);
      #75:if cur>1 then dec(cur);
      #83:begin
           for j:=cur to 49 do
            target[j]:=target[j+1];
           target[50]:=' ';
          end;
     end;
    end;
   #8:
    begin
     if cur>1 then dec(cur);
     for j:=cur to 49 do
      target[j]:=target[j+1];
     target[50]:=' ';
    end;
    ' ' ..'"',''''..'?','A' ..'Z','%','a'..'z','\':
    begin
     for j:=50 downto cur+1 do
      target[j]:=target[j-1];
     target[cur]:=ans;
     if cur<50 then inc(cur);
    end;
   #27: done:=true;
  end;
 until (ans=#13) or (done);
 if not done then readname:=true else readname:=false;
end;

procedure errorbox(s: string);
begin
 window(13,20,67,22);
 fillwin(' ',$00);
 framewin('Error!',doubleframe,$0f,$04);
 writestr((54-length(s)) div 2,1,s,$04);
 readkey;
 while fastkeypressed do readkey;
 window(12,20,68,24);
 fillwin(chr($B0),$78);
 window(15,18,65,18);
end;

function chkcreate: boolean;
begin
 mkdir(target);
 if ioresult<>0 then
  begin
   errorbox('Can''t Create that Directory!');
   chkcreate:=true;
  end
 else chkcreate:=false;
end;

procedure copystuff;
begin
 window(1,1,80,25);
 clrscr;
 textcolor(15);
 gotoxy(1,1);
 while target[length(target)]=' ' do dec(target[0]);
 swapvectors;
 exec('pkunzip.exe','is.zip '+target+' -d');
 swapvectors;
end;

procedure getdestination;
var ans: char;
    error: boolean;
begin
 fillchar(target[1],50,ord(' '));
 target:='C:\IS';
 target[0]:=#50;
 window(13,17,67,19);
 fillwin(' ',$00);
 framewin('Target',singleframe,$09,$01);
 textcolor(15);
 window(15,18,65,18);
 doit:=false;
 repeat
  doit:=readname;
  if doit then error:=chkcreate;
  if (doit) and (error) then
   begin
    fillchar(target[1],50,ord(' '));
    target:='C:\IS';
    target[0]:=#50;
   end;
 until ((doit) and (not error)) or (not doit);
 if (doit) and (not error) then copystuff;
end;

procedure initialize;
begin
 fillwin(chr($B0),$78);
 writestr(54,25,'(C) Channel 7, Dec. 1, 1993',$78);
 titlemessage;
 getconfiguration(8);
 getdestination;
end;

begin
 clrscr;
 textmode(co80);
 initialize;
 window(1,1,80,25);
 clrscr;
end.