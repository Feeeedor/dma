library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dma is 
port
(
	o_tx_start_spi    : out STD_LOGIC;
   i_tx_end_spi          : in STD_LOGIC;
   o_address_spi         : out STD_LOGIC_VECTOR(31 downto 0);
   o_instruction_spi     : out STD_LOGIC;
   i_data_parallel_spi   : in STD_LOGIC_VECTOR(31 downto 0);
   o_data_parallel_spi   : out STD_LOGIC_VECTOR(31 downto 0);
	i_error_spi           : in STD_LOGIC; 
	
	Clk        : in STD_LOGIC;
   Resetn     : in STD_LOGIC;
	
	APB_PSELx         : in STD_LOGIC;
   APB_PADDR_i       : in STD_LOGIC_VECTOR(7 downto 0);
   APB_PENABLE_i     : in STD_LOGIC;
   APB_PWRITE_i      : in STD_LOGIC;
   APB_PWDATA_i      : in STD_LOGIC_VECTOR(31 downto 0);
   APB_PREADY_o      : out STD_LOGIC;
   APB_PRDATA_o      : out STD_LOGIC_VECTOR(31 downto 0);
	APB_PERROR_o      : out STD_LOGIC;
	
	wr_en_1_ram    : out std_logic; 
	data_in_1_ram  : out std_logic_vector	(31 downto 0); 
   addr_in_1_ram  : out std_logic_vector	(31 downto 0);   
   port_en_1_ram  : out std_logic;       
   data_out_1_ram : in std_logic_vector	(31 downto 0)
	);
end entity;

architecture dma_arch of dma is
	TYPE state_type_APB IS (idle_APB, setup_APB, access_APB);
	TYPE state_type_SPI IS (idle_SPI, wait_SPI, exchange_SPI);
	TYPE state_type_IN  IS (idle_IN, setup_IN, read_ram1_IN, read_ram2_IN, read_ram3_IN, read_ram_spi_IN, write_SPI_IN, read_spi_IN, write_ram_IN, end_IN, setup_read_spi_IN, setup_write_spi_IN, end_internal_IN, error_IN);
	signal state_APB 			  		: state_type_APB;
	signal state_SPI 			  		: state_type_SPI;
	signal state_IN 			  		: state_type_IN;

	type memory_array is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0); 
	signal dma_memory : memory_array; 
	
	signal APB_PREADY_s : STD_LOGIC;
	signal APB_PERROR_s : STD_LOGIC;
	
	signal data_s :  STD_LOGIC_VECTOR(31 downto 0);
	signal source_s : std_logic_vector	 (31 downto 0);
	signal destination_s : std_logic_vector	 (31 downto 0);
	signal flags_s : std_logic_vector	 (31 downto 0);
	signal ram_count_s  : std_logic_vector	 (7 downto 0);
	signal errors_s : std_logic_vector	 (31 downto 0);

begin
APB_PERROR_o <= APB_PERROR_s;
APB_PREADY_o <= APB_PREADY_s;
state_APB_proc:
	process (Clk,Resetn)
	begin 
		IF Resetn = '0' then 
			state_APB <= idle_APB;
		ELSIF (rising_edge(Clk)) then
			CASE state_APB is 
			
					when  idle_APB =>
						if APB_PSELx='1' then    
							state_APB <= setup_APB;
						end if;
				
					when setup_APB =>
						state_APB <= access_APB;	
							
					when access_APB =>
						if APB_PADDR_i = "00000110" or APB_PADDR_i = "00000111" then
							state_APB <= setup_APB;
						elsif APB_PREADY_s = '1' and  APB_PSELx='1' then
							state_APB <= setup_APB;
						elsif APB_PREADY_s = '1' and  APB_PSELx='0' then
							state_APB <= idle_APB;
						end if;
						
				end case;
		end if;
	end process;

state_SPI_proc:
process (Clk,Resetn)
	begin 
		IF Resetn = '0' then 
			state_SPI <= idle_SPI;
		ELSIF (rising_edge(Clk)) then
			CASE state_SPI is 
					when  idle_SPI =>
						if state_IN = setup_write_SPI_IN 	or  state_IN = setup_read_SPI_IN then    
							state_SPI <= wait_SPI;						
						end if;
				
					when wait_SPI =>
						if i_tx_end_spi = '1' then  
							state_SPI <= exchange_SPI;	
						elsif i_error_spi = '1' then 
							state_SPI <= idle_SPI;	
						end if;
					when exchange_SPI =>
						if(i_tx_end_spi = '1') then
							state_SPI <= idle_SPI;
						elsif i_error_spi = '1' then 
							state_SPI <= idle_SPI;	
						end if;
				end case;
		end if;
end process;
	





state_IN_proc:
process (Clk,Resetn, state_SPI, state_APB, ram_count_s, source_s, destination_s, flags_s(1), data_s, i_error_spi)
	begin 
		IF Resetn = '0' then 
			state_IN <= idle_IN;
		ELSIF (rising_edge(Clk)) then
			CASE state_IN is 
					when  idle_IN =>
						if state_APB = access_APB and APB_PADDR_i = "00001000" then
							state_IN <= setup_IN;
						end if;	
					when setup_IN =>
						if ram_count_s = "00000000" 	or flags_s(0) = '1' then
						state_IN <= read_ram1_IN;
						else
						state_IN <= end_IN;
						end if;
					when read_ram1_IN =>	
					if source_s /= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" and source_s /= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU" then
						state_IN <= read_ram2_IN;
					end if;
					when read_ram2_IN =>
					if destination_s /= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" and destination_s /= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU" then
						state_IN <= read_ram3_IN;
						end if;
					when read_ram3_IN =>
					if flags_s /= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" and flags_s /= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU" then
						if flags_s(1) = '1' then
						state_IN <= read_ram_spi_IN;
						else
						state_IN <= setup_read_spi_IN;
						end if;
					end if;
					
					when read_ram_spi_IN =>
						if data_s /= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" and data_s /= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU" then
							state_IN <= setup_write_spi_IN;
						end if;
						
					when setup_write_spi_IN => 
					state_IN <= write_SPI_IN;
					
					when write_SPI_IN =>	
						if state_SPI = idle_SPI then 
							state_IN <= end_internal_IN;
						elsif i_error_spi = '1' then 
							state_IN <= error_IN;	
						end if;
						
					when setup_read_spi_IN => 
						state_IN <= read_spi_IN;
						
					when read_spi_IN =>
						if state_SPI = idle_SPI then 
							state_IN <= write_ram_IN;
						elsif i_error_spi = '1' then 
							state_IN <= error_IN;	 
						end if;
					when write_ram_IN =>
					
						state_IN <= end_internal_IN;
					when end_IN =>
						state_IN <= idle_IN;
					when end_internal_IN =>
						state_IN <= setup_IN;
					when error_IN =>
				end case;
		end if;
end process;
	
proces_sig: 
process ( state_APB, state_SPI, state_IN)
begin


	----------------------------------ram_count_s----------------------------
	if  state_IN = idle_IN then
		ram_count_s <= "00000000";
	elsif  state_IN = end_internal_IN then
		ram_count_s <= std_logic_vector(unsigned(ram_count_s) + 1);
	end if;

	
	
		----------------------------------APB_PREADY_s-----------------------------------------
	if state_APB = idle_APB then
		APB_PREADY_s <= '1';
	elsif state_APB = setup_APB then
		APB_PREADY_s <= '0';
	elsif state_IN = end_IN or APB_PERROR_s = '1' then 
	APB_PREADY_s <= '1';
	end if;
	
		
		----------------------------------APB_PRDATA_o-----------------------------------------
	if state_APB = access_APB and APB_PWRITE_i = '0' then
		APB_PRDATA_o <=  dma_memory(to_integer(unsigned(APB_PADDR_i)));
	else
		APB_PRDATA_o <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	end if;
----------------------------------port_en_1_ram-----------------
	if state_IN = read_ram1_IN or state_IN = read_ram2_IN or state_IN = read_ram3_IN or state_IN = read_ram_spi_IN or state_IN = write_ram_IN then
		port_en_1_ram <= '1';
	else
		port_en_1_ram <= '0';
	end if;
----------------------------------addr_in_1_ram-----------------
	if state_IN = read_ram1_IN then
		addr_in_1_ram <= std_logic_vector(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 3*unsigned(ram_count_s));
	elsif state_IN = read_ram2_IN then
		addr_in_1_ram <= std_logic_vector(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 1 + 3*unsigned(ram_count_s));
	elsif state_IN = read_ram3_IN then
		addr_in_1_ram <= std_logic_vector(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 2 + 3*unsigned(ram_count_s));
	elsif state_IN = read_ram_spi_IN then
		addr_in_1_ram <= source_s;
	elsif state_IN = write_ram_IN then
		addr_in_1_ram <= destination_s;
	else
		addr_in_1_ram <=  (others => 'Z');
	end if;
	----------------------------------wr_en_1_ram-----------------
	if state_IN = write_ram_IN then
		wr_en_1_ram <= '1';
	else
		wr_en_1_ram <= 'Z';
	end if;
	
----------------------------------data_in_1_ram-----------------
	if state_IN = write_ram_IN then
		data_in_1_ram <= data_s;
	else
		data_in_1_ram <= (others => 'Z');
	end if;
	
----------------------------------o_tx_start_spi-----------------
		if state_IN = setup_read_spi_IN or state_IN = setup_write_spi_IN then
		o_tx_start_spi <= '1';
		elsif state_SPI = idle_SPI then
		o_tx_start_spi <= '0';
		end if;
----------------------------------o_address_spi-----------------
	if state_IN = write_SPI_IN then
		o_address_spi <= destination_s;
	elsif state_IN = read_SPI_IN then 
		o_address_spi <= source_s;
	else
		o_address_spi<=  (others => 'Z');
	end if;
----------------------------------o_instruction_spi-----------------
	if state_IN = write_SPI_IN then
		o_instruction_spi <= '1';
	elsif state_IN = read_SPI_IN then
		o_instruction_spi <= '0';
	else
		o_instruction_spi <= 'Z';
	end if;
----------------------------------o_data_parallel_spi-----------------
	if state_IN = write_SPI_IN then
		o_data_parallel_spi <= data_s;
	else
		o_data_parallel_spi <=  (others => 'Z');
	end if;


end process;   
 
proces_sig_command: 
process (Clk, state_APB, state_SPI, state_IN)
begin
	----------------------------------source_s-----------------------------------------
	if  state_IN = idle_IN then
		source_s <= (others => 'Z');
	elsif  state_IN = setup_IN then
		source_s <= (others => 'Z');
	elsif  state_IN = end_internal_IN then
		source_s <= (others => 'Z');
	elsif state_IN = read_ram1_IN and source_s = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
		source_s <= data_out_1_ram;
	end if;
		----------------------------------destination_s-----------------------------------------
	if  state_IN = idle_IN then
		destination_s <=  (others => 'Z');
	elsif  state_IN = setup_IN then
		destination_s <= (others => 'Z');
	elsif  state_IN = end_internal_IN then
		destination_s <= (others => 'Z');
	elsif state_IN = read_ram2_IN and destination_s = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"  then
		destination_s <= data_out_1_ram;
	end if;
		----------------------------------flags_s-----------------------------------------
	if  state_IN = idle_IN then
		flags_s <=  (others => 'Z');
	elsif  state_IN = setup_IN then
		flags_s <= (others => 'Z');
	elsif  state_IN = read_ram1_IN then
		flags_s <= (others => 'Z');
	elsif state_IN = read_ram3_IN  and flags_s = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
		flags_s <= data_out_1_ram;
	end if; 
	----------------------------------data_s----------------------------
	if  state_SPI = exchange_SPI  and state_IN = read_spi_IN then
		data_s <= i_data_parallel_spi;
	elsif  state_IN = read_ram_spi_IN  and data_s = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
		data_s <= data_out_1_ram;
	elsif  state_IN = setup_IN then  
		data_s <=  (others => 'Z');
	elsif  state_APB = idle_APB then  
		data_s <=  (others => 'Z');
	end if;	
		----------------------------------APB_PERROR_s----------------------------
	if  state_APB = setup_APB then
			if APB_PADDR_i /= "00000110" then 
				if APB_PADDR_i /= "00000111" 	 then 
					if APB_PADDR_i /= "00001000" then
						APB_PERROR_s <= '1';
					end if;
		      end if;	
			end if;
	elsif  APB_PADDR_i = "00001000"  and dma_memory(6) = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
		APB_PERROR_s <= '1';
	elsif  APB_PADDR_i = "00001000"  and dma_memory(7) = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
		APB_PERROR_s <= '1';
	elsif  APB_PADDR_i = "00001000"  and to_integer(unsigned(dma_memory(6))) >= to_integer(unsigned(dma_memory(7))) then
		APB_PERROR_s <= '1';
	elsif  dma_memory(to_integer(unsigned(APB_PADDR_i))) /=  "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" and state_APB = setup_APB then
		APB_PERROR_s <= '1';
	elsif  ram_count_s =  "11111111" and state_IN = end_internal_IN then
		APB_PERROR_s <= '1';	
	elsif ( to_integer(unsigned(dma_memory(6))) > to_integer(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 3*unsigned(ram_count_s)) 	or to_integer(unsigned(dma_memory(7))) < to_integer(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 3*unsigned(ram_count_s))) and (state_IN = read_ram1_IN) then
		APB_PERROR_s <= '1';
	elsif ( to_integer(unsigned(dma_memory(6))) > to_integer(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 1 + 3*unsigned(ram_count_s)) or	 to_integer(unsigned(dma_memory(7))) < to_integer(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 1 + 3*unsigned(ram_count_s)) ) and state_IN = read_ram2_IN then
		APB_PERROR_s <= '1';
	elsif ( to_integer(unsigned(dma_memory(6))) > to_integer(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 2 + 3*unsigned(ram_count_s)) or	 to_integer(unsigned(dma_memory(7))) < to_integer(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 2 + 3*unsigned(ram_count_s)) ) and state_IN = read_ram3_IN then
		APB_PERROR_s <= '1';
	elsif ( to_integer(unsigned(dma_memory(6))) > to_integer(unsigned(dma_memory(2)))  or	 to_integer(unsigned(dma_memory(7))) < to_integer(unsigned(dma_memory(2))))  and state_IN = read_ram_spi_IN then
		APB_PERROR_s <= '1';	
	elsif  i_error_spi =  '1' and state_spi = wait_spi and state_in = write_spi_IN then
		APB_PERROR_s <= '1';
	elsif  i_error_spi =  '1' and state_spi = wait_spi and state_in = read_spi_IN then
		APB_PERROR_s <= '1';
	elsif  i_error_spi =  '1' and state_spi = exchange_spi and state_in = read_spi_IN  then
		APB_PERROR_s <= '1';
	elsif  i_error_spi =  '1' and state_spi = exchange_spi and state_in = write_spi_IN  then
		APB_PERROR_s <= '1';
	elsif ( to_integer(unsigned(dma_memory(6))) > to_integer(unsigned(dma_memory(3)))  or	 to_integer(unsigned(dma_memory(7))) < to_integer(unsigned(dma_memory(3))))  and state_IN = write_ram_IN then
		APB_PERROR_s <= '1';
	else
		APB_PERROR_s <= '0';
	end if;	
			----------------------------------err	s_s----------------------------
	if  state_APB = setup_APB then
			if APB_PADDR_i /= "00000110" then 
				if APB_PADDR_i /= "00000111" 	 then 
					if APB_PADDR_i /= "00001000" then
						errors_s <= x"00000001";
					end if;
		      end if;	
			end if;
	elsif state_APB /= idle_APB then 
		if  APB_PADDR_i = "00001000"  and dma_memory(6) = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" and state_APB = setup_APB then
			errors_s <= x"00000002";
		elsif  APB_PADDR_i = "00001000"  and dma_memory(7) = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
			errors_s <= x"00000003";
		elsif  APB_PADDR_i = "00001000"  and to_integer(unsigned(dma_memory(6))) >= to_integer(unsigned(dma_memory(7))) then
			errors_s <= x"00000004";
		end if;
	elsif  dma_memory(to_integer(unsigned(APB_PADDR_i))) /=  "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"  and state_APB = setup_APB then
		errors_s <= x"00000005";
	elsif  ram_count_s =  "11111111" and state_IN = end_internal_IN then
		errors_s <= x"00000006";	
	elsif ( to_integer(unsigned(dma_memory(6))) > to_integer(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 3*unsigned(ram_count_s)) or	 to_integer(unsigned(dma_memory(7))) < to_integer(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 3*unsigned(ram_count_s))) and (state_IN = read_ram1_IN) then
		errors_s <= x"00000007";
	elsif ( to_integer(unsigned(dma_memory(6))) > to_integer(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 1 + 3*unsigned(ram_count_s)) or	 to_integer(unsigned(dma_memory(7))) < to_integer(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 1 + 3*unsigned(ram_count_s)) ) and state_IN = read_ram2_IN then
		errors_s <= x"00000008";
	elsif ( to_integer(unsigned(dma_memory(6))) > to_integer(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 2 + 3*unsigned(ram_count_s)) 	or to_integer(unsigned(dma_memory(7))) < to_integer(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 2 + 3*unsigned(ram_count_s)) ) and state_IN = read_ram3_IN then
		errors_s <= x"00000009";
	elsif ( to_integer(unsigned(dma_memory(6))) > to_integer(unsigned(dma_memory(2)))  or	 to_integer(unsigned(dma_memory(7))) < to_integer(unsigned(dma_memory(2))))  and state_IN = read_ram_spi_IN then
		errors_s <= x"0000000A";	
	elsif  i_error_spi =  '1' and state_spi = wait_spi and state_in = write_spi_IN then
		errors_s <= x"0000000B";
	elsif  i_error_spi =  '1' and state_spi = wait_spi and state_in = read_spi_IN then
		errors_s <= x"0000000C";
	elsif  i_error_spi =  '1' and state_spi = exchange_spi and state_in = read_spi_IN  then
		errors_s <= x"0000000D";
	elsif  i_error_spi =  '1' and state_spi = exchange_spi and state_in = write_spi_IN  then
		errors_s <= x"0000000E";
	elsif ( to_integer(unsigned(dma_memory(6))) > to_integer(unsigned(dma_memory(3)))  or	 to_integer(unsigned(dma_memory(7))) < to_integer(unsigned(dma_memory(3))))  and state_IN = write_ram_IN then
		errors_s <= x"0000000F";
	else
		errors_s <= x"00000000";
	end if;
   end process;  
	
	proces_dma_memory: 
process (state_APB, state_SPI, state_IN, APB_PADDR_i, ram_count_s, errors_s, source_s, destination_s, flags_s, data_s)
begin
if  state_APB = idle_APB then
		dma_memory <=  (others => (others => 'Z'));
	else
		dma_memory(0) <= errors_s;
		dma_memory(1) <= ram_count_s & "000000000000000000000000";
		dma_memory(2) <= source_s;
		dma_memory(3) <= destination_s;
		dma_memory(4) <= flags_s;
		dma_memory(5) <= data_s;
	if state_APB = access_APB and APB_PWRITE_i = '1' and APB_PADDR_i = "00000110" then
		dma_memory(to_integer(unsigned(APB_PADDR_i))) <= APB_PWDATA_i;
	elsif state_APB = access_APB and APB_PWRITE_i = '1' and APB_PADDR_i = "00000111" then
		dma_memory(to_integer(unsigned(APB_PADDR_i))) <= APB_PWDATA_i;
	elsif state_APB = access_APB and APB_PWRITE_i = '1' and APB_PADDR_i = "00001000" then
		dma_memory(to_integer(unsigned(APB_PADDR_i))) <= APB_PWDATA_i;
	end if;
end if;
end process;  
end architecture;