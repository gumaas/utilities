library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arith_test_bench is
end entity arith_test_bench;

architecture RTL of arith_test_bench is
	
	constant vect_len_c		: natural := 4;
	
	signal clk				: std_logic := '0';
	
	signal 	data			: unsigned( 2*vect_len_c-1 downto 0 ) := ( others=>'0');
	
	signal 	a_signed,
			b_signed		: signed( vect_len_c-1 downto 0 );	
	
	signal 	a_unsigned,
			b_unsigned		: unsigned( vect_len_c-1 downto 0 );	
	
	signal 	result_sub_signed_FF,
			result_sub_signed_FT,
			result_sub_signed_TF,
			result_sub_signed_TT 	: signed( vect_len_c-1 downto 0);
	
	signal 	result_sub_unsigned_FF,
			result_sub_unsigned_FT,
			result_sub_unsigned_TF,
			result_sub_unsigned_TT 	: unsigned( vect_len_c-1 downto 0);

	signal 	result_add_signed_FF,
			result_add_signed_FT,
			result_add_signed_TF,
			result_add_signed_TT 	: signed( vect_len_c-1 downto 0);
	
	signal 	result_add_unsigned_FF,
			result_add_unsigned_FT,
			result_add_unsigned_TF,
			result_add_unsigned_TT 	: unsigned( vect_len_c-1 downto 0);
						
begin
--	clock generation	
	clkgen : process is
	begin
		wait for 10 ns;
		clk <= not clk;
	end process clkgen;
	
--	data is increased each clock cycle
	datagen : process (clk) is
	begin
		if rising_edge(clk) then
			data	<= data + 1;
		end if;
	end process datagen;
	
--	want to check coponents with every possible input value
--	no matter how will the input data change  
	a_unsigned		<= data(vect_len_c-1 downto 0 );
	b_unsigned		<= data(2*vect_len_c-1 downto vect_len_c );
	
	a_signed		<= signed( a_unsigned );
	b_signed		<= signed( b_unsigned ); 
	
	subtractor_signed_FF_inst : entity work.subtractor_signed
		generic map(
			alen_g      => vect_len_c,
			blen_g      => vect_len_c,
			reslen_g    => vect_len_c,
			reg_out_g   => False,
			reg_arith_g => False
		)
		port map(
			clk_i       => clk,
			a_i         => a_signed,
			b_i         => b_signed,
			result_o    => result_sub_signed_FF,
			overflow_o  => open,
			underflow_o => open
		);	
	
	subtractor_signed_FT_inst : entity work.subtractor_signed
		generic map(
			alen_g      => vect_len_c,
			blen_g      => vect_len_c,
			reslen_g    => vect_len_c,
			reg_out_g   => False,
			reg_arith_g => True
		)
		port map(
			clk_i       => clk,
			a_i         => a_signed,
			b_i         => b_signed,
			result_o    => result_sub_signed_FT,
			overflow_o  => open,
			underflow_o => open
		);	
		
	subtractor_signed_TF_inst : entity work.subtractor_signed
		generic map(
			alen_g      => vect_len_c,
			blen_g      => vect_len_c,
			reslen_g    => vect_len_c,
			reg_out_g   => True,
			reg_arith_g => True
		)
		port map(
			clk_i       => clk,
			a_i         => a_signed,
			b_i         => b_signed,
			result_o    => result_sub_signed_TF,
			overflow_o  => open,
			underflow_o => open
		);	
		
	subtractor_signed_TT_inst : entity work.subtractor_signed
		generic map(
			alen_g      => vect_len_c,
			blen_g      => vect_len_c,
			reslen_g    => vect_len_c,
			reg_out_g   => True,
			reg_arith_g => True
		)
		port map(
			clk_i       => clk,
			a_i         => a_signed,
			b_i         => b_signed,
			result_o    => result_sub_signed_TT,
			overflow_o  => open,
			underflow_o => open
		);	
		
		
		
	subtractor_unsigned_FF_inst : entity work.subtractor_unsigned
		generic map(
			alen_g      => vect_len_c,
			blen_g      => vect_len_c,
			reslen_g    => vect_len_c,
			reg_out_g   => False,
			reg_arith_g => False
		)
		port map(
			clk_i       => clk,
			a_i         => a_unsigned,
			b_i         => b_unsigned,
			result_o    => result_sub_unsigned_FF,
			overflow_o  => open,
			underflow_o => open
		);	
	
	subtractor_unsigned_FT_inst : entity work.subtractor_unsigned
		generic map(
			alen_g      => vect_len_c,
			blen_g      => vect_len_c,
			reslen_g    => vect_len_c,
			reg_out_g   => False,
			reg_arith_g => True
		)
		port map(
			clk_i       => clk,
			a_i         => a_unsigned,
			b_i         => b_unsigned,
			result_o    => result_sub_unsigned_FT,
			overflow_o  => open,
			underflow_o => open
		);	
		
	subtractor_unsigned_TF_inst : entity work.subtractor_unsigned
		generic map(
			alen_g      => vect_len_c,
			blen_g      => vect_len_c,
			reslen_g    => vect_len_c,
			reg_out_g   => True,
			reg_arith_g => False
		)
		port map(
			clk_i       => clk,
			a_i         => a_unsigned,
			b_i         => b_unsigned,
			result_o    => result_sub_unsigned_TF,
			overflow_o  => open,
			underflow_o => open
		);	
		
	subtractor_unsigned_TT_inst : entity work.subtractor_unsigned
		generic map(
			alen_g      => vect_len_c,
			blen_g      => vect_len_c,
			reslen_g    => vect_len_c,
			reg_out_g   => True,
			reg_arith_g => True
		)
		port map(
			clk_i       => clk,
			a_i         => a_unsigned,
			b_i         => b_unsigned,
			result_o    => result_sub_unsigned_TT,
			overflow_o  => open,
			underflow_o => open
		);	
		
		





	adder_signed_FF_inst : entity work.adder_signed
		generic map(
			alen_g      => vect_len_c,
			blen_g      => vect_len_c,
			reslen_g    => vect_len_c,
			reg_out_g   => False,
			reg_arith_g => False
		)
		port map(
			clk_i       => clk,
			a_i         => a_signed,
			b_i         => b_signed,
			result_o    => result_add_signed_FF,
			overflow_o  => open,
			underflow_o => open
		);	
	
	adder_signed_FT_inst : entity work.adder_signed
		generic map(
			alen_g      => vect_len_c,
			blen_g      => vect_len_c,
			reslen_g    => vect_len_c,
			reg_out_g   => False,
			reg_arith_g => True
		)
		port map(
			clk_i       => clk,
			a_i         => a_signed,
			b_i         => b_signed,
			result_o    => result_add_signed_FT,
			overflow_o  => open,
			underflow_o => open
		);	
		
	adder_signed_TF_inst : entity work.adder_signed
		generic map(
			alen_g      => vect_len_c,
			blen_g      => vect_len_c,
			reslen_g    => vect_len_c,
			reg_out_g   => True,
			reg_arith_g => True
		)
		port map(
			clk_i       => clk,
			a_i         => a_signed,
			b_i         => b_signed,
			result_o    => result_add_signed_TF,
			overflow_o  => open,
			underflow_o => open
		);	
		
	adder_signed_TT_inst : entity work.adder_signed
		generic map(
			alen_g      => vect_len_c,
			blen_g      => vect_len_c,
			reslen_g    => vect_len_c,
			reg_out_g   => True,
			reg_arith_g => True
		)
		port map(
			clk_i       => clk,
			a_i         => a_signed,
			b_i         => b_signed,
			result_o    => result_add_signed_TT,
			overflow_o  => open,
			underflow_o => open
		);	
		
		
		
	adder_unsigned_FF_inst : entity work.adder_unsigned
		generic map(
			alen_g      => vect_len_c,
			blen_g      => vect_len_c,
			reslen_g    => vect_len_c,
			reg_out_g   => False,
			reg_arith_g => False
		)
		port map(
			clk_i       => clk,
			a_i         => a_unsigned,
			b_i         => b_unsigned,
			result_o    => result_add_unsigned_FF,
			overflow_o  => open,
			underflow_o => open
		);	
	
	adder_unsigned_FT_inst : entity work.adder_unsigned
		generic map(
			alen_g      => vect_len_c,
			blen_g      => vect_len_c,
			reslen_g    => vect_len_c,
			reg_out_g   => False,
			reg_arith_g => True
		)
		port map(
			clk_i       => clk,
			a_i         => a_unsigned,
			b_i         => b_unsigned,
			result_o    => result_add_unsigned_FT,
			overflow_o  => open,
			underflow_o => open
		);	
		
	adder_unsigned_TF_inst : entity work.adder_unsigned
		generic map(
			alen_g      => vect_len_c,
			blen_g      => vect_len_c,
			reslen_g    => vect_len_c,
			reg_out_g   => True,
			reg_arith_g => False
		)
		port map(
			clk_i       => clk,
			a_i         => a_unsigned,
			b_i         => b_unsigned,
			result_o    => result_add_unsigned_TF,
			overflow_o  => open,
			underflow_o => open
		);	
		
	adder_unsigned_TT_inst : entity work.adder_unsigned
		generic map(
			alen_g      => vect_len_c,
			blen_g      => vect_len_c,
			reslen_g    => vect_len_c,
			reg_out_g   => True,
			reg_arith_g => True
		)
		port map(
			clk_i       => clk,
			a_i         => a_unsigned,
			b_i         => b_unsigned,
			result_o    => result_add_unsigned_TT,
			overflow_o  => open,
			underflow_o => open
		);	


end architecture RTL;
