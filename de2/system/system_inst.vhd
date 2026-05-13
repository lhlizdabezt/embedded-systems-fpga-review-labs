	component system is
		port (
			clk_clk                         : in  std_logic                     := 'X';             -- clk
			hex_0_conduit_end_hex0          : out std_logic_vector(6 downto 0);                     -- hex0
			hex_0_conduit_end_hex1          : out std_logic_vector(6 downto 0);                     -- hex1
			hex_0_conduit_end_hex2          : out std_logic_vector(6 downto 0);                     -- hex2
			hex_0_conduit_end_hex3          : out std_logic_vector(6 downto 0);                     -- hex3
			hex_0_conduit_end_hex4          : out std_logic_vector(6 downto 0);                     -- hex4
			hex_0_conduit_end_hex5          : out std_logic_vector(6 downto 0);                     -- hex5
			key_reader_0_conduit_end_export : in  std_logic_vector(31 downto 0) := (others => 'X'); -- export
			reset_reset_n                   : in  std_logic                     := 'X';             -- reset_n
			switches_0_conduit_end_export   : in  std_logic_vector(31 downto 0) := (others => 'X')  -- export
		);
	end component system;

	u0 : component system
		port map (
			clk_clk                         => CONNECTED_TO_clk_clk,                         --                      clk.clk
			hex_0_conduit_end_hex0          => CONNECTED_TO_hex_0_conduit_end_hex0,          --        hex_0_conduit_end.hex0
			hex_0_conduit_end_hex1          => CONNECTED_TO_hex_0_conduit_end_hex1,          --                         .hex1
			hex_0_conduit_end_hex2          => CONNECTED_TO_hex_0_conduit_end_hex2,          --                         .hex2
			hex_0_conduit_end_hex3          => CONNECTED_TO_hex_0_conduit_end_hex3,          --                         .hex3
			hex_0_conduit_end_hex4          => CONNECTED_TO_hex_0_conduit_end_hex4,          --                         .hex4
			hex_0_conduit_end_hex5          => CONNECTED_TO_hex_0_conduit_end_hex5,          --                         .hex5
			key_reader_0_conduit_end_export => CONNECTED_TO_key_reader_0_conduit_end_export, -- key_reader_0_conduit_end.export
			reset_reset_n                   => CONNECTED_TO_reset_reset_n,                   --                    reset.reset_n
			switches_0_conduit_end_export   => CONNECTED_TO_switches_0_conduit_end_export    --   switches_0_conduit_end.export
		);

