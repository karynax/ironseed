unit gmouse;
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

{***************************
   Mouse Utilities unit for IronSeed

   Channel 7
   Destiny: Virtual


   Copyright 1994

***************************}

interface

type
 mouseicontype = array[0..15,0..15] of byte;
 mousetype =
  object
   error: boolean;
   x,y: integer;
   procedure setmousecursor(n: integer);
   function getstatus : boolean;
  end;
var
 mouse: mousetype;
 oldmouseexitproc: pointer;
 mdefault: mouseicontype;

procedure mousehide;
procedure mouseshow;
procedure mousesetcursor(i: mouseicontype);

implementation

uses crt, graph;

{$L mouse}
{$F+}
procedure mousehide; external;
procedure mousesetcursor(i: mouseicontype); external;
procedure mouseshow; external;
procedure mousemove; external;
function mouseinitialize: boolean; external;
{$F-}

function mousetype.getstatus : boolean; assembler;
asm
 xor bx, bx
 mov ax, 6
  int 33h
 cmp bx, 0
 je @@notpressed
 shr cx, 1
 mov mouse.x, cx
 mov mouse.y, dx
 xor ax, ax
 test bx, 1
 jz @@done
 inc ax
 jmp @@done
@@notpressed:
 mov ax, 03h
  int 33h
 xor ax, ax
 shr cx, 1
 mov mouse.x, cx
 mov mouse.y, dx
@@done:
end;

{$F+}
procedure mouseexitproc;
{$F-}
begin
 asm
  mov ax, 21h
   int 33h
 end;
 exitproc:=oldmouseexitproc;
end;

procedure errorhandler(s: string; errtype: integer);
begin
 closegraph;
 writeln;
 case errtype of
  1: writeln('File Error: ',s);
  2: writeln('Mouse Error: ',s);
  3: writeln('Sound Error: ',s);
  4: writeln('EMS Error: ',s);
  5: writeln('Fatal File Error: ',s);
  6: writeln('Program Error: ',s);
  7: writeln('Music Error: ',s);
 end;
 halt(4);
end;

procedure mousetype.setmousecursor(n: integer);
type
    weaponicontype= array[0..19,0..19] of byte;
var i: integer;
    f: file of weaponicontype;
    tempicon: ^weaponicontype;
begin
 new(tempicon);
 assign(f,'data\weapicon.dta');
 reset(f);
 if ioresult<>0 then errorhandler('weapicon.dta',1);
 seek(f,n+87);
 if ioresult<>0 then errorhandler('weapicon.dta',5);
 read(f,tempicon^);
 if ioresult<>0 then errorhandler('weapicon.dta',5);
 close(f);
 for i:=0 to 15 do
  move(tempicon^[i],mdefault[i],16);
 mousesetcursor(mdefault);
 dispose(tempicon);
end;

begin
 if not mouseinitialize then errorhandler('Mouse required for play.',2)
 else
  begin
   mouse.error:=false;
   oldmouseexitproc:=exitproc;
   exitproc:=@mouseexitproc;
   mouse.setmousecursor(0);
  end;
end.