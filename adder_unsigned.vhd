library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

-- unsigned adder with result wrapping
-- subtraction is done with full precision
-- result range is defined by reslen generic
-- if full precision result is out of result range
-- result is set to min/max value in result range
entity adder_unsigned is
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
end entity adder_unsigned;

architecture RTL of adder_unsigned is
	
--	choose bigger of two values
	function MAX (LEFT, RIGHT: INTEGER) return INTEGER is
	begin
		if LEFT > RIGHT then return LEFT;
		else return RIGHT;
		end if;
	end MAX;

--	vector length required to calculate result
--	default addition function allows result to overflow
--	in order to prevent that input vector lengths are increased
	constant totallen 		: natural := MAX(alen,blen)+1;
	
--	min/max value of wrapped result vector 	
	constant maxval			: unsigned( reslen-1 downto 0 ) := (others => '1');
	constant minval	 		: unsigned( reslen-1 downto 0 ) := (others => '0');
	
--	full resolution result
	signal tmp				: unsigned( totallen-1 downto 0 );
		
begin

--	addition of resized (in order to prevent overflow) input values
	tmp 		<= resize( a_i, totallen) + resize( b_i, totallen);
	
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
