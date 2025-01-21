-- Declare the library and package to use
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Declare the entity
entity Project_Traffic_Controller is
    Port ( G_m, Y_m, R_m : out  STD_LOGIC;  -- Output signals for the main traffic lights
           S_p, G_p : out  STD_LOGIC;      -- Output signals for the pedestrian traffic lights
           X, Y, Z : in  STD_LOGIC);       -- Input signals for the system
end Project_Traffic_Controller;

-- Declare the architecture
architecture Behavioral of Project_Traffic_Controller is
    -- Declare a custom type for the states
    type state_type is (S_0, S_1, S_2, S_3);
    -- Declare two state signals: one for the current state, and one for the next state
    signal current_state, next_state : state_type;
    -- Declare a timer signal to count the duration of the yellow light
    signal timer_count : integer range 0 to 50_000_000; -- 20 seconds

begin

    -- State transition logic
    process (current_state, X, Y, Z, timer_count)
    begin
        case current_state is
            -- Start state: all output signals are set to their initial values
            when S_0 =>
                if Z = '1' then    -- If the pedestrian button is pressed, transition to state 1
                    next_state <= S_1;
                elsif Y = '1' then -- If X is 0 and Y is 1, transition to state 2
                    next_state <= S_2;
                else               -- Otherwise, stay in state 0
                    next_state <= S_0;
                end if;
            -- State 1: pedestrian traffic light is green, main traffic light is yellow
            when S_1 =>
                if Z = '0' then    -- If the pedestrian button is not pressed anymore, go back to state 0
                    next_state <= S_0;
                else               -- Otherwise, stay in state 1
                    next_state <= S_1;
                end if;
            -- State 2: main traffic light is green, main traffic light will turn yellow after 20 seconds
            when S_2 =>
                if timer_count >= 20_000_000 then -- If 20 seconds have elapsed, transition to state 3
                    next_state <= S_3;
                elsif Y = '0' then -- If Y goes back to 0, go back to state 0
                    next_state <= S_0;
                else               -- Otherwise, stay in state 2
                    next_state <= S_2;
                end if;
            -- State 3: main traffic light is red, pedestrian traffic light is green
            when S_3 =>
                if X = '0' then    -- If X goes back to 0, go back to state 0
                    next_state <= S_0;
                else               -- Otherwise, stay in state 3
                    next_state <= S_3;
                end if;
        end case;
    end process;

    -- Output logic
    process (current_state)
    begin
        case current_state is
            when S_0 =>
                G_m <= '1';
                Y_m <= '0';
                R_m <= '0';
                S_p <= '0';
                G_p <= '0';
            when S_1 =>
                G_m <= '0';
                Y_m <= '1';
                R_m <= '0';
                S_p <= '1';
                G_p <= '0';
            when S_2 =>
                G_m <= '0';
                Y_m <= '0';
                R_m <= '1';
                S_p <= '1';
                G_p <= '0';
            when S_3 =>
                G_m <= '0';
                Y_m <= '0';
                R_m <= '1';
                S_p <= '0';
                G_p <= '1';
        end case;
    end process;

    -- Timer logic
    process (current_state, timer_count)
    begin
        if current_state = S_2 and Y = '1' then
            timer_count <= timer_count + 1;
        else
            timer_count <= 0;
        end if;
    end process;

    -- State update logic
    process (current_state, next_state)
    begin
        if current_state /= next_state then
            current_state <= next_state;
        end if;
    end process;

end Behavioral;
