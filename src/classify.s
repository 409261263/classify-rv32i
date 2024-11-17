.globl classify

.text
# =====================================
# NEURAL NETWORK CLASSIFIER
# =====================================
classify:
    # Error handling
    li t0, 5
    blt a0, t0, error_args
    
    # Prolouge
    addi sp, sp, -48
    
    sw ra, 0(sp)
    sw s0, 4(sp)  # m0 matrix
    sw s1, 8(sp)  # m1 matrix
    sw s2, 12(sp) # input matrix
    sw s3, 16(sp) # m0 matrix rows
    sw s4, 20(sp) # m0 matrix cols
    sw s5, 24(sp) # m1 matrix rows
    sw s6, 28(sp) # m1 matrix cols
    sw s7, 32(sp) # input matrix rows
    sw s8, 36(sp) # input matrix cols
    sw s9, 40(sp) # h
    sw s10, 44(sp) # o
    
    # Read pretrained m0
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc     # malloc for rows
    beq a0, x0, error_malloc
    mv s3, a0      # save m0 rows pointer
    
    li a0, 4
    jal malloc     # malloc for cols
    beq a0, x0, error_malloc
    mv s4, a0      # save m0 cols pointer
    
    lw a1, 4(sp)   # restore arg pointer
    lw a0, 4(a1)   # first arg for read_matrix
    mv a1, s3      # second arg
    mv a2, s4      # third arg
    jal read_matrix
    mv s0, a0      # save m0 matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    # Read pretrained m1
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc     # malloc for rows
    beq a0, x0, error_malloc
    mv s5, a0      # save m1 rows pointer
    
    li a0, 4
    jal malloc     # malloc for cols
    beq a0, x0, error_malloc
    mv s6, a0      # save m1 cols pointer
    
    lw a1, 4(sp)   # restore arg pointer
    lw a0, 8(a1)   # first arg for read_matrix
    mv a1, s5      # second arg
    mv a2, s6      # third arg
    jal read_matrix
    mv s1, a0      # save m1 matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    # Read input matrix
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    li a0, 4
    jal malloc     # malloc for rows
    beq a0, x0, error_malloc
    mv s7, a0      # save input rows pointer
    
    li a0, 4
    jal malloc     # malloc for cols
    beq a0, x0, error_malloc
    mv s8, a0      # save input cols pointer
    
    lw a1, 4(sp)   # restore arg pointer
    lw a0, 12(a1)  # first arg for read_matrix
    mv a1, s7      # second arg
    mv a2, s8      # third arg
    jal read_matrix
    mv s2, a0      # save input matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12

    # Compute h = matmul(m0, input)
    addi sp, sp, -28
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    
    # Calculate size for h matrix
    lw t0, 0(s3)    # m0 rows
    lw t1, 0(s8)    # input cols
    mv t3, x0       # initialize result
multiply_h:
    beq t1, x0, end_multiply_h
    add t3, t3, t0
    addi t1, t1, -1
    j multiply_h
end_multiply_h:
    slli t3, t3, 2  # multiply by 4 for bytes
    mv a0, t3
    jal malloc 
    beq a0, x0, error_malloc
    mv s9, a0       # save h matrix pointer
    
    mv a6, a0       # h matrix
    mv a0, s0       # m0 array
    lw a1, 0(s3)    # m0 rows
    lw a2, 0(s4)    # m0 cols
    mv a3, s2       # input array
    lw a4, 0(s7)    # input rows
    lw a5, 0(s8)    # input cols
    jal matmul
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    addi sp, sp, 28
    
    # Compute h = relu(h)
    addi sp, sp, -8
    sw a0, 0(sp)
    sw a1, 4(sp)
    
    mv a0, s9       # h array
    lw t0, 0(s3)    # m0 rows
    lw t1, 0(s8)    # input cols
    mv t3, x0       # initialize result
multiply_relu:
    beq t1, x0, end_multiply_relu
    add t3, t3, t0
    addi t1, t1, -1
    j multiply_relu
end_multiply_relu:
    mv a1, t3       # length of h array
    jal relu
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    addi sp, sp, 8
    
    # Compute o = matmul(m1, h)
    addi sp, sp, -28
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)
    sw a6, 24(sp)
    
    # Calculate size for o matrix
    lw t0, 0(s5)    # m1 rows
    lw t1, 0(s8)    # h cols
    mv t3, x0       # initialize result
multiply_o:
    beq t1, x0, end_multiply_o
    add t3, t3, t0
    addi t1, t1, -1
    j multiply_o
end_multiply_o:
    slli t3, t3, 2  # multiply by 4 for bytes
    mv a0, t3
    jal malloc 
    beq a0, x0, error_malloc
    mv s10, a0      # save o matrix pointer
    
    mv a6, a0       # o matrix
    mv a0, s1       # m1 array
    lw a1, 0(s5)    # m1 rows
    lw a2, 0(s6)    # m1 cols
    mv a3, s9       # h array
    lw a4, 0(s3)    # h rows
    lw a5, 0(s8)    # h cols
    jal matmul
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    lw a6, 24(sp)
    addi sp, sp, 28
    
    # Write output matrix o
    addi sp, sp, -16
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    
    lw a1, 4(sp)
    lw a0, 16(a1)   # output filename
    mv a1, s10      # o array
    lw a2, 0(s5)    # rows
    lw a3, 0(s8)    # cols
    jal write_matrix
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    addi sp, sp, 16
    
    # Compute and return argmax(o)
    addi sp, sp, -12
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    
    mv a0, s10      # o array
    lw t0, 0(s5)    # m1 rows
    lw t1, 0(s8)    # h cols
    mv t3, x0       # initialize result
multiply_argmax:
    beq t1, x0, end_multiply_argmax
    add t3, t3, t0
    addi t1, t1, -1
    j multiply_argmax
end_multiply_argmax:
    mv a1, t3       # length of array
    jal argmax
    mv t0, a0       # save return value
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    addi sp, sp, 12
    
    mv a0, t0

    # Print if not in silent mode
    bne a2, x0, epilogue
    addi sp, sp, -4
    sw a0, 0(sp)
    jal print_int
    li a0, '\n'
    jal print_char
    lw a0, 0(sp)
    addi sp, sp, 4
    
epilogue:
    addi sp, sp, -4
    sw a0, 0(sp)
    
    # Free all allocated memory
    mv a0, s0
    jal free
    mv a0, s1
    jal free
    mv a0, s2
    jal free
    mv a0, s3
    jal free
    mv a0, s4
    jal free
    mv a0, s5
    jal free
    mv a0, s6
    jal free
    mv a0, s7
    jal free
    mv a0, s8
    jal free
    mv a0, s9
    jal free
    mv a0, s10
    jal free
    
    lw a0, 0(sp)
    addi sp, sp, 4

    # Restore saved registers
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    lw s9, 40(sp)
    lw s10, 44(sp)
    addi sp, sp, 48
    
    jr ra

error_args:
    li a0, 31
    j exit

error_malloc:
    li a0, 26
    j exit