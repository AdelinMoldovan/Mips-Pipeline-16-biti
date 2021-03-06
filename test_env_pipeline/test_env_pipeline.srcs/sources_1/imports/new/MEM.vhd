----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/02/2022 09:31:18 PM
-- Design Name: 
-- Module Name: MEM - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MEM is
  Port (clk: in std_logic;
        MemWrite: in std_logic;
        buton: in std_logic;
        ALURes: inout std_logic_vector(5 downto 0);
        RD2: in std_logic_vector(15 downto 0);
        MemData: out std_logic_vector(15 downto 0)
   );
end MEM;

architecture Behavioral of MEM is
    type ram_type is array(0 to 63) of std_logic_vector(15 downto 0);
    signal RAM: ram_type;
    
begin

    process(clk)
     begin
        MemData<=RAM(conv_integer(ALURes));
        
       if rising_edge(clk) then
          if buton='1' then
            if MemWrite='1' then
               RAM(conv_integer(ALURes))<=RD2;    
             end if;
           end if;
         end if;  
               
     end process;           

end Behavioral;
