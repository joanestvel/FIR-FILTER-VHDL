----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Joan esteban Velasco Larrea
-- 
-- Create Date: 11.03.2025 11:54:14
-- Design Name: s010_s100
-- Module Name: s010_s100 - Behavioral
-- Project Name: project_reti_logiche
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity s010_s100 is
    Port ( i_Data : in STD_LOGIC_VECTOR (15 downto 0);
           i_c : in STD_LOGIC;
           o_Data : out STD_LOGIC_VECTOR (15 downto 0));
end s010_s100;

architecture Behavioral of s010_s100 is

    signal s_Temp   :   std_logic;
    
    signal s_c  :   std_logic_vector(14 downto 1);

begin

    o_Data(0) <= i_Data(0);
    o_Data(1) <= I_Data(1) xor (i_c and i_Data(15));
    
    s_Temp  <=  i_c and i_Data(1) and i_Data(15);
    s_c(1)  <=  (not(i_c) and i_Data(15)) or s_Temp;
    
    A:  for i in 2 to 14 generate
            o_Data(i) <= s_c(i-1) xor i_Data(i);
            s_c(i)  <= s_c(i-1) and i_Data(i);
        end generate;
    o_Data(15)  <=  s_c(14) xor i_Data(15);

end Behavioral;
