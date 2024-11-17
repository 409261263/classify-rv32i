.globl read_matrix

.text
# =======================================================
# FUNCTION: Binary Matrix File Reader (No MUL Instruction)
# Loads a matrix from a binary file into dynamically allocated memory.
# =======================================================
read_matrix:
    # Prologue
    addi sp, sp, -40
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    mv s3, a1          # Save address to store row count
    mv s4, a2          # Save address to store column count

    li a1, 0           # File mode: read only
    jal fopen          # Open file

    li t0, -1
    beq a0, t0, fopen_error   # If fopen failed, exit with code 27

    mv s0, a0          # Save file pointer

    # Read header (rows and columns)
    mv a0, s0          # File pointer
    addi a1, sp, 28    # Buffer to store row/column data
    li a2, 8           # Read 8 bytes (2 integers)
    jal fread

    li t0, 8
    bne a0, t0, fread_error   # If fread fails, exit with code 29

    # Extract row and column counts
    lw t1, 28(sp)      # Load rows from buffer
    lw t2, 32(sp)      # Load columns from buffer

    sw t1, 0(s3)       # Store rows to output address
    sw t2, 0(s4)       # Store columns to output address

    # Calculate total matrix size (rows * columns)
    li s1, 0           # Total elements (initialize to 0)
    mv t3, t2          # Copy columns to temporary register

calc_elements:
    beqz t1, alloc_memory  # If rows == 0, move to memory allocation
    add s1, s1, t3         # Accumulate: total_elements += columns
    addi t1, t1, -1        # Decrement rows
    j calc_elements        # Repeat until rows == 0

alloc_memory:
    slli t3, s1, 2         # Multiply total elements by 4 (size in bytes)
    sw t3, 24(sp)          # Store total memory size

    mv a0, t3              # Allocate memory for matrix
    jal malloc

    beq a0, x0, malloc_error  # If malloc fails, exit with code 26

    mv s2, a0              # Save pointer to allocated memory

    # Read matrix data
    mv a0, s0              # File pointer
    mv a1, s2              # Buffer to store matrix data
    lw a2, 24(sp)          # Number of bytes to read
    jal fread

    lw t3, 24(sp)          # Total bytes
    bne a0, t3, fread_error  # If fread fails, exit with code 29

    # Close file
    mv a0, s0
    jal fclose

    li t0, -1
    beq a0, t0, fclose_error  # If fclose fails, exit with code 28

    mv a0, s2              # Return pointer to matrix

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 40
    jr ra                  # Return to caller

# Error handlers
malloc_error:
    li a0, 26
    j error_exit

fopen_error:
    li a0, 27
    j error_exit

fread_error:
    li a0, 29
    j error_exit

fclose_error:
    li a0, 28
    j error_exit

error_exit:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 40
    j exit
