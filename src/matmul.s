.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication Implementation
#
# Performs operation: D = M0 × M1
# Where:
#   - M0 is a (rows0 × cols0) matrix
#   - M1 is a (rows1 × cols1) matrix
#   - D is a (rows0 × cols1) result matrix
#
# Arguments:
#   First Matrix (M0):
#     a0: Memory address of first element
#     a1: Row count (rows0)
#     a2: Column count (cols0)
#
#   Second Matrix (M1):
#     a3: Memory address of first element
#     a4: Row count (rows1)
#     a5: Column count (cols1)
#
#   Output Matrix (D):
#     a6: Memory address for result storage
#
# Validation:
#   - M0_cols (a2) must equal M1_rows (a4)
#   All failures trigger program exit with code 38.
# =======================================================
matmul:
    # Input validation
    li t0, 1                     # Minimum valid value
    blt a1, t0, error            # If M0 row count < 1, exit
    blt a2, t0, error            # If M0 column count < 1, exit
    blt a4, t0, error            # If M1 row count < 1, exit
    blt a5, t0, error            # If M1 column count < 1, exit
    bne a2, a4, error            # If M0_cols != M1_rows, exit

    # Save callee-saved registers on the stack (prologue)
    addi sp, sp, -48
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)
    sw s9, 40(sp)
    sw s10, 44(sp)

    # Initialize variables
    li s0, 0                     # s0 = 0 (row index for M0)
    mv s5, a6                    # s5 = a6 (pointer to result matrix D)
    mv s6, a2                    # s6 = cols0 (number of columns in M0)
    mv s7, a5                    # s7 = cols1 (number of columns in M1)
    mv s8, a0                    # s8 = base address of M0
    mv s9, a3                    # s9 = base address of M1
    mv s10, a1                   # s10 = rows0 (number of rows in M0)

outer_loop_start:
    blt s0, s10, inner_loop_start # If s0 < rows0, process next row
    j outer_loop_end             # All rows processed, exit outer loop

inner_loop_start:
    li s1, 0                     # s1 = 0 (column index for M1)

    # Calculate starting address of row s0 in M0
    # t1 = s0 * s6
    mv a0, s0
    mv a1, s6
    jal multiply_unsigned        # Result in t0
    mv t1, t0
    slli t1, t1, 2               # t1 = t1 * 4 (convert to bytes)
    add s3, s8, t1               # s3 = base address of M0[s0][0]

inner_column_loop:
    blt s1, s7, compute_dot      # If s1 < cols1, compute dot product
    j increment_row              # Else, move to next row

compute_dot:
    # Calculate starting address of column s1 in M1
    slli t2, s1, 2               # t2 = s1 * 4 (byte offset for column)
    mv s4, s9                    # s4 = base address of M1
    add s4, s4, t2               # s4 = address of M1[0][s1]

    # Prepare arguments for `dot` function
    mv a0, s3                    # a0 = pointer to current row in M0
    mv a1, s4                    # a1 = pointer to current column in M1
    mv a2, s6                    # a2 = number of elements in M0 row (cols0)
    li a3, 1                     # a3 = stride for M0 (elements are contiguous)
    mv a4, s7                    # a4 = stride for M1 (number of columns in M1)

    # Call dot product function
    jal dot                      # Result returned in a0

    # Store result in result matrix D
    sw a0, 0(s5)                 # Store the result at D[s0][s1]
    addi s5, s5, 4               # Increment result matrix pointer

    # Increment column index
    addi s1, s1, 1               # s1++
    j inner_column_loop          # Repeat inner column loop

increment_row:
    # Increment row index
    addi s0, s0, 1               # s0++

    j outer_loop_start           # Repeat outer loop

outer_loop_end:
    # Restore callee-saved registers (epilogue)
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
    jr ra                        # Return to caller

error:
    li a0, 38                    # Load exit code 38 into a0
    jal exit                     # Call exit function

# Subroutine: multiply_unsigned
# Multiplies a0 and a1 (unsigned integers), result in t0
multiply_unsigned:
    # Save temporary registers
    addi sp, sp, -8
    sw t1, 0(sp)
    sw t2, 4(sp)

    # Initialize
    mv t0, zero                  # t0 = 0 (product)
    mv t1, a0                    # t1 = multiplicand
    mv t2, a1                    # t2 = multiplier

multiply_unsigned_loop:
    beqz t2, multiply_unsigned_end  # If t2 == 0, done
    andi t3, t2, 1
    beqz t3, shift_multiplicand
    add t0, t0, t1               # t0 += t1
shift_multiplicand:
    slli t1, t1, 1               # t1 <<= 1
    srli t2, t2, 1               # t2 >>= 1
    j multiply_unsigned_loop

multiply_unsigned_end:
    # Restore temporary registers
    lw t2, 4(sp)
    lw t1, 0(sp)
    addi sp, sp, 8
    jr ra
