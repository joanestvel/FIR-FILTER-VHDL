----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11.03.2025 18:12:27
-- Design Name: 
-- Module Name: Sat - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Sat is
    Port ( i_Data : in STD_LOGIC_VECTOR (15 downto 0);
           o_Data : out STD_LOGIC_VECTOR (7 downto 0));
end Sat;

architecture Behavioral of Sat is

    signal s_s    :   std_logic_vector(1 downto 0);

begin

    process(i_Data)
        variable    v_TempOr  :   std_logic;
        variable    v_TempAnd :   std_logic;
    begin
        v_TempOr  :=  '0';
        v_TempAnd :=  '1';
        for i in 7 to 14 loop
            v_TempOr    :=  v_TempOr    or  i_Data(i);
            v_TempAnd   :=  v_TempAnd   and i_Data(i);
        end loop;
        s_s(0)   <=  not(v_TempAnd) and i_Data(15);
        s_s(1)   <=  v_TempOr and not(i_Data(15));
    end process;
    
    o_Data(7)  <=  s_s(0) or (not(s_s(1)) and i_Data(7));
    
    A:  for i in 0 to 6 generate
            o_Data(i)   <=  s_s(1) or (not(s_s(0)) and i_Data(i));
        end generate;

end Behavioral;
