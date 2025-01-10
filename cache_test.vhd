--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:06:12 10/15/2024
-- Design Name:   
-- Module Name:   /home/student2/asazeez/COE758/project/project1/cache_test.vhd
-- Project Name:  project1
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: cache_controller
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY cache_test IS
END cache_test;
 
ARCHITECTURE behavior OF cache_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cache_controller
    PORT(
         CLK_SRC : IN  std_logic;
         CPU_ADDR : OUT  std_logic_vector(15 downto 0);
         CPU_WR_RD : OUT  std_logic;
         CS : OUT  std_logic;
         CPU_DOUT : OUT  std_logic_vector(7 downto 0);
         CPU_DIN : OUT  std_logic_vector(7 downto 0);
         RDY : OUT  std_logic;
         SDRAM_MEM_ADDR : OUT  std_logic_vector(15 downto 0);
         SDRAM_MEM_WR_RD : OUT  std_logic;
         MEMSTRB : OUT  std_logic;
         FSM_STATE : OUT  std_logic_vector(2 downto 0);
         SDRAM_DIN : OUT  std_logic_vector(7 downto 0);
         SDRAM_DOUT : OUT  std_logic_vector(7 downto 0);
         SRAM_DIN : OUT  std_logic_vector(7 downto 0);
         SRAM_DOUT : OUT  std_logic_vector(7 downto 0);
         SRAM_ADDR : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK_SRC : std_logic := '0';

 	--Outputs
   signal CPU_ADDR : std_logic_vector(15 downto 0);
   signal CPU_WR_RD : std_logic;
   signal CS : std_logic;
   signal CPU_DOUT : std_logic_vector(7 downto 0);
   signal CPU_DIN : std_logic_vector(7 downto 0);
   signal RDY : std_logic;
   signal SDRAM_MEM_ADDR : std_logic_vector(15 downto 0);
   signal SDRAM_MEM_WR_RD : std_logic;
   signal MEMSTRB : std_logic;
   signal FSM_STATE : std_logic_vector(2 downto 0);
   signal SDRAM_DIN : std_logic_vector(7 downto 0);
   signal SDRAM_DOUT : std_logic_vector(7 downto 0);
   signal SRAM_DIN : std_logic_vector(7 downto 0);
   signal SRAM_DOUT : std_logic_vector(7 downto 0);
   signal SRAM_ADDR : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLK_SRC_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cache_controller PORT MAP (
          CLK_SRC => CLK_SRC,
          CPU_ADDR => CPU_ADDR,
          CPU_WR_RD => CPU_WR_RD,
          CS => CS,
          CPU_DOUT => CPU_DOUT,
          CPU_DIN => CPU_DIN,
          RDY => RDY,
          SDRAM_MEM_ADDR => SDRAM_MEM_ADDR,
          SDRAM_MEM_WR_RD => SDRAM_MEM_WR_RD,
          MEMSTRB => MEMSTRB,
          FSM_STATE => FSM_STATE,
          SDRAM_DIN => SDRAM_DIN,
          SDRAM_DOUT => SDRAM_DOUT,
          SRAM_DIN => SRAM_DIN,
          SRAM_DOUT => SRAM_DOUT,
          SRAM_ADDR => SRAM_ADDR
        );

   -- Clock process definitions
   CLK_SRC_process :process
   begin
		CLK_SRC <= '0';
		wait for CLK_SRC_period/2;
		CLK_SRC <= '1';
		wait for CLK_SRC_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLK_SRC_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
