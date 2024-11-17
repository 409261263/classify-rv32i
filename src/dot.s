.globl dot

.text
# =======================================================
# FUNCTION: Strided Dot Product Calculator
#
# Args:
#   a0 (int *): Pointer to first input array
#   a1 (int *): Pointer to second input array
#   a2 (int):   Number of elements to process
#   a3 (int):   Skip distance in first array
#   a4 (int):   Skip distance in second array
#
# Returns:
#   a0 (int):   Resulting dot product value
# =======================================================
dot:
    # Validate inputs
    li t0, 1                     # Minimum valid value
    blt a2, t0, error_length     # If element count < 1, exit with error 36
    blt a3, t0, error_stride     # If stride0 < 1, exit with error 37
    blt a4, t0, error_stride     # If stride1 < 1, exit with error 37

    # Save callee-saved registers
    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)

    # Initialize variables
    li s2, 0                     # s2: Accumulator for dot product
    mv t1, a0                    # t1: Pointer to arr0 (p0)
    mv t2, a1                    # t2: Pointer to arr1 (p1)
    mv s3, a2                    # s3: Element count (loop counter)

    slli s0, a3, 2               # s0 = stride_bytes0 = a3 * 4
    slli s1, a4, 2               # s1 = stride_bytes1 = a4 * 4

loop_start:
    beqz s3, loop_end            # If s3 == 0, exit loop

    # Load values from both arrays
    lw t3, 0(t1)                 # Load arr0 element into t3
    lw t4, 0(t2)                 # Load arr1 element into t4

    # Multiply t3 and t4, result in t5
    # Call multiply_signed subroutine
    addi sp, sp, -4              # Adjust stack and save ra
    sw ra, 0(sp)
    # Move operands to a0 and a1
    mv a0, t3
    mv a1, t4
    jal multiply_signed          # Multiply a0 and a1, result in a0 (product)
    lw ra, 0(sp)                 # Restore ra
    addi sp, sp, 4

    # Add the product to the dot product accumulator
    add s2, s2, a0               # s2 += product

    # Increment pointers
    add t1, t1, s0               # t1 += stride_bytes0
    add t2, t2, s1               # t2 += stride_bytes1

    # Decrement loop counter
    addi s3, s3, -1

    j loop_start                 # Repeat loop

loop_end:
    mv a0, s2                    # Move result to a0 (final dot product)

    # Restore callee-saved registers
    lw s3, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 16

    jr ra                        # Return to caller

# Subroutine: multiply_signed
# Multiplies a0 and a1 (signed integers), result in a0
multiply_signed:
    # Save callee-saved registers used in this subroutine
    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)

    # Initialize result
    li s0, 0                     # s0: result

    # Determine sign of operands
    mv s1, a0                    # s1 = multiplicand (a0)
    mv s2, a1                    # s2 = multiplier (a1)
    li s3, 0                     # s3: sign flag (0 for positive, 1 for negative)

    bltz s1, neg_multiplicand
    j check_multiplier

neg_multiplicand:
    neg s1, s1                   # s1 = -s1
    xori s3, s3, 1               # Flip sign flag
    j check_multiplier

check_multiplier:
    bltz s2, neg_multiplier
    j multiplication_loop

neg_multiplier:
    neg s2, s2                   # s2 = -s2
    xori s3, s3, 1               # Flip sign flag

multiplication_loop:
    beqz s2, multiplication_done # If s2 == 0, multiplication done
    add s0, s0, s1               # s0 += s1
    addi s2, s2, -1              # s2--
    j multiplication_loop

multiplication_done:
    # Adjust sign of result
    beqz s3, result_positive     # If sign flag == 0, result is positive
    neg s0, s0                   # s0 = -s0

result_positive:
    mv a0, s0                    # Move result to a0

    # Restore callee-saved registers
    lw s3, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 16
    jr ra                        # Return from subroutine

# Error handling
error_length:
    li a0, 36                    # Error code 36 for invalid length
    jal exit

error_stride:
    li a0, 37                    # Error code 37 for invalid stride
    jal exit
