----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/02/2022 08:11:56 PM
-- Design Name: 
-- Module Name: test_env2 - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_env_pipeline is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env_pipeline;

architecture Behavioral of test_env_pipeline is

component SSD is
  Port (
  signal digit0: in std_logic_vector(3 downto 0);
  signal digit1: in std_logic_vector(3 downto 0);  
  signal digit2: in std_logic_vector(3 downto 0);
  signal digit3: in std_logic_vector(3 downto 0);
  signal clk:in std_logic;
  signal cat:out std_logic_vector(6 downto 0);
  signal an:out std_logic_vector(3 downto 0)
  
  );
end component;

component mpg is
Port(btn: in std_logic;
     clk:in std_logic;
     en: out std_logic);
end component;

component IFetch is
 Port (clk: in std_logic;
       jumpAddress: in std_logic_vector(15 downto 0);
       branchAddress: in std_logic_vector(15 downto 0);
       jump: in std_logic;
       PCSrc: in std_logic;
       enable: in std_logic;
       reset: in std_logic;
       instruction: out std_logic_vector(15 downto 0);
       nextPC: inout std_logic_vector(15 downto 0));   
end component;

component ID is
  Port(clk: in std_logic;
       RegWrite: in std_logic;
       ExtOp: in std_logic;
       buton: in std_logic;
       WD: in std_logic_vector(15 downto 0);
       Instr: in std_logic_vector(15 downto 0);
       RD1: out std_logic_vector(15 downto 0);
       RD2: out std_logic_vector(15 downto 0);
       Ext_Imm: out std_logic_vector(15 downto 0);
       func: out std_logic_vector(2 downto 0);
       sa: out std_logic;
       outmux: inout std_logic_vector(2 downto 0)
   );
end component;

component UC is
  Port (instr: in std_logic_vector(2 downto 0);
        RegDst: out std_logic;  
        ExtOp: out std_logic; 
        ALUSrc: out std_logic; 
        Branch: out std_logic; 
        Jump: out std_logic;
        AluOp: out std_logic_vector(2 downto 0);
        MemWrite: out std_logic; 
        MemtoReg: out std_logic; 
        RegWrite: out std_logic          
  );
end component;

component MEM is
  Port (clk: in std_logic;
        MemWrite: in std_logic;
        buton: in std_logic;
        ALURes: inout std_logic_vector(5 downto 0);
        RD2: in std_logic_vector(15 downto 0);
        MemData: out std_logic_vector(15 downto 0)
   );
end component;

component EX is
  Port (RD1: in std_logic_vector(15 downto 0);
        RD2: in std_logic_vector(15 downto 0);
        ALUSrc: in std_logic;
        Ext_Imm: in std_logic_vector(15 downto 0);
        sa: in std_logic;
        func: in std_logic_vector(2 downto 0);
        nextAddress: in std_logic_vector(15 downto 0);
        branchAddress: out std_logic_vector(15 downto 0);
        ALUOp: in std_logic_vector(2 downto 0);
        Zero: out std_logic;
        ALURes: out std_logic_vector(15 downto 0));
end component;

signal enable, reset, Zero, PCSrc: std_logic:='0';
signal digits, nextAd, instr, jumpAd, RD1, RD2, Ext_Imm,ALURes, branchAd,MemData, outmuxMem: std_logic_vector(15 downto 0):=x"0000";
signal ALUSrc,Branch,Jump,MemWrite,MemtoReg,RegWrite,RegDst,ExtOp,sa: std_logic:='0';  
signal AluOp: std_logic_vector(2 downto 0):="000";
signal func: std_logic_vector(2 downto 0):="000";

--laboratorul 9--
signal RegIF_ID: std_logic_vector(31 downto 0);
signal RegID_EX: std_logic_vector(82 downto 0);
signal RegEX_MEM: std_logic_vector(55 downto 0);
signal RegMEM_WB: std_logic_vector(36 downto 0);
signal outmux_RegDst: std_logic_vector(2 downto 0);

begin
    mpp1:mpg port map(btn=>btn(0),clk=>clk,en=>enable);
    mpp2:mpg port map(btn=>btn(1),clk=>clk,en=>reset);
    ssd1: SSD port map(digit0=>digits(3 downto 0),digit1=>digits(7 downto 4),digit2=>digits(11 downto 8),digit3=>digits(15 downto 12),clk=>clk,cat=>cat,an=>an);
    if1: IFetch port map(clk=>clk,jumpAddress=>jumpAd,branchAddress=>RegEX_MEM(51 downto 36),jump=>Jump,PCSrc=>PCSrc,enable=>enable,reset=>reset,instruction=>instr,nextPC=>nextAd);
    id1: ID port map(clk=>clk,RegWrite=>RegMEM_WB(35),Instr=>RegMEM_WB(15 downto 0),ExtOp=>ExtOp, buton=>enable,WD=>outmuxMem, RD1=>RD1,RD2=>RD2,Ext_Imm=>Ext_Imm,func=>func,sa=>sa, outmux=>RegMEM_WB(2 downto 0));
    uc1: UC port map(instr=>RegIF_ID(15 downto 13),RegDst=>RegDst,ExtOp=>ExtOp,ALUSrc=>ALUSrc,Branch=>Branch,Jump=>Jump,ALUOp=>ALUOp,MemWrite=>MemWrite,MemtoReg=>MemtoReg,RegWrite=>RegWrite );  
    ex1: EX port map(RD1=>RegID_EX(57 downto 42),RD2=>RegID_EX(41 downto 26),ALUSrc=>RegID_EX(75),Ext_Imm=>RegID_EX(25 downto 10),sa=>RegID_EX(9),func=>RegID_EX(8 downto 6),nextAddress=>RegID_EX(73 downto 58),branchAddress=>branchAd,ALUOp=>RegID_EX(78 downto 76),Zero=>Zero,ALURes=>ALURes);
    mem1: MEM port map(clk=>clk,MemWrite=>RegEX_MEM(53),buton=>enable,ALURes=>RegEX_MEM(24 downto 19),RD2=>RegEX_MEM(18 downto 3),MemData=>MemData);

PCSrc <= Branch and Zero;
outmuxMem <= MemData when MemtoReg='1' else ALURes;
jumpAd <= nextAd(15 downto 13) & instr(12 downto 0);


process(sw(7 downto 5))
begin
    case (sw(7 downto 5)) is
        when "000" =>digits<=instr;
        when "001" =>digits<=NextAd;
        when "010" =>digits<=RD1;
        when "011" =>digits<=RD2;
        when "100" =>digits<=Ext_Imm;
        when "101" =>digits<=ALURes;
        when "110" =>digits<=MemData;
        when others =>digits<=outmuxMem;
    end case;
end process;

led(15 downto 13) <= ALUOp;

  --afisarea pe leduri a semnalelor de control
led(7) <= RegDst;
led(6) <= ExtOp;
led(5) <= ALUSrc;
led(4) <= Branch;
led(3) <= Jump;
led(2) <= MemWrite;
led(1) <= MemtoReg;
led(0) <= RegWrite;

led(15 downto 13) <= ALUOp;

--laboratorul 9
process(clk)
begin
  if rising_edge(clk) then
     if enable = '1' then
        RegIF_ID <= nextAd & instr;
     end if;
  end if;   
end process;

process(clk)
begin
  if rising_edge(clk) then
     if enable = '1' then
        RegID_EX <= MemtoReg & RegWrite & MemWrite & Branch & ALUOp & ALUSrc & RegDst & RegIF_ID(31 downto 16) & RD1 & RD2 & Ext_Imm & RegIF_ID(3 downto 0) & RegIF_ID(9 downto 7) & RegIF_ID(6 downto 4); 
     end if;
  end if;   
end process;

outmux_RegDst <= RegID_EX(5 downto 3) when RegID_EX(74) = '0' else RegID_EX(2 downto 0);

process(clk)
begin
  if rising_edge(clk) then
     if enable = '1' then
        RegEX_MEM <= RegID_EX(82 downto 79) &  branchAd & Zero & ALURes & RegID_EX(41 downto 26) & outmux_RegDst;
     end if;
  end if;   
end process;

process(clk)
begin
  if rising_edge(clk) then
     if enable = '1' then
        RegMEM_WB <= RegEX_MEM(55 downto 54) & MemData & RegEX_MEM(34 downto 19) & RegEX_MEM(2 downto 0);
     end if;
  end if;   
end process;

end Behavioral;