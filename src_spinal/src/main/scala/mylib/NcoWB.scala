/*
 * SpinalHDL
 * Copyright (c) Dolu, All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3.0 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library.
 */

package mylib

import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone.{Wishbone, WishboneConfig, WishboneSlaveFactory}

import scala.util.Random

class nco extends BlackBox {
  val io = new Bundle {
    val clk = in Bool()
    val reset_n = in Bool()
    val t_angle_dat = in Bits(32 bits)
    val t_angle_req = in Bool()
    val t_angle_ack = out Bool()
    val i_nco_dat = out Bits(32 bits)
    val i_nco_req = out Bool()
    val i_nco_ack = in Bool()
  }

  mapClockDomain(clock = io.clk, reset = io.reset_n, resetActiveLevel = LOW)
  noIoPrefix()
}
//Hardware definition
class NcoWB extends Component {
  val io = new Bundle {
    val wb = slave(Wishbone(WishboneConfig(addressWidth = 30,
      dataWidth = 32,
      selWidth = 4
    )))
    val angle = out Bits(32 bits)
    val xy = in Bits(32 bits)
    //val sinwave = out Bool()
    //val sinwave_oeb = out Bool()
  }

  val ncoBB = new nco
  //io.sinwave_oeb := False
  //val sinwave = Bool()
  //val sinAccumulator = Reg(Bits(18 bits)) init(0)
  //val delayCnt = Reg(UInt(8 bits)) init(0)
  //val mode = Reg(Bits(2 bits)) init(0)
  //val thetaDelta = Reg(SInt(8 bits)) init(0)
  //val delay = Reg(Bits(8 bits)) init(0)
  val angleInit = Reg(SInt(32 bits)) init(0)
  //val angle = Reg(SInt(width = 32 bits)) init(0)
  val wishboneSlave = WishboneSlaveFactory(io.wb)
  wishboneSlave.driveAndRead(angleInit, address = BigInt("C0000000",16),documentation = "32-bit angle")
  io.angle := angleInit.asBits
  wishboneSlave.read(ncoBB.io.i_nco_dat, BigInt("C0000010", 16))
  //wishboneSlave.driveAndRead(mode, address = BigInt("C0000020",16), documentation = "WB/UART")
  //wishboneSlave.driveAndRead(thetaDelta, address = BigInt("C0000030", 16), documentation = "theta increment")
  //wishboneSlave.driveAndRead(delay, address = BigInt("C0000040", 16), documentation = "delay")

  //sinAccumulator := (sinAccumulator.asUInt + (ncoBB.io.i_nco_dat(15 downto 0).asSInt + S(0x7FFF,16 bits)).asUInt).asBits
  //when(wishboneSlave.askWrite)(sinAccumulator := 0)
  //io.sinwave := sinAccumulator.msb
  ncoBB.io.t_angle_req := True
  ncoBB.io.i_nco_ack := True
  ncoBB.io.t_angle_dat := angleInit.asBits

  /*switch(mode){
    is(0){
      ncoBB.io.t_angle_req := True
      ncoBB.io.i_nco_ack := True
      angle := angleInit
    }
    is(1){
      ncoBB.io.t_angle_req := True
      ncoBB.io.i_nco_ack := True
      when(delayCnt.asBits === delay){
        delayCnt := 0
        angle := angle + thetaDelta.resized
      }.otherwise{
        delayCnt := delayCnt + 1
      }
    }
  }*/

}

/*class NcoWB extends Component {
  val io = new Bundle {
    val wb = slave(Wishbone(WishboneConfig(addressWidth = 32,
      dataWidth = 32,
      selWidth = 4
    )))
    val angle = out Bits(32 bits)
  }

  val m = Mem(Bits(32 bits), 256)


  val angle = Reg(Bits(32 bits)) init(0)
  val wishboneSlave = WishboneSlaveFactory(io.wb)
  wishboneSlave.driveAndRead(angle, address = 0x30000000,documentation = "32-bit angle")
  val maddr = wishboneSlave.createReadAndWrite(Bits(32 bits), 4)
  val mwdata = wishboneSlave.createReadAndWrite(Bits(32 bits), 8)
  val mwrite = wishboneSlave.createReadAndWrite(Bool(), 0xC)
  val mrdata = wishboneSlave.createReadOnly(Bits(32 bits), 0x10)
  when(wishboneSlave.askWrite && wishboneSlave.writeAddress() === U(0xC))(m(U(maddr).resized) := mwdata)
  mrdata := m(U(maddr).resized)
  io.angle := angle

}*/

//Define a custom SpinalHDL configuration with synchronous reset instead of the default asynchronous one. This configuration can be resued everywhere
object MySpinalConfig extends SpinalConfig(defaultConfigForClockDomains = ClockDomainConfig(resetKind = ASYNC, resetActiveLevel = HIGH), targetDirectory = "generated")

//Generate the MyTopLevel's Verilog using the above custom configuration.
object MyTopLevelVerilogWithCustomConfig {
  def main(args: Array[String]) {
    MySpinalConfig.generateVerilog(new NcoWB)
  }
}