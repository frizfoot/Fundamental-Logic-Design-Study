----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/24/2026 02:04:54 AM
-- Design Name: 
-- Module Name: 101 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity F101 is
    port (A,B,C,D,E: in bit;I: out bit);
end F101;

architecture Behavioral of F101 is
    signal F,G,N: bit;

begin
    F<=Not A and B and C;
    G<= D and Not E;
    N<= F XOR G;
    I<=NOT N;

end Behavioral;
