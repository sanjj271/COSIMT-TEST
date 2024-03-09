#!/bin/bash

#Path to Project-dir, Qemu, systemC-demo, Gdb and software-image
#PROJECT_DIR="."
QEMU="/mnt/c/Users/Gogte/Desktop/RP_CODE/qemu-rp/qemu/build/qemu-system-arm"
#HW_DEVICE_TREE="$PROJECT_DIR/qemu-devicetrees/LATEST/SINGLE_ARCH/zcu102-arm.cosim2.dtb"
SYSTEMC_DEMO="/mnt/c/Users/Gogte/Desktop/RP_CODE/qemu-rp/DEMO@/zynqmp_demo2"
export LD_LIBRARY_PATH="/usr/local/systemc-2.3.1/lib-linux64"
GDB="/mnt/c/Users/Gogte/downloads/arm-gnu-toolchain-13.2.Rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-gdb"

SW_TEST_NAME="TEST"
SW_IMAGE="/mnt/c/Users/Gogte/Desktop/sanjana_intern_project/Qemu_test/test3/LinkerM3/kernel2.elf"
OUTPUT_SIM_DATA_PATH="/mnt/c/Users/Gogte/Desktop/RP_CODE/qemu-rp/DEMO@/TestResults"


#Qemu-SytemC co-simulation options
QEMU_MACHINE="lm3s811evb"
SYNC_QUANTUM=10000
I_COUNT="1"
SHARED_UNIX_SOCKET_PATH="/tmp/COSIM"
GDB_PORT="1234"

#Command to start Qemu
#START_QEMU="$QEMU -nographic \
#-M $QEMU_MACHINE \
#-machine-path $SHARED_UNIX_SOCKET_PATH \
#-icount $I_COUNT \
#-sync-quantum $SYNC_QUANTUM \
#-gdb tcp::$GDB_PORT "

START_QEMU="/mnt/c/Users/Gogte/Desktop/RP_CODE/qemu-rp/qemu/build/qemu-system-arm -machine lm3s811evb  -machine-path /tmp/COSIM -icount 1 -sync-quantum 1000000 -gdb tcp::$GDB_PORT "

#Command to start SystemC-demo
START_SYSTEMC="$SYSTEMC_DEMO \
unix:$SHARED_UNIX_SOCKET_PATH/qemu-rport-_machine_cosim \
$SYNC_QUANTUM"

OUTPUT_SIM_DATA="/mnt/c/Users/Gogte/Desktop/RP_CODE/qemu-rp/DEMO@/TestResults/TEST/10000"
mkdir -p $OUTPUT_SIM_DATA
rm -r $OUTPUT_SIM_DATA/*

#Start cosimulation (Qemu and SystemC run on separated processes)
$START_QEMU &> $OUTPUT_SIM_DATA/logQemu & 
$START_SYSTEMC &> $OUTPUT_SIM_DATA/logSC & 
#Use Gdb to download software-image and store sw-data
echo "$(date +%s.%N)" > $OUTPUT_SIM_DATA/startTime
$GDB -q <<EOF
set pagination off
set print elements 0
set print repeats 0
set max-value-size unlimited
file $SW_IMAGE
target remote :$GDB_PORT
load
b MainTest
continue
finish
set logging off
set logging file $OUTPUT_SIM_DATA/qCount
set logging redirect on
set logging on
print qCountValues
set logging off
set logging file $OUTPUT_SIM_DATA/sCount
set logging redirect on
set logging on
print sCountValues
set logging off
q
y
EOF
echo "$(date +%s.%N)" > $OUTPUT_SIM_DATA/endTime
#Kill processes used for co-simulation(i.e. Qemu and SystemC processes)
kill %1
kill %2
