----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/24/2026 01:38:09 AM
-- Design Name: 
-- Module Name: ANDP - Behavioral
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

entity ANDP is
    Port ( A : in STD_LOGIC;
           B : in STD_LOGIC;
           C : inout STD_LOGIC;
           D : in STD_LOGIC;
           E : out STD_LOGIC);
end ANDP;

architecture Behavioral of ANDP is

begin
C<=A and B after 5ns;
E<=C and D after 5ns;

end Behavioral;
