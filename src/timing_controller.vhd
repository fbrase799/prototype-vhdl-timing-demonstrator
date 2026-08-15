library ieee;
use ieee.std_logic_1164.all;

-- Clock-driven timing controller.
--
-- After a rising edge on `trigger`, the controller counts clock cycles and
-- produces two one-cycle output pulses:
--   output_a at DELAY_A cycles after the trigger
--   output_b at DELAY_B cycles after the trigger
--
-- Timing is derived from the clock, not from software-style wait/sleep.
-- A new trigger is ignored while a sequence is already running.

entity timing_controller is
  generic (
    DELAY_A : natural := 4;
    DELAY_B : natural := 8
  );
  port (
    clk      : in  std_logic;
    reset    : in  std_logic;
    trigger  : in  std_logic;
    output_a : out std_logic;
    output_b : out std_logic
  );
end entity timing_controller;

architecture rtl of timing_controller is
  type state_t is (IDLE, RUNNING);

  signal state     : state_t := IDLE;
  signal count     : natural range 0 to DELAY_B := 0;
  signal trigger_d : std_logic := '0';
begin
  assert DELAY_A > 0
    report "DELAY_A must be greater than 0"
    severity failure;
  assert DELAY_B >= DELAY_A
    report "DELAY_B must be greater than or equal to DELAY_A"
    severity failure;

  -- All sequential behavior is synchronous to the rising clock edge.
  process (clk)
    variable next_count : natural range 0 to DELAY_B;
  begin
    if rising_edge(clk) then
      if reset = '1' then
        state     <= IDLE;
        count     <= 0;
        trigger_d <= '0';
        output_a  <= '0';
        output_b  <= '0';
      else
        trigger_d <= trigger;
        output_a  <= '0';
        output_b  <= '0';

        case state is
          when IDLE =>
            if trigger = '1' and trigger_d = '0' then
              state <= RUNNING;
              count <= 0;
            end if;

          when RUNNING =>
            next_count := count + 1;
            count      <= next_count;

            if next_count = DELAY_A then
              output_a <= '1';
            end if;

            if next_count = DELAY_B then
              output_b <= '1';
              state    <= IDLE;
            end if;
        end case;
      end if;
    end if;
  end process;
end architecture rtl;
