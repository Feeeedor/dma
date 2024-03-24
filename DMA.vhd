library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dma is 
port
(
	SPI_START_o    	 	 : out STD_LOGIC;
   SPI_END_i          	 : in  STD_LOGIC;
   SPI_ADDRESS_o         : out STD_LOGIC_VECTOR(31 downto 0);
   SPI_INSTRUCTION_o     : out STD_LOGIC;
   SPI_RDATA_i   			 : in  STD_LOGIC_VECTOR(31 downto 0);
   SPI_WDATA_o   			 : out STD_LOGIC_VECTOR(31 downto 0);
	SPI_ERROR_i           : in  STD_LOGIC; 
	
	Clk        				 : in  STD_LOGIC;
   Resetn     				 : in  STD_LOGIC;
	
	APB_PSELx         	 : in  STD_LOGIC;
   APB_PADDR_i       	 : in  STD_LOGIC_VECTOR(7 downto 0);
   APB_PENABLE_i     	 : in  STD_LOGIC;
   APB_PWRITE_i      	 : in  STD_LOGIC;
   APB_PWDATA_i     	    : in  STD_LOGIC_VECTOR(31 downto 0);
   APB_PREADY_o      	 : out STD_LOGIC;
   APB_PRDATA_o      	 : out STD_LOGIC_VECTOR(31 downto 0);
	APB_PERROR_o      	 : out STD_LOGIC;
	
	RAM_WRITE_o    		 : out std_logic; 
	RAM_WDATA_o  		 	 : out std_logic_vector	(31 downto 0); 
   RAM_ADDRESS_o  		 : out std_logic_vector	(31 downto 0);   
   RAM_PORTENABLER_o  	 : out std_logic;       
   RAM_RDATA_i 		 	 : in  std_logic_vector	(31 downto 0)
	);
end entity;

architecture dma_arch of dma is
	TYPE state_type_APB IS (idle_APB, setup_APB, access_APB);
	TYPE state_type_SPI IS (idle_SPI, wait_SPI, exchange_SPI);
	TYPE state_type_IN  IS (idle_IN, setup_IN, read_source_IN, read_dest_IN, read_flags_IN, read_ram_spi_IN, write_SPI_IN, read_spi_IN, write_ram_IN, end_IN, setup_read_spi_IN, setup_write_spi_IN, end_internal_IN, error_IN);
	signal state_APB 			  		: state_type_APB;
	signal state_SPI 			  		: state_type_SPI;
	signal state_IN 			  		: state_type_IN;

	type memory_array is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0); 
	signal dma_memory : memory_array; 

	signal APB_PREADY_s : STD_LOGIC;
	
begin	
	state_APB_proc:
	process (Clk,Resetn )
	begin 
		IF Resetn = '0'  then 
			state_APB <= idle_APB;
		ELSIF (rising_edge(Clk)) then
			CASE state_APB is 
				
				when  idle_APB =>
					if APB_PENABLE_i = '1' and APB_PSELx='1' then    
						state_APB <= setup_APB;
					end if;
				
				when setup_APB =>
					state_APB <= access_APB;	
							
				when access_APB =>
					if APB_PREADY_s = '1' and  APB_PSELx='1' then
						state_APB <= setup_APB;
					elsif APB_PREADY_s = '1' and  APB_PSELx='0' then
						state_APB <= idle_APB;
					elsif state_IN = error_IN then
						state_APB <= idle_APB;
					end if;
						
			end case;
		end if;
	end process;

	state_SPI_proc:
	process (Clk,Resetn)
		begin 
			if Resetn = '0' or dma_memory(1) /= x"00000000" then 
				state_SPI <= idle_SPI;
			elsif (rising_edge(Clk)) then
				case state_SPI is 
					
					when idle_SPI =>
						if state_IN = setup_write_SPI_IN 	or  state_IN = setup_read_SPI_IN then    
							state_SPI <= wait_SPI;						
						end if;
				
					when wait_SPI =>
						if SPI_END_i = '1' then  
							state_SPI <= exchange_SPI;	
						elsif SPI_ERROR_i = '1' then 
							state_SPI <= idle_SPI;	
						end if;
						
					when exchange_SPI =>
						if SPI_END_i = '1' or SPI_ERROR_i = '1' then --было если енд равен 1
							state_SPI <= idle_SPI;
						end if;
							
				end case;
			end if;
	end process;
	
	state_IN_proc:
	process (Clk,Resetn, state_SPI, state_APB, SPI_ERROR_i)
		begin 
			IF Resetn = '0' then 
				state_IN <= idle_IN;
			ELSIF (rising_edge(Clk)) then
				if dma_memory(1) /= x"00000000" then
					state_IN <= error_IN; 
				else
					CASE state_IN is 
						
						when  idle_IN =>
							if APB_PENABLE_i = '1' and state_APB = access_APB   and dma_memory(0)(0) = '1' and dma_memory(10)(3) = '1' then 
								state_IN <= setup_IN;
							end if;	
							
						when setup_IN =>
							if dma_memory(2) = x"00000000" 	or dma_memory(5)(0) = '1' then
								state_IN <= read_source_IN;
							else
								state_IN <= end_IN;
							end if;
							
						when read_source_IN =>	
							if dma_memory(10)(4) = '1' then
								state_IN <= read_dest_IN;
							end if;
							
						when read_dest_IN =>
							if dma_memory(10)(5) = '1' then
								state_IN <= read_flags_IN;
							end if;
							
						when read_flags_IN =>
							if dma_memory(10)(6) = '1' then
								if dma_memory(5)(1) = '1' then
									state_IN <= read_ram_spi_IN;
								else
									state_IN <= setup_read_spi_IN;
								end if;
							end if;
						
						when read_ram_spi_IN =>
							if dma_memory(10)(7) = '1'  then
								state_IN <= setup_write_spi_IN;
							end if;
							
						when setup_write_spi_IN => 
							state_IN <= write_SPI_IN;
						
						when write_SPI_IN =>	
							if state_SPI = idle_SPI then 
								state_IN <= end_internal_IN;
							elsif SPI_ERROR_i = '1' then 
								state_IN <= error_IN;	
							end if;
							
						when setup_read_spi_IN => 
							state_IN <= read_spi_IN;
							
						when read_spi_IN =>
							if dma_memory(10)(8) = '1' then 
								state_IN <= write_ram_IN;
							elsif SPI_ERROR_i = '1' then 
								state_IN <= error_IN;	 
							end if;
							
						when write_ram_IN =>
							if dma_memory(10)(11) = '1' then 
								state_IN <= end_internal_IN;
							end if;
						when end_IN =>
							state_IN <= idle_IN;
							
						when end_internal_IN =>
							state_IN <= setup_IN;
							
						when error_IN =>
						
					end case;
				end if;
			end if;
	end process;

	APB_PREADY_o <= APB_PREADY_s;
	proces_sig: 
	process (Clk, state_APB, state_SPI, state_IN)
	begin
		----------------------------------APB_PREADY_s-----------------------------------------
		if Resetn = '0' then
			APB_PREADY_s <= '1';
		elsif APB_PENABLE_i = '1' and state_APB = setup_APB then
			APB_PREADY_s <= '0';
		elsif state_IN = end_IN or dma_memory(1) /= x"00000000"  then 
			APB_PREADY_s <= '1';
		elsif APB_PWRITE_i = '1' and APB_PADDR_i = "00000111" and dma_memory(10)(0) = '1' then
			APB_PREADY_s <= '1';
		elsif APB_PWRITE_i = '1' and APB_PADDR_i = "00001000" and dma_memory(10)(1) = '1' then
			APB_PREADY_s <= '1';
		elsif APB_PWRITE_i = '1' and APB_PADDR_i = "00001001" and dma_memory(10)(2) = '1' then
			APB_PREADY_s <= '1';
		elsif dma_memory(10)(9) = '1' then
			APB_PREADY_s <= '1';
		else
			APB_PREADY_s <= APB_PREADY_s;
		end if;	
	   ----------------------------RAM_PORTENABLER_o-----------------
		if state_IN = read_source_IN or state_IN = read_dest_IN or state_IN = read_flags_IN or state_IN = read_ram_spi_IN or state_IN = write_ram_IN then
			RAM_PORTENABLER_o <= '1';
		else
			RAM_PORTENABLER_o <= '0';
		end if;
		---------------------------------RAM_ADDRESS_o-----------------
		if state_IN = read_source_IN then
			RAM_ADDRESS_o <= std_logic_vector(unsigned(dma_memory(9)) + 3 * unsigned(dma_memory(2)(15 downto 0)));
		elsif state_IN = read_dest_IN then
			RAM_ADDRESS_o <= std_logic_vector(unsigned(dma_memory(9)) + 1 + 3*unsigned(dma_memory(2)(15 downto 0)));
		elsif state_IN = read_flags_IN then
			RAM_ADDRESS_o <= std_logic_vector(unsigned(dma_memory(9)) + 2 + 3*unsigned(dma_memory(2)(15 downto 0)));
		elsif state_IN = read_ram_spi_IN then
			RAM_ADDRESS_o <= dma_memory(3);
		elsif state_IN = write_ram_IN then
			RAM_ADDRESS_o <= dma_memory(4);
		else
			RAM_ADDRESS_o <=  (others => 'Z');
		end if;
		----------------------------------RAM_WRITE_o-----------------
		if state_IN = write_ram_IN then
			RAM_WRITE_o <= '1';
		else
			RAM_WRITE_o <= '0';
		end if;
		----------------------------------RAM_WDATA_o-----------------
		if state_IN = write_ram_IN then
			RAM_WDATA_o <=dma_memory(6);
		else
			RAM_WDATA_o <= (others => 'Z');
		end if;
		----------------------------------SPI_START_o-----------------
		if state_IN = read_spi_IN or state_IN = write_spi_IN then
			SPI_START_o <= '1';
		elsif state_SPI = idle_SPI then
			SPI_START_o <= '0';
		else
			SPI_START_o <= '0';
		end if;
		----------------------------------SPI_ADDRESS_o-----------------
		if state_IN = write_SPI_IN then
			SPI_ADDRESS_o <= dma_memory(4);
		elsif state_IN = read_SPI_IN then 
			SPI_ADDRESS_o <= dma_memory(3);
		else
			SPI_ADDRESS_o <= (others => 'Z');
		end if;
		----------------------------------SPI_INSTRUCTION_o-----------------
		if state_IN = write_SPI_IN then
			SPI_INSTRUCTION_o <= '1';
		elsif state_IN = read_SPI_IN then
			SPI_INSTRUCTION_o <= '0';
		else
			SPI_INSTRUCTION_o <= 'Z';
		end if;
		----------------------------------SPI_WDATA_o-----------------
		if state_SPI = exchange_SPI  and state_IN = write_SPI_IN then
			SPI_WDATA_o <= dma_memory(6);
		else
			SPI_WDATA_o <=  (others => 'Z');
		end if;
		-----------------------APB_PRDATA_o--------------
		if Resetn = '0' then
        APB_PRDATA_o <= (others => 'Z');
		elsif rising_edge (Clk) then
         if APB_PENABLE_i = '1' and APB_PWRITE_i = '0' and state_APB = setup_APB  then
            APB_PRDATA_o <= dma_memory(to_integer(unsigned(APB_PADDR_i)));
			elsif APB_PREADY_s = '1' then 
				APB_PRDATA_o <= (others => 'Z');
         else
         end if;
      end if;
	 	-----------------------APB_PERROR_o--------------
		if Resetn = '0' then
			APB_PERROR_o <= '0';
		elsif rising_edge (Clk) then
			if dma_memory(1) /= x"00000000" then
         APB_PERROR_o <= '1';
			else      
			end if;
		end if;
	end process;   
  
	process_registers:
	process (Clk, Resetn)
	begin
				------------------dma_memory(0)------------------
		if Resetn = '0' then
			dma_memory(0) <= (others => '0');
		elsif rising_edge (Clk) then
			if APB_PENABLE_i = '1' and state_APB = setup_APB and APB_PWRITE_i = '1' and APB_PADDR_i = "00000000" then
				dma_memory(0) <= APB_PWDATA_i;
			elsif  state_IN = end_IN then 
				dma_memory(0) <= (others => '0');
			else
			end if;
		end if;
				------------------dma_memory(1)-----DMA_Error_State_s-------------
		if Resetn = '0' then
			dma_memory(1) <= (others => '0');
		elsif rising_edge (Clk) then
			if state_APB = idle_APB then 
				dma_memory(1) <= x"00000000";
			elsif  state_IN /= error_IN and state_APB = setup_APB and APB_PADDR_i /= "00000111" and APB_PADDR_i /= "00001000" and APB_PADDR_i /= "00001001" and APB_PWRITE_i = '1' and APB_PADDR_i /= "00000000" then	
				dma_memory(1) <= x"00000001";
			elsif  state_IN /= error_IN   and dma_memory(7) = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" and dma_memory(0)(0) = '1' then	
				dma_memory(1) <= x"00000002";
			elsif state_IN /= error_IN and state_APB = access_APB then 
				if   dma_memory(8) = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" and dma_memory(0)(0) = '1' then
					dma_memory(1) <= x"00000003";
				elsif   to_integer(unsigned(dma_memory(7))) >= to_integer(unsigned(dma_memory(8))) and dma_memory(0)(0) = '1' then
					dma_memory(1) <= x"00000004";
				elsif  dma_memory(2) =  x"FFFFFFFF" and state_IN = read_source_IN then
					dma_memory(1) <= x"00000005";	
				elsif ( to_integer(unsigned(dma_memory(7))) > to_integer(unsigned(dma_memory(9)) + 3*unsigned(dma_memory(2))) or	 to_integer(unsigned(dma_memory(8))) < to_integer(unsigned(dma_memory(9)) + 3*unsigned(dma_memory(2)))) and (state_IN = read_source_IN) then
					dma_memory(1) <= x"00000006";
				elsif ( to_integer(unsigned(dma_memory(7))) > to_integer(unsigned(dma_memory(9)) + 1 + 3*unsigned(dma_memory(2))) or	 to_integer(unsigned(dma_memory(8))) < to_integer(unsigned(dma_memory(9)) + 1 + 3*unsigned(dma_memory(2))) ) and state_IN = read_dest_IN then
					dma_memory(1) <= x"00000007";
				elsif ( to_integer(unsigned(dma_memory(7))) > to_integer(unsigned(dma_memory(9)) + 2 + 3*unsigned(dma_memory(2))) 	or to_integer(unsigned(dma_memory(8))) < to_integer(unsigned(dma_memory(9)) + 2 + 3*unsigned(dma_memory(2))) ) and state_IN = read_flags_IN then
					dma_memory(1) <= x"00000008";
				elsif ( to_integer(unsigned(dma_memory(7))) > to_integer(unsigned(dma_memory(3)))  or	 to_integer(unsigned(dma_memory(8))) < to_integer(unsigned(dma_memory(3))))  and state_IN = read_ram_spi_IN then
					dma_memory(1) <= x"00000009";	
				elsif  (SPI_ERROR_i =  '1' and state_spi = wait_spi and state_in = write_spi_IN) or dma_memory(1) = x"0000000A" then
					dma_memory(1) <= x"0000000A";
				elsif  SPI_ERROR_i =  '1' and state_spi = wait_spi and state_in = read_spi_IN then
					dma_memory(1) <= x"0000000B";
				elsif  SPI_ERROR_i =  '1' and state_spi = exchange_spi and state_in = read_spi_IN  then
					dma_memory(1) <= x"0000000C";
				elsif  SPI_ERROR_i =  '1' and state_spi = exchange_spi and state_in = write_spi_IN  then
					dma_memory(1) <= x"0000000D";
				elsif ( to_integer(unsigned(dma_memory(7))) > to_integer(unsigned(dma_memory(4)))  or	 to_integer(unsigned(dma_memory(8))) < to_integer(unsigned(dma_memory(4))))  and state_IN = write_ram_IN then
					dma_memory(1) <= x"0000000E";
				else
				end if;
			else
			end if;
		end if;	
	--------------------dma_memory(2)---DMA_DATA COUNTER--------------
		if Resetn = '0' then
			dma_memory(2) <= x"00000000";
		elsif rising_edge (Clk) then
			if state_IN = idle_IN or  state_IN = end_IN then
            dma_memory(2)(15 downto 0) <= x"0000";
			elsif  state_IN = end_internal_IN then
				dma_memory(2)(15 downto 0) <= std_logic_vector(unsigned(dma_memory(2)(15 downto 0)) + 1);
			else
			end if;
		end if;	 
	------------------dma_memory(3)----DMA_Address_Source--------------
		if Resetn = '0' then
			dma_memory(3) <= (others => '0');
		elsif rising_edge (Clk) then
			if  state_IN = idle_IN then
				dma_memory(3) <= (others => '0');
			elsif  state_IN = end_internal_IN then
				dma_memory(3) <= (others => '0');
			elsif state_IN = read_source_IN and dma_memory(10)(4) = '0' then
				dma_memory(3) <= RAM_RDATA_i;
			else
			end if;
		end if;	 	
------------------dma_memory(4)----DMA_Address_Destination--------------
		if Resetn = '0' then
			dma_memory(4) <= (others => '0');
		elsif rising_edge (Clk) then
			if  state_IN = idle_IN then
				dma_memory(4) <=  (others => '0');
			elsif  state_IN = end_internal_IN then
				dma_memory(4) <= (others => '0');
			elsif state_IN = read_dest_IN and dma_memory(10)(5) = '0'  then
				dma_memory(4) <= RAM_RDATA_i;
			else 
			end if;
		end if;		
------------------dma_memory(5)----DMA_Task_Flags--------------
		if Resetn = '0' then
			dma_memory(5) <= (others => '0');
		elsif rising_edge (Clk) then
			if  state_IN = idle_IN then
				dma_memory(5) <=  (others => '0');
			elsif  state_IN = read_source_IN then
				dma_memory(5) <= (others => '0');
			elsif state_IN = read_flags_IN  and dma_memory(10)(6) = '0' then
				dma_memory(5) <= RAM_RDATA_i;
			else
			end if;
		end if;
		------------------dma_memory(6)----DMA_Data--------------
		if Resetn = '0' then
			dma_memory(6) <= (others => '0');
		elsif rising_edge (Clk) then
			if  state_SPI = exchange_SPI  and state_IN = read_spi_IN then
				dma_memory(6) <= SPI_RDATA_i;
			elsif  state_IN = read_ram_spi_IN and dma_memory(10)(7) = '0' then
				dma_memory(6) <= RAM_RDATA_i;
			elsif  state_IN = setup_IN then  
				dma_memory(6) <=  (others => '0');
			elsif  state_IN = end_internal_IN then  
				dma_memory(6) <=  (others => '0');
			else
			end if;
		end if;	

		------------------dma_memory(7)------------------
		if Resetn = '0' then
			dma_memory(7) <= (others => '0');
		elsif rising_edge (Clk) then
			if APB_PENABLE_i = '1' and state_APB = setup_APB and APB_PWRITE_i = '1' and APB_PADDR_i = "00000111" then
				dma_memory(7) <= APB_PWDATA_i;
			else
			end if;
		end if;	 	
		------------------dma_memory(8)------------------
		if Resetn = '0' then
			dma_memory(8) <= (others => '0');
		elsif rising_edge (Clk) then
			if APB_PENABLE_i = '1' and state_APB = setup_APB and APB_PWRITE_i = '1' and APB_PADDR_i = "00001000" then
				dma_memory(8) <= APB_PWDATA_i;
			else
			end if;
		end if;	
		------------------dma_memory(9)------------------
		if Resetn = '0' then
			dma_memory(9) <= (others => '0');
		elsif rising_edge (Clk) then
			if APB_PENABLE_i = '1' and state_APB = setup_APB and APB_PWRITE_i = '1' and APB_PADDR_i = "00001001" then
				dma_memory(9) <= APB_PWDATA_i;
			elsif  state_IN = end_IN then 
				dma_memory(9) <= (others => '0');
			else
			end if;
		end if;
		------------------dma_memory(10)(0)------------------
		if Resetn = '0' then
			dma_memory(10)(0) <= '0';
		elsif rising_edge (Clk) then
			if APB_PENABLE_i = '1' and state_APB = access_APB and APB_PWRITE_i = '1' and APB_PADDR_i = "00000111" and APB_PWDATA_i /= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
				dma_memory(10)(0) <= '1';
			else
			end if;
		end if;	
		------------------dma_memory(10)(1)------------------
		if Resetn = '0' then
			dma_memory(10)(1) <= '0';
		elsif rising_edge (Clk) then
			if APB_PENABLE_i = '1' and state_APB = access_APB and APB_PWRITE_i = '1' and APB_PADDR_i = "00001000" and APB_PWDATA_i /= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
				dma_memory(10)(1) <= '1';
			else
			end if;
		end if;
		------------------dma_memory(10)(2)------------------
		if Resetn = '0' then
			dma_memory(10)(2) <= '0';
		elsif rising_edge (Clk) then
			if state_IN = end_IN then
				dma_memory(10)(2) <= '0';
			elsif APB_PENABLE_i = '1' and state_APB = access_APB and APB_PWRITE_i = '1' and APB_PADDR_i = "00001001" and APB_PWDATA_i /= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
				dma_memory(10)(2) <= '1';
			else
			end if;
		end if;	
			------------------dma_memory(10)(3)------------------
		if Resetn = '0' then
			dma_memory(10)(3) <= '0';
		elsif rising_edge (Clk) then
			if state_IN = end_IN then
				dma_memory(10)(3) <= '0';
			elsif APB_PENABLE_i = '1' and state_APB = access_APB and APB_PWRITE_i = '1' and APB_PADDR_i = "00000000" and APB_PWDATA_i /= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
				dma_memory(10)(3) <= '1';
			else
			end if;
		end if;
				------------------dma_memory(10)(4)------------------
		if Resetn = '0' then
			dma_memory(10)(4) <= '0';
		elsif rising_edge (Clk) then
			if state_IN = end_internal_IN then
				dma_memory(10)(4) <= '0';
			elsif state_IN = read_source_IN and RAM_RDATA_i /= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
				dma_memory(10)(4) <= '1';
			else
			end if;
		end if;
				------------------dma_memory(10)(5)------------------
		if Resetn = '0' then
			dma_memory(10)(5) <= '0';
		elsif rising_edge (Clk) then
			if state_IN = end_internal_IN then
				dma_memory(10)(5) <= '0';
			elsif state_IN = read_dest_IN and RAM_RDATA_i /= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
				dma_memory(10)(5) <= '1';
			else
			end if;
		end if;
				------------------dma_memory(10)(6)------------------
		if Resetn = '0' then
			dma_memory(10)(6) <= '0';
		elsif rising_edge (Clk) then
			if state_IN = end_internal_IN then
				dma_memory(10)(6) <= '0';
			elsif state_IN = read_flags_IN and RAM_RDATA_i /= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
				dma_memory(10)(6) <= '1';
			else
			end if;
		end if;
				------------------dma_memory(10)(7)------------------
		if Resetn = '0' then
			dma_memory(10)(7) <= '0';
		elsif rising_edge (Clk) then
			if state_IN = end_internal_IN then
				dma_memory(10)(7) <= '0';
			elsif state_IN = read_ram_spi_IN and RAM_RDATA_i /= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
				dma_memory(10)(7) <= '1';
			else
			end if;
		end if;
				------------------dma_memory(10)(8)------------------
		if Resetn = '0' then
			dma_memory(10)(8) <= '0';
		elsif rising_edge (Clk) then
			if state_IN = end_internal_IN then
				dma_memory(10)(8) <= '0';
			elsif state_IN = read_spi_IN and SPI_RDATA_i /= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
				dma_memory(10)(8) <= '1';
			else
			end if;
		end if;
						------------------dma_memory(10)(9)------------------
		if Resetn = '0' then
			dma_memory(10)(9) <= '0';
		elsif rising_edge (Clk) then
			if dma_memory(10)(9) = '1' then
				dma_memory(10)(9) <= '0';
			elsif APB_PENABLE_i = '1' and APB_PWRITE_i = '0' and state_APB = access_APB then
				dma_memory(10)(9) <= '1';
			else
			end if;
		end if;
								------------------dma_memory(10)(10)------------------
		if Resetn = '0' then
			dma_memory(10)(10) <= '0';
		elsif rising_edge (Clk) then
			if dma_memory(10)(10) = '1' then
				dma_memory(10)(10) <= '0';
			elsif state_IN = write_ram_IN then
				dma_memory(10)(10) <= '1';
			else
			end if;
		end if;
										------------------dma_memory(10)(11)------------------
		if Resetn = '0' then
			dma_memory(10)(11) <= '0';
		elsif rising_edge (Clk) then
			if dma_memory(10)(11) = '1' then
				dma_memory(10)(11) <= '0';
			elsif dma_memory(10)(10) = '1' then
				dma_memory(10)(11) <= '1';
			else
			end if;
		end if;
		------------------dma_memory(10)(11 to 31)------------------
		if Resetn = '0' then
			dma_memory(10)(31 downto 12) <= (others => '0');
		elsif rising_edge (Clk) then
			if state_APB = idle_APB then
				dma_memory(10)(31 downto 12) <= (others => '0');
			else
			end if;
		end if;
		
		
		------------------dma_memory(11 to 31)------------------
		if Resetn = '0' then
			dma_memory(11 to 31) <= (others => (others => '0'));
		elsif rising_edge (Clk) then
			if state_APB = idle_APB then
				dma_memory(11 to 31) <= (others => (others => '0'));
			else
			end if;
		end if;	
	
end process;

end architecture;