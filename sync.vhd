library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync is
	port(
		clk: in std_logic;
		hsync: out std_logic;
		vsync: out std_logic;
		r: out std_logic_vector(7 downto 0);
		g: out std_logic_vector(7 downto 0);
		b: out std_logic_vector(7 downto 0);	
		movimiento: in std_logic_vector(3 downto 0)
	
	);
end sync;


architecture comportamiento of sync is

signal hpos: integer range 0 to 800:=0;
signal vpos: integer range 0 to 525:=0;
signal contador : integer:=0;
signal bandera: std_logic:='0';
constant max_value : integer:=100000;

signal xref: integer range 0 to 800:=400;
signal yref: integer range 0 to 525:=250;
signal drawcabeza: std_logic:='0';
signal ultima_pul: std_logic_vector(3 downto 0):="1110";
signal drawmuro1: std_logic:='0';
signal drawmuro2: std_logic:='0';
signal drawmuro3: std_logic:='0';
signal drawmuro4: std_logic:='0';

signal random: integer:=0;
signal semilla_random: integer:=0;
signal foodx: integer:=340;
signal foody: integer:=166;
signal drawfood: std_logic:='0';
signal colisionfood: std_logic:='0';
signal nuevacomida: std_logic:='0';


type Posicion is record
        x : integer range 0 to 800;
        y : integer range 0 to 525;
    end record;


type SnakeBody is array(1 to 500) of Posicion;
signal cuerpo_serpiente : SnakeBody;
signal longitud_serpiente : integer := 1;
signal drawbody: std_logic:='0';
  
signal reset: std_logic:='0';
------------------------------------------------------------------
procedure dibujocabeza(signal xactual,yactual,xref,yref:in integer;
					  signal draw: out std_logic) is
begin
	if(xactual>xref and xactual<(xref+10) and yactual>yref and yactual<(yref+10))then
	draw<='1';
	else
	draw<='0';
	end if;
end dibujocabeza;

procedure dibujocomida(signal xactual,yactual,foodx,foody:in integer;
					  signal drawfood: out std_logic) is
begin
	if(xactual>foodx and xactual<(foodx+6) and yactual>foody and yactual<(foody+6))then
	drawfood<='1';
	else
	drawfood<='0';
	end if;
end dibujocomida;

procedure dibujocuerpo(signal xactual,yactual,longitud_serpiente,xref,yref:in integer;
						signal cuerpo_serpiente: inout SnakeBody;
					  signal drawbody: out std_logic
					  ) is
begin
	
           
    drawbody <= '0';
    for i in 1 to 500 loop
       if i <= longitud_serpiente then 
		  if (xactual > cuerpo_serpiente(i).x and xactual < (cuerpo_serpiente(i).x + 10)) and yactual > cuerpo_serpiente(i).y and yactual < (cuerpo_serpiente(i).y + 10) then
            drawbody <= '1';
        end if;
		 end if;
    end loop;
end dibujocuerpo;


procedure dibujoizquierdo(signal xactual,yactual:in integer;
					  signal drawmuro1: out std_logic) is
begin
	if(xactual>160 and xactual<170 and yactual>45 and yactual<525)then
	drawmuro1<='1';
	else
	drawmuro1<='0';
	end if;
end dibujoizquierdo;
procedure dibujoarriba(signal xactual,yactual:in integer;
					  signal drawmuro2: out std_logic) is
begin
	if(xactual>160 and xactual<800 and yactual>45 and yactual<55)then
	drawmuro2<='1';
	else
	drawmuro2<='0';
	end if;
end dibujoarriba;
procedure dibujoderecho(signal xactual,yactual:in integer;
					  signal drawmuro3: out std_logic) is
begin
	if(xactual>790 and xactual<800 and yactual>45 and yactual<525)then
	drawmuro3<='1';
	else
	drawmuro3<='0';
	end if;
end dibujoderecho;
procedure dibujoabajo(signal xactual,yactual:in integer;
					  signal drawmuro4: out std_logic) is
begin
	if(xactual>160 and xactual<800 and yactual>515 and yactual<525)then
	drawmuro4<='1';
	else
	drawmuro4<='0';
	end if;
end dibujoabajo;
------------------------------------------------------------------
begin

process(clk, reset)
	
	begin
	
	if (reset='1') then
	
		hpos<=0;
		vpos<=0;
      contador<=0;
		bandera<='0';


		xref<=400;
		yref<=250;
		drawcabeza<='0';
		ultima_pul<="1110";
		drawmuro1<='0';
		drawmuro2<='0';
		drawmuro3<='0';
		drawmuro4<='0';

		random<=0;
		semilla_random<=0;
		foodx<=340;
		foody<=166;
		drawfood<='0';
		colisionfood<='0';
		nuevacomida<='0';

		longitud_serpiente<= 1;
		drawbody<='0';
  
		reset<='0';
	
	elsif(rising_edge(clk))then
		
		if(movimiento/="1111")then
		ultima_pul<=movimiento;
		end if;
		
		semilla_random<=semilla_random+1;
		
		random<=semilla_random;
---------sincronizacion vga----------------------------		
		if(hpos<800)then
			hpos<=hpos+1;
		else
			hpos<=0;
			if(vpos<525)then
				vpos<=vpos+1;
			else
				vpos<=0;
			end if;
		end if;
		
		--sincronizacion horizontal
		if(hpos>16 and hpos<112)then
			hsync<='0';
		else
			hsync<='1';
		end if;
			
		--sincronizacion vertical
		if(vpos>10 and vpos<12)then
			vsync<='0';
		else
			vsync<='1';
		end if;
		
		
		--disminucion de frecuencia
		if(contador=max_value)then
			bandera<='1';
			contador<=0;
		else
			contador<= contador+1;
		end if;
		
		--inicia logica del juego--------------------------
		
		dibujocabeza(hpos,vpos,xref,yref,drawcabeza);
		dibujocomida(hpos,vpos,foodx,foody,drawfood);
		dibujocuerpo(hpos, vpos,longitud_serpiente,xref,yref,cuerpo_serpiente,drawbody);
		dibujoizquierdo(hpos,vpos,drawmuro1);
		dibujoarriba(hpos,vpos,drawmuro2);
		dibujoderecho(hpos,vpos,drawmuro3);
		dibujoabajo(hpos,vpos,drawmuro4);
		
		if(drawcabeza='1')then
		   r<=(others=>'0');
			g<=(others=>'1');
			b<=(others=>'0');
		elsif (drawbody='1')then
			r<=(others=>'0');
			g<=(others=>'1');
			b<=(others=>'0');
		elsif (drawfood='1')then
			r<=(others=>'1');
			g<=(others=>'0');
			b<=(others=>'0');
		elsif (drawmuro1='1') then
			r<=(others=>'1');
			g<=(others=>'1');
			b<=(others=>'1');
		elsif (drawmuro2='1') then
			r<=(others=>'1');
			g<=(others=>'1');
			b<=(others=>'1');
		elsif (drawmuro3='1') then
			r<=(others=>'1');
			g<=(others=>'1');
			b<=(others=>'1');
		elsif (drawmuro4='1') then
			r<=(others=>'1');
			g<=(others=>'1');
			b<=(others=>'1');
		elsif((hpos>0 and hpos<160) or (vpos>0 and vpos<45))then
			r<=(others=>'0');
			g<=(others=>'0');
			b<=(others=>'0');
		else
			r<=(others=>'0');
			g<=(others=>'0');
			b<=(others=>'0');	
		end if;
		
		if(vpos=0)then
			if (bandera='1') then
				for i in 500 downto 2 loop
                cuerpo_serpiente(i) <= cuerpo_serpiente(i - 1);
            end loop;
            
            cuerpo_serpiente(1).x <= xref;
            cuerpo_serpiente(1).y <= yref;
			end if;
		
			if(ultima_pul(0)='0' and bandera='1')then
				xref<=xref+1;
				bandera<='0';
			end if;
			if(ultima_pul(1)='0'and bandera='1')then
				xref<=xref-1;
				bandera<='0';
			end if;
			if(ultima_pul(2)='0' and bandera='1')then
				yref<=yref+1;
				bandera<='0';
			end if;
			if(ultima_pul(3)='0' and bandera='1')then
				yref<=yref-1;
				bandera<='0';
			end if;
		end if;
	
	
		if(abs(xref - foodx) <= 8 ) and (abs(yref - foody) <= 8) then
			 colisionfood <= '1';
		else
			 colisionfood <= '0';
		end if;

		if(colisionfood = '1') then
			 nuevacomida <= '1';
			if (longitud_serpiente < 500) then
				longitud_serpiente <= longitud_serpiente + 1;
         end if;
		end if;

		if(nuevacomida = '1') then
	
			foodx <= 190+(random mod 600);
			foody <= 70+(random mod 450);
			nuevacomida <= '0';  
			 
		end if;
		
		
		if(abs(xref - 160) <= 10 ) and (abs(yref - 45) <= 480) then
			 reset <= '1';
		elsif(abs(xref - 160) <= 640 ) and (abs(yref - 45) <= 10) then
			 reset <= '1';
		elsif(abs(xref - 790) <= 10 ) and (abs(yref - 45) <= 480) then
			 reset <= '1';
		elsif(abs(xref - 160) <= 640 ) and (abs(yref - 515) <= 10) then
			 reset <= '1';
		else
			 reset <= '0';
		end if;
		-------------------------------------------------
		
		
		
	end if;
	
	
	
	end process;
end comportamiento;