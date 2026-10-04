#!/bin/bash

set -e

echo "========================================"
echo " RV32I DIRECTED REGRESSION"
echo "========================================"

tests=(
    alu
    arithmetic
    imm_alu
    signed
    regfile_corner
    shift_rtype
    shift_imm
    branch
    beq_not_taken
    branches
    memory
    memory_width
    jal
    jalr
    lui_auipc
    system
)

for test in "${tests[@]}"
do
    echo ""
    echo "----------------------------------------"
    echo " Running: $test"
    echo "----------------------------------------"

    verilator --binary --assert --timing \
    -DASSERTIONS \
    --top-module tb_$test \
    rtl/top.sv rtl/pc.sv rtl/instruction_memory.sv rtl/decoder.sv \
    rtl/control_unit.sv rtl/register_file.sv rtl/immediate_generator.sv \
    rtl/alu.sv rtl/data_memory.sv \
    tb/directed/tb_$test.sv \
    -o sim_${test}_sva \
    >/dev/null

    ./obj_dir/sim_${test}_sva
done

echo ""
echo "========================================"
echo " ALL DIRECTED TESTS PASSED"
echo "========================================"
