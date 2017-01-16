library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

-- signed multiplier with result wrapping
-- subtraction is done with full precision
-- result range is defined by reslen generic
-- if full precision result is out of result range
-- result is set to min/max value in result range
entity multiplier_signed is
	-- input and output vectors lengths
	generic(
		alen 	: natural := 8; 
		blen 	: natural := 8;
		reslen	: natural := 8;
	-- full resolution result shift right
		shift 	: natural := 0
	);
	port (
		-- inputs
		a_i			: in signed( alen-1 downto 0 );
		b_i			: in signed( blen-1 downto 0 );	
		
		-- result
		result_o	: out signed( reslen-1 downto 0);
		-- real result is bigger then max result value
		overflow_o	: out std_logic;
		-- real result is bigger then min result value
		underflow_o	: out std_logic	
	);
end entity multiplier_signed;

architecture RTL of multiplier_signed is
	
--	vector length required to calculate result
--	default addition function allows result to overflow
--	in order to prevent that input vector lengths are increased
	constant totallen 		: natural := alen+blen;

--	used to determine min and max value in result range	
	constant shortzeros 	: signed( reslen-2 downto 0 ) := (others => '0');
	constant shortones 		: signed( reslen-2 downto 0 ) := (others => '1');

--	max value of signed vector is 0111...111
--	min value of signed vector is 1000...000		
	constant maxval			: signed( reslen-1 downto 0 ) := '0' & shortones;
	constant minval	 		: signed( reslen-1 downto 0 ) := '1' & shortzeros;

--	full resolution result
	signal tmp				: signed( totallen-1 downto 0 );
--	shifted result
	signal tmp_shift		: signed( totallen-1 downto 0 );
		
begin
	
--	addition input values	
	tmp 		<= a_i * b_i;
	
--	full resolution result shifting
	tmp_shift 	<= shift_right( tmp, shift );
	
--	result wrapping	
	proc_ap : process( tmp_shift ) is
	begin
		if tmp_shift < minval then
			result_o 		<= minval;
			underflow_o 	<= '1';
			overflow_o 		<= '0';
			
		elsif tmp_shift > maxval then
			result_o 		<= maxval;
			underflow_o 	<= '0';
			overflow_o 		<= '1';
			
		else
			result_o 		<= resize( tmp_shift, reslen );
			underflow_o 	<= '0';
			overflow_o 		<= '0';
			
		end if;
	
	end process proc_ap;
	

end architecture RTL;
