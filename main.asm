[BITS 32]

%macro PushAll 0
	push eax
	push ebx
	push ecx
	push edx
%endmacro
%macro PopAll 0
	pop edx
	pop ecx
	pop ebx
	pop eax
%endmacro
%macro PrintString 1
	PushAll

	mov ecx, %1
	mov edx, 0
	%%stringLoop:
		inc edx
		cmp byte [edx+ecx], 0
		jne %%stringLoop
	
	mov eax, 4
	mov ebx, 1
	int 0x80
	PopAll
%endmacro
%macro PrintChar 1
	PushAll
	
	mov ecx, %1
	mov edx, 1
	mov eax, 4
	mov ebx, 1
	int  0x80

	PopAll
%endmacro
;%1 = File Descriptor
;%2 = Read Size
;%3 = 
%macro LoadFileToBuffer 3
	PushAll
	
	mov eax, 3
	mov ebx, %1
	mov ecx, %3
	mov edx, %2
	int 0x80

	PopAll
%endmacro
%macro GetFileDescriptor 2
	PushAll
	mov ebx, %1
	mov eax, 5
	mov ecx, 0
	mov edx, 0
	int 0x80

	cmp eax, 0
	jl errFileFailed

	mov %2, eax
	PopAll
%endmacro
%macro enterFunc 0
	push ebp
	mov ebp, esp
%endmacro
%macro exitFunc 0
	pop ebp
	ret
%endmacro

section .text
	global main

main:
	;Get Number of ARGS passed
	pop eax
	pop eax

	;Only accept Two ARG
	cmp eax, 0x2
	jne errArgsMismatch

	;Get pointer to ARG String
	pop eax
	add eax, 4
	mov [pathPointer], eax

	;Get File Descriptor
	GetFileDescriptor [eax], [BitmapFileDescriptor]
	LoadFileToBuffer [BitmapFileDescriptor], [BitmapFileSize], Bitmap

	mov ecx, 0
	mov eax, LabelFile
	add eax, 8
	mov [LabelFileIndex], eax

	mov eax, ImageFile
	add eax, 16
	mov [ImageFileIndex], eax

	loop1:
		PushAll
		call calculateDistance

		mov eax, [LabelFileIndex]
		mov al, byte [eax]
		mov [Label], al

		inc dword [LabelFileIndex]

		call CheckNearest
		PopAll

		inc ecx
		cmp ecx, [DataCount]
		jl loop1
	call CountNearest
	call PrintNearest
	;call PrintAll

exit:
	mov ebx, 0
	mov eax, 1
	int 0x80
	nop
;ebx is data address
;eax is bitmap addr
calculateDistance:
	enterFunc
	
	mov ebx, [ImageFileIndex]
	mov dword [Sum], 0
	mov ecx, -1
	
	loopDist:
		inc ecx

		mov dl, byte [ebx+ecx]
		mov al, byte [Bitmap+ecx]
		sub al, dl

		jnc carryNotSet

		add al, 256

		carryNotSet:

		movzx eax, al
		;eax sqrd
		mul eax
		add eax, [Sum]
		mov [Sum], eax
		
		cmp ecx, 784
		jl loopDist
	

	add dword [ImageFileIndex], 784
	call SqrtSum
	exitFunc

SqrtSum:
	enterFunc
	fild dword [Sum]
	fsqrt
	fistp dword [Sum]
	exitFunc
CheckNearest:
	enterFunc
	;eax Tracks offset of nearest
	;Nearest Format:
	;First Byte = Label byte
	;Next 4 bytes = Sum Byte
	;Skip the inital label byte inless we need it
	mov eax, -4
	loopNear:
		add eax, 5
		;Get the sum in nearest
		mov ebx, [Nearest+eax]
		;Compare with current sum
		cmp ebx, [Sum]
		
		jle continueLoop
		;Swap the value in Nearest with sum	
		mov ecx, [Sum]
		mov [Nearest+eax], ecx
		mov [Sum], ebx
		;Swap Label with Nearest Label
		mov cl, [Label]
		mov bl, [Nearest+eax-1] 
		mov [Label], bl
		mov [Nearest+eax-1], cl
		continueLoop:
	
		cmp eax, 45
		jl loopNear
	exitFunc
PrintNearest:
	enterFunc
	;Counter
	mov eax, 0
	;Highest Occurance Label
	mov ecx, 0
	;Highest Occurance Counter
	mov edx, 0
	loopPrint:
		;Int at current index
		mov ebx, [NearestHashMap+(eax*4)]
		
		cmp ebx, edx
		jl continuePrintLoop
		;Set to high occurance
		mov edx, ebx
		;store the index of it
		mov ecx, eax

		continuePrintLoop:

		inc eax
		cmp eax, 10
		jl loopPrint
	add cl, 48
	mov [testChar], cl
	PrintChar testChar
	exitFunc
PrintAll:
	enterFunc
	mov eax, 0
	loop4:
		mov bl, [Nearest+eax]
		add bl, 48
		mov [testChar], bl
		PrintChar testChar

		add eax, 5
		cmp eax, 50
		jl loop4
	exitFunc
CountNearest:
	enterFunc
	mov eax, 0
	
	loopCountNear:
		xor ebx,ebx
		mov bl, [eax+Nearest]

		mov edx, [NearestHashMap+(ebx*4)]
		inc edx
		mov [NearestHashMap+(ebx*4)],edx

		add eax, 5
		cmp eax, 50
		jl loopCountNear


	exitFunc

errFileFailed:
	PrintString FailedToLoadFileErr
	jmp exit
errMismatchDataSize:
	PrintString DataSizeMismatchErr
	jmp exit
errArgsMismatch:
	PrintString ArgsErr
	jmp exit
section .data
	pathPointer dd 0x000
	testChar db 'A'
	FailedToLoadFileErr db 'Failed to Read File',0xa, 0
	DataSizeMismatchErr db 'Mismatch in amount of data between Label and Image File', 0xa, 0
	ArgsErr db 'expected program ./images', 0xa, 0
	BitmapFileDescriptor dd 0x0
	ImageSizeX dd 28
	ImageSizeY dd 28
	BitmapFileSize dd 784
	Sum dd 0x0
	Label db 0x0
	DataCount dd 60000
	;10 Neighbours
	;1 byte if label
	;4 bytes for distance
	Nearest db 10 dup(0x01, 0xff, 0xff, 0xff, 0x7f)
	NearestHashMap dd 10 dup(0)
	ImageFileIndex dd 0
	LabelFileIndex dd 0
	ImageFileSize dd 47040016
	LabelFileSize dd 60008
	ImageFile: incbin "./data/train-images.idx3-ubyte"
	LabelFile: incbin "./data/train-labels.idx1-ubyte"
section .bss
	Bitmap: resb 784
