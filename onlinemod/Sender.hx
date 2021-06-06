package onlinemod;

import flixel.FlxG;

import openfl.net.Socket;

import onlinemod.Packets.DataType;
import onlinemod.Packets.DataTypes;
import onlinemod.Packets.PacketsShit;

class Sender
{
  public static function SendPacket(packetId:Int, arguments:Array<Dynamic>, socket:Socket)
  {
    if (socket == null || !socket.connected){
      FlxG.switchState(new OnlinePlayMenuState("Disconnected from server"));
      return;
    }

    var i:Int = 0;
    var types:Array<DataType> = PacketsShit.fields[packetId].types;

    socket.writeByte(packetId);

    // For every element in the array, write the corresponding data to the socket.
    for (type in types)
    {
      switch (type.id)
      {
        case DataTypes.UINT:
          socket.writeUnsignedInt(arguments[i]);
        case DataTypes.INT:
          socket.writeInt(arguments[i]);
        case DataTypes.UBYTE:
          socket.writeByte(arguments[i]);
        case DataTypes.BYTE:
          socket.writeByte(arguments[i]);
        case DataTypes.STRING:
          socket.writeUTF(arguments[i]);
        case DataTypes.FILE:

      }
      i++;
    }

    if (socket != null && socket.connected)
      socket.flush();
  }
}
