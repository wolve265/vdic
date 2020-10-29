
# XM-Sim Command File
# TOOL:	xmsim	19.09-s003
#

set tcl_prompt1 {puts -nonewline "xcelium> "}
set tcl_prompt2 {puts -nonewline "> "}
set vlog_format %h
set vhdl_format %v
set real_precision 6
set display_unit auto
set time_unit module
set heap_garbage_size -200
set heap_garbage_time 0
set assert_report_level note
set assert_stop_level error
set autoscope yes
set assert_1164_warnings yes
set pack_assert_off {}
set severity_pack_assert_off {note warning}
set assert_output_stop_level failed
set tcl_debug_level 0
set relax_path_name 1
set vhdl_vcdmap XX01ZX01X
set intovf_severity_level ERROR
set probe_screen_format 0
set rangecnst_severity_level ERROR
set textio_severity_level ERROR
set vital_timing_checks_on 1
set vlog_code_show_force 0
set assert_count_attempts 1
set tcl_all64 false
set tcl_runerror_exit false
set assert_report_incompletes 0
set show_force 1
set force_reset_by_reinvoke 0
set tcl_relaxed_literal 0
set probe_exclude_patterns {}
set probe_packed_limit 4k
set probe_unpacked_limit 16k
set assert_internal_msg no
set svseed 1
set assert_reporting_mode 0
alias . run
alias quit exit
database -open -shm -into waves.shm waves -default
probe -create -database waves top.sin top.sout top.clk top.rst_n top.tester.A top.tester.B top.tester.alu_op top.tester.crc4 top.tester.test_op top.scoreboard.C top.scoreboard.alu_status top.scoreboard.crc3 top.scoreboard.crc4 top.scoreboard.err_flags top.scoreboard.flags top.scoreboard.in_A top.scoreboard.in_B top.scoreboard.in_alu_op top.scoreboard.in_crc4 top.scoreboard.in_status top.scoreboard.parity top.scoreboard.predicted_C top.scoreboard.predicted_alu_status top.scoreboard.predicted_crc3 top.scoreboard.predicted_err_flags top.scoreboard.predicted_flags top.scoreboard.predicted_parity top.scoreboard.result
probe -create -database waves top.read_serial_in.packet_type top.read_serial_in.temp_d
probe -create -database waves top.read_serial_in.A[31] top.read_serial_in.A[30] top.read_serial_in.A[29] top.read_serial_in.A[28] top.read_serial_in.A[27] top.read_serial_in.A[26] top.read_serial_in.A[25] top.read_serial_in.A[24] top.read_serial_in.A[23] top.read_serial_in.A[22] top.read_serial_in.A[21] top.read_serial_in.A[20] top.read_serial_in.A[19] top.read_serial_in.A[18] top.read_serial_in.A[17] top.read_serial_in.A[16] top.read_serial_in.A[15] top.read_serial_in.A[14] top.read_serial_in.A[13] top.read_serial_in.A[12] top.read_serial_in.A[11] top.read_serial_in.A[10] top.read_serial_in.A[9] top.read_serial_in.A[8] top.read_serial_in.A[7] top.read_serial_in.A[6] top.read_serial_in.A[5] top.read_serial_in.A[4] top.read_serial_in.A[3] top.read_serial_in.A[2] top.read_serial_in.A[1] top.read_serial_in.A[0] top.read_serial_in.B[31] top.read_serial_in.B[30] top.read_serial_in.B[29] top.read_serial_in.B[28] top.read_serial_in.B[27] top.read_serial_in.B[26] top.read_serial_in.B[25] top.read_serial_in.B[24] top.read_serial_in.B[23] top.read_serial_in.B[22] top.read_serial_in.B[21] top.read_serial_in.B[20] top.read_serial_in.B[19] top.read_serial_in.B[18] top.read_serial_in.B[17] top.read_serial_in.B[16] top.read_serial_in.B[15] top.read_serial_in.B[14] top.read_serial_in.B[13] top.read_serial_in.B[12] top.read_serial_in.B[11] top.read_serial_in.B[10] top.read_serial_in.B[9] top.read_serial_in.B[8] top.read_serial_in.B[7] top.read_serial_in.B[6] top.read_serial_in.B[5] top.read_serial_in.B[4] top.read_serial_in.B[3] top.read_serial_in.B[2] top.read_serial_in.B[1] top.read_serial_in.B[0]
probe -create -database waves top.read_serial_in.alu_op[2] top.read_serial_in.alu_op[1] top.read_serial_in.alu_op[0] top.read_serial_in.crc4[3] top.read_serial_in.crc4[2] top.read_serial_in.crc4[1] top.read_serial_in.crc4[0]
probe -create -database waves top.read_packet_in.d[7] top.read_packet_in.d[6] top.read_packet_in.d[5] top.read_packet_in.d[4] top.read_packet_in.d[3] top.read_packet_in.d[2] top.read_packet_in.d[1] top.read_packet_in.d[0]

simvision -input /home/student/kcislo/VDIC/lab01/.simvision/419224_kcislo__autosave.tcl.svcf
