----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:29:29 10/11/2024 
-- Design Name: 
-- Module Name:    sdram_controller - Behavioral 
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

entity sdram_controller is
    Port ( 	clk   : in  std_logic;
				addr  : in  std_logic_vector(15 downto 0);
				memstrb : in  std_logic;
				wr_rd : in  std_logic;
				din   : in  std_logic_vector(7 downto 0);
				dout  : out std_logic_vector(7 downto 0));
end sdram_controller;

architecture Behavioral of sdram_controller is
--change this to be bigger
	type memory is array (256 downto 0) of std_logic_vector(7 downto 0);
	signal sdram_block : memory;-- ((others => (others => 0)));
	
begin  
	process(clk)
		begin
			if (clk'event and clk='1') then
				if(memstrb = '1') then
					if (wr_rd = '1') then
						sdram_block(to_integer(unsigned(addr)))<= din;
					elsif (wr_rd = '0') then
						dout <= sdram_block(to_integer(unsigned(addr)));
					end if;
				end if;
			end if;
	end process;

end Behavioral;
