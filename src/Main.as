package
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.ByteArray;
	import flash.display.Loader;
	import com.bit101.components.*;
	public class Main extends Sprite
	{
		private const SAMPLE_CODE : String = '  push  "i"\r  push  "0"\r  set\r  push  "x"\rloop  push  "i"\r  push  "i"\r  get\r  push  "1"\r  +\r  set\r  push  "29"\r  push  "i"\r  get\r  >\r  !\r  if  loop\r  push  "i"\r  get\r  set\r';
		private var editor : TextArea;
		private var stdout : TextArea;
		private var button : PushButton;
		public function Main()
		{
			Style.fontSize = 10;
			editor = new TextArea(this, 0, 0);
			editor.width = 200;
			editor.height = 420;
			editor.text = SAMPLE_CODE;
			stdout = new TextArea(this, 250, 0);
			stdout.width = 200;
			stdout.height = 420;
			button = new PushButton(this, 200, 220, "abc", function(e : MouseEvent) : void
			{
				stdout.text = "";
				run();
			});
			button.width = 50;
		}
		private function run() : void
		{
			var c1 : int;
			var c2 : int;
			var c3 : int;
			var a : String;
			var i : int;
			var j : int;
			var pc : int = 0;
			var la : Array = new Array();
			var r : ByteArray = new ByteArray();
			var m : Array = String(editor.text).split("\r");
			stdout.text += String(m.length) + "\n";
			for (j = 0; j < m.length ; j++)
			{
				stdout.text += m[j] + "\n";
				var cm : Array = String(m[j]).split("  ");
				if (cm[0] != "") la[cm[0]] = pc + 2; 
				switch (cm[1])
				{
				case "if":
					r[pc] = 0x9D;
					pc++;
					r[pc] = 0x02;
					pc++;
					r[pc] = 0x00;
					pc++;
					if (la[cm[2]] > 1)
					{
						c3 = 255 + la[cm[2]] - pc - 3;
						r[pc] = c3;
						pc++;
						r[pc] = 0xFF;
						pc++;
					}
					else
					{
						r[pc] = cm[2];
						pc++;
						r[pc] = 0x00;
						pc++;
					}
				break;
				case "jump":
					r[pc] = 0x99;
					pc++;
					r[pc] = 0x02;
					pc++;
					r[pc] = 0x00;
					pc++;
					if (la[cm[2]] > 1)
					{
						c3 = 255 + la[cm[2]] - pc - 3;
						r[pc] = c3;
						pc++;
						r[pc] = 0xFF;
						pc++;
					}
					else
					{
						r[pc] = cm[2];
						pc++;
						r[pc] = 0x00;
						pc++;
					}
				break;
				case "push":
					r[pc] = 0x96;
					pc++;
					c1 = cm[2].indexOf("\"") + 1;
					c2 = cm[2].indexOf("\"", 1) - c1;
					a = cm[2].substr(c1, c2);
					c3 = c2 + 2;
					r[pc] = c3;
					pc++;
					r[pc] = 0x00;
					pc++;
					r[pc] = 0x00;
					pc++;
					for (i = 0; i < c2; i++)
					{
						r[pc] = a.charCodeAt(i);
						pc++;
					}
					r[pc] = 0x00;
					pc++;
				break;
				case "end":
					r[pc] = 0x00;
					pc++;
				break;
				case "+":
					r[pc] = 0x0A;
					pc++;
				break;
				case "-":
					r[pc] = 0x0B;
					pc++;
				break;
				case "*":
					r[pc] = 0x0C;
					pc++;
				break;
				case "/":
					r[pc] = 0x0D;
					pc++;
				break;
				case "=":
					r[pc] = 0x0E;
					pc++;
				break;
				case ">":
					r[pc] = 0x0F;
					pc++;
				break;
				case "&":
					r[pc] = 0x10;
					pc++;
				break;
				case "|":
					r[pc] = 0x11;
					pc++;
				break;
				case "!":
					r[pc] = 0x12;
					pc++;
				break;
				case "eq":
					r[pc] = 0x13;
					pc++;
				break;
				case "len":
					r[pc] = 0x14;
					pc++;
				break;
				case "pop":
					r[pc] = 0x17;
					pc++;
				break;
				case "int":
					r[pc] = 0x18;
					pc++;
				break;
				case "get":
					r[pc] = 0x1C;
					pc++;
				break;
				case "set":
					r[pc] = 0x1D;
					pc++;
				break;
				case "add":
					r[pc] = 0x21;
					pc++;
				break;
				case "rnd":
					r[pc] = 0x30;
					pc++;
				break;
				case "time":
					r[pc] = 0x34;
					pc++;
				break;
				}
			}
			for (j = 0; j < la.length; j++)
			{
				for (i = 0; i < pc; i++)
				{
					if (r[i] == la[j])
					{
						c3 = la[j] - i - 4;
						r[i] = c3;
					}
				}
			}
			var ba : ByteArray = new ByteArray();
			for (i = 0; i < 31; i++)
			{
				ba.writeByte(DummyData[i]);
			}
			for (i = 0; i < r.length; i++)
			{
				stdout.text += String(i) + " - " + toHex(r[i]) + "\n";
				ba.writeByte(r[i]);
			}
			for (i = r.length + 31; i < DummyData.length; i++)
			{
				ba.writeByte(DummyData[i]);
			}
			var loader : Loader = new Loader();
			loader.x = 20;
			loader.y = 300;
			loader.loadBytes(ba);
			addChild(loader);
		}
		function toHex(intVal : int) : String 
		{
			var hex : String = intVal.toString(16);
			return (hex.length == 1) ? "0x0" + hex  : "0x" + hex;
		}
		private const DummyData : Array =
		[
			0x46, 0x57, 0x53, 0x04, 0xB0, 0x00, 0x00, 0x00, 0x68, 0x00, 0x10, 0x40, 0x00, 0x04, 0x10, 0x00, 
			0x00, 0x0C, 0x01, 0x00, 0x43, 0x02, 0x33, 0x33, 0x33, 0x3F, 0x03, 0x79, 0x00, 0x00, 0x00, 0x00, 
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
			0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4D, 0x09, 0x01, 0x00, 0x60, 0x0A, 0x3F, 0xC0, 
			0x0A, 0x3F, 0xC0, 0x60, 0x08, 0x78, 0x00, 0x05, 0x01, 0x01, 0x00, 0x01, 0x00, 0x00, 0x40, 0x00
		];
	}
}

