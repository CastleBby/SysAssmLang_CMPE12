#################################################################################################################
# Created by:   Castelan Moreno, Emily
#               ecastela
#               21 August 2018
#
# Assignment:   Lab 5: ACII Binary to Decimal
#               CMPE 012: Computer Systems and Assembly Language
#               UC Santa Cruz, Summer 2018
# Description:  This program reads the user inputed argument and prints the input out as 
#               a binary number then converts and displays the number as a
#               hexadecimal number, decimal number, and Morse Code.
# Notes:        This program is intended to be run from MARS IDE
#               This program does not have error handling and assumes user input is appropriate
#################################################################################################################
#
#
# PSEUDOCODE:
# main
# {  
#    READ USER & PRINT USER PROGRAM ARGUMENT (8-BIT 2'S COMPLEMENT BINARY) AS STRING
#    print bin Representation text = " You entered the binary number"
#    print newLine= "\n "
#    read user program argument, the contents within the address pointed to by the pointer in $a1                        
#    print user program argument as string, use syscall 4
#             final print to console should be: "You entered the binary number: "
#                                               "_ _ _ _ _ _ _ _"
#    
#    CONVERT ASCII STRING TO SIGN-EXTENDED 32-BIT INTEGER & STORE IN $s0
#    load 1st byte from atring 
#    convert the ASCII character to an integer by subtracting 48 (should get either a 0 or 1)
#    shift left logical to appropriate corresponding value in string place
#    set int. into temp. register which will be incremented 
#    repeat until done for 0th->7th byte in string
#
#   CHECK IF THE MOST SIGNIFICANT BIT IS + (0) OR - (1)
#   ANDI against 0x00000080 to check the most significan tbit 
#         = ...80 if negative 
#             if negative then sign extend
#         = ...00 if positive 
#             if positive then branch to "positive" label
#
#    SIGN EXTENSTION FOR NEGATIVE VALUE
#    ORI against 0xFFFFFF00 because changes the leading 0's to 1's
#
#    SET UP SECOND TEXT OUTPUT:
#    print hex Representation text = "The hex representation of the sign-extended number is: "
#    print newLine = "\n "
#    
#    CONVERT THE SIGN EXTENDED INTEGER VALUE STORED IN $s0 TO ASCII
#    LOOP through 4 bits of $s0 at a time by using a bitmask
#    increment the bitmask until it is equal 0xF0000000
#       if-else statement 
#             if 4 bits isolated are between 0-9
#                 add 48 to convert to ASCII   
#             else if bits isolated are between A-F, greater than or equal to 10
#                 subtract 10 
#                 add 65
#       printing the ASCII value
#             print the ASCII value as a character
#             move the value into $a0 and use syscall 11
#    endLoop 
#             
#
#             final print to console should be: "The hex representation of tghe sign-extended number is: "
#                                               " 0X _ _ _ _ _ _ _ _"   
#
#    SET UP THE THIRD OUTPUT TEXT:
#    print dec Representation text = "The number in decimal is: "
#    print newLine = "\n "
#
#    IF THE EXTENDED SIGN 32 BIT IS NEGATIVE
#    use branch to go back to the case if it is a negative 32-bit ext. int.
#         once branched invert all the bits and add 1
#         then branch back
#  
#    CONVERT $s0 INT. VALUE TO ASCII STRING THAT DISPLAYS VALUE AS DECIMAL & PRINT
#    branch to this section once 2sc part is complete 
#         divide the value by 100 and print if greater than 0
#         divide the remainder by 10 and print if greater than 0
#         print the one's remainder
#             final print to console should be: "The number in decimal is: "
#                                               "______"
#   FINAL NEW LINE
#    print new line befor exiting 
#
#    Exit the Program
# } 
# 
#
# REGISTER USAGE:
# $t0: intermediate used to load and shift when converting the ASCII string to int. 
# $t1: temporarily store the int. value before sign extending it to 32-bits and saving in $s0
# $t2: shift variable
# $t5: used to specifiy the highest 4-bits in order to loop
# $t6: used to store the masked 4-bits in the loop then as an intermediate perform if-else to convert to ASCCI
# $t7: used to store the specified 4-bit that have been converted to ASCII, used to print each ASCII character
# $t8: used to check if the 32-bit extended int.'s Most sig. bit is + or -
#
# $s0: used to store the sign-extended 32 bit int. which is converted from the user inputted ASCII string
# $s1: stores 2SC for negative 32-bit sign-ext. integer



.text
.globl main
main: 
  
    #SET UP THE FIRST TEXT OUTPUT
    addi     $v0     $zero     4
    la       $a0     binRep
    syscall 
    # newLine
    addi     $v0    $zero      4
    la       $a0    newLine
    syscall
    
    # READ & PRINT USER INPUT (8-BIT BINARY NUMBER)
    lw       $a0    0($a1)
    li       $v0    4
    syscall
    
    # SET UP THE SECOND TEXT OUTPUT
    # newLine
    addi     $v0    $zero       4
    la       $a0    newLine
    syscall
    
    addi     $v0    $zero       4
    la       $a0    hexRep
    syscall
    # newLine
    addi     $v0    $zero       4
    la       $a0    newLine
    syscall
    
    
    
    # STORE THE 8-BIT BINARY VALUE INTO A REGISTER AS AN INTEGER 
    # load the MSB from the string, subtract 48 to convert from ASCII, then SLL appropriately, add into final int. value
    lw       $a1    0($a1)                        # set $a1 to point to the address2 which contains the string to convert
    
    lbu      $t0    0($a1)                        # load the 0th byte, most significant character, from string into $t0
    addi     $t0    $t0       -48                 # convert from ASCII to int. by subtracting 48, put into $t0
                                                  # should be either a 0 or 1
    sll      $t0    $t0       7                   # shift left logical (sll), shift int. to corresponding value in string place
    add      $t1    $t1       $t0                 # set $t1 to ($t1 + $t0) 
    
    lbu      $t0    1($a1)                        # load the 1st byte from the string into $t0
    addi     $t0    $t0       -48                 # convert from ASCII to int. by subtracting 48, into $t0
    sll      $t0    $t0       6                   # sll to corresponding string place
    add      $t1    $t1       $t0                 # set $t1 to add the 1st string value as an int.
    
    lbu      $t0    2($a1)                        # load the 2nd byte from the string into $t0
    addi     $t0    $t0       -48                 # convert from ASCII to int. by subtracting 48, into $t0
    sll      $t0    $t0       5                   # sll to corresponding string place
    add      $t1    $t1       $t0                 # set $t1 to add the 2nd string value as an int. 
    
    lbu      $t0    3($a1)                        # load the 3rd byte from the string into $t0
    addi     $t0    $t0       -48                 # convert from ASCII to int. by subtracting 48 
    sll      $t0    $t0       4                   # sll to corresponding string place 
    add      $t1    $t1       $t0                 # set $t1 to add the 3rd string value as an int. 
    
    lbu      $t0    4($a1)                        # load the 4th byte from the string into $t0
    addi     $t0    $t0       -48                 # convert from ASCII to int. by subtracting 48
    sll      $t0    $t0       3                   # sll to corresponding string place 
    add      $t1    $t1       $t0                 # set $t1 to add the 4th string value as an int. 
    
    lbu      $t0    5($a1)                        # load the 5th byte from the string into $t0
    addi     $t0    $t0       -48                 # convert from ASCII to int. by subtracting 48
    sll      $t0    $t0       2                   # sll to corresponding string place 
    add      $t1    $t1       $t0                 # set $t1 to add the 5th string value as an int.

    lbu      $t0    6($a1)                        # load the 6th byte from the string into $t0
    addi     $t0    $t0       -48                 # convert from ASCII to int. by subtracting 48
    sll      $t0    $t0       1                   # sll to corresponding string place 
    add      $t1    $t1       $t0                 # set $t1 to add the 6th string value as an int. 
    
    lbu      $t0    7($a1)                        # load the 7th byte from the string into $t0
    addi     $t0    $t0       -48                 # convert from ASCII to int. by subtracting 48
    sll      $t0    $t0       0                   # sll to corresponding string place
    add      $t1    $t1       $t0                 # set $t1 to add the 5th string value as an int. 
    
 
    
    
    # CONVERT TO HEXADECIMAL ASCII string
    # check if the most significant bit is positive or negative
    # if positive (MSB = 0) then branch to "positive" because already extended to 32 bits appropriately
    # if negative (MSB = 1) then sign extend 
    andi     $s0    $t1       0x00000080          # and against immediate value to check/extract MSB in $t1
                                                  # b/c immediate value is equal to ...10000000 (32-bits)
    beq      $s0    $zero     positive            # branch to "positive" if $s0 is equal to zero
    
    # NEGATIVE VALUE CASE
    # sign extension
    ori      $s0    $t1       0xFFFFFF00          # or against immediate value to check & extend MSB in $t1 
                                                  # b/c immediate value is equal to 1111...00000000 (32-bits)
                                                  # stores sign-extended value in $s0                                      
    b positive                                    # branch to positive label if sign-ext. is pos.
    
    negativeCase:                                 # branch back to here in order to find 2S Complement
    # invert all the bits and add 1 to find 2SC 
    xori     $s1    $s0       0xFFFFFFFF          # xori with 1 inverts the bits
    # add 1
    addi     $s1    $s1       0x00000001



   # CONVERT TO ASCII DECIMAL 
   # clear a bunch of registers 
   add       $t4    $zero     $zero 
   add       $t7    $zero     $zero 
   # first print the "-" character 
   # set the $t4 to equal the ASCII of "-"
   addi      $t4    $zero     0x0000002D          # 2D is the value of "-" in ASCII
   addi      $v0    $zero     11                  # use syscall 11 to print single ASCII character
   move      $a0    $t4                           # print the "-"
   syscall
   # convert $s1 to ASCII decimal 
    # set up variables for division 
    # first make sure they are clear
    add      $t1    $zero      $zero
    add      $t2    $zero      $zero
    add      $t3    $zero      $zero
    add      $t5    $zero      $zero 
    add      $t6    $zero      $zero
    add      $t8    $zero      $zero
    addi     $t2    $zero      100
    addi     $t3    $zero      10
    # divide $s0 by 100 & store remainder in 
    div      $t0    $s1        $t2
    mfhi     $t9
    # branch if div yields value greater than zero
    bgt      $t0    $zero      addASCIIhundNeg
    backInNeg:
             # check if the number in the hundreds place is greater than 1
             # if the number in the hundreds place is greater than 1 need to print 0 in between
             andi    $s5        $t8        0x00000001
             bgt     $s5        $a0        skipPrtNeg
             # print the zero
             add     $s7        $s7        48     # convert $s7 to ASCII character "0"  
             addi    $v0        $zero      11     # set up for syscall 11
             move    $a0        $s7               # move the $s7 to $s0 
             syscall                              # print the ASCII character "0" to screen
    skipPrtNeg:         
    # divide the remainder by 10 & store that remainder 
    div      $t8     $t9        $t3
    mfhi     $t1
    # branch if the div yields a value greater than zero
    bgt      $t8    $zero      addASCIItenNeg
    backInnNeg:
    # convert the final remainder to ASCCI & print the final remainder which is the one's value
    addi     $t1    $t1        48
    addi     $v0    $zero      11
    move     $a0    $t1
    syscall
    b doneDecNeg
    
    # add 48 to convert into ASCII and print as single character
    addASCIIhundNeg:
        addi     $t5    $t0    48
        # set to print the character 
        addi     $v0    $zero  11
        move     $a0    $t5
        syscall
        b backInNeg      
    addASCIItenNeg:
        addi     $t6   $t8     48
        # set to print the character 
        addi     $v0   $zero   11
        move     $a0   $t6
        syscall    
        b backInnNeg
    doneDecNeg:
    # branch back to the end of the program after printing the ASCII string in decimal
    b negDone
    
    positive:                                     # regardless of if postive or negative, branch to this label     
                                                                                                                                   
        
        # PRINTING 32-BIT SIGN-EXT. INT. VALUE AS AN ASCII STRING
        # the value is still in $t1 needs to move it to $s0 if you did not sign-extend 
        # check the most significant bit for sign extension 
        andi    $t0    $s0        0xF0000000      # check the most sig. bit of $t1
        beq     $t0    0xF0000000 next            # branch to next
        move    $s0    $t1 
        next: 
        
        # print out the "0x" that will prefix the hex. value as a string
        addi    $v0    $zero    4
        la      $a0    hexPrfx
        syscall
        
        # use bitmask to isolate every 4 bits in the int. 
        # set the registers that will be used as start and end boundaries for loop
        addi    $t5    $zero    0xF0000000        # this is the highest 4 bits specified for the conditions of looping
        addi    $t1    $zero    0xa0000000        # will be used to check if the 4-bit <= to 10
        addi    $t2    $zero    28                # will be used as variable to shift right logical and decremented for looping
        
        # loop 
        startLoop:
        beq     $t5    $zero      endLoop         # branch to "endLoop" when 4 most significant bits are isolated
             # mask the specified 4 bits 
             and     $t6    $t5    $s0            # isolate specified 4 bits from $s0 and store in $t6
             # check if the specified 4 bits are greater than, less than, or equal to 10
             # if block
             beq     $t6    $zero  zeroNybble     # needs seperate branch if equal to zero b/c doesnt require shift
             bgt     $t6    $t1    letterNybble   # branch to letterNybble label if greater than 10
             blt     $t6    $t1    numberNybble   # branch to numberNybbke label if less than 10 
               
             # if statement
             # convert the isolated 4 bits (letter) to ASCII 	
             letterNybble:
             sub     $t7    $t6    $t1            # subtract 10 from $t6 then store in $t7
             srav    $t7    $t7    $t2            # shift right logical by variable $t2 
             addi    $t7    $t7    +65            # add 65 and store in $t7 
             b      printingASCII
             
             # elseif statement
             # convert the istolate 4 bits (number) to ASCII
             zeroNybble:
             addi    $t7    $t6    +48            # add 48 to convert to ASCII 
             
             # else statement
             # convert the isolated 4 bits (number) to ASCII 
             numberNybble: 
             srav    $t6    $t6    $t2            # shift the value over to the rightmost bit place so addition works
             addi    $t7    $t6    +48            # add 48 to and store to $t7
             b      printingASCII
             
             printingASCII:                       # print the $t7 value as an ASCII string
             addi    $v0    $zero  11
             move    $a0    $t7
             syscall 
              
             
        # back to loop block
        srl     $t5    $t5      4                 # shift right logical by 4 bits to "decrement" 
        srl     $t1    $t1      4                 # shift right logical by 4 bits to "decrement"
        sub     $t2    $t2      4                 # decrement by 4 in order to use as shift variable
        add     $t0    $t0      $zero             # reset the value of $t7 for the next loop to work
        
        b startLoop                               # branch back to start
        endLoop:                                  # end loop once the lowest 4 bits have been printed
    
    # SET UP THIRD OUTPUT TEXT
    # newLine
    addi     $v0    $zero      4
    la       $a0    newLine
    syscall 
    # third output text
    addi     $v0    $zero      4
    la       $a0    decRep
    syscall
    # newLine
    addi     $v0    $zero      4
    la       $a0    newLine
    syscall    
    
    
    
    # CONVERT TO ASCII STRING THAT DISPLAYS AS DECIMAL        
    # first branch back to negative case if the sign-extend 32-bit int. if negative 
    andi     $t8    $s0        0x80000000
    beq      $t8    0x80000000 negativeCase
    
    # now actually convert to ASCII decimal 
    # set up variables for division 
    # first make sure they are clear
    add      $t1    $zero      $zero
    add      $t2    $zero      $zero
    add      $t3    $zero      $zero
    add      $t5    $zero      $zero 
    add      $t6    $zero      $zero
    add      $t8    $zero      $zero
    addi     $t2    $zero      100
    addi     $t3    $zero      10
    add      $s7    $zero      $zero
    # divide $s0 by 100 & store remainder in 
    div      $t0    $s0        $t2
    mfhi     $t9
    # branch if div yields value greater than zero
    bgt      $t0    $zero      addASCIIhund
    # branch if the div yields a value greater than zero
    backIn:
             # check if the number in the hundreds place is greater than 1
             # if the number in the hundreds place is greater than 1 need to print 0 in between
             andi    $s5        $a0        0x00000001
             blt     $s5        0x00000001 skipZeroPrint
             # print the zero
             add     $s7        $s7        48     # convert $s7 to ASCII character "0"  
             addi    $v0        $zero      11     # set up for syscall 11
             move    $a0        $s7               # move the $s7 to $s0 
             syscall                              # print the ASCII character "0" to screen
    skipZeroPrint:
    # divide the remainder by 10 & store that remainder 
    div      $t8    $t9        $t3
    mfhi     $t1
    bgt      $t8    $zero      addASCIIten
    backInn:
    # convert the final remainder to ASCCI & print the final remainder which is the one's value
    addi     $t1    $t1        48
    addi     $v0    $zero      11
    move     $a0    $t1
    syscall
    b doneDec
    
    # add 48 to convert into ASCII and print as single character
    addASCIIhund:                                 # branch here if the hundreds place value is 1
        addi     $t5    $t0    48                 # convert the 1 to ASCII
        # set to print the character 
        addi     $v0    $zero  11                 # set up to print a single ASCII character 
        move     $a0    $t5                       # move the ASCII number to $a0
        syscall                                   # print to console
        b backIn         
    addASCIIten:                                  # branch here is the tens place value is 1 or greater
        addi     $t6   $t8     48                 # convert the value to ASCII
        # set to print the character 
        addi     $v0   $zero   11
        move     $a0   $t6
        syscall                                   # print to console
        b backInn                                 # branch back to check 1's place
    
    # branching stuffs 
    negDone: 
    doneDec:

    
    # Last newLine
    addi     $v0    $zero      4
    la       $a0    newLine
    syscall   
    
    # EXIT PROGRAM: 
    addi     $v0    $zero     10
    syscall  

.data
    binRep:  .asciiz "You entered the binary number: "
    newLine: .asciiz "\n"
    hexRep:  .asciiz "The hex representation of the sign-extended number is: "
    hexPrfx: .asciiz "0x"
    decRep:  .asciiz "The number in decimal is: "
   
