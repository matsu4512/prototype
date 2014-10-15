package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.utils.setInterval;
	
	[SWF(width="640", height="420", backgroundColor="0", frameRate="60")]
	public class Otoge extends Sprite
	{
		private var lane:World;
		
		public function Otoge()
		{
			this.lane = new World(0, 0, 160, 640, 420, 7);
			addChild(this.lane);
			lane.x = stage.stageWidth/2;
			lane.y = stage.stageHeight/2;
			
			lane.rect_y = -210;
			
			var w:Number = 640/7;
			var h:Number = 5;
			
			lane.addNote(new Note(0, w, h, 0));
			lane.addNote(new Note(0, w, h, 6));
			lane.addNote(new Note(-0.1, w, h, 1));
			lane.addNote(new Note(-0.2, w, h, 2));
			lane.addNote(new Note(-0.3, w, h, 3));
			lane.addNote(new Note(-0.4, w, h, 4));
			lane.addNote(new Note(-0.5, w, h, 5));
			lane.addNote(new Note(-0.6, w, h, 6));
			
			lane.addChargeNote(new Note(-0.7, w, h, 3), new Note(-1.0, w, h, 3));
			
			h = 10;
			lane.addChainNote(Vector.<Note>([
				new Note(-1.20, w, h, 0),
				new Note(-1.22, w, h, 1),
				new Note(-1.24, w, h, 2),
				new Note(-1.26, w, h, 3),
				new Note(-1.28, w, h, 4),
				new Note(-1.30, w, h, 3),
				new Note(-1.32, w, h, 2),
				new Note(-1.34, w, h, 3),
				new Note(-1.36, w, h, 4),
				new Note(-1.38, w, h, 5),
				new Note(-1.40, w, h, 6),
				new Note(-1.42, w, h, 5),
				new Note(-1.44, w, h, 4),
				new Note(-1.46, w, h, 3),
				new Note(-1.48, w, h, 2),
				new Note(-1.50, w, h, 1)
			]));
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(e:Event):void
		{
			lane.update();
		}
	}
}
import flash.display.GradientType;
import flash.display.Sprite;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.geom.Rectangle;

import flashx.textLayout.elements.GlobalSettings;

class World extends Sprite
{
	public var rect_x:Number;
	public var rect_y:Number;
	private var rect_width:Number;
	private var screen_width:Number;
	private var screen_height:Number;
	private var lane_num:uint;
	private var notes:Vector.<Note>;
	private var judge_line:JudgeLine;
	private var particles:Vector.<Particle>;
	
	public function World(rect_x:Number, rect_y:Number, rect_width:Number, screen_width:Number, screen_height:Number, lane_num:uint = 7)
	{
		this.rect_x = rect_x;
		this.rect_y = rect_y;
		this.rect_width = rect_width;
		this.screen_width = screen_width;
		this.screen_height = screen_height;
		this.lane_num = lane_num;
		this.notes = new Vector.<Note>();
		this.draw();
		
		this.judge_line = new JudgeLine(screen_width, 1);
		this.judge_line.y = 180;
		this.judge_line.x = -screen_width/2;
		this.addChild(this.judge_line);
		
		this.particles = new Vector.<Particle>();
	}
	
	public function draw():void
	{
		this.graphics.clear();
		this.graphics.lineStyle(1, 0xFFFFFF);
		var m:Matrix = new Matrix();
		m.createGradientBox(this.screen_width, this.screen_height, Math.PI/2, -this.screen_width/2, -this.screen_height/2);
		this.graphics.lineGradientStyle(GradientType.LINEAR, [0xFFFFFF, 0xFFFFFF, 0xFFFFFF], [0, 1, 1], [0, 100, 255], m);
		this.graphics.moveTo(-this.screen_width / 2, this.screen_height / 2);
		this.graphics.lineTo(this.rect_x - this.rect_width / 2, this.rect_y);
		this.graphics.moveTo(this.screen_width / 2, this.screen_height / 2);
		this.graphics.lineTo(this.rect_x + this.rect_width / 2, this.rect_y);
		
		for (var i:uint = 0; i < this.notes.length; i++) {
			this.drawNote(notes[i]);
		}
	}
	
	private function calcRect(note:Note):Rectangle
	{
		var x1:Number = this.rect_x - this.rect_width / 2 + ((note.lane + 0.5) / this.lane_num) * this.rect_width;
		var x2:Number = this.screen_width * ((note.lane + 0.5) / this.lane_num) - this.screen_width / 2;
		var y1:Number = (this.screen_height / 2 - this.rect_y);
		var y2:Number = (this.screen_height / 2 - this.rect_y) * note._y * note._y * note._y;
		var w:Number = (this.screen_width - this.rect_width) / this.lane_num * y2 / y1 + this.rect_width / this.lane_num;
		var h:Number = 5 * y2 / y1;
		note.scaleX = note.scaleY = w / note.w;
		return new Rectangle(x1 + (x2 - x1) * y2 / y1 - w / 2, this.rect_y + y2 - h / 2, w, h);
	}
	
	private function drawNote(note:Note):void
	{
		var rect:Rectangle = this.calcRect(note);
		note.x = rect.x;
		note.y = rect.y;
		if (note.type == 0) {
		} else if (note.type == 1) {
			if (note.next != null) { 
				var rect2:Rectangle = this.calcRect(note.next);
				this.graphics.moveTo(rect.x, rect.y);
				this.graphics.lineTo(rect2.x, rect2.bottom);
				this.graphics.moveTo(rect.right, rect.y);
				this.graphics.lineTo(rect2.right, rect2.bottom);
			}			
		} else if (note.type == 2) {
			if (note.next != null) { 
				var rect2:Rectangle = this.calcRect(note.next);
				this.graphics.moveTo(rect.x + rect.width / 2, rect.y + rect.height / 2);
				this.graphics.lineTo(rect2.x + rect2.width / 2, rect2.y + rect2.height / 2);
			}
		}
	}
	
	public function explode(n:uint, color:uint, x:Number, y:Number):void
	{
		for (var i:uint = 0; i < n; i++) {
			var t:Number = 2 * Math.PI * Math.random();
			var v:Number = Math.random() * 3 + 2;
			var p:Particle = new Particle(color, Math.random() * 3 + 1, Math.cos(t) * v, Math.sin(t) * v);
			this.particles.push(p);
			this.addChild(p);
			p.x = x;
			p.y = y;
		}
	}
	
	public function explode2():void
	{
		
	}
	
	public function addNote(note:Note):void
	{
		this.notes.push(note);
		this.addChild(note);
		note.draw();
	}
	
	public function addChargeNote(note1:Note, note2:Note):void
	{
		note1.type = note2.type = 1;
		note1.next = note2;
		this.addNote(note1);
		this.addNote(note2);
	}
	
	public function addChainNote(notes:Vector.<Note>):void
	{
		for (var i:uint = 0; i < notes.length; i++) {
			notes[i].type = 2;
			if (i < notes.length - 1) {
				notes[i].next = notes[i+1];
			}
			this.addNote(notes[i]);
		}
	}
	
	public function update():void
	{
		var i:uint = this.notes.length;
		while (i--) {
			this.notes[i]._y += 0.005;
			if (this.notes[i]._y > 2) {
				this.notes.splice(i, 1);
			}
			
			if (this.notes[i]._y < 0.98 && this.notes[i]._y + 0.005 >= 0.98) {
				this.notes[i].visible = false;
				explode(20, 0xFF0000, this.notes[i].x + this.notes[i].width/2, this.notes[i].y);
			}
		}
		
		i = this.particles.length;
		while (i--) {
			var p:Particle = this.particles[i];
			p.x += p.vx;
			p.y += p.vy;
			p.alpha -= p.va;
			if (p.alpha < 0) {
				this.particles.splice(i, 1);
				this.removeChild(p);
			}
		}
		
		this.draw();
	}
}

class Note extends Sprite
{
	public var _y:Number;
	public var w:Number;
	public var h:Number;
	public var lane:uint;
	public var type:uint; //0:normal, 1:charge, 2:chain
	public var next:Note;
	
	public function Note(y:Number, width:Number, height:Number, lane:uint)
	{
		this._y = y;
		this.w= width;
		this.h= height;
		this.lane = lane;
	}
	
	public function draw():void
	{
		this.graphics.clear();
		this.graphics.lineStyle(1, 0xFFFFFF);
		if (this.type == 0) {
			this.filters = [new GlowFilter(0xFF0000, 1.0, 8.0, 8.0, 2, 1)];
			this.graphics.drawRect(this.x, this.y, this.w, this.h);
		} else if (this.type == 1) {
			this.filters = [new GlowFilter(0xFF, 1.0, 8.0, 8.0, 2, 1)];
			this.graphics.drawRect(this.x, this.y, this.w, this.h);
		} else if (this.type == 2) {
			this.filters = [new GlowFilter(0xFF00, 1.0, 8.0, 8.0, 2, 1)];
			this.graphics.drawCircle(this.x + this.w/ 2, this.y + this.h/ 2, this.h);
		}
	}
}

class JudgeLine extends Sprite
{
	public function JudgeLine(w:Number, h:Number)
	{
		this.graphics.clear();
		this.graphics.lineStyle(h, 0xFFFFFF);
		this.graphics.moveTo(0, 0);
		this.graphics.lineTo(w, 0);
		this.filters = [new GlowFilter(0xFFFF00, 1.0, 8, 8, 2, 1)];
	}
}

class Particle extends Sprite
{
	public var vx:Number;
	public var vy:Number;
	public var va:Number;
	
	public function Particle(color:uint, size:Number, vx:Number, vy:Number)
	{
		this.vx = vx;
		this.vy = vy;
		this.va = Math.random()*0.05 + 0.05;
		
		this.graphics.beginFill(0xFFFFFF);
		this.graphics.drawCircle(0, 0, size);
		this.graphics.endFill();
		this.filters = [new GlowFilter(color, 1.0, 32.0, 32.0, 4, 2)];
	}
}