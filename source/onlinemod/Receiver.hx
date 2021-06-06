package onlinemod;

import flixel.FlxG;

import openfl.utils.ByteArray;
import openfl.utils.Endian;

import onlinemod.Packets.Packet;
import onlinemod.Packets.PacketsShit;

class Receiver
{
  public var bufferedBytes:Int = 0; // Number of bytes in the buffer

  // The reason some of these variables are public is that they are needed for the loading bar in OnlineLoadState. It's not elegant.
  var packet:Packet; // The packet type being analyzed. Contains the Data Types, size, variable-length arguments, etc.
  public var packetId:Int; // The ID of the packet being received.
  var endedPacket:Bool = true; // Whether the current packet is done being analyzed and we can move on to the next one.
  var w:Int = 0; // Index of the current variable data being analyzed and stuff.
  public var varLength:Int = 0; // The amount of extra bytes taken up by variable-length datatypes.
  var varSize:Int; // The byte-size of the size-specificator of the current variable-length datatype being analyzed.

  var buffers:Array<ByteArray> = []; // Stores the data from each TCP message (these can contain only partial information, so we have to store them)
  public var HandleData:Int->Array<Dynamic>->Void;

  public function new(HandleData:Int->Array<Dynamic>->Void)
  {
    this.HandleData = HandleData;
  }

  public function OnData(data:ByteArray)
  {
    // This function is triggered whenever data is received from a socket.

    // Save the bytes on memory.
    bufferedBytes += data.length;
    buffers.push(data);

    while (bufferedBytes > 0)
    {
      if (endedPacket)
      {
        // If we're starting a new packet, initialize all relevant PacketID variables.
        endedPacket = false;
        packetId = consume(1).readUnsignedByte();
        if (packetId < PacketsShit.fields.length)
          packet = PacketsShit.fields[packetId];
        else{
          // If the PacketID doesn't exist, close the socket.
          FlxG.switchState(new OnlinePlayMenuState("Received invalid packet"));
          return;
        }

        varSize = packet.varLengths[0]; // Byte-size of the size-specifier of the first variable argument.
                                        // If there's no variable arguments, it returns the size of the entire packet.
      }

      // If there's still variable arguments left, and there's enough bytes received to complete it, then handle it.
      while (bufferedBytes >= packet.varSpaces[w] + varLength + varSize && w < packet.varLengths.length)
      {
        // Under some cases this code fails but I'm too lazy to fix it. There shouldn't be any issues with the packets I implemented.
        varLength += readBuffer(packet.varSpaces[w] + varLength, varSize);
        w++;
        varSize = packet.varLengths[w];
        continue;
      }

      // If this is the last variable argument (or if there were none), and there's enough bytes received to complete it, then handle it.
      if (bufferedBytes >= packet.varSpaces[w] + varLength && w == packet.varLengths.length)
      {
        // Handle the whole packet.
        HandleData(packetId, packet.handle(consume(packet.size + varLength)));
        w = 0;
        varLength = 0;
        endedPacket = true;
        continue;
      }

      // If you can't do anything with the data, just stop and wait for more data to come.
      break;
    }
  }

  public function readBuffer(n:Int, bytes:Int)
  {
    // Reads 'bytes' number of bytes starting at position n from the buffered bytes.
		// Similar behaviour to 'consume', but this function doesn't consume the bytes.
    var runningTotal:Int = 0;
    for (buf in buffers)
    {
      runningTotal += buf.length;
      if (n < runningTotal)
      {
        buf.position = n;
        var result:Int;
        // This if-statement is hardcoded because this function shouldn't be needed for anything else.
        if (bytes == 2)
          result = buf.readUnsignedShort();
        else
          result = buf.readUnsignedInt();
        buf.position = 0;

        return result;
      }
    }

    // This code should never be reached.
    return -1;
  }

  public function consume(n:Int)
  {
    // This function returns a Buffer from the n bytes that were received longest ago, and clears and updates the buffers accordingly.
    if (n == 0)
      return null;

    bufferedBytes -= n;

    if (n == buffers[0].length){
      return buffers.shift();
    }

    var dst:ByteArray = new ByteArray(n);

    if (n < buffers[0].length) {
      buffers[0].readBytes(dst, 0, n);
      var newBuf:ByteArray = new ByteArray(buffers[0].length - n);
      buffers[0].readBytes(newBuf, 0, buffers[0].length - n);
      buffers[0] = newBuf;
		  return dst;
		}

    do
    {
      var buf:ByteArray = buffers[0];
      var offset:Int = dst.length - n;

      if (n >= buf.length){
        dst.writeBytes(buffers.shift());
      }
      else
      {
        dst.writeBytes(buf, 0, n);

        var size:Int = buf.length - n;
        var newBuf:ByteArray = new ByteArray(size);
        buffers[0].position = n;
        buffers[0].readBytes(newBuf, 0, size);
        buffers[0] = newBuf;
      }

      n -= buf.length;
    }while (n > 0);

    dst.position = 0;
    return dst;
  }

}
