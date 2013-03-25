ideal
p486
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

global mymove: far
global fillchar386: far
global move386: far
global fillchar286: far
global move286: far
global move: far
global fillchar: far

segment mover_text word 'code'
assume cs: mover_text

proc mymove far
  ; 12 source
  ; 8  destination
  ; 6  dwords to move
 push bp
 mov bp, sp
 push ds
 push es
 lds si, [ss: bp+12]
 les di, [ss: bp+8]
 mov cx, [ss: bp+6]
 rep movsd
 pop es
 pop ds
 pop bp
 retf 10
endp mymove

proc move far
  ; 12 source
  ; 8  destination
  ; 6  bytes to move
 push bp
 mov bp, sp
 push ds
 push es
 lds si, [ss: bp+12]
 les di, [ss: bp+8]
 mov cx, [ss: bp+6]
 mov bx, cx
 and bx, 3
 shr cx, 2
 rep movsd
 or bx, bx
 jz @@end
 mov cx, bx
 rep movsb
@@end:
 pop es
 pop ds
 pop bp
 retf 10
endp move

proc fillchar far
  ; 10 target
  ; 8  byte count
  ; 6  databyte
 push bp
 mov bp, sp
 push es
 les di, [ss:bp+10]   ; target
 mov al, [ss:bp+6]    ; byte type
 mov ah, al
 mov bx, ax
 shl eax, 16
 mov ax, bx           ; copy out byte to all bytes in eax
 mov cx, [ss:bp+8]
 mov bx, cx
 and bx, 3            ; extra
 shr cx, 2            ; dwords in cx
 rep stosd            ; copy to target
 or bx, bx
 jz @@end
 mov cx, bx
 rep stosb            ; do the extra
@@end:
 pop es
 pop bp
 retf 8
endp fillchar

proc move386 far
  ; 12 source
  ; 8  destination
  ; 6  bytes to move
 push bp
 mov bp, sp
 push ds
 push es
 push di
 push si
 lds si, [ss: bp+12]
 les di, [ss: bp+8]
 mov cx, [ss: bp+6]
 mov bx, cx
 and bx, 3
 shr cx, 2
 rep movsd
 or bx, bx
 jz @@end
 mov cx, bx
 rep movsb
@@end:
 pop si
 pop di
 pop es
 pop ds
 pop bp
 retf 10
endp move386

proc move286 far
 push bp
 mov bp, sp
 push ds
 push es
 push di
 push si
 lds si, [ss: bp+12]
 les di, [ss: bp+8]
 mov cx, [ss: bp+6]
 mov bx, cx
 and bx, 1
 shr cx, 1
 rep movsw
 or bx, bx
 jz @@end
 mov cx, bx
 rep movsb
@@end:
 pop si
 pop di
 pop es
 pop ds
 pop bp
 retf 10
endp move286

proc fillchar386 far
  ; 10 target
  ; 8  byte count
  ; 6  databyte
 push bp
 mov bp, sp
 push es
 push di
 les di, [ss:bp+10]   ; target
 mov al, [ss:bp+6]    ; byte type
 mov ah, al
 mov bx, ax
 shl eax, 16
 mov ax, bx           ; copy out byte to all bytes in eax
 mov cx, [ss:bp+8]
 mov bx, cx
 and bx, 3            ; extra
 shr cx, 2            ; dwords in cx
 rep stosd            ; copy to target
 or bx, bx
 jz @@end
 mov cx, bx
 rep stosb            ; do the extra
@@end:
 pop di
 pop es
 pop bp
 retf 8
endp fillchar386

proc fillchar286 far
  ; 10 target
  ; 8  byte count
  ; 6  databyte
 push bp
 mov bp, sp
 push es
 push di
 les di, [ss:bp+10]   ; target
 mov al, [ss:bp+6]    ; byte type
 mov ah, al
 mov bx, ax
 shl eax, 16
 mov ax, bx           ; copy out byte to all bytes in eax
 mov cx, [ss:bp+8]
 mov bx, cx
 and bx, 1            ; extra
 shr cx, 1	      ; words in cx
 rep stosw            ; copy to target
 or bx, bx
 jz @@end
 mov cx, bx
 rep stosb            ; do the extra
@@end:
 pop di
 pop es
 pop bp
 retf 8
endp fillchar286

ends mover_text
end
