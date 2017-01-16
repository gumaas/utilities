library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

-- unsigned multiplier with result wrapping
-- subtraction is done with full precision
-- result range is defined by reslen generic
-- if full precision result is out of result range
-- result is set to min/max value in result range
entity multiplier_unsigned is
	-- input and output vectors lengths
	generic(
		alen 	: natural := 8; 
		blen 	: natural := 8;
		reslen	: natural := 8
	);
	port (
		-- inputs
		a_i			: in unsigned( alen-1 downto 0 );
		b_i			: in unsigned( blen-1 downto 0 );	
		
		-- result
		result_o	: out unsigned( reslen-1 downto 0);
		-- real result is bigger then max result value
		overflow_o	: out std_logic;
		-- real result is bigger then min result value
		underflow_o	: out std_logic	
	);
end entity multiplier_unsigned;

architecture RTL of multiplier_unsigned is
	
--	vector length required to calculate result
--	default addition function allows result to overflow
--	in order to prevent that input vector lengths are increased
	constant totallen 		: natural := alen+blen;

--	min/max values of result vector	
	constant maxval			: unsigned( reslen-1 downto 0 ) := (others => '1');
	constant minval	 		: unsigned( reslen-1 downto 0 ) := (others => '0');

--	full resolution result
	signal tmp				: unsigned( totallen-1 downto 0 );
		
begin

--	addition input values
	tmp 		<= a_i * b_i;

--	result wrapping	
	proc_ap : process( tmp ) is
	begin
		if tmp > maxval then
			result_o 		<= maxval;
			underflow_o 	<= '0';
			overflow_o 		<= '1';
						
		else
			result_o 		<= resize( tmp, reslen );
			underflow_o 	<= '0';
			overflow_o 		<= '0';
			
		end if;
	
	end process proc_ap;
	

end architecture RTL;
