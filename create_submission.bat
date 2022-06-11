@echo off
:: declare list of program names
set programs=program1 program2 program3

:: declare list of data_mems
set data_mems=data_mem_1 data_mem_2 data_mem_3 data_mem_3a data_mem_3b data_mem_3c

:: create submission directory if not existing
if not exist "%~dp0\submission\" mkdir "%~dp0\submission\"

:: create toplevel_tb_files directory if not existing
if not exist "%~dp0\submission\toplevel_tb_files\" mkdir "%~dp0\submission\toplevel_tb_files\"

:: for each program
(for %%p in (%programs%) do (
    :: create program directory if not exiting
    if not exist "%~dp0\submission\%%p\" mkdir "%~dp0\submission\%%p\"

    :: assemble program using assembler
    python "%~dp0\assembler\assembler.py" "%~dp0\assembly\%%p.asm"

    :: copy asm file and assembled program into folder
    copy "%~dp0\assembly\%%p.asm" "%~dp0\submission\%%p\" > NUL
    copy "%~dp0\assembler\translated\%%p" "%~dp0\submission\%%p\instructions" > NUL
    copy "%~dp0\assembler\translated\%%p" "%~dp0\submission\%%p\" > NUL
    copy "%~dp0\assembler\translated\%%p" "%~dp0\submission\toplevel_tb_files\" > NUL
))

:: copy assembler file and usage text file
copy "%~dp0\assembler\assembler.py" "%~dp0\submission\" > NUL
copy "%~dp0\assembler\usage.txt" "%~dp0\submission\" > NUL

:: copy README and this bat file
copy "%~dp0\README.txt" "%~dp0\submission\" > NUL
copy "%~dp0\create_submission.bat" "%~dp0\submission\" > NUL

:: copy processor .sv files
for /r "%~dp0\processor" %%f in (*.sv) do copy "%%f" "%~dp0\submission\program1\" > NUL
for /r "%~dp0\processor" %%f in (*.sv) do copy "%%f" "%~dp0\submission\program2\" > NUL
for /r "%~dp0\processor" %%f in (*.sv) do copy "%%f" "%~dp0\submission\program3\" > NUL
for /r "%~dp0\processor" %%f in (*.sv) do copy "%%f" "%~dp0\submission\toplevel_tb_files\" > NUL

:: copy data_mems
copy "%~dp0\processor\data_mem_1" "%~dp0\submission\program1\" > NUL
copy "%~dp0\processor\data_mem_2" "%~dp0\submission\program2\" > NUL
copy "%~dp0\processor\data_mem_3" "%~dp0\submission\program3\" > NUL
copy "%~dp0\processor\data_mem_3a" "%~dp0\submission\program3\" > NUL
copy "%~dp0\processor\data_mem_3b" "%~dp0\submission\program3\" > NUL
copy "%~dp0\processor\data_mem_3c" "%~dp0\submission\program3\" > NUL

:: copy each data mem into toplevel
for %%d in (%data_mems%) do copy "%~dp0\processor\%%d" "%~dp0\submission\toplevel_tb_files\" > NUL