.globl abs

.text
# =================================================================
# FUNCTION: Absolute Value Converter 11/17
# Args:
#   a0 (int *): Memory address of the integer to be converted
# Returns:
#   None - The operation modifies the value at the pointer address
# =================================================================
abs:
    # Prologue
    # Load number from memory
    lw t0 0(a0)
    
    # Check if number is negative
    bge t0, zero, done
    
    # If negative, multiply by -1 (subtract from 0)
    sub t0, zero, t0
    
    # Store result back to memory
    sw t0, 0(a0)

done:
    # Epilogue
    jr ra