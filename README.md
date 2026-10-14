# Parameterized Serial-In Shift Register

A synthesizable, parameterized shift register written in Verilog, with a serial input, clock, enable signal, parallel register output, and serial output.

## Features

- Parameterized register width (`width`, default: 4 bits)
- Positive-edge-triggered operation
- Synchronous shift enable (`En`)
- Serial data input (`serial_in`)
- Parallel state output (`q`)
- Serial output from the least significant bit (`serial_out = q[0]`)
- Testbench support with Icarus Verilog and GTKWave

## How It Works

When `En` is high at a rising edge of `clk`, the register shifts right by one bit:

```text
q_next = {serial_in, q[width-1:1]}
```

The new serial input enters the most significant bit. The other bits move one position toward the least significant bit.

When `En` is low, the register holds its previous value.

The serial output continuously reflects the least significant bit:

```text
serial_out = q[0]
```

For example, with `width = 4`, if the current state is `q = 1011` and `serial_in = 0`, the next state is `q = 0101`.

## RTL Interface

| Port | Direction | Width | Description |
|---|---|---:|---|
| `clk` | Input | 1 | Clock; state updates on rising edges |
| `En` | Input | 1 | Shift enable; shifts when high |
| `serial_in` | Input | 1 | Serial data shifted into the MSB |
| `q` | Output | `width` | Current register contents |
| `serial_out` | Output | 1 | Current least significant bit, `q[0]` |

### Parameter

| Parameter | Default | Description |
|---|---:|---|
| `width` | 4 | Number of bits in the register; use `width >= 2` with the RTL slice shown below |

## Testbench

Save the testbench as `sr_tb.v`. It should instantiate `top`, generate a clock, apply inputs, and inspect `q` and `serial_out`. Keep simulation-only system tasks such as `$dumpfile`, `$dumpvars`, and `$finish` out of the synthesizable RTL.

Example clock generation:

```verilog
initial clk = 0;
always #5 clk = ~clk;
```

With `` `timescale 1ns/100ps ``, this creates a 10 ns clock period (100 MHz).

## Simulation with Icarus Verilog

From a terminal in the directory containing `top.v` and `sr_tb.v`:

```bash
iverilog -g2012 -s sr_tb -o sim top.v sr_tb.v
vvp sim
```

To generate and inspect a VCD waveform, include this in the testbench:

```verilog
initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, sr_tb);
end
```

Then open the waveform:

```bash
gtkwave wave.vcd
```

Inspect `clk`, `En`, `serial_in`, `q`, and `serial_out`. Confirm that `q` changes only on rising edges when enabled, holds when disabled, and `serial_out` always equals `q[0]`.

## Suggested Verification Cases

- [ ] Initial state is zero in simulation.
- [ ] `En = 0`: register holds its value while `serial_in` changes.
- [ ] `En = 1`: register shifts at each rising edge.
- [ ] Shift in all zeros.
- [ ] Shift in all ones.
- [ ] Apply alternating input bits (`1, 0, 1, 0, ...`).
- [ ] Check that `serial_out` equals `q[0]` after every update.
- [ ] Verify input changes between clock edges do not directly change `q`.
- [ ] Check that shifting pauses when `En` is low and resumes when it becomes high.
- [ ] Test additional widths, such as 2 and 8, if supported by the intended design.

## Project Files

A simple project layout:

```text
shift-register/
├── top.v       # Synthesizable shift-register RTL
├── sr_tb.v     # Simulation testbench
├── wave.vcd    # Generated simulation waveform
└── README.md   # Project documentation
```

Generated files (`wave.vcd` and the simulator executable) can be omitted from version control if they are reproducible.

## License

Add the license appropriate for your project before publishing or distributing it.
