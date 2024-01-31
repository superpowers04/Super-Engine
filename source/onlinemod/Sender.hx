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
	try{
	  var i:Int = 0;
	  var types:Array<DataType> = PacketsShit.fields[packetId].types;

	  socket.writeByte(packetId);

	  // For every element in the array, write the corresponding data to the socket.
	  while (i < types.length)
	  {
		switch (types[i].id)
		{
		  case DataTypes.UINT:
			socket.writeUnsignedInt(arguments[i]);
		  case DataTypes.INT:
			socket.writeInt(arguments[i]);
		  case DataTypes.UBYTE | DataTypes.BYTE:
			socket.writeByte(arguments[i]);
		  case DataTypes.STRING:
			socket.writeUTF(arguments[i]);
		  case DataTypes.FILE:

		}
		i++;
	  }
	if(OnlineHostMenu.socket != null){

		var pktName:String = 'Unknown ID ${packetId}';
		if(Packets.PacketsShit.fields[packetId] != null){
			pktName = Packets.PacketsShit.fields[packetId].name;
		}
		trace('Sending $pktName with data $arguments');
	}

	  if (socket != null && socket.connected)
		socket.flush();
	  else
		trace('how the fuck did the socket disconnect');
	}catch(e){
	  FlxG.switchState(new OnlinePlayMenuState(e.message));
	  return;
	}
  }
}
