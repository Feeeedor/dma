library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.dma;    
use work.dma_tests;

entity dma_tb is
end entity dma_tb;

architecture tb_arch of dma_tb is

  
	signal wr_en_1    :  std_logic;   --write enable for port 1
	signal data_in_1  :  std_logic_vector(31 downto 0);  --Input data to port 1.  
   signal addr_in_1  :  std_logic_vector(31 downto 0);    --address for port 1  
   signal port_en_1  :  std_logic;   --enable port 1.
   signal data_out_1 :  std_logic_vector(31 downto 0);   --output data from port 1.
	 
   signal Clk     : std_logic ;
   signal Resetn  : std_logic ;
	
   signal APB_PADDR_i    : std_logic_vector(7 downto 0);
   signal APB_PENABLE_i  : std_logic ;
	signal APB_PSELx         :  STD_LOGIC;
   signal APB_PWRITE_i   : std_logic ;
   signal APB_PWDATA_i   : std_logic_vector(31 downto 0);
   signal APB_PREADY_o   : std_logic;
   signal APB_PRDATA_o   : std_logic_vector(31 downto 0);
	signal APB_PERROR_o      :  STD_LOGIC;
	
	signal o_tx_start_spi    :  STD_LOGIC;
   signal i_tx_end          :  STD_LOGIC;
   signal o_address         :  STD_LOGIC_VECTOR(31 downto 0);
   signal o_instruction     :  STD_LOGIC;
   signal i_data_parallel   :  STD_LOGIC_VECTOR(31 downto 0);
   signal o_data_parallel   :  STD_LOGIC_VECTOR(31 downto 0);
	signal i_error           :  STD_LOGIC; 
	
begin
	sim_dma: entity work.dma
		port map (
			Clk     => Clk,
         Resetn   => Resetn,
         APB_PADDR_i     => APB_PADDR_i,
			APB_PSELx       =>  APB_PSELx,
         APB_PENABLE_i   => APB_PENABLE_i,
         APB_PWRITE_i    => APB_PWRITE_i,
         APB_PWDATA_i    => APB_PWDATA_i,
         APB_PREADY_o    => APB_PREADY_o,
         APB_PRDATA_o    => APB_PRDATA_o,
			APB_PERROR_o    => APB_PERROR_o,
			SPI_START_o  => o_tx_start_spi,
			SPI_END_i        => i_tx_end,  
			SPI_ADDRESS_o       => o_address,  
			SPI_INSTRUCTION_o   => o_instruction,   
			SPI_RDATA_i => i_data_parallel, 
			SPI_WDATA_o => o_data_parallel,  
			SPI_ERROR_i         => i_error,  
			
			
			RAM_WRITE_o        => wr_en_1,
			RAM_WDATA_o       => data_in_1,
			RAM_ADDRESS_o    	 => addr_in_1,
			RAM_PORTENABLER_o    	 => port_en_1,
			RAM_RDATA_i      => data_out_1
         );


	tb_instance: entity work.dma_tests
		port map (
			Clk => Clk,
			Resetn  => Resetn,
			APB_PSELx =>  APB_PSELx,
			APB_PADDR_i    => APB_PADDR_i,
			APB_PENABLE_i  => APB_PENABLE_i,
			APB_PWRITE_i   => APB_PWRITE_i,
			APB_PWDATA_i   => APB_PWDATA_i,

			data_out_1 => data_out_1,
		
			i_tx_end => i_tx_end,
			i_data_parallel => i_data_parallel,
			i_error => i_error 
		  );

end architecture tb_arch;