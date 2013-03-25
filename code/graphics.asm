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

global mousehide: far
global mousesetcursor: far
global mouseshow: far
global mousemove: far
global mouseinitialize: far
global fastkeypressed: far
global setrgb256: far
global set256colors: far
global setvidmode: far

segment graphics_text word 'code'
assume cs: graphics_text

back   db 256 dup(0)
fore   db 256 dup(0)
hiding db 0
busy   db 0
mousex dw 160
mousey dw 100

proc mouseinitialize far
 push es
 mov ax, 0
  int 33h
 mov [cs: hiding], 1
 mov cx, 1
 mov ax, cs
 mov es, ax
 mov dx, offset mousemove
 mov ax, 0Ch
  int 33h
 mov cx, 0
 mov dx, 200
 mov ax, 08h
  int 33h
 mov cx, 0
 mov dx, 640
 mov ax, 07h
  int 33h
 sti
 pop es
 retf
endp mouseinitialize

proc mousehide far
 cli
 cmp [cs: busy], 0
 je @@checkhide
 sti
 retf
@@checkhide:
 cmp [cs: hiding], 0
 je @@continue
 inc [cs: hiding]
 sti
 retf
@@continue:
 mov [cs: busy], 1
 sti
 push bp
 push es
 push ds
 cld
 mov ax, 0A000h
 mov es, ax
 mov ax, cs
 mov ds, ax
 mov si, offset back
 mov dx, [cs: mousex]
 add dx, 16
 cmp dx, 319
 jg @@overflowx
 mov dx, 16
 jmp @@nooverflow
@@overflowx:
 mov dx, 320
 sub dx, [cs: mousex]
@@nooverflow:
 mov bp, [cs: mousey]
 add bp, 16
 cmp bp, 199
 jg @@overflowy
 mov bp, 16
 jmp @@drawset
@@overflowy:
 mov bp, 200
 sub bp, [cs: mousey]
@@drawset:
 mov bx, bp
 mov ax, [cs: mousey]
 imul di, ax, 320
 add di, [cs: mousex]
@@loop:
  mov cx, dx
  rep movsb
  add di, 320
  sub di, dx
  dec bx
 jnz @@loop
 mov [cs: hiding], 1
 pop ds
 pop es
 pop bp
 mov [cs: busy], 0
 retf
endp mousehide

proc mousesetcursor far
 push bp
 mov bp, sp
 push es
 push ds
 cld
 mov ax, [ss:bp+8]
 mov ds, ax
 mov si, [ss:bp+6]
 mov ax, cs
 mov es, ax
 mov di, offset fore
 mov cx, 64
  rep movsd
 pop ds
 pop es
 pop bp
 retf 4
endp mousesetcursor

proc mouseshow far
 cli
 cmp [cs: busy], 0
 je @@checkhide
 sti
 retf
@@checkhide:
 cmp [cs: hiding], 1
 je @@notshown
 dec [cs: hiding]
 sti
 retf
@@notshown:
 mov [cs: busy], 1
 sti
 push bp
 push es
 push ds
 cld
 mov ax, 0A000h
 mov ds, ax
 mov ax, cs
 mov es, ax
 mov di, offset back
 mov dx, [cs: mousex]
 add dx, 16
 cmp dx, 319
 jg @@overflowx
 mov dx, 16
 jmp @@nooverflow
@@overflowx:
 mov dx, 320
 sub dx, [cs: mousex]
@@nooverflow:
 mov bp, [cs: mousey]
 add bp, 16
 cmp bp, 199
 jg @@overflowy
 mov bp, 16
 jmp @@drawset
@@overflowy:
 mov bp, 200
 sub bp, [cs: mousey]
@@drawset:
 mov bx, bp
 mov ax, [cs: mousey]
 imul si, ax, 320
 add si, [cs: mousex]
@@loop:
  mov cx, dx
  rep movsb
  add si, 320
  sub si, dx
  dec bx
 jnz @@loop
 mov ax, 0A000h
 mov es, ax
 mov ax, cs
 mov ds, ax
 mov bx, bp
 mov si, offset fore
 mov ax, [cs: mousey]
 dec ax
 imul di, ax, 320
 add di, [cs: mousex]
 add di, dx
 sub si, 16
 add si, dx
@@loopy:
 add di, 320
 sub di, dx
 mov cx, dx
 add si, 16
 sub si, dx
@@loopx:
  mov al, [ds: si]
  cmp al, 255
  je @@continue
  mov [es: di], al
@@continue:
  inc di
  inc si
  dec cx
  jnz @@loopx
 dec bx
 jnz @@loopy
 mov [cs: hiding], 0
 pop ds
 pop es
 pop bp
 mov [cs: busy], 0
 retf
endp

proc mousemove far
 cli
 cmp [cs: busy], 0
 je @@checkhide
 sti
 retf
@@checkhide:
 cmp [cs: hiding], 0
 je @@nothidden
 shr cx, 1
 mov [cs: mousex], cx
 mov [cs: mousey], dx
 sti
 retf
@@nothidden:
 mov [cs: busy], 1
 sti
 cld
 push bp
 push es
 push ds
 push cx
 push dx
 mov ax, 0A000h
 mov es, ax
 mov ax, cs
 mov ds, ax
 mov si, offset back
 mov dx, [cs: mousex]
 add dx, 16
 cmp dx, 319
 jg @@overflowx
 mov dx, 16
 jmp @@nooverflow
@@overflowx:
 mov dx, 320
 sub dx, [cs: mousex]
@@nooverflow:
 mov bp, [cs: mousey]
 add bp, 16
 cmp bp, 199
 jg @@overflowy
 mov bp, 16
 jmp @@drawset
@@overflowy:
 mov bp, 200
 sub bp, [cs: mousey]
@@drawset:
 mov bx, bp
 mov ax, [cs: mousey]
 imul di, ax, 320
 add di, [cs: mousex]
@@loop:
  mov cx, dx
  rep movsb
  add di, 320
  sub di, dx
  dec bx
 jnz @@loop
 pop dx
 mov [cs: mousey], dx
 pop cx
 shr cx, 1
 mov [cs: mousex], cx
 mov ax, 0A000h
 mov ds, ax
 mov ax, cs
 mov es, ax
 mov di, offset back
 mov dx, [cs: mousex]
 add dx, 16
 cmp dx, 319
 jg @@overflowx2
 mov dx, 16
 jmp @@nooverflow2
@@overflowx2:
 mov dx, 320
 sub dx, [cs: mousex]
@@nooverflow2:
 mov bp, [cs: mousey]
 add bp, 16
 cmp bp, 199
 jg @@overflowy2
 mov bp, 16
 jmp @@drawset2
@@overflowy2:
 mov bp, 200
 sub bp, [cs: mousey]
@@drawset2:
 mov bx, bp
 mov ax, [cs: mousey]
 imul si, ax, 320
 add si, [cs: mousex]
@@loop2:
  mov cx, dx
  rep movsb
  add si, 320
  sub si, dx
  dec bx
 jnz @@loop2
 mov ax, 0A000h
 mov es, ax
 mov ax, cs
 mov ds, ax
 mov bx, bp
 mov si, offset fore
 mov ax, [cs: mousey]
 dec ax
 imul di, ax, 320
 add di, [cs: mousex]
 add di, dx
 sub si, 16
 add si, dx
@@loopy:
 add di, 320
 sub di, dx
 mov cx, dx
 add si, 16
 sub si, dx
@@loopx:
  mov al, [ds: si]
  cmp al, 255
  je @@continue
  mov [es: di], al
@@continue:
  inc di
  inc si
  dec cx
  jnz @@loopx
 dec bx
 jnz @@loopy
 pop ds
 pop es
 pop bp
 mov [cs: busy], 0
 retf
endp mousemove

proc fastkeypressed far
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
endp fastkeypressed

proc setrgb256 far
 push bp
 mov bp, sp
 mov dx, 03c8h
 mov al, [bp+6]
 out dx, al
 inc dx
 mov al, [bp+8]
 out dx, al
 mov al, [bp+10]
 out dx, al
 mov al, [bp+12]
 out dx, al
 pop bp
 retf 8
endp setrgb256

proc set256colors far
 push bp
 mov bp, sp
 push ds
 xor di, di
 mov ax, [bp+8]
 mov dx, ax
 mov si, [bp+6]
 mov dx, 3DAh
@@wait48:
 in ax, dx
 test ax, 8
 jz @@wait48
@@wait40:
 in ax, dx
 test ax, 8
 jnz @@wait40
 mov dx, 3C8h
 xor ax, ax
 out dx, al
 inc dx
 mov cx, 256
 cli
@@loop:
 outsb
 outsb
 outsb
 loop @@loop
 sti
 pop ds
 pop bp
 retf 4
endp set256colors

proc setvidmode far
 push bp
 mov bp, sp
 xor ah, ah
 mov al, [bp+6]
  int 10h
 pop bp
 retf 2
endp

ends graphics_text
end
