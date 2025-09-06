```mermaid
graph TB
    %% Основные блоки
    subgraph "Учебный процессор"
        direction TB
        
        %% Блок управления
        CU[Control Unit<br/>Блок управления]
        
        %% Регистровый файл
        subgraph RF[Register File]
            R0[Reg 0: 0]
            R1[Reg 1: 1] 
            R2[Reg 2]
            R3[Reg 3]
            Rn[Reg n...]
        end
        
        %% АЛУ
        subgraph ALU[16-bit ALU]
            ALU0[ALU 74181<br/>4-bit]
            ALU1[ALU 74181<br/>4-bit]
            ALU2[ALU 74181<br/>4-bit]
            ALU3[ALU 74181<br/>4-bit]
            CLA[CLA 74182<br/>Carry Lookahead]
        end
        
        %% Входные интерфейсы
        INSTR[Instruction Input<br/>Команды]
        IMM[Immediate Data<br/>Непосредственные значения]
        
        %% Выходные интерфейсы
        RES[Result Output<br/>Результат]
        FLAGS[Flags Output<br/>Флаги]
        
        %% Внутренние шины
        BUS_A[Bus A<br/>16-bit]
        BUS_B[Bus B<br/>16-bit]
        BUS_RES[Result Bus<br/>16-bit]
    end

    %% Соединения
    %% Входы
    INSTR --> CU
    IMM --> ALU
    
    %% Управление
    CU --> RF
    CU --> ALU
    
    %% Данные
    RF -- "Operand A" --> BUS_A --> ALU
    RF -- "Operand B" --> BUS_B --> ALU
    
    %% Мультиплексор выбора источника B
    MUX_B{MUX B Source<br/>0: Register<br/>1: Immediate}
    BUS_B --> MUX_B
    IMM --> MUX_B
    MUX_B --> ALU
    
    %% АЛУ соединения
    ALU0 -- "nGG/nGP" --> CLA
    ALU1 -- "nGG/nGP" --> CLA  
    ALU2 -- "nGG/nGP" --> CLA
    ALU3 -- "nGG/nGP" --> CLA
    CLA -- "carry_ic" --> ALU1
    CLA -- "carry_ic" --> ALU2
    CLA -- "carry_ic" --> ALU3
    
    %% Выходы
    ALU -- "Result" --> BUS_RES --> RES
    ALU -- "Flags" --> FLAGS
    
    %% Обратная связь для записи
    BUS_RES --> RF

    %% Группировка
    classDef control fill:#e1f5fe,stroke:#01579b
    classDef data fill:#f3e5f5,stroke:#4a148c  
    classDef alu fill:#e8f5e8,stroke:#1b5e20
    classDef reg fill:#fff3e0,stroke:#e65100
    classDef io fill:#fbe9e7,stroke:#bf360c
    
    class CU,INSTR control
    class RF,R0,R1,R2,R3,Rn reg
    class ALU,ALU0,ALU1,ALU2,ALU3,CLA alu
    class BUS_A,BUS_B,BUS_RES data
    class RES,FLAGS,IMM io

    ```