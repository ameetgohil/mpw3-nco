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

//Hardware definition
class NcoWB extends Component {
  val io = new Bundle {
    val wb = slave(Wishbone(WishboneConfig(addressWidth = 30,
      dataWidth = 32,
      selWidth = 4
    )))
    val angle = out Bits(32 bits)
    val xy = in Bits(32 bits)
  }



  val angle = Reg(Bits(32 bits)) init(0)
  val wishboneSlave = WishboneSlaveFactory(io.wb)
  wishboneSlave.driveAndRead(angle, address = BigInt("C0000000",16),documentation = "32-bit angle")
  io.angle := angle
  wishboneSlave.read(io.xy, BigInt("C0000004", 16))

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
object MySpinalConfig extends SpinalConfig(defaultConfigForClockDomains = ClockDomainConfig(resetKind = SYNC, resetActiveLevel = HIGH), targetDirectory = "generated")

//Generate the MyTopLevel's Verilog using the above custom configuration.
object MyTopLevelVerilogWithCustomConfig {
  def main(args: Array[String]) {
    MySpinalConfig.generateVerilog(new NcoWB)
  }
}