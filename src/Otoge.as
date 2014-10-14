package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.setInterval;
	
	[SWF(width="640", height="420", backgroundColor="0", frameRate="60")]
	public class Otoge extends Sprite
	{
		private var lane:World;
		
		public function Otoge()
		{
			this.lane = new World(0, 0, 64, 42, 640, 420);
			addChild(this.lane);
			lane.x = stage.stageWidth/2;
			lane.y = stage.stageHeight/2;
			
			setInterval(function():void{
				lane.addNote(new Note(Math.random(), 0, 0, 0));
			}, 500);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(e:Event):void
		{
//			lane.rect_x = mouseX - 480;
//			lane.rect_y = mouseY - 320;
			lane.update();
		}
	}
}
import flash.display.Sprite;

class World extends Sprite
{
	public var rect_x:Number;
	public var rect_y:Number;
	private var rect_width:Number;
	private var rect_height:Number;
	private var screen_width:Number;
	private var screen_height:Number;
	private var notes:Vector.<Note>;
	
	public function World(rect_x:Number, rect_y:Number, rect_width:Number, rect_height:Number, screen_width:Number, screen_height:Number)
	{
		this.rect_x = rect_x;
		this.rect_y = rect_y;
		this.rect_width = rect_width;
		this.rect_height = rect_height;
		this.screen_width = screen_width;
		this.screen_height = screen_height;
		this.notes = new Vector.<Note>();
		this.draw();
	}
	
	public function draw():void
	{
		this.graphics.clear();
		this.graphics.lineStyle(1, 0xFFFFFF);
		this.graphics.drawRect(this.rect_x - this.rect_width / 2, this.rect_y - this.rect_height / 2, this.rect_width, this.rect_height);
		this.graphics.moveTo(-this.screen_width / 2, -this.screen_height / 2);
		this.graphics.lineTo(this.rect_x - this.rect_width / 2, this.rect_y - this.rect_height / 2);
		this.graphics.moveTo(this.screen_width / 2, -this.screen_height / 2);
		this.graphics.lineTo(this.rect_x + this.rect_width / 2, this.rect_y - this.rect_height / 2);
		this.graphics.moveTo(-this.screen_width / 2, this.screen_height / 2);
		this.graphics.lineTo(this.rect_x - this.rect_width / 2, this.rect_y + this.rect_height / 2);
		this.graphics.moveTo(this.screen_width / 2, this.screen_height / 2);
		this.graphics.lineTo(this.rect_x + this.rect_width / 2, this.rect_y + this.rect_height / 2);
		
		for (var i:uint = 0; i < this.notes.length; i++) {
			this.drawNote(notes[i]);
		}
	}
	
	private function drawNote(note:Note):void
	{
		var x1:Number = this.rect_x - this.rect_width / 2 + note.x * this.rect_width;
		var x2:Number = this.screen_width * note.x - this.screen_width / 2;
		var y1:Number = (this.screen_height / 2 - (this.rect_y + this.rect_height / 2));
		var y2:Number = (this.screen_height / 2 - (this.rect_y + this.rect_height / 2)) * note.y * note.y * note.y;
		this.graphics.drawCircle(x1 + (x2 - x1) * y2 / y1, (this.rect_y + this.rect_height / 2) + y2, 5);
	}
	
	public function addNote(note:Note):void
	{
		this.notes.push(note);
	}
	
	public function update():void
	{
		for (var i:uint = 0; i < this.notes.length; i++) {
			this.notes[i].y += 0.005;
		}
		
		this.draw();
	}
}

class Note
{
	public var x:Number;
	public var y:Number;
	public var width:Number;
	public var height:Number;
	
	public function Note(x:Number, y:Number, width:Number, height:Number)
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}
}