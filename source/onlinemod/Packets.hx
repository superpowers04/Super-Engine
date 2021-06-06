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
  public static var SEND_CLIENT_TOKEN(default, never) = new Packet([DataTypes.UINT]).id;
  public static var SEND_SERVER_TOKEN(default, never) = new Packet([DataTypes.UINT]).id;
  public static var SEND_PASSWORD(default, never) = new Packet([DataTypes.STRING]).id;
  public static var PASSWORD_CONFIRM(default, never) = new Packet([DataTypes.UBYTE]).id;
  public static var SEND_NICKNAME(default, never) = new Packet([DataTypes.STRING]).id;
  public static var NICKNAME_CONFIRM(default, never) = new Packet([DataTypes.UBYTE]).id;

  public static var BROADCAST_NEW_PLAYER(default, never) = new Packet([DataTypes.UBYTE, DataTypes.STRING]).id;
  public static var END_PREV_PLAYERS(default, never) = new Packet([]).id;
  public static var JOINED_LOBBY(default, never) = new Packet([]).id;
  public static var PLAYER_LEFT(default, never) = new Packet([DataTypes.UBYTE]).id;
  public static var GAME_START(default, never) = new Packet([DataTypes.STRING, DataTypes.STRING]).id;

  public static var GAME_READY(default, never) = new Packet([]).id;
  public static var PLAYERS_READY(default, never) = new Packet([DataTypes.UBYTE]).id;
  public static var EVERYONE_READY(default, never) = new Packet([DataTypes.UBYTE]).id;
  public static var SEND_SCORE(default, never) = new Packet([DataTypes.INT]).id;
  public static var BROADCAST_SCORE(default, never) = new Packet([DataTypes.UBYTE, DataTypes.INT]).id;
  public static var GAME_END(default, never) = new Packet([]).id;
  public static var FORCE_GAME_END(default, never) = new Packet([]).id;

  public static var SEND_CHAT_MESSAGE(default, never) = new Packet([DataTypes.UBYTE, DataTypes.STRING]).id;
  public static var REJECT_CHAT_MESSAGE(default, never) = new Packet([DataTypes.UBYTE]).id;
  public static var MUTED(default, never) = new Packet([]).id;
  public static var BROADCAST_CHAT_MESSAGE(default, never) = new Packet([DataTypes.UBYTE, DataTypes.STRING]).id;
  public static var SERVER_CHAT_MESSAGE(default, never) = new Packet([DataTypes.STRING]).id;

  public static var READY_DOWNLOAD(default, never) = new Packet([]).id;
  public static var SEND_CHART(default, never) = new Packet([DataTypes.FILE]).id;
  public static var SEND_VOICES(default, never) = new Packet([DataTypes.FILE]).id;
  public static var SEND_INST(default, never) = new Packet([DataTypes.FILE]).id;
  public static var REQUEST_VOICES(default, never) = new Packet([]).id;
  public static var REQUEST_INST(default, never) = new Packet([]).id;
  public static var DENY(default, never) = new Packet([]).id;

  public static var KEEP_ALIVE(default, never) = new Packet([]).id;

  public static var DISCONNECT(default, never) = new Packet([]).id;
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

  public static var count:Int = 0;

  public function new(types:Array<Int>)
  {
    this.id = count;
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

    for (type in types)
    {
      switch (type.id)
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
    }
    return arguments;
  }
}
