library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;


-- signed adder with result wrapping
-- subtraction is done with full precision
-- result range is defined by reslen generic
-- if full precision result is out of result range
-- result is set to min/max value in result range
entity adder_signed is
	-- input and output vectors lengths
	generic(
		alen 	: natural := 8; 
		blen 	: natural := 8;
		reslen	: natural := 8;
	-- full resolution result shift right
		shift 	: natural := 0;
		sync     : boolean := False
	);
	port (
	    
	    clk_i      : in std_logic := '0';
	    
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
end entity adder_signed;

architecture RTL of adder_signed is
	
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
    
    
    signal  result          : signed( reslen-1 downto 0);
    signal  underflow       : std_logic;
    signal  overflow        : std_logic;
    
    signal  result_r        : signed( reslen-1 downto 0);
    signal  underflow_r     : std_logic;
    signal  overflow_r      : std_logic;
begin

--	addition of resized (in order to prevent overflow) input values
	tmp 		<= resize( a_i, totallen) + resize( b_i, totallen);
	
--	full resolution result shifting
	tmp_shift 	<= shift_right( tmp, shift );
	
--	result wrapping
	proc_ap : process( tmp_shift ) is
	begin
		if tmp_shift < minval then
			result 		    <= minval;
			underflow     	<= '1';
			overflow  		<= '0';
			
		elsif tmp_shift > maxval then
			result    		<= maxval;
			underflow     	<= '0';
			overflow  		<= '1';
			
		else
			result    		<= resize( tmp_shift, reslen );
			underflow     	<= '0';
			overflow 		<= '0';
			
		end if;
	
	end process proc_ap;
	
	   -- data latch
    reg_sp : process (clk_i) is
        begin
            if rising_edge(clk_i) then
                result_r        <= result;
                underflow_r     <= underflow;
                overflow_r      <= overflow;
            end if;
        end process reg_sp;
    
    -- asynchronous signals are put on output
    -- since registers output is not used it should be removed in synthesis
    async_out_gen : if sync = False generate    
        
        result_o        <= result;
        underflow_o     <= underflow;
        overflow_o      <= overflow;
        
    end generate async_out_gen;
    
    -- synchronous outputs are put on output
    sync_out_gen : if sync = True generate
        
        result_o        <= result_r;
        underflow_o     <= underflow_r;
        overflow_o      <= overflow_r;
        
    end generate sync_out_gen;

end architecture RTL;
