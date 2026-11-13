`timescale 1ns/1ps
`default_nettype none

/*
Макрос определяет задачу для проверки условия и вывода 
сообщения о прохождении или провале теста.

condition: условие для проверки.
s: строка с сообщением.
*/

`define TBASSERT_METHOD(TB_NAME) reg [512:0] tbassertLastPassed = "";       \
    task TB_NAME(                                                           \
                input condition,                                            \
                input [512:0] s                                             \
                );                                                          \
    if (condition === 1'bx)                                                 \
    $display("-Failed === x value: %-s", s);                                \
        else if (condition == 0) $display("-Failed: %-s", s);               \
            else if (s != tbassertLastPassed) begin                         \
                $display("Passed: %-s", s);                                 \
                tbassertLastPassed = s;                                     \
        end                                                                 \
    endtask                                                     

/*
major count number is hard-coded (a quoted string)
Макрос расширяет TBASSERT_METHOD, добавляя 
возможность указания минорного и мажорного номеров.

condition: условие для проверки.
s: строка с сообщением.
minor: минорный номер.
major: мажорный номер (строка).
*/

`define TBASSERT_2_METHOD(TB_NAME) reg [512:0] tbassert2LastPassed = "", f; \ 
    task TB_NAME(                                                       \
                input condition,                                            \
                input [512:0] s,                                            \
                input integer minor,                                        \
                input [512:0] major                                         \
                );                                                          \
    $sformat(f, "%0s %0d-%0s", s, minor, major);                            \
    if (condition === 1'bx)                                                 \
        $display("-Failed === x value: %-s", f);                            \
        else if (condition == 0) $display("-Failed: %-s", f);               \
            else if (f != tbassert2LastPassed) begin                        \
            $display("Passed: %-s", f);                                     \
            tbassert2LastPassed = f;                                        \
        end                                                             \ 
    endtask                                                  


/*
Этот макрос определяет задачу для условной 
проверки с использованием TBASSERT_2_METHOD.

caseCondition: условие для выполнения проверки.
condition: условие для проверки.
s: строка с сообщением.
minor: минорный номер.
major: мажорный номер (строка).
*/

`define CASE_TBASSERT_2_METHOD(TB_NAME, TBASSERT_2_TB_NAME)                 \
    task TB_NAME (input caseCondition,                                      \
                    input condition,                                        \
                    input [512:0] s,                                        \
                    input integer minor,                                    \
                    input [512:0] major);                                   \
    if (caseCondition) TBASSERT_2_TB_NAME(condition, s, minor, major);  \
    endtask

/*
minor count number is hard-coded (a quoted string)
Этот макрос аналогичен TBASSERT_2_METHOD, 
но мажорный и минорный номера меняются местами.

condition: условие для проверки.
s: строка с сообщением.
minor: минорный номер (строка).
major: мажорный номер.
*/

`define TBASSERT_2R_METHOD(TB_NAME) reg [512:0] tbassert2RLastPassed = "", fR; \
    task TB_NAME(                                                              \
                input condition,                                               \
                input [512:0] s,                                               \
                input [512:0] minor,                                           \
                input integer major                                            \
                );                                                             \
                $sformat(fR, "%0s %0s-%0d", s, minor, major);                  \  
    if (condition === 1'bx) $display("-Failed === x value: %-s", fR);          \ 
    else if (condition == 0)                                                   \
    $display("-Failed: %-s", fR);                                              \
    else if (fR != tbassert2RLastPassed) begin                                 \
        $display("Passed: %-s", fR);                                           \
        tbassert2RLastPassed = fR;                                             \
        end                                                                    \
    endtask

/*    
5. Этот макрос определяет задачу для условной 
проверки с использованием TBASSERT_2R_METHOD.
caseCondition: условие для выполнения проверки.
condition: условие для проверки.
s: строка с сообщением.
minor: минорный номер (строка).
major: мажорный номер.
*/

`define CASE_TBASSERT_2R_METHOD(TB_NAME, TBASSERT_2_TB_NAME)                   \
    task TB_NAME(                                                              \
                input caseCondition,                                           \
                input condition,                                               \
                input [512:0] s,                                               \
                input [512:0] minor,                                           \
                input integer major);                                          \
                if (caseCondition) TBASSERT_2_TB_NAME(condition, s, minor, major);\ 
    endtask

/*
major and minor count numbers are both integers
6. Этот макрос аналогичен TBASSERT_2_METHOD, 
но мажорный и минорный номера являются целыми числами.

condition: условие для проверки.
s: строка с сообщением.
minor: минорный номер.
major: мажорный номер.
*/

`define TBASSERT_2I_METHOD(TB_NAME) reg [512:0] tbassert2ILastPassed = "", fI;  \
    task TB_NAME(                                                               \
                input condition,                                                \
                input [512:0] s,                                                \
                input integer minor,                                            \
                input integer major);                                           \
    $sformat(fI, "%0s %0d-%0d", s, minor, major);                               \
    if (condition === 1'bx)                                                     \
        $display("-Failed === x value: %-s", fI);                               \
        else if (condition == 0) $display("-Failed: %-s", fI);                  \
            else if (fI != tbassert2ILastPassed) begin                          \
                $display("Passed: %-s", fI);                                    \
                tbassert2ILastPassed = fI;                                      \
        end                                                                     \
    endtask

/*
Этот макрос определяет задачу для условной 
проверки с использованием TBASSERT_2I_METHOD.

caseCondition: условие для выполнения проверки.
condition: условие для проверки.
s: строка с сообщением.
minor: минорный номер.
major: мажорный номер.
*/

`define CASE_TBASSERT_2I_METHOD(TB_NAME, TBASSERT_2_TB_NAME)    \
    task TB_NAME(                                               \
                input caseCondition,                            \
                input condition,                                \
                input integer s,                                \
                input integer minor,                            \
                input integer major);                           \
        if (caseCondition) TBASSERT_2_TB_NAME(condition, s, minor, major); \ 
    endtask

// Этот макрос определяет задачу для ожидания одного такта тактового сигнала.
// Clk: тактовый сигнал.
`define TBCLK_WAIT_TICK_METHOD(TB_NAME)     \
    task TB_NAME;                           \
        repeat (1) @(posedge Clk);          \
    endtask                             
