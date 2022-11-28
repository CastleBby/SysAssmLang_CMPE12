####################################################################################
# Created by:  Castelan Moreno, Emily
#              ecastela
#              23 August 2018
#
# Assignment:  Lab 6: Musical Subroutines
#              CMPE 012, Computer Systems and Assembly Language
#              UC Santa Cruz, Summer 2018
# 
# Description: This program uses subroutines to determine the pitch and duration of notes in
#              in a string. Notes are provided in a string of arguments in the 
#              .data segment and are seperated by spaces.
#              The program uses syscall 33 to play the song.
# Notes:       This program is intended to be run from MARS IDE.
#              The program assumes the first note provides a rhythm 
#              set for duration.
#              The program follows LilyPad syntax.
####################################################################################
#---------------
# REGISTER USAGE:
# $t0: loading address into temp. register
# $t1: incrementing/counting in loop
# $t2: value of [space] in ASCII 
# $t3: load the byte that would be octave for checking 
# $t4: load the byte that would be rhythm for checking 
# $t5: int. 4 to execute division for get_rhythm into beats 
# $t6: for looping and calling play_song as many times as there notes
# $t7: loads byte for checking song length 
# $t8: number of notes in string "song"
# $a0 & $a1: used to pass arguments between subroutines
# $v0 & $v1: used for outputs for subroutines
# f0 & f2: floating point numbers used for beat values 1/2 and 1/16 

# PROGRAM: 
# separated into 6 subroutines
# DATA SEGMENT:
# this is where the user will input the song to play as a string

# data for floating point values for rhythms  
.data
fpHalfBeat: .double .5
fpQrtrBeat: .double .25



# PLAY SONG:########################################################################################
# input  $a0 - address of first character in string containing song
#        $a1 - tempo of song in beats per minute
.text
play_song:
jal      get_song_length              # jump and link to get_song_length
                                      # to determine number of notes in string
move     $t8               $v0        # move the number of notes in string into $t8
     playLoop:
     bgt      $t6          $t8   end  # end loop once all notes have been played              
     jal      play_note               # jump and link to play_note
                                      # to use syscall 33 and play the note
     addi     $t6          $t6   1    # increment the loop counter 
end:
jal      exit_program                 # jump and link to exit program subprogram





# GET SONG LENGTH: determines the number of notes in a string#######################################################
# $t0: address of string, incremented to check each character in the string
# $t1: counter, determines the number of notes in the string "song"
# $t2: value of space in ASCII decimal, used to check against the value of each character in the string "song"
.text
get_song_length:
li       $t2    32                    # value of space in ASCII decimal
move     $t0    $a0                   # loads the address of song into $t0 
spaceLoop:                            # loop that counts the number of spaces in the string "song" 
                                      # adds one to register $t1 for each [space] which has a value of 32 in ASCII 
                                      # and a value of 20 in hex
lb       $t7    0($t0)                # loads the first byte, the first character, into $a0 
beqz     $t7    done                  # branch to doneCounting when the null termination of the string is reached
addi     $t0    $t0        1          # increments address $t0 to the next character 
     # if statement 
     # if the character = [space] increment $t1 by one
     bne   $t7    $t2      skipAddtn  # skip the addition if the character in $t7 isn't a [space]
     addi  $t1    $t1      1          # increment $t1 if the value is a [space]
skipAddtn: 
b spaceLoop                           # branch back to the start of the Loop
done:                                 # finish looping when null terminator is reached 
addi     $t1    $t1        1          # one more +1 to the $t1 register to account for the note after the last space
move     $v0    $t1                   # move to $v0 for final output to work as a function
jr       $ra

# PLAY NOTE: plays note using syscall system 33 ###########################################################
# input  $a0 - pitch
#        $a1 - note duration in milliseconds
# output no output arguments, plays note using syscall system service 33 
.text
play_note:

li       $v0    33                    # syscall 33 setup
li       $a2    108                   # sets instrument to "ethnic"  
li       $a3    127                   # sets volume to 127 max
# jal to read note for pitch and rhythm
jal      read_note
syscall                               # plays note
jr       $ra


# READ NOTE:  reads single note using pith & rhythm subs ############################################
# input  $a0 - address of first character in string containing note enconding 
#        $a1 - rhythm of previous note
# output $v0 - note rhythm in bits {31:16}, note pitch in bits {15:0}
#              note rhythm, take 4 and divide by value of the rhythm 
#              note pitch, MIDI value 0-127
#        $v1 - address of first character of what would be next note
.text 
read_note:
jal      get_pitch                   # call get_pitch subprogram
sll      $v0    $v0         16
la       $v0    0($v0)               # move pitch value into $a0
jal      get_rhythm                  # call get_rhythm subprogram
la       $v0    0($v0)               # move rhythm value into $a1





# GET PITCH: get pitch by checking note, accidental, and modifer ####################################
.text
get_pitch:
move     $t0    $a0                   # loads the address of the song into $t0 
lb       $t9    0($t0)                # loads the first byte, the first character, into $t9

# a bunch of different if's for each potential MIDI pitch value 
bne      $t9    97         checkb     # branch if first note encoding isn't a     
addi     $t1    $t9        -40        # convert to corresponding note value a  
checkb:
bne      $t9    98         checkc     # branch if first note econdign isn't b
addi     $t1    $t9        -39        # convert to corresponding note value b 
checkc:
bne      $t9    99         checkd     # branch if first note encoding isn't c
addi     $t1    $t9        -39        # convert to corresponding note value c 
checkd:
bne      $t9    100        checke     # branch if first note encoding isn't d 
addi     $t1    $t9        -38        # convert to correpsonding note value d
checke: 
bne      $t9    101        checkf     # branch if first note encoding isn't e
addi     $t1    $t9        -37        # convert to corresponding note value e 
checkf:
bne      $t9    102        checkg     # branch if first note encoding isn't f
addi     $t1    $t9        -37        # convert to corresponding note value f
checkg:
bne      $t9    103        checkr     # branch if first note encoding isn't g
addi     $t1    $t9        -36        # convert to corresponding note value g
checkr:
bne      $t9    114        notR       # branch if first not encoding isn't r 
add      $t1    $zero      $zero      # set pitch to zero because r is a rest 
b noModr
notR:
# accidental pitch modifier 
# first move to next character by incrementing $a0 
addi     $t0    $t0        1          # increments address to next charcter
lb       $t2    0($t0)                # loads the first byte of $t0 into $t2, the second character
beq      $t2    32         noMod      # if the character is a space there are no modifiers 
beq      $t2    44         noAccMod   # if the character is a comma there is no accidental but there is an octave modifier
beq      $t2    39         noAccMod   # if the character is an apostrophe there is no accidental but there is an octave modifier
bne      $t2    101        checki     # branch if not e, to sharp modifying option 
addi     $t1    $t1        -1         # minus 1 to make the pitch value flat
b afterAccidental
checki: 
addi     $t1    $t1        1          # add 1 to make the pitch value sharp
b afterAccidental
# octave pitch modifier 
# option for octave following accidental modifier 
afterAccidental: 
# need a loop that checks for octave modifiers until a space or number is reached
addi     $t0    $t0        2          # increment address to what would be octave
lb       $t3    0($t0)                # loads the byte into $t3, would be octave
noAccMod:                             # if no accidental modifier but octave modifer present
                                      # address has already been incremented just load the byte into $t3
lb       $t3    0($t0)
octLoop:
bne      $t3    44         checkAps   # if the character isn't a comma check apostrophe
addi     $t1    $t1        -12        # if comma, decrease midi pitch value by 12
b checkAgain
checkAps:
bne      $t3    39         noOct      # if the character isn't an apostrophe either, character is not an octave modifier
addi     $t1    $t1        12         # if apostrophe, increase midi pitch value by 12
b checkAgain
checkAgain:
addi     $t0    $t0        1          # increment address to next character
lb       $t3    0($t0)                # load the byte into $t3 for checking 
b octLoop
noOct:                                # branches out of the loop if the character is neither a , or '
noModr: 
noMod:                                # if no modifiers at all
                                      # don't need to increment address again because that's what 
                                      # got it to branch here, getting a character that wasn't a 
                                      # note or modifier value
move     $v0    $t1                   # move final pitch value to $v0 for output function
move     $v1    $t0                   # move address which has been incremented to $v1
jr       $ra


# clear register $1 for use
add      $t1    $zero      $zero
# GET RHYTHM: get duration of sound in beats #######################################################
.text
get_rhythm:

addi     $t5    $zero      4          # load 4 into register in order to execute division
lb       $t4    0($t0)                # load the byte to be checked into $t4
                                      # can assume the first note in a song will have a rhythem explicility stated
bne      $t4    49         check2     # branch if character isn't 1
div      $t1    $t5        $t4        # 4/$t4 should be 4 beats
check2:
bne      $t4    50         check4     # branch if character isn't 2
div      $t1    $t5        $t4        # 4/$t4 should be 2 beats
check4: 
bne      $t4    52         check8     # branch if character isn't 4
div      $t1    $t5        $t4        # 4/$t5 should be 1 beat
check8:
bne      $t4    56         check16    # branch if character isn't 8
l.d      $f0    fpHalfBeat            # 4/$t5 should be 1/2 beat
check16: 
beq      $t4    32         noRhythm   # if the value is a space, there is no rhythm indicated
l.d      $f2    fpQrtrBeat            # 4/$t5 should be 1/4 beat
# increment the address to the first character of next note
addi     $a0    $a0        2          # would need to skip the space between notes to get to next note character
# move stuff to the proper output registers 
move     $v0    $t1                   # move final beat into $v0 for function output
move     $v1    $a0                   # address of first character of next note into $v1
# if beat value is floating point 
b doneRhythm
noRhythm:
addi     $a0    $a0        1          # already at a space, need to only increment by 1
move     $v0    $a1                   # use previous note rhythm
move     $v1    $a0                   # address of first character of next note into $v1
doneRhythm:
jr       $ra    



# EXIT PROGRAM ###########################################################################
.text
exit_program:
li       $v0    10
syscall