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
	signal APB_PERROR_s : STD_LOGIC;
	
	signal DMA_Data_s :  STD_LOGIC_VECTOR(31 downto 0);
	signal DMA_Address_Source_s : std_logic_vector	 (31 downto 0);
	signal DMA_Address_Destination_s : std_logic_vector	 (31 downto 0);
	signal DMA_Task_Flags_s : std_logic_vector	 (31 downto 0);
	signal DMA_Task_Counter_s  : std_logic_vector	 (7 downto 0);
	signal DMA_Error_State_s : std_logic_vector	 (31 downto 0);

begin
	APB_PERROR_o <= APB_PERROR_s;
	APB_PREADY_o <= APB_PREADY_s;
	
	state_APB_proc:
	process (Clk,Resetn )
	begin 
		IF Resetn = '0'  then 
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
					elsif APB_PADDR_i = "00001000" and APB_PWDATA_i = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
						state_APB <= setup_APB;
					elsif APB_PREADY_s = '1' and  APB_PSELx='1' then
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
			if Resetn = '0' or APB_PERROR_s = '1' then 
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
						if(SPI_END_i = '1') or SPI_ERROR_i = '1' then
							state_SPI <= idle_SPI;
						end if;
							
				end case;
			end if;
	end process;
	
	state_IN_proc:
	process (Clk,Resetn, state_SPI, state_APB, DMA_Task_Counter_s, DMA_Address_Source_s, DMA_Address_Destination_s, DMA_Task_Flags_s(1), DMA_Data_s,APB_PERROR_s , SPI_ERROR_i)
		begin 
			IF Resetn = '0' then 
				state_IN <= idle_IN;
			ELSIF (rising_edge(Clk)) then
				if APB_PERROR_s = '1' then
					state_IN <= error_IN; 
				else
					CASE state_IN is 
						
						when  idle_IN =>
							if state_APB = access_APB and APB_PADDR_i = "00001000"  and APB_PENABLE_i = '1' then --енаблер строка зависимость сделать
								state_IN <= setup_IN;
							end if;	
							
						when setup_IN =>
							if DMA_Task_Counter_s = "00000000" 	or DMA_Task_Flags_s(0) = '1' then
								state_IN <= read_source_IN;
							else
								state_IN <= end_IN;
							end if;
							
						when read_source_IN =>	
							if DMA_Address_Source_s /= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" and DMA_Address_Source_s /= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU" then
								state_IN <= read_dest_IN;
							end if;
							
						when read_dest_IN =>
							if DMA_Address_Destination_s /= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" and DMA_Address_Destination_s /= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU" then
								state_IN <= read_flags_IN;
							end if;
							
						when read_flags_IN =>
							if DMA_Task_Flags_s /= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" and DMA_Task_Flags_s /= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU" then
								if DMA_Task_Flags_s(1) = '1' then
									state_IN <= read_ram_spi_IN;
								else
									state_IN <= setup_read_spi_IN;
								end if;
							end if;
						
						when read_ram_spi_IN =>
							if DMA_Data_s /= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" and DMA_Data_s /= "UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU" then
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
							if state_SPI = idle_SPI then 
								state_IN <= write_ram_IN;
							elsif SPI_ERROR_i = '1' then 
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
			end if;
	end process;
	
	proces_sig: 
	process (state_APB, state_SPI, state_IN)
	begin
		----------------------------------DMA_Task_Counter_s----------------------------
		if  state_IN = idle_IN then
			DMA_Task_Counter_s <= "00000000";
		elsif  state_IN = end_internal_IN then
			DMA_Task_Counter_s <= std_logic_vector(unsigned(DMA_Task_Counter_s) + 1);
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
		if  APB_PWRITE_i = '0' and  state_APB = access_APB then
			APB_PRDATA_o <=  dma_memory(to_integer(unsigned(APB_PADDR_i)));
		else
			APB_PRDATA_o <= (others => 'Z');
		end if;
	      ----------------------------RAM_PORTENABLER_o-----------------
		if state_IN = read_source_IN or state_IN = read_dest_IN or state_IN = read_flags_IN or state_IN = read_ram_spi_IN or state_IN = write_ram_IN then
			RAM_PORTENABLER_o <= '1';
		else
			RAM_PORTENABLER_o <= '0';
		end if;
			----------------------------------RAM_ADDRESS_o-----------------
		if state_IN = read_source_IN then
			RAM_ADDRESS_o <= std_logic_vector(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 3*unsigned(DMA_Task_Counter_s));
		elsif state_IN = read_dest_IN then
			RAM_ADDRESS_o <= std_logic_vector(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 1 + 3*unsigned(DMA_Task_Counter_s));
		elsif state_IN = read_flags_IN then
			RAM_ADDRESS_o <= std_logic_vector(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 2 + 3*unsigned(DMA_Task_Counter_s));
		elsif state_IN = read_ram_spi_IN then
			RAM_ADDRESS_o <= DMA_Address_Source_s;
		elsif state_IN = write_ram_IN then
			RAM_ADDRESS_o <= DMA_Address_Destination_s;
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
			RAM_WDATA_o <= DMA_Data_s;
		else
			RAM_WDATA_o <= (others => 'Z');
		end if;
		----------------------------------SPI_START_o-----------------
		if state_IN = read_spi_IN or state_IN = write_spi_IN then
			SPI_START_o <= '1';
		elsif state_SPI = idle_SPI then
			SPI_START_o <= '0';
		end if;
		----------------------------------SPI_ADDRESS_o-----------------
		if state_IN = write_SPI_IN then
			SPI_ADDRESS_o <= DMA_Address_Destination_s;
		elsif state_IN = read_SPI_IN then 
			SPI_ADDRESS_o <= DMA_Address_Source_s;
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
		if state_IN = write_SPI_IN then
			SPI_WDATA_o <= DMA_Data_s;
		else
			SPI_WDATA_o <=  (others => 'Z');
		end if;
	end process;   
 
	proces_sig_command: 
	process (Clk, state_APB, state_SPI, state_IN)
	begin
		----------------------------------DMA_Address_Source_s-----------------------------------------
		if  state_IN = idle_IN then
			DMA_Address_Source_s <= (others => 'Z');
		elsif  state_IN = end_internal_IN then
			DMA_Address_Source_s <= (others => 'Z');
		elsif state_IN = read_source_IN and DMA_Address_Source_s = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
			DMA_Address_Source_s <= RAM_RDATA_i;
		end if;
			----------------------------------DMA_Address_Destination_s-----------------------------------------
		if  state_IN = idle_IN then
			DMA_Address_Destination_s <=  (others => 'Z');
		elsif  state_IN = end_internal_IN then
			DMA_Address_Destination_s <= (others => 'Z');
		elsif state_IN = read_dest_IN and DMA_Address_Destination_s = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"  then
			DMA_Address_Destination_s <= RAM_RDATA_i;
		end if;
			----------------------------------DMA_Task_Flags_s-----------------------------------------
		if  state_IN = idle_IN then
			DMA_Task_Flags_s <=  (others => 'Z');
		elsif  state_IN = read_source_IN then
			DMA_Task_Flags_s <= (others => 'Z');
		elsif state_IN = read_flags_IN  and DMA_Task_Flags_s = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
			DMA_Task_Flags_s <= RAM_RDATA_i;
		end if; 
		----------------------------------DMA_Data_s----------------------------
		if  state_SPI = exchange_SPI  and state_IN = read_spi_IN then
			DMA_Data_s <= SPI_RDATA_i;
		elsif  state_IN = read_ram_spi_IN and DMA_Data_s = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
			DMA_Data_s <= RAM_RDATA_i;
		elsif  state_IN = setup_IN then  
			DMA_Data_s <=  (others => 'Z');
		elsif  state_APB = idle_APB then  
			DMA_Data_s <=  (others => 'Z');
		end if;	
			----------------------------------APB_PERROR_s----------------------------
		if state_APB = idle_APB then 
			APB_PERROR_s <= '0';
		elsif DMA_Error_State_s /= x"00000000" then	
			APB_PERROR_s <= '1';
		else
			APB_PERROR_s <= '0';
		end if;	
				----------------------------------DMA_Error_State_s----------------------------
		if state_APB = idle_APB then 
			DMA_Error_State_s <= x"00000000";
		elsif  state_IN /= error_IN and state_APB = setup_APB and APB_PADDR_i /= "00000110" and APB_PADDR_i /= "00000111" and APB_PADDR_i /= "00001000" and APB_PWRITE_i = '1' then	
			DMA_Error_State_s <= x"00000001";
		elsif  state_IN /= error_IN and state_APB = setup_APB and APB_PADDR_i = "00001000"  and dma_memory(6) = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then	
			DMA_Error_State_s <= x"00000002";
		elsif state_IN /= error_IN and state_APB = access_APB then 
			if  APB_PADDR_i = "00001000"  and dma_memory(7) = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
				DMA_Error_State_s <= x"00000003";
			elsif  APB_PADDR_i = "00001000"  and to_integer(unsigned(dma_memory(6))) >= to_integer(unsigned(dma_memory(7))) then
				DMA_Error_State_s <= x"00000004";
			elsif  DMA_Task_Counter_s =  "11111111" and state_IN = read_source_IN then
				DMA_Error_State_s <= x"00000005";	
			elsif ( to_integer(unsigned(dma_memory(6))) > to_integer(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 3*unsigned(DMA_Task_Counter_s)) or	 to_integer(unsigned(dma_memory(7))) < to_integer(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 3*unsigned(DMA_Task_Counter_s))) and (state_IN = read_source_IN) then
				DMA_Error_State_s <= x"00000006";
			elsif ( to_integer(unsigned(dma_memory(6))) > to_integer(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 1 + 3*unsigned(DMA_Task_Counter_s)) or	 to_integer(unsigned(dma_memory(7))) < to_integer(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 1 + 3*unsigned(DMA_Task_Counter_s)) ) and state_IN = read_dest_IN then
				DMA_Error_State_s <= x"00000007";
			elsif ( to_integer(unsigned(dma_memory(6))) > to_integer(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 2 + 3*unsigned(DMA_Task_Counter_s)) 	or to_integer(unsigned(dma_memory(7))) < to_integer(unsigned(dma_memory(to_integer(unsigned(APB_PADDR_i)))) + 2 + 3*unsigned(DMA_Task_Counter_s)) ) and state_IN = read_flags_IN then
				DMA_Error_State_s <= x"00000008";
			elsif ( to_integer(unsigned(dma_memory(6))) > to_integer(unsigned(dma_memory(2)))  or	 to_integer(unsigned(dma_memory(7))) < to_integer(unsigned(dma_memory(2))))  and state_IN = read_ram_spi_IN then
				DMA_Error_State_s <= x"00000009";	
			elsif  (SPI_ERROR_i =  '1' and state_spi = wait_spi and state_in = write_spi_IN) or DMA_Error_State_s = x"0000000A" then
				DMA_Error_State_s <= x"0000000A";
			elsif  SPI_ERROR_i =  '1' and state_spi = wait_spi and state_in = read_spi_IN then
				DMA_Error_State_s <= x"0000000B";
			elsif  SPI_ERROR_i =  '1' and state_spi = exchange_spi and state_in = read_spi_IN  then
				DMA_Error_State_s <= x"0000000C";
			elsif  SPI_ERROR_i =  '1' and state_spi = exchange_spi and state_in = write_spi_IN  then
				DMA_Error_State_s <= x"0000000D";
			elsif ( to_integer(unsigned(dma_memory(6))) > to_integer(unsigned(dma_memory(3)))  or	 to_integer(unsigned(dma_memory(7))) < to_integer(unsigned(dma_memory(3))))  and state_IN = write_ram_IN then
				DMA_Error_State_s <= x"0000000E";
			else
				DMA_Error_State_s <= x"00000000";
			end if;
		end if;
	end process;  
	
	proces_dma_memory:
	process (state_APB, APB_PADDR_i, DMA_Task_Counter_s, DMA_Error_State_s, DMA_Address_Source_s, DMA_Address_Destination_s, DMA_Task_Flags_s, DMA_Data_s)
	begin
		if  state_IN /= error_IN then	
			if  state_APB = idle_APB then
				dma_memory <=  (others => (others => 'Z'));
			else
				dma_memory(0) <= DMA_Error_State_s;
				dma_memory(1) <= DMA_Task_Counter_s & "000000000000000000000000";
				dma_memory(2) <= DMA_Address_Source_s;
				dma_memory(3) <= DMA_Address_Destination_s;
				dma_memory(4) <= DMA_Task_Flags_s;
				dma_memory(5) <= DMA_Data_s;
				if state_APB = access_APB and APB_PWRITE_i = '1' and APB_PADDR_i = "00000110" then
					dma_memory(to_integer(unsigned(APB_PADDR_i))) <= APB_PWDATA_i;
				elsif state_APB = access_APB and APB_PWRITE_i = '1' and APB_PADDR_i = "00000111" then
					dma_memory(to_integer(unsigned(APB_PADDR_i))) <= APB_PWDATA_i;
				elsif state_APB = access_APB and APB_PWRITE_i = '1' and APB_PADDR_i = "00001000" then
					dma_memory(to_integer(unsigned(APB_PADDR_i))) <= APB_PWDATA_i;
				end if;
			end if;
		end if;
	end process;  
end architecture;