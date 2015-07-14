import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;

	private var habitatModel:ArrayCollection = new ArrayCollection([{
		"_prompt": "Select a habitat metric ...",
		"_cfg": { },
		"_timePeriodHabitat": {
			"_cfg": { },
			"_prompt": "Select a time period...",
			"Current": {
				"_cfg": { },
				"_prompt": "Select a response...",
				"_alias": ['_currentResponse'] // object path to alias node
			},
			"2046 - 2065": {
				"_cfg": { },
				"_prompt": "Select a response...",
				"_alias": ['_futureResponse'] // object path to alias node
			}
		},
		"_currentResponse": { // Alias node
			"_cfg": { },
			"_prompt": "Select a response...",
			"Thermal class (July mean)": { }
		},
		"_futureResponse": { // Alias node
			"_cfg": { },
			"_prompt": "Select a response...",
			"Thermal class (July mean)": { },
			"Change in thermal class (July mean)": { },
			"Change in degrees (July mean)": { }
		},
		"Stream temperature" : {
			"_cfg": { },
			"_prompt": "Select a time period...",
			"_alias": ['_timePeriodHabitat']
		}
	}]);

	/*private function habitatSelectChange():void {
		var targetDropdown:spark.components.DropDownList;
		var habitatSelected:String = habitatSelect.selectedItem;
		targetDropdown = habitatTimePeriodSelect;
		
		dropdownBuild(targetDropdown, habitatModel.getItemAt(0), true, [habitatSelected]);
	}

	private function habitatTimePeriodSelectChange():void {
		var targetDropdown:spark.components.DropDownList = habitatResponseSelect;
		var habitatSelected:String = habitatSelect.selectedItem;
		var timePeriodSelected:String = habitatTimePeriodSelect.selectedItem;
		var finderArray:Array = ["_timePeriodHabitat", timePeriodSelected];
		
		dropdownBuild(targetDropdown, habitatModel.getItemAt(0), true, finderArray);
	}*/