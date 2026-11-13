# ALU_discrete_ic
This repository presents ALUs based on 74181/74182 and 74381/74382 chips (4/16/32 bits) implemented in SystemVerilog, with UVM verification labs for Verilator.


## Разрабатываемые дизайны

[4 разрядное АЛУ 74381](./simlpe_ALU/74381/rtl/top/alu_4_bit.v)

[16 разрядное АЛУ 74381](./simlpe_ALU/74381/rtl/top/alu_16_bit.v)

[4 разрядное АЛУ 74382](./simlpe_ALU/74382/rtl/src/alu_74382.sv)

[16 разрядное АЛУ 74382](./simlpe_ALU/74382/rtl/top/alu_16_chain.sv)

[4 разрядное АЛУ 74181](./classic_ALU/src_common/74181.v)

[16 разрядное АЛУ 74181](./classic_ALU/74181_16bit/rtl/top/top_alu_16.v)

[32 разрядное АЛУ 74181](./classic_ALU/74181_32bit/rtl/top/top_alu_32.v)

[Скоростная схема ускоренного переноса](./common_CLA/74182_CLA/)


## Лабораторные работы

[UVM-верификация АЛУ 74381/74382 в среде Verilator](./uvm_lab_ALU_7438x/) — студентческая лабораторная работа по методологии UVM: окружение agent/refmodel/scoreboard/coverage, тесты по таблицам истинности datasheet, исчерпывающий перебор, охота на дефект OVR в 74382.

## Документация

- [DOCs/datasheets/](./DOCs/datasheets/) — даташиты 74181/74182/74381/74382;
- [SNUG 2013: Applications of Custom UVM Report Servers](./DOCs/Application%20notes/SNUG_Applications_of_custom_UVM_report_servers.pdf) — первоисточник паттернов кастомного report server (G. McGregor, Verilab);
