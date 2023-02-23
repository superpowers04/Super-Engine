package onlinemod;

import openfl.utils.ByteArray;


class DataTypes
{
  public static var UINT(default, never) = new DataType(4, false).id;
  public static var INT(default, never) = new DataType(4, false).id;
  public static var UBYTE(default, never) = new DataType(1, false).id;
  public static var BYTE(default, never) = new DataType(1, false).id;
  public static var STRING(default, never) = new DataType(2, true).id;
  public static var FILE(default, never) = new DataType(4, true).id;
}

class DataTypesShit
{
  public static var datatypes:Array<DataType> = [];
}

class Packets
{
  public static var SEND_CLIENT_TOKEN(default, never) = new Packet("SEND_CLIENT_TOKEN",[DataTypes.UINT]).id;
  public static var SEND_SERVER_TOKEN(default, never) = new Packet("SEND_SERVER_TOKEN",[DataTypes.UINT]).id;
  public static var SEND_PASSWORD(default, never) = new Packet("SEND_PASSWORD",[DataTypes.STRING]).id;
  public static var PASSWORD_CONFIRM(default, never) = new Packet("PASSWORD_CONFIRM",[DataTypes.UBYTE]).id;
  public static var SEND_NICKNAME(default, never) = new Packet("SEND_NICKNAME",[DataTypes.STRING]).id;
  public static var NICKNAME_CONFIRM(default, never) = new Packet("NICKNAME_CONFIRM",[DataTypes.UBYTE]).id;
  public static var BROADCAST_NEW_PLAYER(default, never) = new Packet("BROADCAST_NEW_PLAYER",[DataTypes.UBYTE, DataTypes.STRING]).id;
  public static var END_PREV_PLAYERS(default, never) = new Packet("END_PREV_PLAYERS",[]).id;
  public static var JOINED_LOBBY(default, never) = new Packet("JOINED_LOBBY",[]).id;
  public static var PLAYER_LEFT(default, never) = new Packet("PLAYER_LEFT",[DataTypes.UBYTE]).id;
  public static var GAME_START(default, never) = new Packet("GAME_START",[DataTypes.STRING, DataTypes.STRING]).id;
  public static var GAME_READY(default, never) = new Packet("GAME_READY",[]).id;
  public static var PLAYERS_READY(default, never) = new Packet("PLAYERS_READY",[DataTypes.UBYTE]).id;
  public static var EVERYONE_READY(default, never) = new Packet("EVERYONE_READY",[DataTypes.UBYTE]).id;
  public static var SEND_SCORE(default, never) = new Packet("SEND_SCORE",[DataTypes.INT]).id;
  public static var BROADCAST_SCORE(default, never) = new Packet("BROADCAST_SCORE",[DataTypes.UBYTE, DataTypes.INT]).id;
  public static var GAME_END(default, never) = new Packet("GAME_END",[]).id;
  public static var FORCE_GAME_END(default, never) = new Packet("FORCE_GAME_END",[]).id;
  public static var SEND_CHAT_MESSAGE(default, never) = new Packet("SEND_CHAT_MESSAGE",[DataTypes.UBYTE, DataTypes.STRING]).id;
  public static var REJECT_CHAT_MESSAGE(default, never) = new Packet("REJECT_CHAT_MESSAGE",[DataTypes.UBYTE]).id;
  public static var MUTED(default, never) = new Packet("MUTED",[]).id;
  public static var BROADCAST_CHAT_MESSAGE(default, never) = new Packet("BROADCAST_CHAT_MESSAGE",[DataTypes.UBYTE, DataTypes.STRING]).id;
  public static var SERVER_CHAT_MESSAGE(default, never) = new Packet("SERVER_CHAT_MESSAGE",[DataTypes.STRING]).id;
  public static var READY_DOWNLOAD(default, never) = new Packet("READY_DOWNLOAD",[]).id;
  public static var SEND_CHART(default, never) = new Packet("SEND_CHART",[DataTypes.FILE]).id;
  public static var SEND_VOICES(default, never) = new Packet("SEND_VOICES",[DataTypes.FILE]).id;
  public static var SEND_INST(default, never) = new Packet("SEND_INST",[DataTypes.FILE]).id;
  public static var REQUEST_VOICES(default, never) = new Packet("REQUEST_VOICES",[]).id;
  public static var REQUEST_INST(default, never) = new Packet("REQUEST_INST",[]).id;
  public static var DENY(default, never) = new Packet("DENY",[]).id;
  public static var KEEP_ALIVE(default, never) = new Packet("KEEP_ALIVE",[]).id;
  public static var DISCONNECT(default, never) = new Packet("DISCONNECT",[]).id;
  // Custom packets for custom server
  public static var SUPPORTED(default, never) = new Packet("SUPPORTED",[]).id;
  public static var SEND_CURRENT_INFO(default, never) = new Packet("SEND_CURRENT_INFO",[DataTypes.INT, DataTypes.INT, DataTypes.INT]).id;
  public static var BROADCAST_CURRENT_INFO(default, never) = new Packet("BROADCAST_CURRENT_INFO",[DataTypes.UBYTE, DataTypes.INT, DataTypes.INT, DataTypes.INT]).id;
  public static var KEYPRESS(default, never) = new Packet("KEYPRESS",[DataTypes.INT,DataTypes.INT,DataTypes.INT,DataTypes.INT]).id;
  public static var VERSION(default, never) = new Packet("VERSION",[DataTypes.INT]).id;

  // [PacketName, PacketContents]
  public static var CUSTOMPACKETSTRING(default, never) = new Packet("CUSTOMPACKETSTRING",[DataTypes.STRING,DataTypes.STRING]).id;
  public static var CUSTOMPACKETINT(default, never) = new Packet("CUSTOMPACKETINT",[DataTypes.STRING,DataTypes.INT]).id;
}


class PacketsShit
{
  public static var fields:Array<Packet> = [];
}


class DataType
{
  public var id:Int;
  public var size:Int;
  public var variable:Bool;

  public static var count:Int = 0;

  public function new(size:Int, variable:Bool)
  {
    this.id = count;
    count++;
    this.size = size;
    this.variable = variable;

    DataTypesShit.datatypes.push(this);
  }
}

class Packet
{
  public var id:Int;
  public var types:Array<DataType> = [];
  public var size:Int = 0;
  public var varLengths:Array<Int> = [];
  public var varSpaces:Array<Int> = [];
  public var name:String = "Unknown";

  public static var count:Int = 0;

  public function new(?name:String = "Unspecified Packet Name",types:Array<Int>)
  {
    this.id = count;
    this.name = name;
    count++;
    var lastVar:Int = 0;

    for (t in types)
    {
      var type = DataTypesShit.datatypes[t];
      this.types.push(type);
      if (type.variable)
      {
        varLengths.push(type.size);

        varSpaces.push(size - lastVar);
        lastVar = size - lastVar;
      }

      size += type.size;
    }

    varSpaces.push(size - lastVar);

    PacketsShit.fields.push(this);
  }

  public function handle(buf:ByteArray)
  {
    var arguments:Array<Dynamic> = [];
    var i = 0;
    while (i < types.length)
    {
      switch (types[i].id)
      {
        case DataTypes.UINT:
          arguments.push(buf.readUnsignedInt());
        case DataTypes.INT:
          arguments.push(buf.readInt());
        case DataTypes.UBYTE:
          arguments.push(buf.readUnsignedByte());
        case DataTypes.BYTE:
          arguments.push(buf.readByte());
        case DataTypes.STRING:
          arguments.push(buf.readUTF());
        case DataTypes.FILE:
          var size:Int = buf.readUnsignedInt();
          var bytes:ByteArray = new ByteArray(size);

          buf.readBytes(bytes, 0, size);
          arguments.push(bytes);
      }
      i++;
    }
    return arguments;
  }
}
