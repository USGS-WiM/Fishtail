// 06.16.12 - NE - Updates to model to show more layers.
// 06.13.12 - NE - Initial creation.

// ArrayCollection variable for populating scenario dropdowns with correct dependencies
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.events.FlexEvent;
	
	import spark.components.DropDownList;
	import spark.components.supportClasses.DropDownController;

	private var scenarioModel:ArrayCollection = new ArrayCollection([{
		"_prompt": "Select a species or thermal group ...",
		"_cfg": { },
		"_timePeriodGroup": {
			"_cfg": { },
			"_prompt": "Select a time period...",
			"Current": {
				"_cfg": { },
				"_prompt": "Select a response...",
				"_alias": ['_currentGroupResponse'] // object path to alias node
			},
			"2046 - 2065": {
				"_cfg": { },
				"_prompt": "Select a response...",
				"_alias": ['_futureGroupResponse'] // object path to alias node
			}
		},
		"_timePeriodIndividual": {
			"_cfg": { },
			"_prompt": "Select a time period...",
			"Current": {
				"_cfg": { },
				"_prompt": "Select a response...",
				"_alias": ['_currentIndividualResponse'] // object path to alias node
			},
			"2046 - 2065": {
				"_cfg": { },
				"_prompt": "Select a response...",
				"_alias": ['_futureIndividualResponse'] // object path to alias node
			}
		},
		"_currentGroupResponse": { // Alias node
			"_cfg": { },
			"_prompt": "Select a response...",
			"Predicted occurrence": { }
		},
		"_futureGroupResponse": { // Alias node
			"_cfg": { },
			"_prompt": "Select a response...",
			"Vulnerability": { },
			"Opportunity": { },
			"Sensitivity": { },
			"Number of species lost": { },
			"Number of species gained": { },
			"Number of species lost or gained": { },
			"Percent of 14 modeled species lost": { },
			"Percent of 14 modeled species gained": { }
		},
		"_currentIndividualResponse": { // Alias node
			"_cfg": { },
			"_prompt": "Select a response...",
			"Predicted occurrence": { },
			"Probability of occurrence": { }
		},
		"_futureIndividualResponse": { // Alias node
			"_cfg": { },
			"_prompt": "Select a response...",
			"Vulnerability": { },
			"Opportunity": { },
			"Sensitivity": { }
		},
		"Cold water species" : {
			"_cfg": { },
			"_prompt": "Select a time period...",
			"_alias": ['_timePeriodGroup']
		},
		"Warm water species" : {
			"_cfg": { },
			"_prompt": "Select a time period...",
			"_alias": ['_timePeriodGroup']
		},
		"Cool water species" : {
			"_cfg": { },
			"_prompt": "Select a time period...",
			"_alias": ['_timePeriodGroup']
		},
		"Individual species" : {
			"_cfg": { },
			"_prompt": "Select an individual species...",
			//add individual species list
			"Blackchin Shiner": {
				"_cfg": { },
				"_prompt": "Select a time period...",
				"_alias": ['_timePeriodIndividual']
			},
			"Brook Stickleback": {
				"_cfg": { },
				"_prompt": "Select a time period...",
				"_alias": ['_timePeriodIndividual']
			},
			"Brook Trout": {
				"_cfg": { },
				"_prompt": "Select a time period...",
				"_alias": ['_timePeriodIndividual']
			},
			"Brown Trout": {
				"_cfg": { },
				"_prompt": "Select a time period...",
				"_alias": ['_timePeriodIndividual']
			},
			"Common Carp": {
				"_cfg": { },
				"_alias": ['_timePeriodIndividual']
			},
			"Green Sunfish": {
				"_cfg": { },
				"_prompt": "Select a time period...",
				"_alias": ['_timePeriodIndividual']
			},
			"Iowa Darter": {
				"_cfg": { },
				"_prompt": "Select a time period...",
				"_alias": ['_timePeriodIndividual']
			},
			"Mottled Sculpin": {
				"_cfg": { },
				"_prompt": "Select a time period...",
				"_alias": ['_timePeriodIndividual']
			},
			"Northern Hogsucker": {
				"_cfg": { },
				"_prompt": "Select a time period...",
				"_alias": ['_timePeriodIndividual']
			},
			"Northern Pike": {
				"_cfg": { },
				"_prompt": "Select a time period...",
				"_alias": ['_timePeriodIndividual']
			},
			"Rainbow Trout": {
				"_cfg": { },
				"_prompt": "Select a time period...",
				"_alias": ['_timePeriodIndividual']
			},
			"Redside Dace": {
				"_cfg": { },
				"_prompt": "Select a time period...",
				"_alias": ['_timePeriodIndividual']
			},
			"Slimy Sculpin": {
				"_cfg": { },
				"_prompt": "Select a time period...",
				"_alias": ['_timePeriodIndividual']
			},
			"Smallmouth Bass": {
				"_cfg": { },
				"_prompt": "Select a time period...",
				"_alias": ['_timePeriodIndividual']
			},
			"Stonecat": {
				"_cfg": { },
				"_prompt": "Select a time period...",
				"_alias": ['_timePeriodIndividual']
			},
			"White Sucker": {
				"_cfg": { },
				"_prompt": "Select a time period...",
				"_alias": ['_timePeriodIndividual']
			}
		}
	}]);

	private function dropdownBuild(dropdown:spark.components.DropDownList, modelObject:Object, sort:Boolean, finderArray:Array = null):void {
		/*var dropdownList:ArrayCollection = new ArrayCollection();
		var initialModelObject:Object = modelObject;
		if (finderArray != null) {
			for (var i:int = 0; i < finderArray.length; i++) {
				modelObject = modelObject[finderArray[i]];
			}
		}
		
		for (var item:String in modelObject) {
			if (item.match("_") == null && item != "_alias") {
				dropdownList.addItemAt(item, dropdownList.length);
			} else if (item == "_prompt") {
				dropdown.prompt = modelObject[item];
			} else if (item == "_alias") {
				dropdownList = processAlias(modelObject._alias, initialModelObject);
			}
		}
		
		dropdown.dataProvider = dropdownList;
		dropdown.selectedIndex = -1;
		
		if (sort == true) {
			sortComboLists(dropdownList);
			dropdownList.refresh();
		}*/
		
		//scenarioUpdate();
	}

	private function speciesSelectChange():void {
		/*var targetDropdown:spark.components.DropDownList;
		var speciesSelected:String = speciesSelect.selectedItem;
		if (speciesSelected == "Individual species") {
			targetDropdown = indSpeciesSelect;
			dropdownBuild(targetDropdown, scenarioModel.getItemAt(0), true, [speciesSelected]);
		} else {
			//targetDropdown = timePeriodSelect;
			indSpeciesSelect.dataProvider = null;
		}*/
	}

	private function indSpeciesSelectChange():void {
		/*var targetDropdown:spark.components.DropDownList = timePeriodSelect;
		var speciesSelected:String = speciesSelect.selectedItem;
		var indSpeciesSelected:String = indSpeciesSelect.selectedItem;
		dropdownBuild(targetDropdown, scenarioModel.getItemAt(0), true, [speciesSelected,indSpeciesSelected]);*/
	}

	private function timePeriodSelectChange():void {
		/*var targetDropdown:spark.components.DropDownList = fishResponseLate20Select;
		var speciesSelected:String = speciesSelect.selectedItem;
		var indSpeciesSelected:String = indSpeciesSelect.selectedItem;
		//var timePeriodSelected:String = timePeriodSelect.selectedItem;
		var timePeriodSelected:String = timeOpt.selectedValue.toString();
		var finderArray:Array;
		if (speciesSelected == "Individual species") {
			finderArray = ["_timePeriodIndividual",timePeriodSelected];
		} else {
			finderArray = ["_timePeriodGroup",timePeriodSelected];
		}
		dropdownBuild(targetDropdown, scenarioModel.getItemAt(0), false, finderArray);*/
	}

	private function processAlias(aliasObject:Object, modelObject:Object):ArrayCollection {
		var dropdownList:ArrayCollection = new ArrayCollection();
		var aliasItemsObject:Object = modelObject[aliasObject];
		
		for (var item:String in aliasItemsObject) {
			if (item.match("_") == null) {
				dropdownList.addItemAt(item, dropdownList.length);
			}
		}
		
		return dropdownList;
	}

	private function sortComboLists(listCollection:ArrayCollection):void {
		var sort:Sort = new Sort();
		sort.fields = [new SortField(null, true)];
		listCollection.sort = sort;
		listCollection.refresh();
	}