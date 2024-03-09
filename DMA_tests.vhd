library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity dma_tests is
port (    
	Clk        : out STD_LOGIC;
   Resetn     : out STD_LOGIC;
	APB_PSELx         : out STD_LOGIC;
	APB_PADDR_i       : out STD_LOGIC_VECTOR(7 downto 0);
	APB_PENABLE_i     : out STD_LOGIC;
	APB_PWRITE_i      : out STD_LOGIC;
	APB_PWDATA_i      : out STD_LOGIC_VECTOR(31 downto 0);
	
	data_out_1 : out std_logic_vector(31 downto 0);
	
   i_tx_end          :  out STD_LOGIC;
	i_data_parallel   :  out STD_LOGIC_VECTOR(31 downto 0);
	i_error           :  out STD_LOGIC
);
end entity;

architecture test of dma_tests is
CONSTANT second 	: TIME := 10 us;
signal Clk_s : std_logic;

begin
synchronizer : PROCESS 
BEGIN
	Clk_s <= '0';
	WAIT FOR second;
	Clk_s <= '1';
	WAIT FOR second;
END PROCESS;
Clk<=Clk_s;
process 
begin
	i_tx_end <= '0';
	i_data_parallel <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	i_error <='0';
	data_out_1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	Resetn <= '0';
	APB_PSELx <= 'Z';
	APB_PADDR_i <="ZZZZZZZZ";
	APB_PENABLE_i <= 'Z';
	APB_PWRITE_i <= 'Z';
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait for 10 ns;
Resetn <= '1';	
   wait until rising_edge(Clk_s);--1	 
   APB_PSELx <= '1';
	APB_PADDR_i <="00000110";
	APB_PWRITE_i <= '1';
	APB_PWDATA_i<=x"00000010";
	wait until rising_edge(Clk_s);--2
	wait until rising_edge(Clk_s);--3
	APB_PADDR_i <= "00000111";
	APB_PWRITE_i <= '1';
	APB_PWDATA_i<= x"000000F0";
	wait until rising_edge(Clk_s);--4
	wait until rising_edge(Clk_s);--5
	APB_PADDR_i <="00001000";
	APB_PWRITE_i <= '1';
	APB_PWDATA_i<=x"00000011";
	wait until rising_edge(Clk_s);--6
	APB_PENABLE_i <= '1';
	wait until rising_edge(Clk_s);--7
	data_out_1 <= x"00000020";
	wait until rising_edge(Clk_s);--8
	data_out_1 <= x"00000030";
   wait until rising_edge(Clk_s);--9
	data_out_1 <= x"00000000";
	wait until rising_edge(Clk_s);--10
	data_out_1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--11
	wait until rising_edge(Clk_s);--12
	wait until rising_edge(Clk_s);--13
	i_tx_end <= '1';
	wait for 10 ns;
	i_tx_end <= '0';
	i_data_parallel <= x"00000300";
	wait until rising_edge(Clk_s);--14
	i_tx_end <= '1';
	wait for 10 ns;
	i_tx_end <= '0';
	i_data_parallel <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	
	
	wait until rising_edge(Clk_s);--15
	wait until rising_edge(Clk_s);--16
	APB_PSELx <= '0';
	wait until rising_edge(Clk_s);--17
	wait until rising_edge(Clk_s);--18
	wait until rising_edge(Clk_s);--19
	i_tx_end <= '0';
	i_data_parallel <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	i_error <='0';
	data_out_1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	Resetn <= '0';
	APB_PSELx <= 'Z';
	APB_PADDR_i <="ZZZZZZZZ";
	APB_PENABLE_i <= 'Z';
	APB_PWRITE_i <= 'Z';
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait for 10 ns;
	Resetn <= '1';
	wait until rising_edge(Clk_s);--1
	 APB_PSELx <= '1';
	APB_PADDR_i <="00000110";
	APB_PWRITE_i <= '1';
	APB_PWDATA_i<=x"00000010";
	wait until rising_edge(Clk_s);--2
	wait until rising_edge(Clk_s);--3
	APB_PADDR_i <= "00000111";
	APB_PWRITE_i <= '1';
	APB_PWDATA_i<= x"000000F0";
	wait until rising_edge(Clk_s);--4
	wait until rising_edge(Clk_s);--5
	APB_PADDR_i <="00001000";
	APB_PWRITE_i <= '1';
	APB_PWDATA_i<=x"00000011";
	wait until rising_edge(Clk_s);--6
	APB_PENABLE_i <= '1';
	wait until rising_edge(Clk_s);--7
	data_out_1 <= x"00000020";
	wait until rising_edge(Clk_s);--8
	data_out_1 <= x"00000030";
   wait until rising_edge(Clk_s);--9
	data_out_1 <= x"00000002";
	wait until rising_edge(Clk_s);--10
	data_out_1 <= x"00111000";
	wait until rising_edge(Clk_s);--11
	data_out_1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--12
	wait until rising_edge(Clk_s);--13
	i_tx_end <= '1';
	wait for 10 ns;
	i_tx_end <= '0';
	wait until rising_edge(Clk_s);--14
	i_tx_end <= '1';
	wait for 10 ns;
	i_tx_end <= '0';
	
	
	
	wait until rising_edge(Clk_s);--15
	wait until rising_edge(Clk_s);--16
	APB_PSELx <= '0';
	wait until rising_edge(Clk_s);--17
	wait until rising_edge(Clk_s);--18
	wait until rising_edge(Clk_s);--19
	i_tx_end <= '0';
	i_error <='0';
	data_out_1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	Resetn <= '0';
	APB_PSELx <= 'Z';
	APB_PADDR_i <="ZZZZZZZZ";
	APB_PENABLE_i <= 'Z';
	APB_PWRITE_i <= 'Z';
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait for 10 ns;
	Resetn <= '1';
	wait until rising_edge(Clk_s);--
wait;
end process;


   
end architecture;