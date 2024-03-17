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
constant second 	: time := 10 ns;
signal Clk_s : std_logic;

begin

synchronizer:
process 
begin
	Clk_s <= '0';
	wait for second;
	Clk_s <= '1';
	wait for second;
end process;

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
	APB_PENABLE_i <= '0';
	APB_PWRITE_i <= 'Z';
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait for 10 ns;
	Resetn <= '1';	
	---------------------------MRAMtoRAM------------------------------
   wait until rising_edge(Clk_s);--1	 
   APB_PSELx <= '1';
	APB_PADDR_i <="00000111";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--2
	APB_PWDATA_i<=x"00000010";
	wait until rising_edge(Clk_s);--3
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00001000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"000000F0";
	wait until rising_edge(Clk_s);--5
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <="00001001";
	wait until rising_edge(Clk_s);--4
	APB_PWRITE_i <= '1';
	APB_PWDATA_i<=x"00000011";
	wait until rising_edge(Clk_s);--6
	APB_PENABLE_i <= '1';
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00000000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"00000001";
	wait until rising_edge(Clk_s);--5
	APB_PWRITE_i <= 'Z' ;
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--8
	data_out_1 <= x"00000020";
	wait until rising_edge(Clk_s);--9
	wait until rising_edge(Clk_s);--9
	data_out_1 <= x"00000030";
   wait until rising_edge(Clk_s);--10
	wait until rising_edge(Clk_s);--10
	data_out_1 <= x"00000000";
	wait until rising_edge(Clk_s);--11
	wait until rising_edge(Clk_s);--11
	data_out_1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--12
	wait until rising_edge(Clk_s);--13
	wait until rising_edge(Clk_s);--14
	 wait until rising_edge(Clk_s);--1
	  wait until rising_edge(Clk_s);--1
	   wait until rising_edge(Clk_s);--1
	i_tx_end <= '1';
	wait for 10 ns;
	i_tx_end <= '0';
		 wait until rising_edge(Clk_s);--1
	  wait until rising_edge(Clk_s);--1
	   wait until rising_edge(Clk_s);--1
	i_data_parallel <= x"00000300";
	wait until rising_edge(Clk_s);--15
	i_tx_end <= '1';
	wait for 10 ns;
	i_tx_end <= '0';
	i_data_parallel <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--16
	wait until rising_edge(Clk_s);--17
	APB_PSELx <= '0';
	wait until rising_edge(Clk_s);--18
	wait until rising_edge(Clk_s);--19
	wait until rising_edge(Clk_s);--20
	i_tx_end <= '0';
	i_data_parallel <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	i_error <='0';
	data_out_1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	Resetn <= '0';
	APB_PSELx <= 'Z';
	APB_PADDR_i <="ZZZZZZZZ";
	APB_PENABLE_i <= '0';
	APB_PWRITE_i <= 'Z';
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--21
	wait until rising_edge(Clk_s);--22
	wait until rising_edge(Clk_s);--23
	wait until rising_edge(Clk_s);--24
	wait for 10 ns;
	Resetn <= '1';
	-----------------------RAMtoMRAM-----------------------------------------
	wait until rising_edge(Clk_s);--1	 
   APB_PSELx <= '1';
	APB_PADDR_i <="00000111";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--2
	APB_PWDATA_i<=x"00000010";
	wait until rising_edge(Clk_s);--3
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00001000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"000000F0";
	wait until rising_edge(Clk_s);--5
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <="00001001";
	wait until rising_edge(Clk_s);--4
	APB_PWRITE_i <= '1';
	APB_PWDATA_i<=x"00000011";
	wait until rising_edge(Clk_s);--6
	APB_PENABLE_i <= '1';
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00000000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"00000001";
	wait until rising_edge(Clk_s);--5
	APB_PWRITE_i <= 'Z' ;
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--8
	data_out_1 <= x"00000020";
	wait until rising_edge(Clk_s);--8
	wait until rising_edge(Clk_s);--8
	data_out_1 <= x"00000030";
   wait until rising_edge(Clk_s);--9
	wait until rising_edge(Clk_s);--9
	data_out_1 <= x"00000002";
	wait until rising_edge(Clk_s);--10
	wait until rising_edge(Clk_s);--10
	data_out_1 <= x"00111000";
	wait until rising_edge(Clk_s);--11
	wait until rising_edge(Clk_s);--11
	data_out_1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--12
	wait until rising_edge(Clk_s);--13
		 wait until rising_edge(Clk_s);--1
	  wait until rising_edge(Clk_s);--1
	   wait until rising_edge(Clk_s);--1
	i_tx_end <= '1';
	wait for 10 ns;
	i_tx_end <= '0';
		 wait until rising_edge(Clk_s);--1
	  wait until rising_edge(Clk_s);--1
	   wait until rising_edge(Clk_s);--1
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
	wait until rising_edge(Clk_s);--20
	wait until rising_edge(Clk_s);--21
	wait until rising_edge(Clk_s);--22
	wait until rising_edge(Clk_s);--23
	-----------------------------------MRAMtoRAM and RAMtoMRAM-------------------------------
	 wait until rising_edge(Clk_s);--1	 
   APB_PSELx <= '1';
	APB_PADDR_i <="00000111";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--2
	APB_PWDATA_i<=x"00000010";
	wait until rising_edge(Clk_s);--3
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00001000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"000000F0";
	wait until rising_edge(Clk_s);--5
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <="00001001";
	wait until rising_edge(Clk_s);--4
	APB_PWRITE_i <= '1';
	APB_PWDATA_i<=x"00000011";
	wait until rising_edge(Clk_s);--6
	APB_PENABLE_i <= '1';
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00000000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"00000001";
	wait until rising_edge(Clk_s);--5
	APB_PWRITE_i <= 'Z' ;
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--8
	data_out_1 <= x"00000020";
	wait until rising_edge(Clk_s);--9
	wait until rising_edge(Clk_s);--9
	data_out_1 <= x"00000030";
   wait until rising_edge(Clk_s);--10
	wait until rising_edge(Clk_s);--9
	data_out_1 <= x"00000001";
	wait until rising_edge(Clk_s);--11
	wait until rising_edge(Clk_s);--9
	data_out_1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--12
	wait until rising_edge(Clk_s);--13
	wait until rising_edge(Clk_s);--14
		 wait until rising_edge(Clk_s);--1
	  wait until rising_edge(Clk_s);--1
	   wait until rising_edge(Clk_s);--1
	i_tx_end <= '1';
	wait for 10 ns;
	i_tx_end <= '0';
		 wait until rising_edge(Clk_s);--1
	  wait until rising_edge(Clk_s);--1
	   wait until rising_edge(Clk_s);--1
	i_data_parallel <= x"00000300";
	wait until rising_edge(Clk_s);--15
	i_tx_end <= '1';
	wait for 10 ns;
	i_tx_end <= '0';
	i_data_parallel <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--16
	wait until rising_edge(Clk_s);--17
	wait until rising_edge(Clk_s);--18
	wait until rising_edge(Clk_s);--19
	data_out_1 <= x"00000020";
	wait until rising_edge(Clk_s);--20
	wait until rising_edge(Clk_s);--9
	data_out_1 <= x"00000030";
   wait until rising_edge(Clk_s);--21
	wait until rising_edge(Clk_s);--9
	data_out_1 <= x"00000002";
	wait until rising_edge(Clk_s);--22
	wait until rising_edge(Clk_s);--9
	data_out_1 <= x"00111000";
	wait until rising_edge(Clk_s);--23
	wait until rising_edge(Clk_s);--9
	data_out_1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--24
	wait until rising_edge(Clk_s);--25
		 wait until rising_edge(Clk_s);--1
	  wait until rising_edge(Clk_s);--1
	   wait until rising_edge(Clk_s);--1
	i_tx_end <= '1';
	wait for 10 ns;
	i_tx_end <= '0';
		 wait until rising_edge(Clk_s);--1
	  wait until rising_edge(Clk_s);--1
	   wait until rising_edge(Clk_s);--1
	wait until rising_edge(Clk_s);--26
	i_tx_end <= '1';
	wait for 10 ns;
	i_tx_end <= '0';
	wait until rising_edge(Clk_s);--27
	wait until rising_edge(Clk_s);--28
	APB_PSELx <= '0';
	wait until rising_edge(Clk_s);--29
	wait until rising_edge(Clk_s);--30
	wait until rising_edge(Clk_s);--31
	wait until rising_edge(Clk_s);--32
	wait until rising_edge(Clk_s);--33
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
	wait until rising_edge(Clk_s);--34
	wait until rising_edge(Clk_s);--35
	wait until rising_edge(Clk_s);--36
	wait until rising_edge(Clk_s);--37
	wait for 10 ns;
	Resetn <= '1';
		-----------------------------чтение0-------------------------
	wait until rising_edge(Clk_s);--1	 
   APB_PSELx <= '1';
	APB_PADDR_i <="00000000";
	APB_PWRITE_i <= '0';
	wait until rising_edge(Clk_s);--2
	wait until rising_edge(Clk_s);--3
	APB_PSELx <= 'Z';
	APB_PADDR_i <="ZZZZZZZZ";
	APB_PWRITE_i <= 'Z';
	Resetn <= '0';
	wait until rising_edge(Clk_s);--7
	wait until rising_edge(Clk_s);--8
	wait until rising_edge(Clk_s);--9
	wait until rising_edge(Clk_s);--10
	wait for 10 ns;
	Resetn <= '1';
			-----------------------------чтение1-------------------------
	wait until rising_edge(Clk_s);--1	 
   APB_PSELx <= '1';
	APB_PADDR_i <="00000001";
	APB_PWRITE_i <= '0';
	wait until rising_edge(Clk_s);--2
	wait until rising_edge(Clk_s);--3
	APB_PSELx <= 'Z';
	APB_PADDR_i <="ZZZZZZZZ";
	APB_PWRITE_i <= 'Z';
	Resetn <= '0';
	wait until rising_edge(Clk_s);--7
	wait until rising_edge(Clk_s);--8
	wait until rising_edge(Clk_s);--9
	wait until rising_edge(Clk_s);--10
	wait for 10 ns;
	Resetn <= '1';
			-----------------------------чтение2-------------------------
	wait until rising_edge(Clk_s);--1	 
   APB_PSELx <= '1';
	APB_PADDR_i <="00000010";
	APB_PWRITE_i <= '0';
	wait until rising_edge(Clk_s);--2
	wait until rising_edge(Clk_s);--3
	APB_PSELx <= 'Z';
	APB_PADDR_i <="ZZZZZZZZ";
	APB_PWRITE_i <= 'Z';
	Resetn <= '0';
	wait until rising_edge(Clk_s);--7
	wait until rising_edge(Clk_s);--8
	wait until rising_edge(Clk_s);--9
	wait until rising_edge(Clk_s);--10
	wait for 10 ns;
	Resetn <= '1';
	-----------------------------0b0001-------------------------
	wait until rising_edge(Clk_s);--1	 
   APB_PSELx <= '1';
	APB_PADDR_i <="00010000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--2
	APB_PWDATA_i<=x"00000010";
	wait until rising_edge(Clk_s);--3
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <="00000001";
	APB_PWRITE_i <= '0';
	wait until rising_edge(Clk_s);--4
	wait until rising_edge(Clk_s);--5
	APB_PSELx <= 'Z';
	APB_PADDR_i <="ZZZZZZZZ";
	APB_PWRITE_i <= 'Z';
	wait until rising_edge(Clk_s);--6
	Resetn <= '0';
	wait until rising_edge(Clk_s);--7
	wait until rising_edge(Clk_s);--8
	wait until rising_edge(Clk_s);--9
	wait until rising_edge(Clk_s);--10
	wait for 10 ns;
	Resetn <= '1';
	---------------------0b0010 ---------------------------
	wait until rising_edge(Clk_s);--1	 
   APB_PSELx <= '1';
	APB_PADDR_i <="00001001";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--2
	APB_PWDATA_i<=x"00000010";
	wait until rising_edge(Clk_s);--3
	APB_PENABLE_i <= '1';
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00000000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"00000001";
	wait until rising_edge(Clk_s);--5
	APB_PWRITE_i <= 'Z' ;
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--4
	APB_PADDR_i <="00000001";
	APB_PWRITE_i <= '0';
	wait until rising_edge(Clk_s);--4
	wait until rising_edge(Clk_s);--5
	APB_PENABLE_i <= '0';
	APB_PSELx <= 'Z';
	APB_PADDR_i <="ZZZZZZZZ";
	APB_PWRITE_i <= 'Z';
	wait until rising_edge(Clk_s);--6
	Resetn <= '0';
	wait until rising_edge(Clk_s);--7
	wait until rising_edge(Clk_s);--8
	wait until rising_edge(Clk_s);--9
	wait until rising_edge(Clk_s);--10
	wait for 10 ns;
	Resetn <= '1';
	---------------------0b0011---------------------------
	wait until rising_edge(Clk_s);--1	 
   APB_PSELx <= '1';
	APB_PADDR_i <="00000111";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--2
	APB_PWDATA_i<=x"00000010";
	wait until rising_edge(Clk_s);--3
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <="00001001";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<=x"00000110";
	wait until rising_edge(Clk_s);--5
	APB_PENABLE_i <= '1';
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00000000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"00000001";
	wait until rising_edge(Clk_s);--5
	APB_PWRITE_i <= 'Z' ;
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--4
	APB_PADDR_i <="00000001";
	APB_PWRITE_i <= '0';
	wait until rising_edge(Clk_s);--6
	wait until rising_edge(Clk_s);--7
	APB_PSELx <= 'Z';
	APB_PADDR_i <="ZZZZZZZZ";
	APB_PWRITE_i <= 'Z';
	APB_PENABLE_i <= '0';
	wait until rising_edge(Clk_s);--8
	Resetn <= '0';
	wait until rising_edge(Clk_s);--9
	wait until rising_edge(Clk_s);--10
	wait until rising_edge(Clk_s);--11
	wait until rising_edge(Clk_s);--12
	wait for 10 ns;
	Resetn <= '1';
	---------------------0b0100---------------------------
	wait until rising_edge(Clk_s);--1	 
   APB_PSELx <= '1';
	APB_PADDR_i <="00000111";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--2
	APB_PWDATA_i<=x"00000110";
	wait until rising_edge(Clk_s);--3
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00001000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"000000F0";
	wait until rising_edge(Clk_s);--5
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <="00001001";
	wait until rising_edge(Clk_s);--6
	APB_PWRITE_i <= '1';
	APB_PWDATA_i<=x"00000011";
	wait until rising_edge(Clk_s);--7
	APB_PENABLE_i <= '1';
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00000000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"00000001";
	wait until rising_edge(Clk_s);--5
	APB_PWRITE_i <= 'Z' ;
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--4
	APB_PADDR_i <="00000001";
	APB_PWRITE_i <= '0';
	wait until rising_edge(Clk_s);--8
	wait until rising_edge(Clk_s);--9
	APB_PSELx <= 'Z';
	APB_PADDR_i <="ZZZZZZZZ";
	APB_PWRITE_i <= 'Z';
	APB_PENABLE_i <= '0';
	wait until rising_edge(Clk_s);--10
	Resetn <= '0';
	wait until rising_edge(Clk_s);--11
	wait until rising_edge(Clk_s);--12
	wait until rising_edge(Clk_s);--13
	wait until rising_edge(Clk_s);--14
	wait for 10 ns;
	Resetn <= '1';
	---------------------0b0110---------------------------
	wait until rising_edge(Clk_s);--1	 
   APB_PSELx <= '1';
	APB_PADDR_i <="00000111";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--2
	APB_PWDATA_i<=x"00000010";
	wait until rising_edge(Clk_s);--3
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00001000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"000000F0";
	wait until rising_edge(Clk_s);--5
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <="00001001";
	wait until rising_edge(Clk_s);--6
	APB_PWRITE_i <= '1';
	APB_PWDATA_i<=x"00000111";
	wait until rising_edge(Clk_s);--7
	APB_PENABLE_i <= '1';
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00000000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--8
	APB_PWDATA_i<= x"00000001";
	wait until rising_edge(Clk_s);--9
	APB_PWRITE_i <= 'Z' ;
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--10
	data_out_1 <= x"00000020";
	wait until rising_edge(Clk_s);--11
	wait until rising_edge(Clk_s);--12
	data_out_1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PENABLE_i <= 'Z';
	APB_PADDR_i <="00000001";
	APB_PWRITE_i <= '0';
	wait until rising_edge(Clk_s);--13
	wait until rising_edge(Clk_s);--14
	APB_PSELx <= 'Z';
	APB_PADDR_i <="ZZZZZZZZ";
	APB_PWRITE_i <= 'Z';
	APB_PENABLE_i <= '0';
	wait until rising_edge(Clk_s);--15
	Resetn <= '0';
	wait until rising_edge(Clk_s);--16
	wait until rising_edge(Clk_s);--17
	wait until rising_edge(Clk_s);--18
	wait until rising_edge(Clk_s);--19
	wait for 10 ns;
	Resetn <= '1';
	---------------------0b0111---------------------------
	wait until rising_edge(Clk_s);--1	 
   APB_PSELx <= '1';
	APB_PADDR_i <="00000111";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--2
	APB_PWDATA_i<=x"00000010";
	wait until rising_edge(Clk_s);--3
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00001000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"000000F0";
	wait until rising_edge(Clk_s);--5
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <="00001001";
	wait until rising_edge(Clk_s);--4
	APB_PWRITE_i <= '1';
	APB_PWDATA_i<=x"000000F0";
	wait until rising_edge(Clk_s);--6
		APB_PENABLE_i <= '1';
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00000000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"00000001";
	wait until rising_edge(Clk_s);--5
	APB_PWRITE_i <= 'Z' ;
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--8
	data_out_1 <= x"00000020";
	wait until rising_edge(Clk_s);--8
	wait until rising_edge(Clk_s);--9
	data_out_1 <= x"00000030";
   wait until rising_edge(Clk_s);--10
	wait until rising_edge(Clk_s);--10
	data_out_1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
		APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PENABLE_i <= 'Z';
	APB_PADDR_i <="00000001";
	APB_PWRITE_i <= '0';
	wait until rising_edge(Clk_s);--12
	wait until rising_edge(Clk_s);--11
	APB_PSELx <= 'Z';
	APB_PADDR_i <="ZZZZZZZZ";
	APB_PWRITE_i <= 'Z';
	APB_PENABLE_i <= '0';
	wait until rising_edge(Clk_s);--11
	Resetn <= '0';
	wait until rising_edge(Clk_s);--12
	wait until rising_edge(Clk_s);--13
	wait until rising_edge(Clk_s);--14
	wait until rising_edge(Clk_s);--15
	wait for 10 ns;
	Resetn <= '1';
	---------------------------0b1000------------------------------
	wait until rising_edge(Clk_s);--1	 
   APB_PSELx <= '1';
	APB_PADDR_i <="00000111";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--2
	APB_PWDATA_i<=x"00000010";
	wait until rising_edge(Clk_s);--3
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00001000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"000000F0";
	wait until rising_edge(Clk_s);--5
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <="00001001";
	wait until rising_edge(Clk_s);--4
	APB_PWRITE_i <= '1';
	APB_PWDATA_i<=x"000000EF";
	wait until rising_edge(Clk_s);--6
		APB_PENABLE_i <= '1';
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00000000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"00000001";
	wait until rising_edge(Clk_s);--5
	APB_PWRITE_i <= 'Z' ;
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--8
	data_out_1 <= x"00000020";
	wait until rising_edge(Clk_s);--8
	wait until rising_edge(Clk_s);--8
	data_out_1 <= x"00000030";
   wait until rising_edge(Clk_s);--8
	wait until rising_edge(Clk_s);--9
	data_out_1 <= x"00000000";
   wait until rising_edge(Clk_s);--10
	wait until rising_edge(Clk_s);--10
	data_out_1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
		APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PENABLE_i <= 'Z';
	APB_PADDR_i <="00000001";
	APB_PWRITE_i <= '0';
	wait until rising_edge(Clk_s);--12
	wait until rising_edge(Clk_s);--12
	APB_PSELx <= 'Z';
	APB_PADDR_i <="ZZZZZZZZ";
	APB_PWRITE_i <= 'Z';
	APB_PENABLE_i <= '0';
	wait until rising_edge(Clk_s);--11
	Resetn <= '0';
	wait until rising_edge(Clk_s);--12
	wait until rising_edge(Clk_s);--13
	wait until rising_edge(Clk_s);--14
	wait until rising_edge(Clk_s);--15
	wait for 10 ns;
	Resetn <= '1';
	-----------------------0b1001-----------------------------------------
	wait until rising_edge(Clk_s);--1	 
   APB_PSELx <= '1';
	APB_PADDR_i <="00000111";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--2
	APB_PWDATA_i<=x"00000010";
	wait until rising_edge(Clk_s);--3
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00001000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"000000F0";
	wait until rising_edge(Clk_s);--5
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <="00001001";
	wait until rising_edge(Clk_s);--4
	APB_PWRITE_i <= '1';
	APB_PWDATA_i<=x"00000011";
	wait until rising_edge(Clk_s);--6
		APB_PENABLE_i <= '1';
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00000000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"00000001";
	wait until rising_edge(Clk_s);--5
	APB_PWRITE_i <= 'Z' ;
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--8
	data_out_1 <= x"00000120";
	wait until rising_edge(Clk_s);--8
	wait until rising_edge(Clk_s);--8
	data_out_1 <= x"00000030";
   wait until rising_edge(Clk_s);--9
	wait until rising_edge(Clk_s);--9
	data_out_1 <= x"00000002";
	wait until rising_edge(Clk_s);--10
	wait until rising_edge(Clk_s);--10
	data_out_1 <= x"00111000";
	wait until rising_edge(Clk_s);--11
	wait until rising_edge(Clk_s);--11
		data_out_1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PENABLE_i <= 'Z';
	APB_PADDR_i <="00000001";
	APB_PWRITE_i <= '0';
	wait until rising_edge(Clk_s);--10
	wait until rising_edge(Clk_s);--12
	APB_PSELx <= 'Z';
	APB_PADDR_i <="ZZZZZZZZ";
	APB_PWRITE_i <= 'Z';
	APB_PENABLE_i <= '0';
	wait until rising_edge(Clk_s);--11
	Resetn <= '0';
	wait until rising_edge(Clk_s);--12
	wait until rising_edge(Clk_s);--13
	wait until rising_edge(Clk_s);--14
	wait until rising_edge(Clk_s);--15
	wait for 10 ns;
	Resetn <= '1';
	-----------------------0b1010-----------------------------------------
	wait until rising_edge(Clk_s);--1	 
   APB_PSELx <= '1';
	APB_PADDR_i <="00000111";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--2
	APB_PWDATA_i<=x"00000010";
	wait until rising_edge(Clk_s);--3
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00001000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"000000F0";
	wait until rising_edge(Clk_s);--5
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <="00001001";
	wait until rising_edge(Clk_s);--4
	APB_PWRITE_i <= '1';
	APB_PWDATA_i<=x"00000011";
	wait until rising_edge(Clk_s);--6
		APB_PENABLE_i <= '1';
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00000000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"00000001";
	wait until rising_edge(Clk_s);--5
	APB_PWRITE_i <= 'Z' ;
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--8
	data_out_1 <= x"00000020";
	wait until rising_edge(Clk_s);--8
	wait until rising_edge(Clk_s);--8
	data_out_1 <= x"00000030";
   wait until rising_edge(Clk_s);--9
	wait until rising_edge(Clk_s);--9
	data_out_1 <= x"00000002";
	wait until rising_edge(Clk_s);--10
	wait until rising_edge(Clk_s);--10
	data_out_1 <= x"00111000";
	wait until rising_edge(Clk_s);--11
	wait until rising_edge(Clk_s);--11
	data_out_1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--12
	i_error <='1';
	wait until rising_edge(Clk_s);--13
	wait until rising_edge(Clk_s);--13
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PENABLE_i <= 'Z';
	APB_PADDR_i <="00000001";
	APB_PWRITE_i <= '0';
	i_error <='0';
	wait until rising_edge(Clk_s);--10
	wait until rising_edge(Clk_s);--12
	APB_PSELx <= 'Z';
	APB_PADDR_i <="ZZZZZZZZ";
	APB_PWRITE_i <= 'Z';
	APB_PENABLE_i <= '0';
	wait until rising_edge(Clk_s);--11
	Resetn <= '0';
	wait until rising_edge(Clk_s);--12
	wait until rising_edge(Clk_s);--13
	wait until rising_edge(Clk_s);--14
	wait until rising_edge(Clk_s);--15
	wait for 10 ns;
	Resetn <= '1';
	-----------------------0b1101-----------------------------------------
	wait until rising_edge(Clk_s);--1	 
   APB_PSELx <= '1';
	APB_PADDR_i <="00000111";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--2
	APB_PWDATA_i<=x"00000010";
	wait until rising_edge(Clk_s);--3
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00001000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"000000F0";
	wait until rising_edge(Clk_s);--5
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <="00001001";
	wait until rising_edge(Clk_s);--4
	APB_PWRITE_i <= '1';
	APB_PWDATA_i<=x"00000011";
	wait until rising_edge(Clk_s);--6
		APB_PENABLE_i <= '1';
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00000000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"00000001";
	wait until rising_edge(Clk_s);--5
	APB_PWRITE_i <= 'Z' ;
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--8
	data_out_1 <= x"00000020";
	wait until rising_edge(Clk_s);--8
	wait until rising_edge(Clk_s);--8
	data_out_1 <= x"00000030";
   wait until rising_edge(Clk_s);--9
	wait until rising_edge(Clk_s);--9
	data_out_1 <= x"00000002";
	wait until rising_edge(Clk_s);--10
	wait until rising_edge(Clk_s);--10
	data_out_1 <= x"00111000";
	wait until rising_edge(Clk_s);--11
	wait until rising_edge(Clk_s);--11
	data_out_1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--12
	wait until rising_edge(Clk_s);--13
	i_tx_end <= '1';
	wait for 10 ns;
	i_tx_end <= '0';
	i_error <='1';
	wait until rising_edge(Clk_s);--13
	wait until rising_edge(Clk_s);--13
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PENABLE_i <= 'Z';
	APB_PADDR_i <="00000001";
	APB_PWRITE_i <= '0';
	i_error <='0';
	wait until rising_edge(Clk_s);--10
	wait until rising_edge(Clk_s);--12
	APB_PSELx <= 'Z';
	APB_PADDR_i <="ZZZZZZZZ";
	APB_PWRITE_i <= 'Z';
	APB_PENABLE_i <= '0';
	wait until rising_edge(Clk_s);--11
	Resetn <= '0';
	wait until rising_edge(Clk_s);--12
	wait until rising_edge(Clk_s);--13
	wait until rising_edge(Clk_s);--14
	wait until rising_edge(Clk_s);--15
	wait for 10 ns;
	Resetn <= '1';
	---------------------------0b1011------------------------------
   wait until rising_edge(Clk_s);--1	 
   APB_PSELx <= '1';
	APB_PADDR_i <="00000111";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--2
	APB_PWDATA_i<=x"00000010";
	wait until rising_edge(Clk_s);--3
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00001000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"000000F0";
	wait until rising_edge(Clk_s);--5
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <="00001001";
	wait until rising_edge(Clk_s);--4
	APB_PWRITE_i <= '1';
	APB_PWDATA_i<=x"00000011";
	wait until rising_edge(Clk_s);--6
		APB_PENABLE_i <= '1';
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00000000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"00000001";
	wait until rising_edge(Clk_s);--5
	APB_PWRITE_i <= 'Z' ;
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--8
	data_out_1 <= x"00000020";
	wait until rising_edge(Clk_s);--9
	wait until rising_edge(Clk_s);--9
	data_out_1 <= x"00000030";
   wait until rising_edge(Clk_s);--10
	wait until rising_edge(Clk_s);--10
	data_out_1 <= x"00000000";
	wait until rising_edge(Clk_s);--11
	wait until rising_edge(Clk_s);--11
	data_out_1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--12
	i_error <='1';
	wait until rising_edge(Clk_s);--13
	wait until rising_edge(Clk_s);--13
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PENABLE_i <= 'Z';
	APB_PADDR_i <="00000001";
	APB_PWRITE_i <= '0';
	i_error <='0';
	wait until rising_edge(Clk_s);--10
	wait until rising_edge(Clk_s);--12
	APB_PSELx <= 'Z';
	APB_PADDR_i <="ZZZZZZZZ";
	APB_PWRITE_i <= 'Z';
	APB_PENABLE_i <= '0';
	wait until rising_edge(Clk_s);--11
	Resetn <= '0';
	wait until rising_edge(Clk_s);--12
	wait until rising_edge(Clk_s);--13
	wait until rising_edge(Clk_s);--14
	wait until rising_edge(Clk_s);--15
	wait for 10 ns;
	Resetn <= '1';
	---------------------------0b1100------------------------------
   wait until rising_edge(Clk_s);--1	 
   APB_PSELx <= '1';
	APB_PADDR_i <="00000111";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--2
	APB_PWDATA_i<=x"00000010";
	wait until rising_edge(Clk_s);--3
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00001000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"000000F0";
	wait until rising_edge(Clk_s);--5
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <="00001001";
	wait until rising_edge(Clk_s);--4
	APB_PWRITE_i <= '1';
	APB_PWDATA_i<=x"00000011";
	wait until rising_edge(Clk_s);--6
		APB_PENABLE_i <= '1';
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00000000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"00000001";
	wait until rising_edge(Clk_s);--5
	APB_PWRITE_i <= 'Z' ;
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--8
	data_out_1 <= x"00000020";
	wait until rising_edge(Clk_s);--9
	wait until rising_edge(Clk_s);--9
	data_out_1 <= x"00000030";
   wait until rising_edge(Clk_s);--10
	wait until rising_edge(Clk_s);--10
	data_out_1 <= x"00000000";
	wait until rising_edge(Clk_s);--11
	wait until rising_edge(Clk_s);--11
	data_out_1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--12
	wait until rising_edge(Clk_s);--13
	wait until rising_edge(Clk_s);--14
	i_tx_end <= '1';
	wait for 10 ns;
	i_tx_end <= '0';
	i_error <='1';
	wait until rising_edge(Clk_s);--13
	wait until rising_edge(Clk_s);--13
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PENABLE_i <= '0';
	APB_PADDR_i <="00000001";
	APB_PWRITE_i <= '0';
	i_error <='0';
	wait until rising_edge(Clk_s);--10
	wait until rising_edge(Clk_s);--12
	APB_PSELx <= 'Z';
	APB_PADDR_i <="ZZZZZZZZ";
	APB_PWRITE_i <= 'Z';
	wait until rising_edge(Clk_s);--11
	Resetn <= '0';
	wait until rising_edge(Clk_s);--12
	wait until rising_edge(Clk_s);--13
	wait until rising_edge(Clk_s);--14
	wait until rising_edge(Clk_s);--15
	wait for 10 ns;
	Resetn <= '1';
	---------------------------0b1110------------------------------
	wait until rising_edge(Clk_s);--1	 
   APB_PSELx <= '1';
	APB_PADDR_i <="00000111";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--2
	APB_PWDATA_i<=x"00000010";
	wait until rising_edge(Clk_s);--3
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00001000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"000000F0";
	wait until rising_edge(Clk_s);--5
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <="00001001";
	wait until rising_edge(Clk_s);--4
	APB_PWRITE_i <= '1';
	APB_PWDATA_i<=x"00000011";
	wait until rising_edge(Clk_s);--6
		APB_PENABLE_i <= '1';
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00000000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"00000001";
	wait until rising_edge(Clk_s);--5
	APB_PWRITE_i <= 'Z' ;
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--8
	data_out_1 <= x"00000020";
	wait until rising_edge(Clk_s);--9
	wait until rising_edge(Clk_s);--9
	data_out_1 <= x"00000130";
   wait until rising_edge(Clk_s);--10
	wait until rising_edge(Clk_s);--10
	data_out_1 <= x"00000000";
	wait until rising_edge(Clk_s);--11
	wait until rising_edge(Clk_s);--11
	data_out_1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--12
	wait until rising_edge(Clk_s);--13
	wait until rising_edge(Clk_s);--14
	i_tx_end <= '1';
	wait for 10 ns;
	i_tx_end <= '0';
	i_data_parallel <= x"00000300";
	wait until rising_edge(Clk_s);--15
	i_tx_end <= '1';
	wait for 10 ns;
	i_tx_end <= '0';
	i_data_parallel <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--16
	wait until rising_edge(Clk_s);--17
	wait until rising_edge(Clk_s);--13
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PENABLE_i <= 'Z';
	APB_PADDR_i <="00000001";
	APB_PWRITE_i <= '0';
	i_error <='0';
	wait until rising_edge(Clk_s);--10
	wait until rising_edge(Clk_s);--12
	APB_PSELx <= 'Z';
	APB_PADDR_i <="ZZZZZZZZ";
	APB_PWRITE_i <= 'Z';
	wait until rising_edge(Clk_s);--11
	Resetn <= '0';
	wait until rising_edge(Clk_s);--12
	wait until rising_edge(Clk_s);--13
	wait until rising_edge(Clk_s);--14
	wait until rising_edge(Clk_s);--15
	wait for 10 ns;
	Resetn <= '1';
	---------------------------reset------------------------------
   wait until rising_edge(Clk_s);--1	 
   APB_PSELx <= '1';
	APB_PADDR_i <="00000111";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--2
	APB_PWDATA_i<=x"00000010";
	wait until rising_edge(Clk_s);--3
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00001000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"000000F0";
	wait until rising_edge(Clk_s);--5
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <="00001001";
	wait until rising_edge(Clk_s);--4
	APB_PWRITE_i <= '1';
	APB_PWDATA_i<=x"00000011";
	wait until rising_edge(Clk_s);--6
		APB_PENABLE_i <= '1';
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	APB_PADDR_i <= "00000000";
	APB_PWRITE_i <= '1';
	wait until rising_edge(Clk_s);--4
	APB_PWDATA_i<= x"00000001";
	wait until rising_edge(Clk_s);--5
	APB_PWRITE_i <= 'Z' ;
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--8
	data_out_1 <= x"00000020";
	wait until rising_edge(Clk_s);--9
	wait until rising_edge(Clk_s);--9
	data_out_1 <= x"00000030";
   wait until rising_edge(Clk_s);--10
	wait until rising_edge(Clk_s);--9
	data_out_1 <= x"00000000";
	wait until rising_edge(Clk_s);--11
	wait until rising_edge(Clk_s);--9
	data_out_1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--12
	wait until rising_edge(Clk_s);--13
	Resetn <= '1';
	i_tx_end <= '0';
	i_data_parallel <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	i_error <='0';
	data_out_1 <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	Resetn <= '0';
	APB_PSELx <= 'Z';
	APB_PADDR_i <="ZZZZZZZZ";
	APB_PENABLE_i <= '0';
	APB_PWRITE_i <= 'Z';
	APB_PWDATA_i<="ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
	wait until rising_edge(Clk_s);--14
	Resetn <= '0';
	
	
wait;
end process;


   
end architecture;