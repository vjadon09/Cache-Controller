----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:13:19 10/11/2024 
-- Design Name: 
-- Module Name:    sram - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sram is
    Port ( clk : in  std_logic;
			  addr: in std_logic_vector(7 downto 0);
			  wen: in std_logic;
			  din: in std_logic_vector(7 downto 0);
			  dout: out std_logic_vector(7 downto 0));
end sram;

architecture Behavioral of sram is	type mem_block is array (31 downto 0) of std_logic_vector(7 downto 0);
	type memory is array (7 downto 0) of mem_block;
	signal sram_block : memory;
	signal index : std_logic_vector(2 downto 0);
	signal offset : std_logic_vector(4 downto 0);

begin
	process(CLK, WEN)
		begin
			if (clk'event and clk='1') then
				index <= addr(7 downto 5);
				offset <= addr(4 downto 0);
				if (wen = '1') then
					sram_block(to_integer(unsigned(index)))(to_integer(unsigned(offset))) <= din;
				end if;
				dout <= sram_block(to_integer(unsigned(index)))(to_integer(unsigned(offset)));
			end if;
	end process;
end Behavioral;
