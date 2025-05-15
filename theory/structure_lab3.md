# Лабораторная работа № 3 - Исследование программного процессора biRISC-V

## Цели и задачи

## 1 Введение в стандарт RISC-V
[Содержание 1 главы](./birisc_v%20description/Chapter_1_RISC_V_Intriducing.md)


## 2 Описание процессора biRISC-V
В данном разделе представлено краткое описание архитектуры и модулей RTL дизайна процессора biRISC-V

### Описание и ключевые особенности процессора

[Содержание 2 главы](./birisc_v%20description/Chapter_2_Core_description.md)

### Архитектура (реализация) процессора

#### Общие компоненты

##### Ядро процессора

###### 1 frontend

###### 1.1 npc

###### 1.2 decode

###### 1.3 fetch

###### 2 lsu

###### 2.1 lsu_fifo

###### 3 mmu

###### 4 csr

###### 4.1 biriscv_csr_regfile

###### 5 multiplier

###### 6 divider

###### 7 issue

###### 7.1 pipe_ctrl

###### 7.1.1 trace_sim

###### 7.2 regfile

###### 7.2.1 xilinx_2r1w

###### 7.3 trace_sim

###### 8 exec

###### 8.1 alu

#### Реализация с TCM памятью

##### tcm_top

###### 1 dport_mux

###### 2 tcm_mem

###### 2.1 tcm_mem_pmem

###### 2.2 tcm_mem_ram

###### 3 dport_axi

###### 3.1 dport_axi_fifo

#### Реализация с КЭШ памятью

##### top

###### 1 dcache

###### 1.1 dcache_if_pmem

###### 1.1.1 dcache_if_pmem_fifo

###### 1.2 dcache_pmem_mux

###### 1.3 dcache_mux

###### 1.4 dcache_core

###### 1.4.1 dcache_core_data_ram

###### 1.4.2 dcache_core_tag_ram

###### 1.5 dcache_axi

###### 1.5.1 dcache_axi_fifo

###### 1.5.2 dcache_axi_axi

###### 2 icache

###### 2.1 icache_tag_ram

###### 2.2 icache_data_ram

## 3 Руководство по программированию 


## 4 Интеграционные тесты


## Приложение А - описание сигнальных линий модулей ядра biRISC-V

В качестве примера рекомендуется посмотреть книгу "Цифровой синтез". Лабораторная работа - schoolMIPS / schoolRISCV.  
