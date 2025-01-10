----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:46:09 10/12/2024 
-- Design Name: 
-- Module Name:    cache_controller - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: S
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

entity cache_controller is
    Port (	CLK_SRC 			: in  std_logic;
				CPU_ADDR			: out std_logic_vector(15 downto 0);
				CPU_WR_RD		: out std_logic;
				CS					: out std_logic;
				CPU_DOUT			: out std_logic_vector(7 downto 0);
				CPU_DIN			: out std_logic_vector(7 downto 0);
				RDY				: out std_logic;
				SDRAM_MEM_ADDR	: out std_logic_vector(15 downto 0);
				SDRAM_MEM_WR_RD: out std_logic;
				MEMSTRB				: out std_logic;
				FSM_STATE		: out std_logic_vector(2 downto 0);
				SDRAM_DIN		: out std_logic_vector(7 downto 0);
				SDRAM_DOUT		: out std_logic_vector(7 downto 0);
				SRAM_DIN			: out std_logic_vector(7 downto 0);
				SRAM_DOUT		: out std_logic_vector(7 downto 0);
				SRAM_ADDR		: out std_logic_vector(7 downto 0));
end cache_controller;

architecture Behavioral of cache_controller is
-- table to store dirty, valid and cache tags
	type memory is array (7 downto 0) of std_logic_vector(7 downto 0);
	signal tag_reg : memory:= (others=> (others => ('0')));
	signal valid		: std_logic_vector(7 downto 0):= "00000000";
	signal dirty		: std_logic_vector(7 downto 0):= "00000000";
	
-- address word register fields 
	signal tag	: std_logic_vector(7 downto 0);
	signal index: std_logic_vector(2 downto 0);
	signal offset: std_logic_vector(4 downto 0);
	
-- sram signals
	signal sram_wen		: std_logic_vector(0 downto 0);
	signal sram_dataIn	: std_logic_vector(7 downto 0);
	signal sram_dataOut	: std_logic_vector(7 downto 0);
	signal sram_address	: std_logic_vector(7 downto 0);
	
-- sdram signals
	signal cache_tag			: std_logic_vector(7 downto 0);
	signal sdram_address		: std_logic_vector(15 downto 0);
	signal sdram_wr_rd_en	: std_logic;
	signal sdram_memstrb		: std_logic;
	signal sdram_dataIn		: std_logic_vector(7 downto 0);
	signal sdram_dataOut		: std_logic_vector(7 downto 0);
	signal counter				: integer;
	signal mm_offset			: integer:=0;
	
-- cpu signals
	signal cpu_rdy 		: 	std_logic;
	signal cpu_address	:	std_logic_vector(15 downto 0);
	signal cpu_wr_rd_en	: 	std_logic;
	signal cpu_cs			: 	std_logic;
	signal cpu_dataIn		: 	std_logic_vector(7 downto 0);
	signal cpu_dataOut	: 	std_logic_vector(7 downto 0);
	signal cpu_rst			: 	std_logic;

-- fsm signals
	signal state : std_logic_vector(2 downto 0);
	type state_type is (s1, s2, s3, s4, s6, s7, s0);
	signal yfsm: state_type;
	signal present_state: state_type;
	
-- ila, icon, vio signals
	signal control0		: 	std_logic_vector(35 downto 0);
	signal control1		: 	std_logic_vector(35 downto 0);
	signal trig				: 	std_logic_vector(7 downto 0);
	signal ila_data		: 	std_logic_vector(119 downto 0);

-- SDRAM controller component
	component sdram_controller
		Port (clk   : in  std_logic;
				addr  : in  std_logic_vector(15 downto 0);
				memstrb : in  std_logic;
				wr_rd : in  std_logic;
				din   : in  std_logic_vector(7 downto 0);
				dout  : out std_logic_vector(7 downto 0));
	end component;

	component bram
	  port (clka 	: IN STD_LOGIC;
			  wea 	: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		     addra 	: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		     dina 	: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		     douta 	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
	end component;

-- CPU component
	component CPU_gen
		Port (clk 		: in   STD_LOGIC;
				rst 		: in   STD_LOGIC;
				trig 		: in   STD_LOGIC;
				Address 	: out  STD_LOGIC_VECTOR (15 downto 0);
				wr_rd 	: out  STD_LOGIC;
				cs 		: out  STD_LOGIC;
				DOut 		: out  STD_LOGIC_VECTOR (7 downto 0));
	end component;
	
	component icon
		port (CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0));
	end component;
	
-- ila component
	component ila
		port (CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
				CLK : IN STD_LOGIC;
				DATA : IN STD_LOGIC_VECTOR(119 DOWNTO 0);
				TRIG0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0));
	end component;

begin

-- SDRAM instantiation
	big_sdram: sdram_controller port map(
		clk   => CLK_SRC,
		addr  => sdram_address,
		memstrb => sdram_memstrb,
		wr_rd => sdram_wr_rd_en,
		din   => sdram_dataIn,
		dout  => sdram_dataOut);
-- SRAM instantiation
	sram : bram port map (
		clka => CLK_SRC,
	   wea 	=> sram_wen,
	   addra 	=> sram_address,
	   dina 	=> sram_dataIn,
	   douta 	=> sram_dataOut);
			  
-- CPU instantiation
	big_cpu: cpu_gen port map(
		clk => CLK_SRC,
      rst => '0',
      trig => cpu_rdy,
		-- Interface to the Cache Controller.
      Address => cpu_address, 
      wr_rd => cpu_wr_rd_en,
      cs => cpu_cs,
      DOut => cpu_dataOut);

-- icon instantiation
	sys_icon : icon port map (CONTROL0 => control0);	

-- ila instantiation
	sys_ila : ila port map (
		 CONTROL => control0,
		 CLK => CLK_SRC,
		 DATA => ila_data,
		 TRIG0 => trig);	
	 
-- Next state generation
	process(CLK_SRC)	
		begin
			if (CLK_SRC'event and CLK_SRC='1') then
				case yfsm is 
					when s1 => -- s1: checks for hit
						cpu_rdy <='0'; -- cache controller is not idle
						state<="001"; 
						tag <= cpu_address(15 downto 8); -- get tag from cpu address
						index <= cpu_address(7 downto 5); -- get index from cpu address
						offset <= cpu_address(4 downto 0); -- get offset from cpu address
						sdram_address(15 downto 5) <= cpu_address(15 downto 5); -- get the tag and index from the cpu address (tag & index)
						sram_address(7 downto 0) <= cpu_address(7 downto 0); -- get the index and offset from cpu address (index & offset)
						sram_wen		 <= "0"; -- not writing to sram
						-- check that tag is in tag table and the valid is 1 
						if (valid(to_integer(unsigned(index))) = '1') and (tag = tag_reg(to_integer(unsigned(index)))) then
							yfsm <= s2; -- found a hit so look for read/write operation
						else
							-- check dirty bit and valid
							if (dirty(to_integer(unsigned(index))) = '1') and (valid(to_integer(unsigned(index))) = '1') then
								yfsm<=s7; -- load sram block to sdram 
							else
								yfsm<=s6; -- write new memory block to cache
							end if;
						end if;
					when s2 => --s2: found a HIT
						state<="010";
						if (cpu_wr_rd_en='1') then
							yfsm <= s3; -- write from cpu to cache
						else
							yfsm <= s4; -- read from cache to cpu
						end if;
					when s3 =>
						state <= "011";
						sram_wen		 <= "1"; -- writing to sram
						valid(to_integer(unsigned(index))) <= '1'; -- set valid bit
						dirty(to_integer(unsigned(index))) <= '1'; -- set dirty bit
						sram_dataIn  <= cpu_dataOut; -- loading the cpu data to the cache block
						cpu_dataIn	 <= "00000000"; -- doesn't matter
						yfsm<=s0; -- goes to idle						
					when s4 => -- s4: reading from cpu to cache
						state <= "100";
						cpu_dataIn <= sram_dataOut; -- output cache value to cpu
						yfsm<=s0; -- go to idle
					when s6=> -- s6: writing new memory block to cache
						state<="110";
						if (counter = 64) then -- takes 32 cycles to write to memory
							counter<=0;
							valid(to_integer(unsigned(index))) <= '1'; -- set valid to 1
							tag_reg(to_integer(unsigned(index))) <= tag; -- get tag from tag register
							mm_offset<=0;
							yfsm<=s2; -- check for read or 
						else
							if (counter mod 2 = 1) then -- only access memory on rising edges
								sdram_memstrb<='0';
							else 
								sdram_address 	<= cache_tag & index & std_logic_vector(to_unsigned(mm_offset, 5)); -- (tag & index & offset)
								sdram_wr_rd_en <= '0'; -- not writing to sdram
								sdram_memstrb	<='1'; 
								sram_address 	<= index & std_logic_vector(to_unsigned(mm_offset, 5)); -- (index & offset)
								sram_dataIn 	<= sdram_dataOut; -- writing sdram block to sram
								sram_wen 		<= "1"; -- enable sram for writing
								mm_offset <= mm_offset+1; -- increment to next byte
							end if;	
							counter <= counter + 1; -- increment counter 
						end if;
					when s7=> -- s7: write cache block to memory
						state<="111";
						if (counter = 64) then -- takes 32 cycles to read from memory
							dirty(to_integer(unsigned(index))) <= '0'; -- set dirty to 0
							tag_reg(to_integer(unsigned(index))) <= tag; -- the tag in tag table
							counter<=0; --reset counters
							mm_offset<=0;
							yfsm<=s6; -- load new block from sdram to sram
						else
							if (counter mod 2 = 1) then -- writes only on rising edge
								sdram_memstrb<='0';
							else 
								sdram_address <= tag & index & std_logic_vector(to_unsigned(mm_offset, 5)); -- write each byte in the block (tag&index&offset)
								sdram_wr_rd_en <= '1'; -- writing to sdram
								sram_address <= index & std_logic_vector(to_unsigned(mm_offset, 5)); --  (index&offset)
								sram_wen <= "0"; -- not writing to cache
								--sram_dataIn  <= sdram_dataOut; -- 
								sdram_dataIn <= sram_dataOut; -- writing cache data to memory
								sdram_memstrb<='1'; 
								mm_offset <= mm_offset+1; -- increment to next byte
							end if;
							counter <= counter + 1; -- increment counter
						end if;
					when s0 => -- s0: cache idle
						state <= "000";
						cpu_rdy <= '1'; -- tell cpu cache is idle
						if (cpu_cs = '1') then -- cpu sends signal
							yfsm <= s1; -- check for hit/miss
						end if;
				end case;
			end if;
		end process;
		
		-- store data in signals to ports
		FSM_STATE <= state;
		CPU_ADDR <= cpu_address;
		CPU_WR_RD <= cpu_wr_rd_en;
		--CS <= cpu_cs;
		CPU_DOUT <= cpu_dataOut;
		CPU_DIN <=	cpu_dataIn;
		RDY <= cpu_rdy;
		SDRAM_MEM_ADDR <= sdram_address;
		SDRAM_MEM_WR_RD <= sdram_wr_rd_en;
		MEMSTRB <= sdram_memstrb;
		SDRAM_DIN <= sdram_dataIn;
		SDRAM_DOUT <= sdram_dataOut;
		SRAM_DIN	<= sram_dataIn;
		SRAM_DOUT <= sram_dataOut;
		SRAM_ADDR <= sram_address;
		
		-- map ports to ila data
		ila_data(15 downto 0) <= cpu_address;
		ila_data(16) <= cpu_wr_rd_en;
		ila_data(17) <= cpu_cs;
		ila_data(18) <= '0';
		ila_data(19) <= cpu_rdy;
		ila_data(27 downto 20) <= cpu_dataOut;
		ila_data(35 downto 28) <= cpu_dataIn;
		
		ila_data(36) <= sdram_memstrb;
		ila_data(52 downto 37) <= sdram_address;
		ila_data(53)<= sdram_wr_rd_en;
		ila_data(61 downto 54) <= sdram_dataIn;
		ila_data(69 downto 62) <= sdram_dataOut;
	
		ila_data(77 downto 70) <= sram_dataIn;
		ila_data(85 downto 78) <= sram_dataOut;
		ila_data(93 downto 86) <= sram_address;
		ila_data(94 downto 94) <= sram_wen;
		ila_data(97 downto 95) <= state;
		
		ila_data(105 downto 98) 	<= valid;
		ila_data(113 downto 106)	<= dirty;
		ila_data(119 downto 114) <= (others=>'0');
		
end Behavioral;
