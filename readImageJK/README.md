# readImageJK

## PURPOSE:
This function reads the output file "position.txt" produced by  the ImageJ macros "Particle_Identification". "position.txt"  file must consist of the columns of data in the following   order: particle number, frame label, particle area,  paricle x-coordinate, particle y-coordinate, slice number. It is assumbed that columns are separated by commas  and arbitrary number of spaces AND/OR tabs.

## CALLING SEQUENCE:
       Result = readImageJK()

## INPUTS
       The fuction doesn't have input variables.
       
## OUTPUTS
       A structure with the following tags: 
         .iParticle  - an array of particle numbers 
         .iFrame     - an array of frame numbers
         .X          - an array of x-coordinate of the particles
         .Y          - an array of y-coordinate of the particles
         .area       - an array with area of the particles
         .error      - an array with errors in particle positions 
         

## PROCEDURE:
       

## MODIFICATION HISTORY:
           Written by:  Anton Kananovich, April 2016
           Modified:    Anton Kananovich, May 2018.
                         Optimized for memory economy. Now works 
                         correctly with framelables which contain file
                         extension (for example, "fubar4834.tiff").
                        Anton Kananovich, June 2018
                         added a keyword lowmem. Set the keywork if your computer
                         has insufficient memory
                        Anton Kananovich, July 2018
                         fixed the bug, when each element of the
                         /lowmem version of the array
                         returnStructur.iParticle was larger by unity
                         than that of the usual version of the
                         function.
                         The iParticle and iFrame not return exact same numbers
                         as in the file, without subtraction of 1 (unity)
           Modified:    Anton Kananovich, July 2018
                         added the 'path' input variable. Without the
                         variable supplied, the function will work as
                         before. With the variable supplied, the
                         will open and process the file designated 
                         in the variable.    
