library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

-- unsigned subtractor with result wrapping
-- subtraction is done with full precision
-- result range is defined by reslen generic
-- if full precision result is out of result range
-- result is set to min/max value in result range
-- result is 0 if if b in bigger then a
entity subtractor_unsigned is
	-- input and output vectors lengths
	generic(
		alen_g 		: natural := 8; 
		blen_g 		: natural := 8;
		reslen_g		: natural := 8;
--		add output register
		reg_out_g	: boolean := False;
--		add register right after arithmetic operation
		reg_arith_g	: boolean := False
	);
	port (
--		component is asynchronous by default
--		clock is mandatory when reg_out_g or reg_arith_g is set
		clk_i 		: in std_logic := '0';
		
		-- inputs
		a_i			: in unsigned( alen_g-1 downto 0 );
		b_i			: in unsigned( blen_g-1 downto 0 );	
		
		-- result
		result_o	: out unsigned( reslen_g-1 downto 0);
		-- real result is bigger then max result value
		overflow_o	: out std_logic;
		-- real result is bigger then min result value
		underflow_o	: out std_logic	
	);
end entity subtractor_unsigned;

architecture RTL of subtractor_unsigned is
	
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
	constant totallen 		: natural := MAX(alen_g,blen_g)+1;
		
	constant maxval			: unsigned( reslen_g-1 downto 0 ) := (others => '1');
	constant minval	 		: unsigned( reslen_g-1 downto 0 ) := (others => '0');
	
--	full resolution result
	signal 	tmp				: unsigned( totallen-1 downto 0 );
	signal 	tmp_r			: unsigned( totallen-1 downto 0 );
	signal 	tmp_selected	: unsigned( totallen-1 downto 0 );
	
	
--	temporary signal
	signal 	result 			: unsigned( reslen_g-1 downto 0);
	signal 	underflow 		: std_logic;
	signal 	overflow 		: std_logic;
	
--	registers are used only in synchronous mode
	signal 	result_r 		: unsigned( reslen_g-1 downto 0);
	signal 	underflow_r 	: std_logic;
	signal 	overflow_r 		: std_logic;
	
	signal 	zero 			: std_logic;
	signal 	zero_r 			: std_logic;
	signal 	zero_selected 	: std_logic;
	
begin

--	addition of resized (in order to prevent overflow) input values
	tmp 				<= resize( a_i, totallen) - resize( b_i, totallen);
--	registered or async value
	tmp_selected 		<= tmp_r when reg_arith_g else tmp;
	
--	result is zero if b in bigger then a
--	result must be limited
--	if subtraction result is registered then result is set in following cycle
--	otherwise result is set in the same cycle
	zero				<= '1' when b_i > a_i else '0';
	zero_selected		<= zero_r when  reg_arith_g else zero;
	
--	result wrapping
	proc_ap : process( tmp_selected, zero_selected ) is
	begin
		if zero_selected = '1' then
			result 			<= minval;
			underflow 		<= '0';
			overflow 		<= '0';
		
		elsif tmp_selected > maxval then
			result 			<= maxval;
			underflow 		<= '0';
			overflow 		<= '1';
						
		else
			result 			<= resize( tmp_selected, reslen_g );
			underflow 		<= '0';
			overflow 		<= '0';
			
		end if;
	
	end process proc_ap;
	
		-- data latch
	reg_sp : process (clk_i) is
        begin
        	if rising_edge(clk_i) then
        		zero_r			<= zero;
        		tmp_r			<= tmp;
                result_r        <= result;
                underflow_r     <= underflow;
                overflow_r      <= overflow;
            end if;
        end process reg_sp;
	
	-- asynchronous signals are put on output
	-- since registers output is not used it should be removed in synthesis
    async_out_gen : if reg_out_g = False generate	
    	
        result_o        <= result;
        underflow_o     <= underflow;
        overflow_o      <= overflow;
        
	end generate async_out_gen;
	
	-- synchronous outputs are put on output
	sync_out_gen : if reg_out_g = True generate
	    
        result_o        <= result_r;
        underflow_o     <= underflow_r;
        overflow_o      <= overflow_r;
        
    end generate sync_out_gen;

end architecture RTL;
