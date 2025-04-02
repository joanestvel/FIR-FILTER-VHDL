----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Joan Esteban Velasco Larrea
-- 
-- Create Date: 11.03.2025 10:10:22
-- Design Name: FIR Filter
-- Module Name: project_reti_logiche - rtl
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
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity project_reti_logiche is
    Port ( i_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_start : in STD_LOGIC;
           i_add : in STD_LOGIC_VECTOR (15 downto 0);
           
           o_done : out STD_LOGIC;
           
           o_mem_addr : out STD_LOGIC_VECTOR (15 downto 0);
           i_mem_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_mem_data : out STD_LOGIC_VECTOR (7 downto 0);
           o_mem_we : out STD_LOGIC;
           o_mem_en : out STD_LOGIC);
end project_reti_logiche;

architecture rtl of project_reti_logiche is

    component d12_d60 is
        Port ( i_Data : in STD_LOGIC_VECTOR (18 downto 0);
               i_c : in STD_LOGIC;
               o_Data : out STD_LOGIC_VECTOR (15 downto 0));
    end component;
    
    component Sat is
        Port ( i_Data : in STD_LOGIC_VECTOR (15 downto 0);
               o_Data : out STD_LOGIC_VECTOR (7 downto 0));
    end component;
    
    component Add_Gen is
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
    end component;
    
    component FSM is
        Port 
            (i_clk                  :   in  std_logic
            ;i_sta                  :   in  std_logic
            ;i_rst                  :   in  std_logic
            ;i_d3,i_d4,i_d7,i_eq    :   in  std_logic
            ;o_rstC                 :   out std_logic                   --Signal used to reset the counter
            ;o_zero                 :   out std_logic                   --Signal used to pass a zero to the data being processed
            ;o_W                    :   out std_logic                   --Signal used to register the address
            ;o_Up                   :   out std_logic                   --Signal used to increase the counter
            ;o_cMX                  :   out std_logic                   --Signal used to select which address will be registered
            ;o_C                    :   out std_logic_vector(1 downto 0)--Signal used to add an "offset" to the address
            ;o_RAMen                :   out std_logic                   --Signal used to enable reading the RAM memmory
            ;o_mem_we               :   out std_logic                   --Signal used to enable writting in the RAM memmory
            ;o_WEN_CTRL             :   out std_logic                   --Signal used to enable register the control Data
            ;o_WEN_COEFFICIENTS     :   out std_logic                   --Signal used to enable register the Coefficients
            ;o_WEN_DATA             :   out std_logic                   --Signal used to enable regiser the Data to be processed
            ;o_Done                 :   out std_logic                   --Signal used to notify when the Data has been alredy processed and saved in the memmory
            );
    end component;
    
    type t_DATA_COEFFICIENTS    is array (0 to 6) of std_logic_vector(7 downto 0);
    type t_MULT is array (0 to 6) of std_logic_vector(15 downto 0);
    
    signal s_s,s_k2,s_k1    :   std_logic_vector(7 downto 0);--Registered Control signals
    signal s_k              :   std_logic_vector(15 downto 0);--Registerd data length
    signal s_WEN_CTRL,s_WEN_COEFFICIENTS,s_WEN_DATA :   std_logic;--Write enables for the registers

    signal s_COEFFICIENTS,s_DATA    :   t_DATA_COEFFICIENTS;--Coefficients from the filter and the data to be processed
    
    signal s_MULT   :   t_MULT;--Result of the multiplication of each data with its coefficient
    signal s_NORM   :   std_logic_vector(15 downto 0);--Result of the normalization, or the data processed but without saturation
    signal s_ADDER  :   std_logic_vector(18 downto 0);--Result before the normalization
    
    signal s_NClk   :   std_logic;
    
    signal s_MX     :   std_logic_vector(7 downto 0);
    
    --FSM control signals
    signal s_rstC               :   std_logic;
    signal s_W                  :   std_logic;
    signal s_Up                 :   std_logic;
    signal s_cMX                :   std_logic;
    signal s_C                  :   std_logic_vector(1 downto 0);
    signal s_d3,s_d4,s_d7,s_eq  :   std_logic;--input 
    signal s_zero               :   std_logic;

begin

    s_NClk  <=  not(i_clk);
    s_k <=  s_k1 & s_k2;
    --Shifter Register that stores the control data (data length and the order of the filter)
    process(i_clk,i_rst)
    begin
        if(i_rst = '1') then
            s_s <=  (others=>'0');
            s_k2 <=  (others=>'0');
            s_k1 <=  (others=>'0');
        elsif(rising_edge(i_clk)) then
            if(s_WEN_CTRL = '1') then
                s_k1    <=  s_k2;
                s_k2    <=  s_s;
                s_s <=  i_mem_data;
            end if;
        end if;
    end process;
    
    --Multiplexer to slect to transfer the data from the memmory or a zero to the Data Shifter register
    s_MX    <=  i_mem_data when s_zero = '0' else
                X"00";
    
    --Shifter register that stores the coefficients of the filter and the Data
    process(i_clk,i_rst)
    begin
        if(i_rst = '1') then
            s_COEFFICIENTS(0)  <=  (others => '0');
            s_DATA(0)  <=  (others => '0');
        elsif(rising_edge(i_clk)) then
            if(s_WEN_COEFFICIENTS = '1') then
                s_COEFFICIENTS(0)  <=  i_mem_data;
            end if;
            if(s_WEN_DATA = '1') then
                s_DATA(0)  <=  s_MX;
            end if;
        end if;
    end process;
    
    A:  for i in 1 to 6 generate
            process(i_clk,i_rst)
            begin
                if(i_rst = '1') then
                    s_COEFFICIENTS(i)  <=  (others => '0');
                    s_DATA(i)  <=  (others => '0');
                elsif(rising_edge(i_clk)) then
                    if(s_WEN_COEFFICIENTS = '1') then
                        s_COEFFICIENTS(i) <= s_COEFFICIENTS(i-1);
                    end if;
                    if(s_WEN_DATA = '1') then
                        s_DATA(i) <= s_DATA(i-1);
                    end if;
                end if;
            end process;
        end generate;
    
    --Multiplications
    B:  for i in 0 to 6 generate
            s_Mult(i) <= std_logic_vector(signed(s_DATA(i))*signed(s_COEFFICIENTS(i)));
        end generate;
    
    --Adder
    process(s_Mult)
        variable v_Temp :   signed(18 downto 0);
    begin
        v_Temp  :=  (others => '0');
        for i in 0 to 6 loop
            v_Temp := v_Temp + signed(s_Mult(i));
        end loop;
        s_ADDER <= std_logic_vector(v_Temp);
    end process;
    
    --Normalization
    C:  d12_d60 port map 
                        (i_Data => s_ADDER
                        ,i_C    => s_s(0)
                        ,o_Data => s_NORM
                        );
    
    --Saturation
    D:  Sat port map
                    (i_Data => s_NORM
                    ,o_Data => o_mem_data
                    );
    
    --Address Generator
    E:  Add_Gen port map
                        (i_Add => i_add
                        ,i_clk => i_clk
                        ,i_rst => i_rst
                        ,i_rstC => s_rstC
                        ,i_W => s_W
                        ,i_Up => s_Up
                        ,i_cMX => s_cMX
                        ,i_C => s_C
                        ,i_k => s_k
                        ,i_s => s_s(0)
                        ,o_d3 => s_d3
                        ,o_d4 => s_d4
                        ,o_d7 => s_d7
                        ,o_eq => s_eq
                        ,o_Add => o_mem_addr
                        );
                    
    F: FSM  port map
                    (i_clk              =>  s_NClk
                    ,i_sta              =>  i_start
                    ,i_rst              =>  i_rst
                    ,i_d3               =>  s_d3
                    ,i_d4               =>  s_d4
                    ,i_d7               =>  s_d7
                    ,i_eq               =>  s_eq
                    ,o_rstC             =>  s_rstC
                    ,o_zero             =>  s_zero
                    ,o_W                =>  s_W
                    ,o_Up               =>  s_Up
                    ,o_cMX              =>  s_cMX
                    ,o_C                =>  s_C
                    ,o_RAMen            =>  o_mem_en
                    ,o_mem_we           =>  o_mem_we
                    ,o_WEN_CTRL         =>  s_WEN_CTRL 
                    ,o_WEN_COEFFICIENTS =>  s_WEN_COEFFICIENTS
                    ,o_WEN_DATA         =>  s_WEN_DATA
                    ,o_Done             =>  o_done
                    );
    
end rtl;
