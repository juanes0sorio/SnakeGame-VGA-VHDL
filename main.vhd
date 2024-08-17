library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main is
	port(
		clk_25: in std_logic;
		vga_vs, vga_hs : out std_logic;
		vga_r, vga_g, vga_b: out std_logic_vector(7 downto 0);
		
	   vga_clk: out std_logic;
		vga_blank_n : std_logic := '1';
		vga_sync_n : std_logic := '0';
		
		switch: in std_logic_vector(3 downto 0)
		
	);
end main;


architecture comportamiento of main is
	
	component sync is
		port(
			clk: in std_logic;
			hsync: out std_logic;
			vsync: out std_logic;
			r: out std_logic_vector(7 downto 0);
			g: out std_logic_vector(7 downto 0);
			b: out std_logic_vector(7 downto 0);
			movimiento: in std_logic_vector(3 downto 0)
			);
	end component sync;

begin

	sincronizacion: sync port map (clk_25,vga_hs,vga_vs,vga_r,vga_g,vga_b,switch);
	
	vga_clk<=clk_25;
	

end comportamiento;