package CustomComponents
{
import flash.events.MouseEvent;

import mx.controls.CheckBox;
import mx.controls.DataGrid;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.events.DataGridEvent;

public class CheckBoxHeaderRenderer2 extends CheckBox
{

	public function CheckBoxHeaderRenderer2()
	{
		super();
		this.selected = true;
	}

	private var _data:DataGridColumn;

	override public function get data():Object
	{
		return _data;
	}

	override public function set data(value:Object):void
	{
		_data = value as DataGridColumn;
		DataGrid(listData.owner).addEventListener(DataGridEvent.HEADER_RELEASE, sortEventHandler);
		DataGrid(listData.owner).addEventListener(MouseEvent.CLICK, clickEventHandler);
	}

	private function sortEventHandler(event:DataGridEvent):void
	{
		if (event.itemRenderer == this)
			event.preventDefault();
	}

	private function clickEventHandler(event:MouseEvent):void
	{
		try
		{			
			var preSel:Boolean = true;
				for (var i:String in DataGrid(listData.owner).dataProvider)
				{
					if(DataGrid(listData.owner).dataProvider[i][data.dataField] == false)
					{
						preSel = false;
						break;
					}	
				}//end for
			selected = preSel;
		}
		catch(te:Error)
		{
			
		}			
	}

	override protected function clickHandler(event:MouseEvent):void
	{
		super.clickHandler(event);
		//Hace que se actualice toda la columna
		data.clearStyle("");
	}

}

}