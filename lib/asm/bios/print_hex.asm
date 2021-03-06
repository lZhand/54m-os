; prints hex value in `dx` as string

bios_print_hex:
	pusha
	mov cx, 4  ; counter, 4 x 4 bits === 16 bit hex, 4 chars

	call _bios_get_next_chunk
	call _bios_output_hex_string

	popa
	ret

_bios_get_next_chunk:
	cmp cx, 0  ; if counter is 0, return
	jg $ + 3  ; jump 3 bytes of instruction (?!) just works
	ret

	dec cx  ; decrement the counter
	mov bx, BIOS_HEX_OUT
	add bx, 2  ; this skips the first 2 bytes -> '0x'
	add bx, cx  ; add the counter to the address -- selects which byte to write


	mov ax, dx  ; make copy of current value in dx
	shr dx, 4  ; shift dx right 4 so we are ready for the next loop
	and ax, 0xf  ; 0xf == 15 == 1111 -> ANDing gives us the last 4 bits only

	cmp ax, 0xa  ; 0xa == 10
	jl _bios_print_hex_number  ; if less than 10, represented as numeral
	jmp _bios_print_hex_letter  ; else is letter

_bios_print_hex_number:
	add ax, 0x30  ; 0x30 === 48 == ASCII code for '0'
	jmp _bios_append_to_BIOS_HEX_OUTput

_bios_print_hex_letter:
	add ax, 0x57  ; 0x57 === 87 == ASCII code for 'a' MINUS 10
	jmp _bios_append_to_BIOS_HEX_OUTput

_bios_append_to_BIOS_HEX_OUTput:
	mov byte [bx], al ; [bx] points to a byte of BIOS_HEX_OUT, al is the lower half of a-register
	jmp _bios_get_next_chunk

_bios_output_hex_string:
	mov bx, BIOS_HEX_OUT
	call bios_print_string
	ret

BIOS_HEX_OUT: db '0x0000', 0
