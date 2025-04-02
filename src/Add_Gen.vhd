----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.03.2025 18:47:59
-- Design Name: 
-- Module Name: Add_Gen - Behavioral
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

entity Add_Gen is
    Port ( i_Add : in STD_LOGIC_VECTOR (15 downto 0);
           i_clk : in std_logic;
           i_rst : in std_logic;
           i_rstC : in std_logic;
           i_W : in STD_LOGIC;
           i_Up : in STD_LOGIC;
           i_cMX : in STD_LOGIC;
           i_C : in STD_LOGIC_VECTOR (1 downto 0);
           i_k : in STD_LOGIC_VECTOR (15 downto 0);
           i_s : in std_logic;
           o_d3 : out STD_LOGIC;
           o_d4 : out STD_LOGIC;
           o_d7 : out STD_LOGIC;
           o_eq : out STD_LOGIC;
           o_Add : out STD_LOGIC_vector(15 downto 0));
end Add_Gen;

architecture Behavioral of Add_Gen is

    signal s_MX1        :   std_logic_vector(15 downto 0);--Output from the multiplexer and the Address register input
    signal s_MX2        :   std_logic_vector(15 downto 0);--output from the multiplexer and the adder input 
    signal s_Addr       :   std_logic_vector(15 downto 0);--Output Address
    
    signal s_RAdd       :   std_logic_vector(15 downto 0);--Registered Address
    
    signal s_Sub        :   std_logic_vector(15 downto 0);--i_k-4
    
    signal s_Count      :   std_logic_vector(15 downto 0);--Counter to move between different address
    
    signal s_07,s_70    :   std_logic_vector(15 downto 0);

begin

    --Multiplexer 1
    s_MX1   <=  i_Add when i_cMX = '0' else s_Addr;
    
    --Address register
    process(i_clk,i_rst)
    begin
        if(i_rst = '1') then
            s_RAdd <= (others => '0');
        elsif(rising_edge(i_clk)) then
            if(i_W = '1') then
                s_RAdd <= s_MX1;
            end if;
        end if;
    end process;
    
    --Sub
    
    s_Sub   <=  std_logic_vector(unsigned(i_k)-4);
    
    --0 or 7 selection
    s_70(15 downto 3) <= (others => '0');
    s_70(2 downto 0) <= (others => i_s);
    
    s_07(15 downto 3) <= (others => '0');
    s_07(2 downto 0) <= (others => not(i_s));
    
    --Multiplexer 2
    s_MX2   <=  (others => '0') when i_C = "00" else 
                s_Sub when i_C = "01" else
                s_70 when i_C = "10" else
                s_07;
    
    --Adder
    
    s_Addr   <=  std_logic_vector(unsigned(s_RAdd)+unsigned(s_Count)+unsigned(s_MX2));
    
    o_Add   <=  s_Addr;
    
    --Counter
    process(i_clk,i_rstC)
    begin
        if(i_rstC = '1') then
            s_Count <=  (others => '0');
        elsif(rising_edge(i_clk)) then
            if(i_Up = '1') then
                s_Count <= std_logic_vector(unsigned(s_Count) + 1);
            end if;
        end if;
    end process;
    
    --Equal
    
    o_eq    <=  '1' when s_Count = i_k else
                '0';
    
    --output control signal logic
    o_d3    <=  s_Count(1) and s_Count(0);
    o_d4    <=  s_Count(2);
    o_d7    <=  s_Count(2) and s_Count(1) and s_Count(0);
    
end Behavioral;
