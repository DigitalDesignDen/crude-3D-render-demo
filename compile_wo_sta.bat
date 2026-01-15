

G:\altera\13.0sp1\quartus\bin64\quartus_map --read_settings_files=on --write_settings_files=off graphics_pipe -c graphics_pipe_top
G:\altera\13.0sp1\quartus\bin64\quartus_fit --read_settings_files=off --write_settings_files=off graphics_pipe -c graphics_pipe_top
G:\altera\13.0sp1\quartus\bin64\quartus_asm --read_settings_files=off --write_settings_files=off graphics_pipe -c graphics_pipe_top
G:\altera\13.0sp1\quartus\bin64\quartus_pgm -c USB-Blaster .\output_files\graphics_pipe_top.cdf