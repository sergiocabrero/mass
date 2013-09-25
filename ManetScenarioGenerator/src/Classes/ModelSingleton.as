package Classes
{
    import Entities.*;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    
    import mx.events.PropertyChangeEvent;

    //Singleton para el acceso al modelo de datos (nodos, movimientos, estados y propiedades del escenario)
    public class ModelSingleton extends EventDispatcher
    {

         private static var _instance:ModelSingleton;

         protected var _modelManetNodesTable:ManetNodesTable;
         protected var _modelScenarioProperties:ScenarioProperties;

         protected var _displayPropertiesInstance:DisplayPropertiesSingleton;

         //public var modelScenarioPropertiesProxy:ObjectProxy;
         public var scenarioPropertiesCallableProxy:CallableScenarioPropertiesProxy;
         public var scenarioPropertiesReadableProxy:ReadableScenarioPropertiesProxy;
         public var manetNodesTableCallableProxy:CallableManetNodesTableProxy;
         public var manetNodesTableReadableProxy:ReadableManetNodesTableProxy;

         protected var _lockedEvents:Boolean = false;

         //Constructor
        public function ModelSingleton()
        {
            this._modelManetNodesTable = new ManetNodesTable();
            this.manetNodesTableCallableProxy = new CallableManetNodesTableProxy(this._modelManetNodesTable);
            this.manetNodesTableReadableProxy = new ReadableManetNodesTableProxy(this._modelManetNodesTable);

            this._displayPropertiesInstance = DisplayPropertiesSingleton.getSingletonInstance();

            var tempDate:Date = new Date("01/01/2009");
            //this._modelScenarioProperties = new ScenarioProperties(tempDate, 400, 300, 100, "");
            this._modelScenarioProperties = new ScenarioProperties(null, 400, 300, 100, "");
            this.scenarioPropertiesCallableProxy = new CallableScenarioPropertiesProxy(this._modelScenarioProperties);

            this._modelManetNodesTable.addEventListener(ModelPropertyChangeEventType.MANETNODESTABLE_CHANGE_EVENT, manetNodesTableProxy_handler);
            this._modelScenarioProperties.addEventListener(ModelPropertyChangeEventType.SCENARIOPROPERTIES_CHANGE_EVENT, scenarioPropertiesProxy_handler);
            this._modelManetNodesTable.addEventListener(ModelPropertyChangeEventType.MANETNODE_CHANGE_EVENT, manetNode_handler);

            this._displayPropertiesInstance.addEventListener(DisplayPropertyChangeEventKind.CLEAR_SCENARIO_EVENT, clearScenarioEvent_handler);
        }


        //Metodo que devuelve la instancia del singleton
        public static function getSingletonInstance():ModelSingleton
        {
            if (ModelSingleton._instance == null)
            {
                ModelSingleton._instance = new ModelSingleton();
            }
            return _instance;
        }

        //Manejador de eventos MANETNODE_CHANGE_EVENT (cambios sobre un nodo)
        protected function manetNode_handler(event:PropertyChangeEvent):void
        {
            try
            {
                var newEvent:PropertyChangeEvent = new PropertyChangeEvent(ModelPropertyChangeEventType.MANETNODE_CHANGE_EVENT, event.bubbles, event.cancelable, event.kind, event.property, event.oldValue
                , event.newValue, event.source);

                dispatchEvent(newEvent);


                var tempMovF:Movement = this._modelManetNodesTable.getManetNodeFirstMovement(ManetNode(event.newValue).id);
                var tempMovL:Movement = this._modelManetNodesTable.getManetNodeLastMovement(ManetNode(event.newValue).id);
                //Comprobamos si tras el cambio, hay que actualizar los tiempos de inicio o fin del escenario
                if(this._modelScenarioProperties.initTime != null && tempMovF != null &&
                    tempMovF.fromTimestampPositionCheckpoint.pointTime.time < this._modelScenarioProperties.initTime.time)
                {
                    this._modelScenarioProperties.initTime = new Date(tempMovF.fromTimestampPositionCheckpoint.pointTime.time);
                }
                else if(this._modelScenarioProperties.initTime == null)
                {
                    this._modelScenarioProperties.initTime = new Date(tempMovF.fromTimestampPositionCheckpoint.pointTime.time);
                }


                if(this._modelScenarioProperties.endTime != null && tempMovL != null &&
                    tempMovL.toTimestampPositionCheckpoint.pointTime.time > this._modelScenarioProperties.endTime.time)
                {
                    this._modelScenarioProperties.endTime = new Date(tempMovL.toTimestampPositionCheckpoint.pointTime.time);
                }
                else if(this._modelScenarioProperties.endTime == null)
                {
                    this._modelScenarioProperties.endTime = new Date(tempMovL.toTimestampPositionCheckpoint.pointTime.time);
                }
            }
            catch(thrownError:Error)
            {
                trace("Error!!: " + thrownError.message);
            }
        }

        //Manejador de eventos MANETNODESTABLE_CHANGE_EVENT (cambios sobre la tabla de nodos)
        private function manetNodesTableProxy_handler(event:PropertyChangeEvent):void
        {
            var newEvent:PropertyChangeEvent = new PropertyChangeEvent(ModelPropertyChangeEventType.MANETNODESTABLE_CHANGE_EVENT, event.bubbles, event.cancelable, event.kind, event.property, event.oldValue
            , event.newValue, event.source);

            dispatchEvent(newEvent);
        }

        //Manejador de eventos SCENARIOPROPERTIES_CHANGE_EVENT (cambios en propiedades del escenario)
        private function scenarioPropertiesProxy_handler(event:PropertyChangeEvent):void
        {
            var newEvent:PropertyChangeEvent = new PropertyChangeEvent(ModelPropertyChangeEventType.SCENARIOPROPERTIES_CHANGE_EVENT, event.bubbles, event.cancelable, event.kind, event.property, event.oldValue
            , event.newValue, event.source);
            dispatchEvent(newEvent);
        }

        //Manejador de evento CLEAR_SCENARIO_EVENT (limpiar escenario)
        private function clearScenarioEvent_handler(event:Event):void
        {
            this._modelManetNodesTable.clearAll();
            this._modelScenarioProperties.initialize();
        }

        //Cierra o abre el despacho de eventos sobre los nodos, tabla de nodos y propiedades del escenario
        public function lockDispatchModelEvents(lock:Boolean):void
        {
            this._lockedEvents = lock;
            //Si se desbloquea el modelo se lanza un evento para que la vista trate de actualizarse
            if (!lock)
            {
                dispatchEvent(new Event(ModelPropertyChangeEventType.MODEL_UNLOCKED_EVENT));
            }
        }
        
        //FR
        public function lockDispatchSaveEvent(lock:Boolean):void
        {
            this._lockedEvents = lock;
            //Si se desbloquea el modelo se lanza un evento para que la vista trate de actualizarse
            if (!lock)
            {
                dispatchEvent(new Event(ModelPropertyChangeEventType.SAVE_FILE_EVENT));
            }
        }
        
        public function lockDispatchMapAfterSavingEvent(lock:Boolean):void
        {
            this._lockedEvents = lock;
            //Si se desbloquea el modelo se lanza un evento para que la vista trate de actualizarse
            if (!lock)
            {
                dispatchEvent(new Event(ModelPropertyChangeEventType.MAP_AFTER_SAVING_EVENT));
            }
        }
        
        public function lockDispatchTracesModelEvents(lock:Boolean):void
        {
            this._lockedEvents = lock;
            //Si se desbloquea el modelo se lanza un evento para que la vista trate de actualizarse
            if (!lock)
            {
                dispatchEvent(new Event(ModelPropertyChangeEventType.TRACES_MODEL_UNLOCKED_EVENT));
            }
        }
        
        public function lockDispatchKMLorGPXSaveEvent(lock:Boolean):void
        {
            this._lockedEvents = lock;
            //Si se desbloquea el modelo se lanza un evento para que la vista trate de actualizarse
            if (!lock)
            {
                dispatchEvent(new Event(ModelPropertyChangeEventType.SAVE_KML_OR_GPX_FILE_EVENT));
            }
        }
        
        public function lockDispatchCheckConnectionEvent(lock:Boolean):void
        {
            this._lockedEvents = lock;
            //Si se desbloquea el modelo se lanza un evento para que la vista trate de actualizarse
            if (!lock)
            {
                dispatchEvent(new Event(ModelPropertyChangeEventType.CHECK_CONNECTION_EVENT));
            }
        }
        
        public function lockDispatchSetGoogleMobilityValueEvent(lock:Boolean):void
        {
            this._lockedEvents = lock;
            //Si se desbloquea el modelo se lanza un evento para que la vista trate de actualizarse
            if (!lock)
            {
                dispatchEvent(new Event(ModelPropertyChangeEventType.SET_GOOGLE_MOBILITY_VALUE));
            }
        }
        //FR

        //Informa del estado del despacho de eventos cuando se efectuan cambios en los nodos,
        //tabla de nodos o propiedades del escenario
        public function isLocked():Boolean
        {
            return this._lockedEvents;
        }




    }



}
