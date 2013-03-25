program detectsoundinformation;
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

{$I DSMI.INC}, strings,crt,MCP,DET_SB,DET_PAS,DET_ARIA,DETGUS;

var
 scard: TSoundCard;


function HexWord(w: Word) : String;
const
 hexChars: array [0..$F] of Char =
   '0123456789ABCDEF';
begin
   HexWord := {hexChars[Hi(w) shr 4] +} hexChars[Hi(w) and $F] + hexChars[Lo(w) shr 4] + hexChars[Lo(w) and $F];
end;

procedure detectcardinfo(scard: PSoundCard);
var
 a: integer;
begin
 a:=0;
 fillchar(scard^,sizeof(scard^),0);
 a:=detectGUS(scard);
 if a<>0 then a:=detectPAS(scard);
 if a<>0 then a:=detectSB16(scard);
 if a<>0 then a:=detectAria(scard);
 if a<>0 then a:=detectSBPro(scard);
 if a<>0 then a:=detectSB(scard);
end;

procedure displaydata;
begin
 writeln(#13#10'Sound Card : ',strpas(scard.name));
 writeln('Port       : ',HexWord(scard.ioport),'h');
 writeln('IRQ        : ',scard.dmairq);
 writeln('DMA Channel: ',scard.dmachannel);
 writeln('Mix Rate   : ',scard.maxrate);
end;

begin
 detectcardinfo(@scard);
 displaydata;
end.
