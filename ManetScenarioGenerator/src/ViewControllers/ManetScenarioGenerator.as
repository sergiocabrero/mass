// ActionScript file

			import Classes.DisplayPropertiesSingleton;
			import Classes.DisplayPropertyChangeEventKind;
			import Classes.ModelPropertyChangeEventKind;
			import Classes.ModelPropertyChangeEventType;
			import Classes.ModelSingleton;
			
			import Entities.ManetNode;
			
			import mx.events.PropertyChangeEvent;
			import mx.events.PropertyChangeEventKind;
			
			private var myInstance:ModelSingleton;
			private var displayPropertiesInstance:DisplayPropertiesSingleton;
			private var modelInstance:ModelSingleton;

			
			private function manetnodestablechange(event:PropertyChangeEvent):void
			{
				trace("cambio de tabla nodos");
				
			}
			
			private function scenariopropertieschange(event:PropertyChangeEvent):void
			{
				trace("cambio de propiedades de escenario");
			}

			private function manetnodechange(event:PropertyChangeEvent):void
			{
				trace("cambio de un nodo");
			}

			private function displayProperties_changeEvent_handler(event:PropertyChangeEvent):void
			{
				switch (event.kind)
				{
					case DisplayPropertyChangeEventKind.SCALE_FACTOR_CHANGE_EVENT:
						this.sciScale.scaleFactor = Number(event.newValue);
						break;	
					case DisplayPropertyChangeEventKind.MOUSE_XCOORD_SCENARIO_CHANGE:
						this.mcvScenarioField.setCoordinates(Number(event.newValue), DisplayPropertiesSingleton.getSingletonInstance().mouseScenarioYcoord);
						break;
					case DisplayPropertyChangeEventKind.MOUSE_YCOORD_SCENARIO_CHANGE:
						this.mcvScenarioField.setCoordinates(DisplayPropertiesSingleton.getSingletonInstance().mouseScenarioXcoord, Number(event.newValue));
						break;	
				}				
			}
			
			private function model_changeEvent_handler(event:PropertyChangeEvent):void
			{
				if (event.kind == ModelPropertyChangeEventKind.SET_MANET_NODE_ID)
				{
					this.displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
					this.displayPropertiesInstance.setManetNodeId(ManetNode(event.oldValue).id, ManetNode(event.newValue).id);
				}	
			}
			
			private function initializeApplication_handler(event:Event):void
			{
				this.displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();
				this.modelInstance = ModelSingleton.getSingletonInstance();
				
				this.displayPropertiesInstance.addEventListener(PropertyChangeEventKind.UPDATE, displayProperties_changeEvent_handler);
				this.modelInstance.addEventListener(ModelPropertyChangeEventType.MANETNODE_CHANGE_EVENT, model_changeEvent_handler);

				
			}
			
			