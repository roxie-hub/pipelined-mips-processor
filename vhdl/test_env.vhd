----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/03/2022 11:20:45 AM
-- Design Name: 
-- Module Name: RF - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_env is
     Port (btn : in std_logic_vector(4 downto 0);
        sw : in std_logic_vector(15 downto 0);
        clk : in std_logic;
        an : out std_logic_vector(3 downto 0);
        cat : out std_logic_vector(6 downto 0);
        led : out std_logic_vector(15 downto 0)); 
end test_env;

architecture Behavioral of test_env is

signal Branch: std_logic;
signal BGEZ: std_logic;
signal MemWrite: std_logic;
signal MemData: std_logic_vector(15 downto 0);
signal ALUSrc : std_logic;
signal ALUOp: std_logic_vector(1 downto 0);
signal Zero: std_logic;
signal ALURes: std_logic_vector(15 downto 0);
signal RegWrite: std_logic;
signal RegDst: std_logic;
signal ExtOp: std_logic;
signal RD1: std_logic_vector(15 downto 0):=x"0000";
signal RD2: std_logic_vector(15 downto 0):=x"0000";
signal Ext_Imm: std_logic_vector(15 downto 0):=x"0000";
signal func:  std_logic_vector(2 downto 0):="000";
signal sa: std_logic;
signal wd: std_logic_vector(15 downto 0):=x"0000";
signal JAdr: std_logic_vector(15 downto 0):=x"0000";
signal BAdr: std_logic_vector(15 downto 0):=x"0000";
signal PCSrc:std_logic;
signal PCSrc1:std_logic;
signal Jump:std_logic;
signal RST:std_logic;
signal EN:std_logic;
signal pc_1:std_logic_vector(15 downto 0);
signal Instr:std_logic_vector(15 downto 0);
signal enable : std_logic:='0';
signal enable1 : std_logic:='0';
signal cnt : std_logic_vector(15 downto 0);
signal sum: std_logic_vector(15 downto 0);
signal MemtoReg: std_logic;

signal testNr: std_logic_vector(15 downto 0):= x"0000";
signal cntTest: std_logic_vector(2 downto 0):= "000";
signal enTest: std_logic;
signal WA: std_logic_vector(2 downto 0);

----
signal if_id : std_logic_vector(31 downto 0); --(15 dt 0)->Instr , (31 dt 16)->pc_1
signal id_ex : std_logic_vector(78 downto 0); --(77)->sa , (76 dt 75)->wb , (74 dt 72)->mem , (71 dt 70)->ex , (69 dt 54)->pc_1 , (53 dt 38)->rd1 , (37 dt 22)->rd2 , (21 dt 6)->ext_imm , (5 dt 3)->func , (2 dt 0)->wa
signal ex_mem: std_logic_vector(57 downto 0); --(57 dt 56)->wb , (55 dt 53)->mem , (52 dt 37)->branchAddr , (36 dt 21)->AluRes , (20)->zero , (19)->rd1_15 , (18 dt 3)->rd2 , (2 dt 0)->wa
signal mem_wb: std_logic_vector(36 downto 0); --(36 dt 35)->wb , (34 dt 19)->MemData , (18 dt 3)->AluRes , (2 dt 0)->wa

component MPG port(clk : in std_logic;
                       btn : in  std_logic;
                       enable : out std_logic);
    end component;
    
   component IF_cmp is
     Port (
        clk : in std_logic;
        EN : in std_logic;
        RST : in std_logic;
        JAdr: in std_logic_vector(15 downto 0);
        BAdr: std_logic_vector(15 downto 0);
        PCSrc: in std_logic;
        Jump: in std_logic;
        pc_1: out std_logic_vector(15 downto 0);
        Instr: out std_logic_vector(15 downto 0);
        BGEZ: in std_logic
        ); 
end component;
    
component SSD_test_env port(an: out STD_LOGIC_VECTOR (3 downto 0);
                    cat:  out   STD_LOGIC_VECTOR (6 downto 0);
                    clk : in STD_LOGIC;
                    semnal: in  STD_LOGIC_VECTOR (15 downto 0));
    end component;

component ID is
  Port (  EN : in std_logic;
  Clk: in std_logic;
  RegWrite : in std_logic;
  RegDst: in std_logic;
  ExtOp: in std_logic;
  Instr: in std_logic_vector(15 downto 0);
  WD: in std_logic_vector(15 downto 0);
  RD1: out std_logic_vector(15 downto 0);
  RD2: out std_logic_vector(15 downto 0);
  Ext_Imm: out std_logic_vector(15 downto 0);
  func: out std_logic_vector(2 downto 0);
  sa: out std_logic;
  WA: in std_logic_vector(2 downto 0)
  );
end component;

component ALU_cmp is
  Port ( rd1 : in std_logic_vector (15 downto 0);
         rd2 : in std_logic_vector (15 downto 0);
         Ext_Imm: in std_logic_vector(15 downto 0); 
         sa: in std_logic;
         func : in std_logic_vector (2 downto 0);
         ALUSrc : in std_logic;
         ALUOp: in std_logic_vector(1 downto 0);
         Zero: out std_logic;
         ALURes: out std_logic_vector(15 downto 0));
      
end component;

component RAM_cmp is
  Port (   EN : in std_logic;
        MemWrite: in std_logic;
         MemData: out std_logic_vector(15 downto 0);
         ALURes: in std_logic_vector(15 downto 0);
         RD2 : in std_logic_vector(15 downto 0);
         Clk : in std_logic
         );
end component;

component UC is
  Port ( Instr: in std_logic_vector(2 downto 0);
        RegDst: out std_logic;
        ExtOp: out std_logic;
        ALUSrc: out std_logic;
        Branch: out std_logic;
        Jump: out std_logic;
        BGEZ: out std_logic;
        MemWrite: out std_logic;
        MemtoReg: out std_logic;
        ALUOp: out std_logic_vector(1 downto 0);
        RegWrite: out std_logic
        );
end component;

begin
    M: MPG port map(clk,btn(0),enable);
    M1: MPG port map(clk,btn(1),enable1);
    IF_c: IF_cmp port map(clk, EN, RST, JAdr, BAdr, PCSrc, Jump, pc_1, Instr, PCSrc1);
    ID_c: ID port map(EN,clk,mem_wb(35),RegDst,ExtOp,if_id(15 downto 0),WD,RD1,RD2,Ext_Imm,func,sa,mem_wb(2 downto 0));
    ALU_C: ALU_cmp port map(id_ex(53 downto 38),id_ex(37 downto 22),id_ex(21 downto 6),id_ex(78),id_ex(5 downto 3),id_ex(70),id_ex(72 downto 71),Zero,ALURes);
    RAM_c: RAM_cmp port map(EN,ex_mem(57),MemData,ex_mem(36 downto 21),ex_mem(18 downto 3),Clk);
    UC_c: UC port map(if_id(15 downto 13),RegDst,ExtOp,ALUSrc,Branch,Jump,BGEZ,MemWrite,MemtoReg,ALUOp,RegWrite);
EN <= enable;
RST <= enable1;

PCSrc <= ex_mem(54) and ex_mem(20);
PCSrc1 <= ex_mem(53) and (not ex_mem(19));
BAdr <= ex_mem(52 downto 37);
JAdr <= "000" & if_id(12 downto 0);
WD <= mem_wb(34 downto 19) when MemtoReg = '0' else mem_wb(18 downto 3);
WA <= if_id(9 downto 7) when RegDst = '0' else  if_id(6 downto 4);

---pipeline
process(clk,en)
begin
    if rising_edge(clk) then
        if en = '1' then
            if_id(31 downto 16) <= pc_1;
            if_id(15 downto 0) <= Instr;
        end if;
    end if;
end process;

process(clk,en)
begin
    if rising_edge(clk) then
        if en = '1' then
            id_ex(78) <= sa;
            id_ex(77) <= MemtoReg;
            id_ex(76) <= RegWrite;
            id_ex(75) <= MemWrite;
            id_ex(74) <= Branch;
            id_ex(73) <= Bgez;
            id_ex(72 downto 71) <= AluOp; 
            id_ex(70) <= AluSrc; 
            id_ex(69 downto 54) <= pc_1;
            id_ex(53 downto 38) <= rd1; 
            id_ex(37 downto 22) <= rd2; 
            id_ex(21 downto 6) <= Ext_Imm; 
            id_ex(5 downto 3) <= func;
            id_ex(2 downto 0) <= wa; 
        end if;
    end if;
end process;

process(clk,en)
begin
    if rising_edge(clk) then
        if en = '1' then
            ex_mem(57) <= id_ex(77);
            ex_mem(56) <= id_ex(76);
            ex_mem(55) <= id_ex(75);
            ex_mem(54) <= id_ex(74);
            ex_mem(53) <= id_ex(73);
            ex_mem(52 downto 37) <= id_ex(69 downto 54) + id_ex(21 downto 6);
            ex_mem(36 downto 21) <= AluRes;
            ex_mem(20) <= zero;
            ex_mem(19) <= id_ex(53);
            ex_mem(18 downto 3) <= id_ex(37 downto 22);
            ex_mem(2 downto 0) <= id_ex(2 downto 0);
        end if;
    end if;
end process;

process(clk,en)
begin
    if rising_edge(clk) then
        if en = '1' then
            mem_wb(36)<=ex_mem(57);
            mem_wb(35)<=ex_mem(56);
            mem_wb(34 downto 19)<=MemData;
            mem_wb(18 downto 3)<=ex_mem(36 downto 21);
            mem_wb(2 downto 0)<=ex_mem(2 downto 0);
        end if;
    end if;
end process;

-- testinog of processor
   with sw(1 downto 0) Select
   testNr <= pc_1 when "00",  
            Instr when "01",
            rd1 when "10",  
            rd2 when "11"; 
            
S: SSD_test_env port map(an,cat,clk, testNr);

end Behavioral;
