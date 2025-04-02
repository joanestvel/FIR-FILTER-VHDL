----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.03.2025 20:02:16
-- Design Name: 
-- Module Name: FSM - Behavioral
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

entity FSM is
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
        ;o_RAMen                :   out std_logic                   --Signal used to enable reading the RAM memory
        ;o_mem_we               :   out std_logic                   --Signal used to enable writing in the RAM memory
        ;o_WEN_CTRL             :   out std_logic                   --Signal used to enable register the control Data
        ;o_WEN_COEFFICIENTS     :   out std_logic                   --Signal used to enable register the Coefficients
        ;o_WEN_DATA             :   out std_logic                   --Signal used to enable register the Data to be processed
        ;o_Done                 :   out std_logic                   --Signal used to notify when the Data has been already processed and saved in the memory
        );
end FSM;

architecture Behavioral of FSM is

    type state_type is (st0,st1,st2,st3,st4,st5,st6,st7,st8,st9,st10,st11,st12,st13,st14,st15,st16,st17,st18,st19,st20,st21,st22,st23,st24);
    signal state, next_state : state_type;

begin
    SYNC_PROC: process (i_clk)
   begin
      if (rising_edge(i_clk)) then
         if (i_rst = '1') then
            state <= st0;
         else
            state <= next_state;
         end if;
      end if;
   end process;

   OUTPUT_DECODE: process (state)
   begin
      o_rstC              <=  '0';
      o_zero              <=  '0';
      o_W                 <=  '0';
      o_Up                <=  '0';
      o_cMX               <=  '0';
      o_C                 <=  "00";
      o_RAMen             <=  '0';
      o_mem_we            <=  '0';
      o_WEN_CTRL          <=  '0';
      o_WEN_COEFFICIENTS  <=  '0';
      o_WEN_DATA          <=  '0';
      o_Done              <=  '0';
      case (state) is
      --Reset the Counter
        when st0 =>
            o_rstC              <=  '1';
      --Saving the address
        when st1 =>
            o_W                 <=  '1';
      --Getting data from the memory
        when st2 =>
            o_RAMen             <=  '1';
      --Saving the Data (Control)
        when st3 =>
            o_RAMen             <=  '1';
            o_WEN_CTRL          <=  '1';
      --Increase the Counter
        when st4 =>
            o_Up                <=  '1';
      --Saving the new address
        when st5 =>
            o_W                 <=  '1';
            o_cMX               <=  '1';
            o_C                 <=  "10";
      --Resetting the counter and getting the Data from the memory
        when st6 =>
            o_rstC              <=  '1';
            o_RAMen             <=  '1';
      --Saving the Data (Coefficients)
        when  st7 =>
            o_RAMen             <=  '1';
            o_WEN_COEFFICIENTS  <=  '1';
      --Incrising the counter
        when st8 =>
            o_Up                <=  '1';
      --Getting the data from the memory
        when st9 =>
            o_RAMen             <=  '1';
      --Saving the new address
        when st10 =>
            o_W                 <=  '1';
            o_cMX               <=  '1';
            o_C                 <=  "11";
      --Resetting the counter and getting the data from the memory
        when st11 =>
            o_rstC              <=  '1';
            o_RAMen             <=  '1';
      --saving the data (The signal)
        when st12 =>
            o_RAMen             <=  '1';
            o_WEN_DATA          <=  '1';
      --Incrising the counter
        when st13 =>
            o_Up                <=  '1';
      --Getting the data from the memory
        when st14 =>
            o_RAMen             <=  '1';
      --Saving the new value in the memory
        when st15 =>
            o_C                 <=  "01";
            o_RAMen             <=  '1';
            o_mem_we            <=  '1';
      --Getting data from the memory
        when st16 =>
            o_RAMen             <=  '1';
      --Saving the data (signal)
        when st17 =>
            o_RAMen             <=  '1';
            o_WEN_DATA          <=  '1';
      --Incrising the counter
        when st18 =>
            o_Up                <=  '1';
      --Saving the new address
        when st19 =>
            o_W                 <=  '1';
            o_cMX               <=  '1';
            o_C                 <=  "01";
      --Resetting the counter and saving the the new value in the memory
        when st20 =>
            o_rstC              <=  '1';
            o_RAMen             <=  '1';
            o_mem_we            <=  '1';
      --Passing a zero to the data (signal)
        when st21 =>
            o_zero              <=  '1';
            o_WEN_DATA          <=  '1';
      --Incrising the counter
        when st22 =>
            o_Up                <=  '1';
      --Saving the new value in the memory
        when st23 =>
            o_RAMen             <=  '1';
            o_mem_we            <=  '1';
      --End
        when st24 =>
            o_Done              <=  '1';
      end case;
   end process;

   NEXT_STATE_DECODE: process (state, i_sta,i_d3,i_d4,i_d7,i_eq)
   begin
      case (state) is
         when st0 =>
            if (i_sta = '1') then
                next_state  <=  st1;
            else
                next_state  <=  st0;
            end if;
         when st1 =>
            next_state  <=  st2;
         when st2 =>
            next_state  <=  st3;
         when st3 =>
            next_state  <=  st4;
         when st4 =>
            if (i_d3 = '1') then
                next_state  <=  st5;
            else
                next_state  <=  st2;
            end if;
         when st5 =>
            next_state  <=  st6;
         when st6 =>
            next_state  <=  st7;
         when st7 =>
            next_state  <=  st8;
         when st8 =>
            if (i_d7 = '1') then
                next_state  <=  st10;
            else
                next_state  <=  st9;
            end if;
         when st9 =>
            next_state  <=  st7;
         when st10 =>
            next_state  <=  st11;
         when st11 =>
            next_state  <=  st12;
         when st12 =>
            next_state  <=  st13;
         when st13 =>
             if (i_d4 = '1') then
                next_state  <=  st15;
             else
                next_state  <=  st14;
             end if;
         when st14 =>
            next_state  <=  st12;
         when st15 =>
            next_state  <=  st16;
         when st16 =>
            next_state  <=  st17;
         when st17 =>
            next_state  <=  st18;
         when st18 =>
            if (i_eq = '1') then
                next_state  <=  st19;
            else
                next_state  <=  st15;
            end if;
         when st19 =>
            next_state  <=  st20;
         when st20 =>
            next_state  <=  st21;
         when st21 =>
            next_state  <=  st22;
         when st22 =>
            next_state  <=  st23;
         when st23 =>
            if (i_d4 = '1') then
                next_state  <=  st24;
            else
                next_state  <=  st21;
            end if;
         when st24 =>
            if (i_sta = '0') then
                next_state  <=  st0;
            else
                next_state  <=  st24;
            end if;
         when others =>
            NULL;
      end case;
   end process;
end Behavioral;
