.text
    .align 1
    .globl _start

_start:
    # salvando x0 e y0
    jal readValue
    mv s1, a0 # x 
    jal readValue
    mv s2, a0 # y

    jal readValue # pular a linha com P2

    jal readValue
    la t0, C
    sb a0, 0(t0) # salvar o valor de C
    jal readValue
    la t0, L 
    sb a0, 0(t0) # salvar o valor de L
    jal readValue
    la t0, CMAX
    sb a0, 0(t0) # salvar o valor de CMAX

    la t0, L
    lb s3, 0(t0) 
    addi s3, s3, -1 # s3 = L-1
    whileReadSensor:
        bge s2, s3, endReadSensor # y >= L-1
        mv a0, s1
        mv a1, s2
        jal readSensor
        jal decideMove
        add s1, s1, a0 # x = x+dir
        addi s2, s2, 1 # y++
        mv a0, s1
        mv a1, s2
        jal printPosition
        j whileReadSensor
    endReadSensor:
    li a0, 0 # exit code
    li a7, 97 # syscall exit
_end:
    ecall

# Lê um char da entrada padrão e salva em crtChar
readChar:
    addi sp, sp, -4
    sw ra, 0(sp)

    li a0, 0 # stdin
    la a1, crtChar # salvar em crtChar
    li a2, 1 # ler 1 byte
    li a7, 64 # read command
    ecall

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# Retorna um valor numérico lido na entrada
readValue:
    addi sp, sp, -4
    sw ra, 0(sp)

    li t1, 0 # bCounter

    doRead:
        # lendo char da entrada
        jal readChar
        la t0, crtChar 
        lb t0, 0(t0) # t0 = crtChar

        # *if crtChar >= '0' && crtChar <= '9' 
        li t2, 48
        blt t0, t2, no_digit
        li t2, 58
        bge t0, t2, no_digit

        la t2, buffer
        add t2, t2, t1
        sb t0, 0(t2) # buffer[bCounter] = crtChar
        addi, t1, t1, 1 # bCounter++

        no_digit:
        # *while crtChar != '\n' && crtChar != ' '
        li t4, '\n'
        beq t0, t4, stopRead
        li t4, ' '
        bne t0, t4, doRead
    stopRead:

    mv a0, t1
    li a1, 0
    jal convertValue # convertValue(bCounter, 0)

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# * Entrada:
# ** a0: num Chars no buffer
# ** a1: posição em Sensor em que será salvo o valor
# * Retorno: 
# ** a0: O valor convertido de Str para Num 
convertValue:
    addi sp, sp, -4
    sw ra, 0(sp)

    mv t0, a0
    li a0, 0 # converted = 0

    li t1, 0 # i = 0
    forValue:
        bge t1, t0, compValue

        li t3, 1 # pow = 1
        li t4, 0 # j = 0
        li t5, -1
        add t5, t5, t0
        sub t5, t5, t1 # numChs-i-1
        forPow:
            bge t4, t5, endPow # j >= numChs-i-1
            li t2, 10
            mul t3, t3, t2 # pow = pow * 10
            addi t4, t4, 1
            j forPow
        endPow:

        la t2, buffer
        add t2, t2, t1
        lb t2, 0(t2)
        addi t2, t2, -48 # digit = buffer[i] - 48

        mul t2, t2, t3 # digit*pow
        add a0, a0, t2 # converted += digit*pow

        addi t1, t1, 1
        j forValue

    compValue:
        la t0, sensor
        addi t0, t0, a1
        sw a0, 0(t0) # sensor[pos] = converted

    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# * Entrada:
# ** a0: posição x do carro
# ** a1: posição y do carro
# * lê a próxima linha da matriz
# * salva o valor de 11 posições próximas ao x do carro
readSensor:
    addi sp, sp, -4
    sw ra, 0(sp)

    mv s4, a0 # salvando o valor de x0

    li a3, 0 # cCounter
    li a4, 0 # bCounter
    li a5, 0 # nCounter
    li a6, 0 # inFlag

    doReadSensor:

        jal readChar
        la a2, crtChar
        lb a2, 0(a2) # a2 = crtChar
        
        is_space:
        li t0, ' '
        bne a2, t0, is_digit #* if crtChar == ' '
        addi a3, a3, 1 # cCounter++
        beq a6, zero, no_action #* if inFlag == 0
        mv a0, a4
        mv a1, a5
        addi a5, a5, 1 # nCounter++
        jal convertValue
        li a6, 0 # inFlag = 0
        li a4, 0 # bCounter = 0
        j no_action 

        is_digit: 
        li t0, -5
        add t0, s4, t0 # t0 = x0-5
        blt a3, t0, no_action # cCounter < x0-5
        li t0, 6
        add t0, s4, t0 # t0 = x0+6
        bge a3, t0, no_action # cCounter >= x0+6
        la t0, buffer
        add t0, t0, a4
        sb a2, 0(t0) # buffer[bCounter] = crtChar
        addi a4, a4, 1 # bCounter++
        li a6, 1 # inFlag = 1

        no_action:
        li t0, '\n'
        la t1, L 
        la t2, C
        lb t1, 0(t1)  
        addi t1, t1, -2 # t1 = L-2
        lb t2, 0(t2) 
        addi t2, t2, -1 # t2 = C-1 
        
        # while (crtChar != '\n' && (y != L-2 || cCounter != C-1) )
        beq a2, t0, endReadSensor
        bne a1, t1, doReadSensor
        bne a3, t2, doReadSensor
    endReadSensor:
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

# * Retorna a direção que o carro deve seguir em x
# * direita: 1, esquerda: -1, centro: 0
decideMove:
    addi sp, sp, -4
    sw ra, 0(sp)

    li t0, 5 # S_POS = 5
    la t3, sensor # t3 = &sensor[0]
    li t1, 100 # valor max preto

    addi t2, t0, -1 # t2 = S_POS-1
    add t2, t3, t2 # t2 = &sensor[S_POS-1]
    lb t2, 0(t2) # t2 = sensor[S_POS-1]
    bge t1, t2, nd_center # 100 >= sensor[S_POS-1] 

    addi t2, t0, 1 # t2 = S_POS+1
    add t2, t3, t2 # t2 = &sensor[S_POS+1]
    lb t2, 0(t2) # t2 = sensor[S_POS+1]
    bge t1, t2, nd_center # 100 >= sensor[S_POS+1]
    j d_center

    nd_center:
    li t2, 1 # fLeft = 1
    li t4, 1 # fRight = 1

    li t5, 0 # i = 0
    forLeft:
        bge t5, t0, endLeft # i >= S_POS
        add a1, t3, t5 # a1 = &sensor[i]
        lb a1, 0(a1) # a1 = sensor[i]
        bge t1, a1, c_left # 100 >= sensor[i]
        li t2, 0 # fLeft = 0
        j endLeft
        c_left: 
        addi t5, t5, 1 # i++
        j forLeft

    endLeft:

    addi t5, t0, 1 # i = S_POS+1
    addi t6, t0, 6 # t6 = S_POS+6
    forRight:
        bge t5, t6, endRight
        add a1, t3, t5 # a1 = &sensor[i]
        lb a1, 0(a1) # a1 = sensor[i]
        bge t1, a1, c_right # 100 >= sensor[i]
        li t4, 0 # fRight = 0
        j endRight
        c_right:
        addi t5, t5, 1
        j forRight
    endRight:
    
    d_left:
    beq t2, zero, d_right 
    bne t4, zero, d_right
    li a0, -1
    j d_finish

    d_right:
    bne t2, zero, d_center
    beq t4, zero, d_center
    li a0, 1
    j d_finish

    d_center:
    li a0, 0

    d_finish:
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

printPosition:
    addi sp, sp, -4
    sw ra, 0(sp)

    lw ra, 0(sp)
    addi sp, sp, 4
    ret    

.bss
    C: .skip 4
    L: .skip 4
    CMAX: .skip 4
    crtChar: .skip 1
    .align 2
    buffer: .skip 3
    .align 2
    sensor: .skip 11