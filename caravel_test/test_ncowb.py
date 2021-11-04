import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, with_timeout

@cocotb.test()
async def test_start(dut):
    clock = Clock(dut.clk, 25, units="ns") # 40M
    cocotb.fork(clock.start())
    
    dut.RSTB <= 0
    dut.power1 <= 0;
    dut.power2 <= 0;
    dut.power3 <= 0;
    dut.power4 <= 0;

    await ClockCycles(dut.clk, 8)
    dut.power1 <= 1;
    await ClockCycles(dut.clk, 8)
    dut.power2 <= 1;
    await ClockCycles(dut.clk, 8)
    dut.power3 <= 1;
    await ClockCycles(dut.clk, 8)
    dut.power4 <= 1;

    await ClockCycles(dut.clk, 80)
    dut.RSTB <= 1

    # wait with a timeout for the project to become active
    await with_timeout(RisingEdge(dut.uut.mprj.wrapped_nco_7.active), 180, 'us')

    #await with_timeout(dut.uut.mprj.wrapped_nco_7.u_ncowb.ncoBB.i_nco_dat.value.binstr == "E87B9680", 10, 'us')

    # wait
    await ClockCycles(dut.clk, 6000)

    # assert something
    ncoval = dut.uut.mprj.wrapped_nco_7.u_ncowb.ncoBB.i_nco_dat.value.integer
    #print(hex(ncoval))
    #print(ncoval == 0xE87B9680)
    assert(ncoval == 0xE87B9680)
    

