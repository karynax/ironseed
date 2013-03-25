;********************************************************************
;    This file is part of Ironseed.
;
;    Ironseed is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    Ironseed is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with Ironseed.  If not, see <http://www.gnu.org/licenses/>.
;********************************************************************

ideal
p486

global mymove2: near


segment mover_text word 'code'
assume cs: mover_text

proc mymove2 near
 mov bx, sp
 push ds
 push es
 lds si, [ss: bx+8]
 les di, [ss: bx+4]
 mov cx, [ss: bx+2]
 cld
 rep movsd
 pop es
 pop ds
 ret 10   
endp mymove2

ends mover_text
end
