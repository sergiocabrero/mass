package Classes
{
	public class ModelPropertyChangeEventKind
	{
		public static var ADDED_MANET_NODE:String = "AddedManetNode";
		public static var SET_MANET_NODE:String = "SetManetNode";
		public static var REMOVED_MANET_NODE:String = "RemovedManetNode";
		public static var CLEAR_MANET_NODES_TABLE:String = "ClearManetNodesTable";
		public static var SET_MANET_NODE_ID:String = "SetManetNodeId";
		public static var SET_MANET_NODE_RANGE:String = "SetManetNodeRange";
		public static var SET_MANET_NODE_COLOUR:String = "SetManetNodeColour";
		public static var SET_MANET_NODE_DIRECTION:String = "SetManetNodeDirection";
		public static var SET_MANET_NODE_NAME:String = "SetManetNodeName";
		public static var SET_MANET_NODE_PATTERN:String = "SetManetNodePattern";
		public static var SET_MANET_NODE_STATE:String = "SetManetNodeState";
		
		public static var SET_MANET_NODE_MOVEMENT:String = "SetManetNodeMovement";
		public static var REMOVED_MANET_NODE_MOVEMENT:String = "RemovedManetNodeMovement";
		public static var REMOVED_MANET_NODE_CHECKPOINT:String = "RemovedManetNodeCheckpoint";
		public static var UPDATED_MANET_NODE_CHECKPOINT:String = "UpdatedManetNodeCheckpoint";
		public static var ADDED_MANET_NODE_CHECKPOINT:String = "AddedManetNodeCheckpoint";
		
		public static var SET_SCENARIO_INIT_TIME:String = "SetScenarioInitTime";
		public static var SET_SCENARIO_END_TIME:String = "SetScenarioEndTime";
		public static var SET_SCENARIO_WIDTH:String = "SetScenarioWidth";
		public static var SET_SCENARIO_HEIGHT:String = "SetScenarioHeight";
		public static var SET_SCENARIO_DEPTH:String = "SetScenarioDepth";
		public static var SET_SCENARIO_BACKGROUND_IMAGE_PATH:String = "SetScenarioBackgroundImagePath";
		public static var SET_GOOGLEMAP:String = "SetGoogleMap"; //FR
		public static var GEOCODING_COMPLETED:String = "GeocodingCompleted"; //FR
		public static var SET_SCENARIO_EASTERN_POSITION:String = "SetScenarioEasternPosition"; //FR
		public static var SET_SCENARIO_SOUTHERN_POSITION:String = "SetScenarioSouthernPosition"; //FR
		public static var SET_TRACES:String = "SetTraces"; //FR
		public static var SET_CONNECTED:String = "SetConnected"; //FR
		public static var UPDATED_MANET_NODE_STATE:String = "UpdatedManetNodeState"; //FR
		public static var GOOGLE_MOBILITY_VALUE:String = "GoogleMobilityValue"; //FR
		
		public function ModelPropertyChangeEventKind()
		{
		}

	}
}