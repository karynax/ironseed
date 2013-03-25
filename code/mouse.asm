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

segment mouse_text word 'code'
assume cs: mouse_text

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
 cmp ax, 0
 je @@error       ; error
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
  int 33h         ; set y
 mov cx, 0
 mov dx, 640
 mov ax, 07h
  int 33h         ; set x
 mov ax, 1Ch
 mov bx, 1
  int 33h         ; set sampling to 30
 sti
 pop es
 mov ax, 1
 retf
@@error:
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
 cli
  rep movsd
 sti
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
	;; save bp
	push bp
	;; save segments
	push es
	push ds
	;; save x and y
	push cx
	push dx
	;; load segments
	mov ax, 0A000h
	mov es, ax
	mov ax, cs
	mov ds, ax
;;; restore old background under cursor
	;; load si with old back ground buffer
	mov si, offset back

	;; load dx with number of x pixels
	mov dx, [cs: mousex]
	add dx, 16
	cmp dx, 319
	jg @@overflowx
	mov dx, 16
	jmp @@nooverflow
@@overflowx:
	mov dx, 320
	sub dx, [cs: mousex]
	;; load bp with number of y pixels
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
	;; copy the number of y pixels into bx
	mov bx, bp
	;; load di with the pixel address on the screen
	mov ax, [cs: mousey]
	imul di, ax, 320
	add di, [cs: mousex]

@@loop:
	;; copy x pixels
	 mov cx, dx
	 rep movsb
	;; advance pointer to start of next row
	 add di, 320
	 sub di, dx
	;; dec y counter
	 dec bx
	jnz @@loop

	;; store new y and x co-ordinates
	pop dx
	mov [cs: mousey], dx
	pop cx
	shr cx, 1
	mov [cs: mousex], cx

	;; load segments
	mov ax, 0A000h
	mov ds, ax
	mov ax, cs
	mov es, ax

	;; load di with pointer to background buffer
	mov di, offset back
	;; load dx with number of x pixels
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
	;; load bp with number of y pixels
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
	;; copy number of y pixels to bx
	mov bx, bp
	;; load si with adress of pixel
	mov ax, [cs: mousey]
	imul si, ax, 320
	add si, [cs: mousex]
@@loop2:
	;; copy y pixels
	 mov cx, dx
	 rep movsb
	;; advance pointer to start of next row
	 add si, 320
	 sub si, dx
	;; dec y counter
	 dec bx
	jnz @@loop2

	;; load segments
	mov ax, 0A000h
	mov es, ax
	mov ax, cs
	mov ds, ax

	;; copy number of y pixels into bx
	mov bx, bp

	;; load si wth cursor buffer
	mov si, offset fore
	;; load screen pointer
	mov ax, [cs: mousey]
	dec ax
	imul di, ax, 320
	add di, [cs: mousex]
	;; adjust pointers?????
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

ends mouse_text
end
