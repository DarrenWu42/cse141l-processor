Navigation:

In the top level folder, there are 3 program folers, 1 extra toplevel_tb files folder, the
assembler python file, the usage.txt for that assembler, a create_submission.bat file, and
finally this README.txt.

In each of the 3 program folders, there are the complete sv files required for each program as well
as an instructions file that contains the machine code instructions for the processor. Each folder
also contains the TIS-9 assembly code for the program. 

In each program folder there is also a TopLevel_tb.sv file, which will work to test each program
individually.

In the toplevel_tb_files folder, every data_mem and program instruction exists and thoroughly tests
every single program.

The create_submission.bat file is supposed to exist in a directory above the submission folder,
where it would automatically assemble code and copy all the required files into a submission
folder, which made for quicker testing on the Sanity Check and easier to keep the submission folder
up to date. This executable won't work where it's currently placed and is just here more as a proof
of work.
===================================================================================================
Working:

Every program works. Program 1 and 2 were tested with full coverage tests, so any possible input
for each program was tested and compared (this took a long time, especially for Program 2). Program
3 was tested with a few different patterns and pattern sets, but enough for me to feel safe turning
it in.
===================================================================================================
Work Distribution:

I can't really say how long I spent working on this project since I didn't really keep track, but
probably no more than 30 hours.