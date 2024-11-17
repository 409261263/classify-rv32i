.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Write Matrix to Binary File (No MUL Instruction)
# ==============================================================================
write_matrix:
    # Prologue
    addi sp, sp, -44             # Allocate stack space
    sw ra, 0(sp)                 # Save return address
    sw s0, 4(sp)                 # Save temporary registers
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

    # Save arguments
    mv s1, a1                    # Matrix base address
    mv s2, a2                    # Rows
    mv s3, a3                    # Columns

    # Open file for writing
    li a1, 1                     # Mode: write
    jal fopen                    # Call fopen
    li t0, -1
    beq a0, t0, fopen_error       # fopen error: exit with code 27

    mv s0, a0                    # Save file descriptor

    # Write header (rows and columns)
    sw s2, 24(sp)                # Store rows in buffer
    sw s3, 28(sp)                # Store columns in buffer
    mv a0, s0                    # File descriptor
    addi a1, sp, 24              # Buffer with rows and columns
    li a2, 2                     # Number of elements
    li a3, 4                     # Size of each element
    jal fwrite                   # Write rows and columns to file
    li t0, 2
    bne a0, t0, fwrite_error      # fwrite error: exit with code 30

    # Calculate total number of elements (rows * cols)
    li s4, 0                     # Initialize total elements to 0
    mv t0, s2                    # Copy rows to temporary register
calc_total_elements:
    beqz t0, write_data          # If rows == 0, go to write data
    add s4, s4, s3               # s4 += columns
    addi t0, t0, -1              # Decrement rows
    j calc_total_elements        # Repeat until rows == 0

write_data:
    # Write matrix data
    mv a0, s0                    # File descriptor
    mv a1, s1                    # Matrix base address
    mv a2, s4                    # Number of elements
    li a3, 4                     # Size of each element
    jal fwrite                   # Write matrix data to file
    bne a0, s4, fwrite_error      # fwrite error: exit with code 30

    # Close file
    mv a0, s0                    # File descriptor
    jal fclose                   # Close file
    li t0, -1
    beq a0, t0, fclose_error      # fclose error: exit with code 28

    # Epilogue
    lw ra, 0(sp)                 # Restore registers
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 44              # Deallocate stack space
    jr ra                        # Return to caller

# Error handlers
fopen_error:
    li a0, 27                    # Error code for fopen failure
    j error_exit

fwrite_error:
    li a0, 30                    # Error code for fwrite failure
    j error_exit

fclose_error:
    li a0, 28                    # Error code for fclose failure
    j error_exit

error_exit:
    # Restore registers and exit with error
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 44
    j exit
