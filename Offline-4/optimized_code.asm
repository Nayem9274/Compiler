.MODEL SMALL
.STACK 1000H

.DATA
TMP_1 DW '?'
TMP_2 DW '?'
TMP_3 DW '?'
i2 DW '?'
j2 DW '?'
k3 DW '?'
ll3 DW '?'
m3 DW '?'
n3 DW '?'
o3 DW '?'
p3 DW '?'


.CODE
main PROC

MOV AX, @DATA
MOV DS, AX

;int k,ll,m,n,o,p  

;i=1  
MOV TMP_1, 1
MOV DX, TMP_1
MOV i2, DX

;printf(i)  
PUSH i2
CALL PRINTLN
POP i2

;j=5+8  
MOV TMP_1, 5
MOV TMP_2, 8
MOV AX, TMP_1
MOV TMP_3, AX
MOV AX, TMP_2
ADD TMP_3, AX
MOV DX, TMP_3
MOV j2, DX

;printf(j)  
PUSH j2
CALL PRINTLN
POP j2

;k=i+2*j  
MOV TMP_1, 2
MOV AX, j2
IMUL TMP_1
MOV TMP_2, AX
MOV AX, i2
MOV TMP_1, AX
MOV AX, TMP_2
ADD TMP_1, AX
MOV DX, TMP_1
MOV k3, DX

;printf(k)  
PUSH k3
CALL PRINTLN
POP k3

;m=k%9  
MOV TMP_1, 9
MOV AX, k3
CWD
IDIV TMP_1
MOV TMP_2, DX
; MOV DX, TMP_2	PEEPHOLE_OPTIMIZATION
MOV m3, DX

;printf(m)  
PUSH m3
CALL PRINTLN
POP m3

;n=m<=ll  
MOV TMP_1, 1
MOV AX, ll3
CMP m3, AX
JLE L_1
MOV TMP_1, 0
L_1:
MOV DX, TMP_1
MOV n3, DX

;printf(n)  
PUSH n3
CALL PRINTLN
POP n3

;o=i!=j  
MOV TMP_1, 1
MOV AX, j2
CMP i2, AX
JNE L_2
MOV TMP_1, 0
L_2:
MOV DX, TMP_1
MOV o3, DX

;printf(o)  
PUSH o3
CALL PRINTLN
POP o3

;p=n||o  
MOV TMP_1, 1
CMP n3, 0
JNE L_3
CMP o3, 0
JNE L_3
MOV TMP_1, 0
L_3:
MOV DX, TMP_1
MOV p3, DX

;printf(p)  
PUSH p3
CALL PRINTLN
POP p3

;p=n&&o  
MOV TMP_1, 0
CMP n3, 0
JE L_4
CMP o3, 0
JE L_4
MOV TMP_1, 1
L_4:
MOV DX, TMP_1
MOV p3, DX

;printf(p)  
PUSH p3
CALL PRINTLN
POP p3

;p++  
MOV AX, p3
MOV TMP_1, AX
INC p3

;printf(p)  
PUSH p3
CALL PRINTLN
POP p3

;k=-p  
MOV AX, p3
MOV TMP_2, AX
NEG TMP_2
MOV DX, TMP_2
MOV k3, DX

;printf(k)  
PUSH k3
CALL PRINTLN
POP k3
MOV TMP_2, 0

MOV AH, 4CH
INT 21H
main ENDP

PRINTLN PROC     PUSH AX    PUSH BX     PUSH CX     PUSH DX    PUSH BP        MOV BP, SP    MOV AX, WORD PTR[BP + 12]     TEST AX,8000H    JZ PRINTLN_HELPER    MOV CX, AX    MOV AH, 2    MOV DL, 45    INT 21H    MOV AX, CX            PRINTLN_HELPER:    MOV CX, 0    WHILE:       MOV BX, 10       CALL DIVIDE_HELPER         CALL ABS_HELPER       PUSH DX        INC CX       CMP AX, 0       JNE WHILE     MOV AH, 2         GO:       POP BX       MOV DL, BL       ADD DL, 48       INT 21H        DEC CX       CMP CX, 0       JG GO    LAST:      MOV AH, 2      MOV DL, 0DH      INT 21H      MOV AH, 2      MOV DL, 0AH      INT 21H       POP BP      POP DX      POP CX      POP BX      POP AX    RET    PRINTLN ENDPDIVIDE_HELPER PROC      PUSH BX    CWD    IDIV BX    POP BX    RETDIVIDE_HELPER ENDPABS_HELPER PROC     PUSH AX   CMP DX, 0   JGE ABS_LAST   MOV AX, 0   SUB AX, DX   MOV DX, AX     ABS_LAST:   POP AX   RETABS_HELPER ENDP


END MAIN
