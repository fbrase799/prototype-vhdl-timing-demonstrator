library ieee;
use ieee.std_logic_1164.all;
use std.env.all;

entity timing_controller_tb is
end entity timing_controller_tb;

architecture sim of timing_controller_tb is
  constant CLK_PERIOD : time    := 10 ns;
  constant DELAY_A    : natural := 4;
  constant DELAY_B    : natural := 8;

  signal clk      : std_logic := '0';
  signal reset    : std_logic := '1';
  signal trigger  : std_logic := '0';
  signal output_a : std_logic;
  signal output_b : std_logic;

  signal errors : natural := 0;

  procedure check(
    condition : in boolean;
    message   : in string;
    signal errors_sig : inout natural
  ) is
  begin
    if not condition then
      report message severity error;
      errors_sig <= errors_sig + 1;
    end if;
  end procedure check;
begin
  dut : entity work.timing_controller
    generic map (
      DELAY_A => DELAY_A,
      DELAY_B => DELAY_B
    )
    port map (
      clk      => clk,
      reset    => reset,
      trigger  => trigger,
      output_a => output_a,
      output_b => output_b
    );

  clk <= not clk after CLK_PERIOD / 2;

  stimulus : process
    procedure sample_after_edge is
    begin
      wait until rising_edge(clk);
      wait for 1 ns;
    end procedure sample_after_edge;

    procedure expect_idle(cycle_idx : natural) is
    begin
      check(output_a = '0',
            "output_a unexpectedly high at cycle " & integer'image(cycle_idx),
            errors);
      check(output_b = '0',
            "output_b unexpectedly high at cycle " & integer'image(cycle_idx),
            errors);
    end procedure expect_idle;

    -- Drive a one-cycle trigger and verify the full timing sequence.
    -- Cycle 0 is the clock edge that samples the rising trigger.
    procedure run_sequence is
    begin
      wait until falling_edge(clk);
      trigger <= '1';
      sample_after_edge;
      trigger <= '0';
      expect_idle(0);

      for cycle_idx in 1 to DELAY_A - 1 loop
        sample_after_edge;
        expect_idle(cycle_idx);
      end loop;

      sample_after_edge;
      check(output_a = '1',
            "output_a missing at cycle " & integer'image(DELAY_A),
            errors);
      check(output_b = '0',
            "output_b unexpectedly high at cycle " & integer'image(DELAY_A),
            errors);

      for cycle_idx in DELAY_A + 1 to DELAY_B - 1 loop
        sample_after_edge;
        expect_idle(cycle_idx);
      end loop;

      sample_after_edge;
      check(output_a = '0',
            "output_a unexpectedly high at cycle " & integer'image(DELAY_B),
            errors);
      check(output_b = '1',
            "output_b missing at cycle " & integer'image(DELAY_B),
            errors);

      sample_after_edge;
      expect_idle(DELAY_B + 1);
    end procedure run_sequence;
  begin
    reset   <= '1';
    trigger <= '0';

    for i in 1 to 4 loop
      wait until rising_edge(clk);
    end loop;

    wait until falling_edge(clk);
    reset <= '0';

    for i in 1 to 2 loop
      wait until rising_edge(clk);
    end loop;

    report "Starting first timing sequence";
    run_sequence;

    for i in 1 to 4 loop
      wait until rising_edge(clk);
    end loop;

    report "Starting second timing sequence";
    run_sequence;

    wait for 2 * CLK_PERIOD;

    if errors = 0 then
      report "Simulation passed" severity note;
    else
      report "Simulation failed with " & integer'image(errors) & " error(s)"
        severity failure;
    end if;

    stop;
  end process;
end architecture sim;
