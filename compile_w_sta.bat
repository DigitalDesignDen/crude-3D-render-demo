G:\altera\13.0sp1\quartus\bin64\quartus_sh --flow compile graphics_pipe.qpf -c graphics_pipe_top

G:\altera\13.0sp1\quartus\bin64\quartus_pgm -c USB-Blaster -o "p;.\output_files\graphics_pipe_top.sof" -m JTAG
REM G:\altera\13.0sp1\quartus\bin64\quartus_pgm -c USB-Blaster .\output_files\graphics_pipe_top.cdf