unit heapchk;
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

interface
procedure WriteHexWord(w: Word);
procedure HeapStats;
function HeapFunc (Size: Word): Integer; far;
function GetHeapStats:String;
function GetHeapStats1:String;
function GetHeapStats2:String;

procedure HeapShow;

implementation
uses crt,saveload;
procedure WriteHexWord(w: Word);
const
 hexChars: array [0..$F] of Char =
   '0123456789ABCDEF';
begin
 Write(hexChars[Hi(w) shr 4],
       hexChars[Hi(w) and $F],
       hexChars[Lo(w) shr 4],
       hexChars[Lo(w) and $F]);
end;
procedure HeapStats;
var heaptotal: LongInt;
begin
     write('heap: HeapEnd(');
     WriteHexWord(SEG(HeapEnd^));
     Write(':');
     WriteHexWord(OFS(HeapEnd^));
     Write(') HeapOrg(');
     WriteHexWord(SEG(HeapOrg^));
     Write(':');
     WriteHexWord(OFS(HeapOrg^));
     Write(') HeapPtr(');
     WriteHexWord(SEG(HeapPtr^));
     Write(':');
     WriteHexWord(OFS(HeapPtr^));
     WriteLn(')');
     heaptotal := SEG(HeapEnd^) - SEG(HeapOrg^);
     heaptotal := (heaptotal shl 4) + OFS(HeapEnd^) - OFS(HeapOrg^);
     WriteLn('heap: TotalSize(', heaptotal, ') MaxAvail(', MaxAvail, ') MemAvail(', MemAvail, ')');
end; { HeapStats }

function GetHeapStats1:String;
var
   heaptotal : LongInt;
   s1	     : String;
begin
   heaptotal := SEG(HeapEnd^) - SEG(HeapOrg^);
   heaptotal := (heaptotal shl 4) + OFS(HeapEnd^) - OFS(HeapOrg^);
   str(heaptotal, s1);
   GetHeapStats1 := 'heap: TotalSize(' + s1 + ')';
end;

function GetHeapStats2:String;
var
   s2, s3 : String;
begin
   str(MaxAvail, s2);
   str(MemAvail, s3);
   GetHeapStats2 := 'MaxAvail(' + s2 + ') MemAvail(' + s3 + ')';
end;

function GetHeapStats:String;
var
   heaptotal  : LongInt;
   s1, s2, s3 : String;
begin
   heaptotal := SEG(HeapEnd^) - SEG(HeapOrg^);
   heaptotal := (heaptotal shl 4) + OFS(HeapEnd^) - OFS(HeapOrg^);
   str(heaptotal, s1);
   str(MaxAvail, s2);
   str(MemAvail, s3);
   GetHeapStats := 'heap: TotalSize(' + s1 + ') MaxAvail(' + s2 + ') MemAvail(' + s3 + ')';
end;

function HeapFunc (Size: Word): Integer;
begin
     if Size = 0 then begin
        HeapFunc := 0;
        exit;
     end;
     textmode(co80);
     writeln('alloc failure: size(', Size, ')');
     HeapStats;
     HeapFunc := 0;
end;
procedure HeapShow;
var s1,s2:string[11];
begin
     str(MaxAvail, s1);
     str(MemAvail, s2);
     yesnorequest('Avail:' + s2 + ' MaxAlloc:' +s1,0,31);
     {textmode(co80);
     writeln('Avail:', s2, ' MaxAlloc:', s1);}
end;
end.
