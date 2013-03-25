program ConfigureFrinj;
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

{$M 2000,0,0}

uses crt, strings, dos;

type
   configfile = 
   record     
      tslice,rate,soundcard,irq,dma,port,stereo,music : word;
   end;	      
   bloentry   = 
   record     
      filename	      : array[0..13] of char;
      offset,filesize : longint;
   end;	      
   bloheader  = 
   record     
      signature	: array[0..3] of char;
      version	: integer;
      entries	: array[0..255] of bloentry;
      checksum	: longint;
   end;
const
   validports: array[0..9,0..7] of Word	= (
($ffff,$ffff,$ffff,$ffff, $ffff,$ffff,$ffff,$ffff),{auto}
($220,$230,$240,$250,$260,$210,$ffff,$ffff),{SB}
($220,$230,$240,$250,$260,$210,$ffff,$ffff),{SB Pro}
($220,$240,$260,$280,$ffff,$ffff,$ffff,$ffff),{SB 16}
($ffff,$ffff,$ffff,$ffff, $ffff,$ffff,$ffff,$ffff),{aria}
($388,$384,$38C,$288,$ffff,$ffff,$ffff,$ffff),{PAS}
($388,$384,$38C,$288,$ffff,$ffff,$ffff,$ffff),{PAS+}
($388,$384,$38C,$288,$ffff,$ffff,$ffff,$ffff),{PAS16}
($ffff,$ffff,$ffff,$ffff, $ffff,$ffff,$ffff,$ffff),{GUS}
($ffff,$ffff,$ffff,$ffff, $ffff,$ffff,$ffff,$ffff){auto}
);
   validirqs: array[0..9,0..8] of Word = (
($ffff,$ffff,$ffff,$ffff, $ffff,$ffff,$ffff,$ffff ,$ffff),{auto}
(7,2,3,5,$ffff,$ffff,$ffff,$ffff,$ffff),{SB}
(5,7,2,3,$ffff,$ffff,$ffff,$ffff,$ffff),{SB Pro}
(5,7,10,2,$ffff,$ffff,$ffff,$ffff,$ffff),{SB 16}
($ffff,$ffff,$ffff,$ffff, $ffff,$ffff,$ffff,$ffff,$ffff),{aria}
(7,10,11,12,13,15,2,3,5),{PAS}
(7,10,11,12,13,15,2,3,5),{PAS+}
(7,10,11,12,13,15,2,3,5),{PAS16}
($ffff,$ffff,$ffff,$ffff, $ffff,$ffff,$ffff,$ffff,$ffff),{GUS}
($ffff,$ffff,$ffff,$ffff, $ffff,$ffff,$ffff,$ffff,$ffff){auto}
);
   validdmas: array[0..9,0..5] of Word = (
($ffff,$ffff,$ffff,$ffff, $ffff,$ffff),{auto}
(1,$ffff,$ffff,$ffff,$ffff,$ffff),{SB}
(1,3,0,$ffff,$ffff,$ffff),{SB Pro}
(5,6,7,0,1,3),{SB 16}
($ffff,$ffff,$ffff, $ffff,$ffff,$ffff),{aria}
(1,3,5,6,7,0),{PAS}
(1,3,5,6,7,0),{PAS+}
(1,3,5,6,7,0),{PAS16}
($ffff,$ffff,$ffff, $ffff,$ffff,$ffff),{GUS}
($ffff,$ffff,$ffff, $ffff,$ffff,$ffff){auto}
);
var	      
   done		   : boolean;
   cf		   : configfile;
   ans		   : char;
   str1		   : string[19];
   cursor,i	   : byte;
   head, scrambled : bloheader;

function HexWord(w: Word) : String;
const
 hexChars: array [0..$F] of Char =
   '0123456789ABCDEF';
begin
   HexWord := {hexChars[Hi(w) shr 4] +} hexChars[Hi(w) and $F] + hexChars[Lo(w) shr 4] + hexChars[Lo(w) and $F];
end;

function getsoundcardname: string;
begin
   case cf.soundcard of
     0 : getsoundcardname:='Auto Detect        ';
     1 : getsoundcardname:='SoundBlaster       ';
     2 : getsoundcardname:='SoundBlaster Pro   ';
     3 : getsoundcardname:='SoundBlaster 16    ';
     4 : getsoundcardname:='Aria               ';
     5 : getsoundcardname:='ProAudio Spectrum  ';
     6 : getsoundcardname:='ProAudio Spectrum+ ';
     7 : getsoundcardname:='ProAudio Spectrum16';
     8 : getsoundcardname:='Gravis UltraSound  ';
     9 : getsoundcardname:='None               ';
   else getsoundcardname:='Unknown!           ';
   end;
end;

procedure titlemessage;
begin
   fillwin(chr($B0),$78);
   writestr(63,25,'(C) Channel 7 1994',$78);
   window(1,1,80,4);
   framewin('',singleframe,$1B,$1B);
   fillwin(' ',$19);
   writestr(35,1,'Channel 7',$1B);
   writestr(31,2,'Destiny : Virtual',$1D);
   window(21,10{9},60,17);
   fillwin(chr($B0),$08);
   window(20,9{8},59,16);
   fillwin(' ',$09);
   framewin('System Configuration',doubleframe,$09,$09);
   {writestr(2,1,'Computer Speed:',$09);
   writestr(2,2,'Music Active  :',$09);}
   writestr(2,1,'Sound Card    :',$09);
   writestr(2,2,'Port          :',$09);
   writestr(2,3,'Soundcard IRQ :',$09);
   writestr(2,4,'Soundcard DMA :',$09);
   writestr(2,5,'Sampling Rate :',$09);
   writestr(2,6,'Stereo        :',$09);
end;

procedure display;
begin

   case cf.tslice of
     0	: str1:='12 Mhz SLOOOOWWWW   ';
     5	: str1:='16 Mhz Very Slow    ';
     10	: str1:='25 Mhz Slow         ';
     25	: str1:='33 Mhz Average      ';
     40	: str1:='50 Mhz Fast         ';
     50	: str1:='66 Mhz Very Fast    ';
     80	: str1:='99 Mhz Insane       ';
   end;	

   if cursor=1 then i:=$1B else i:=$09;
   {writestr(18,1,str1,i);}

   if cf.music=1 then str1:='Active             ' else str1:='Inactive           ';
   if cursor=2 then i:=$1B else i:=$09;
   {writestr(18,2,str1,i);}

   if cursor=3 then i:=$1B else i:=$09;
   writestr(18,1,getsoundcardname,i);
   
   if cursor=4 then i:=$1B else i:=$09;
   if cf.port = $ffff then
      writestr(18,2,   'N/A                ',i)
   else
      writestr(18,2,HexWord(cf.port) + 'h              ',i);
      

   fillchar(str1[1],19,$20);
   str(cf.irq,str1);
   str1[0]:=#19;
   if cursor=5 then i:=$1B else i:=$09;
   if cf.irq = $ffff then
      str1 := 'N/A                ';
   writestr(18,3,str1,i);
   
   fillchar(str1[1],19,$20);
   str(cf.dma,str1);
   str1[0]:=#19;
   if cursor=6 then i:=$1B else i:=$09;
   if cf.dma = $ffff then
      str1 := 'N/A                ';
   writestr(18,4,str1,i);

   fillchar(str1[1],19,$20);
   str(cf.rate,str1);
   str1[0]:=#19;
   if cursor=7 then i:=$1B else i:=$09;
   writestr(18,5,str1,i);

   if cf.stereo=1 then str1:='Stereo             ' else str1:='Mono               ';
   if cursor=8 then i:=$1B else i:=$09;
   writestr(18,6,str1,i);
   
end;

function changevalue(list : array of Word; item : Word; max : Integer; dir : Integer) : Word;
var
   i, j	: Integer;
   {str1	: string;}
begin
   if item = $ffff then
   begin
      changevalue := $ffff;
      exit;
   end;
   j := -1;
   for i := 0 to max do
   begin
      {str(list[i], str1);
      writestr(1,i + 1,str1,$0f);}
      if item = list[i] then
      begin
	 j := i;
	 break;
      end;
   end;
   if j < 0 then
   begin
      changevalue := list[0];
      exit;
   end;
   j := j + dir;
   if (j > max) or (list[j] = $ffff) then
   begin
      changevalue := list[0];
      exit;
   end;
   if j < 0 then
   begin
      for i := max downto 0 do
	 if list[i] <> $ffff then
	 begin
	    changevalue := list[i];
	    exit;
	 end;
      changevalue := list[0];
   end;
   changevalue := list[j];
end;

procedure addcursor;
begin
 case cursor of
  1: case cf.tslice of
       0: cf.tslice:=5;
       5: cf.tslice:=10;
      10: cf.tslice:=25;
      25: cf.tslice:=40;
      40: cf.tslice:=50;
      50: cf.tslice:=80;
     end;
  2: if cf.music=1 then cf.music:=0 else cf.music:=1;
  3: begin
	if cf.soundcard<9 then inc(cf.soundcard) else cf.soundcard:=0;
	cf.port	:= validports[cf.soundcard,0];
	cf.irq	:= validirqs[cf.soundcard,0];
	cf.dma	:= validdmas[cf.soundcard,0];
     end;
  4: cf.port := changevalue(validports[cf.soundcard], cf.port, 7, 1);
  5: {if cf.irq<12 then inc(cf.irq) else cf.irq:=2;}
     cf.irq := changevalue(validirqs[cf.soundcard], cf.irq,8,1);
  6: {if cf.dma<7 then inc(cf.dma) else cf.dma:=0;}
     cf.dma := changevalue(validdmas[cf.soundcard], cf.dma,5,1);
  7: case cf.rate of
       8000: cf.rate:=12000;
      12000: cf.rate:=16000;
      16000: cf.rate:=22050;
      22050: cf.rate:=44100;
     end;
  8: if cf.stereo=1 then cf.stereo:=0 else cf.stereo:=1;
 end;
end;

procedure subcursor;
begin
 case cursor of
  1: case cf.tslice of
       5: cf.tslice:=0;
      10: cf.tslice:=5;
      25: cf.tslice:=10;
      40: cf.tslice:=25;
      50: cf.tslice:=40;
      80: cf.tslice:=50;
     end;
  2: if cf.music=1 then cf.music:=0 else cf.music:=1;
  3: begin
	if cf.soundcard>0 then dec(cf.soundcard) else cf.soundcard:=9;
	cf.port	:= validports[cf.soundcard,0];
	cf.irq	:= validirqs[cf.soundcard,0];
	cf.dma	:= validdmas[cf.soundcard,0];
     end;
  4: cf.port := changevalue(validports[cf.soundcard], cf.port,7, -1);
  5: {if cf.irq>2 then dec(cf.irq) else cf.irq:=12;}
     cf.irq := changevalue(validirqs[cf.soundcard], cf.irq,8,-1);
  6: {if cf.dma>0 then dec(cf.dma) else cf.dma:=7;}
     cf.dma := changevalue(validdmas[cf.soundcard], cf.dma,5,-1);
  7: case cf.rate of
      12000: cf.rate:=8000;
      16000: cf.rate:=12000;
      22050: cf.rate:=16000;
      44100: cf.rate:=22050;
     end;
  8: if cf.stereo=1 then cf.stereo:=0 else cf.stereo:=1;
 end;
end;

procedure mainloop;
begin
 done:=false;
 cursor:=3;
 repeat
  display;
  ans:=readkey;
  case ans of
    #0: begin
         ans:=readkey;
         case ans of
          #80: if cursor=8 then cursor:=3{1} else inc(cursor);
          #72: if cursor=3{1} then cursor:=8 else dec(cursor);
          #73,#77: addcursor;
          #81,#75: subcursor;
         end;
        end;
   '+': addcursor;
   '-': subcursor;
   #27: done:=true;
  end;
 until done;
end;

procedure errorhandler(s: string);
begin
   {writeln('*** ERROR SAVING FILE ***'#13);}
   writeln(s);
   halt(255);
end;

function loadconfigfile : boolean;
var
   f : file of configfile;
begin
   loadconfigfile := true;
   assign(f, 'sound.cfg');
   if ioresult<>0 then begin
      loadconfigfile := false;
      exit;
   end;
   reset(f);
   if ioresult<>0 then begin
      loadconfigfile := false;
      exit;
   end;
   read(f, cf);
   if ioresult<>0 then begin
      loadconfigfile := false;
   end;
   close(f);
end;

procedure saveconfigfile;
var
   f : file of configfile;
begin
   assign(f, 'sound.cfg');
   if ioresult<>0 then errorhandler('Can''t open "sound.cfg".');
   rewrite(f);
   if ioresult<>0 then errorhandler('Can''t open "sound.cfg".');
   write(f, cf);
   if ioresult<>0 then errorhandler('Unable to write to "sound.cfg".');
   close(f);
   if ioresult<>0 then errorhandler('Unable to close "sound.cfg".');
end;

begin
   if not loadconfigfile then
   begin
      cf.tslice:=40;
      cf.soundcard:=0;
      cf.rate:=44100;
      cf.irq:=$ffff;
      cf.dma:=$ffff;
      cf.music:=1;
      cf.stereo:=0;
      cf.port := $ffff;
   end;
   titlemessage;
   mainloop;
   window(1,1,80,25);
   clrscr;
   saveconfigfile;
   writeln(#13'Configuration Complete.');
end.
