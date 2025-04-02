----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.03.2025 13:32:46
-- Design Name: 
-- Module Name: d12_d60 - Behavioral
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
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity d12_d60 is
    Port ( i_Data   : in    STD_LOGIC_VECTOR (18 downto 0);
           i_C      : in    STD_LOGIC;
           o_Data   : out   STD_LOGIC_VECTOR (15 downto 0));
end d12_d60;

architecture Behavioral of d12_d60 is

    component s010_s100 is
        Port ( i_Data : in STD_LOGIC_VECTOR (15 downto 0);
               i_c : in STD_LOGIC;
               o_Data : out STD_LOGIC_VECTOR (15 downto 0));
    end component;
    
    
    signal s_slA4,s_slA6,s_slA8,s_slA10     :   std_logic_vector(15 downto 0);
    signal s_add                            :   std_logic_vector(15 downto 0);
    signal s_C                              :   std_logic_vector(15 downto 0);

begin

    s_C <=  (others=>i_C);
    --slA4:
    s_slA4(15)              <=  i_Data(18) and not(i_C);
    s_slA4(14 downto 0)     <=  i_Data(18 downto 4) and not(s_C(14 downto 0));
    
    --slA6
    s_slA6(15 downto 13)    <=  (others => i_Data(18));
    s_slA6(12 downto 0)     <=  i_Data(18 downto 6);
    
    --slA8
    s_slA8(15 downto 11)    <=  (others => (i_Data(18) and not(i_C)));
    s_slA8(10 downto 0)     <=  i_Data(18 downto 8) and not(s_C(10 downto 0));
    
    --slA10
    s_slA10(15 downto 9)    <=  (others => i_Data(18));
    s_slA10(8 downto 0)     <=  i_Data(18 downto 10);
    
    --Adder
    s_add   <=  std_logic_vector(signed(s_slA4) + signed(s_slA6) + signed(s_slA8) + signed(s_slA10));
    
    A:  s010_s100   port map 
                            (i_Data => s_add
                            ,i_C    => i_C
                            ,o_Data => o_Data
                            );

end Behavioral;
