// 11.28.12 - NE - Fixed behavior for NHD streams and lakes toggle vs. habitat or fish response scenarios. Updated release build.
// 06.18.12 - NE - Updates to legend behavior.
// 06.16.12 - NE - Updated scenarioUpdate() to use more of scenario model for results.
// 06.14.12 - NE - Updated scenario updater with correct codes for all species, vul, opp, sens, etc.
// 06.05.12 - NE - Tweaked handling of scenario layer to show layer only if scenario is possible.

// 04.01.11 - JB - Added AS side logic for right-click and mousewheel
// 03.28.11 - JB - Template clean-up and updates 
// 06.28.10 - JB - Added new Wim LayerLegend component
// 03.26.10 - JB - Created
 /***
 * ActionScript file for template */

import com.blogagic.util.HTMLToolTip;
import com.esri.ags.FeatureSet;
import com.esri.ags.Graphic;
import com.esri.ags.events.ExtentEvent;
import com.esri.ags.events.LayerEvent;
import com.esri.ags.events.MapEvent;
import com.esri.ags.events.MapMouseEvent;
import com.esri.ags.geometry.Extent;
import com.esri.ags.geometry.MapPoint;
import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
import com.esri.ags.layers.TiledMapServiceLayer;
import com.esri.ags.layers.supportClasses.LayerInfo;
import com.esri.ags.symbols.InfoSymbol;
import com.esri.ags.tasks.IdentifyTask;
import com.esri.ags.tasks.QueryTask;
import com.esri.ags.tasks.supportClasses.AddressCandidate;
import com.esri.ags.tasks.supportClasses.AddressToLocationsParameters;
import com.esri.ags.tasks.supportClasses.IdentifyParameters;
import com.esri.ags.tasks.supportClasses.Query;
import com.esri.ags.utils.JSON;
import com.esri.ags.utils.WebMercatorUtil;

import controls.skins.WiMInfoWindowSkin;

import flash.display.StageDisplayState;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.FileReference;
import flash.utils.ByteArray;
import flash.utils.describeType;

import flashx.textLayout.events.UpdateCompleteEvent;

import gov.usgs.wim.controls.LayerToggle;
import gov.usgs.wim.controls.WiMInfoWindow;
import gov.usgs.wim.utils.XmlResourceLoader;

import mx.binding.utils.BindingUtils;
import mx.collections.ArrayCollection;
import mx.collections.SortField;
import mx.controls.*;
import mx.core.FlexGlobals;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.core.UIComponent;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.events.IndexChangedEvent;
import mx.events.ResizeEvent;
import mx.managers.CursorManager;
import mx.managers.PopUpManager;
import mx.managers.ToolTipManager;
import mx.resources.ResourceBundle;
import mx.rpc.AsyncResponder;
import mx.rpc.events.ResultEvent;
import mx.utils.Base64Decoder;
import mx.utils.ObjectProxy;

import spark.components.DropDownList;
import spark.components.Group;
import spark.components.HGroup;
import spark.components.SkinnableContainer;
import spark.components.supportClasses.SkinnableComponent;
import spark.events.IndexChangeEvent;

			[Bindable]
			[Embed(source='assets/images/Satellite.png')] 
			private var satelliteIcon:Class;
			[Bindable]
			[Embed(source='assets/images/grayCanvas.png')]
			private var grayCanvasIcon:Class;
			/* Image based on file from Wikimedia Commons and is licensed under https://secure.wikimedia.org/wikipedia/en/wiki/en:GNU_Free_Documentation_License */
			[Bindable]
			[Embed(source='assets/images/mountain.png')] 
			private var mountainIcon:Class;
			[Bindable]
			[Embed(source='assets/images/shield.png')]
			private var streetsIcon:Class;

			private var xmlResourceLoader:XmlResourceLoader = new XmlResourceLoader();

			private var scenarioLayerInfos:Array;
			private var scenarioCatchmentsLayerInfos:Array;
			private var scenarioCatchmentsSmallLayerInfos:Array;
			private var scenarioHUC12LayerInfos:Array;
			private var streamTempLayerInfos:Array;
			private var climateStreamflowLayerInfos:Array;
			private var fishVisSearchLayerInfos:Array;

			private var layerDef:String;
			
			[Bindable]
			private var anyLayerDrew:Boolean;

			private var _queryWindow:WiMInfoWindow;

			private var popUpBoxes:Object = new Object();

			[Bindable]
			private var npsUrlTemplate:String = "http://{subDomain}.tiles.mapbox.com/v3/nps.pt-shaded-relief,nps.pt-urban-areas,nps.pt-river-lines,nps.pt-admin-lines,nps.pt-park-poly,nps.pt-mask,nps.pt-hydro-features,nps.pt-admin-labels,nps.pt-roads,nps.pt-road-shields,nps.pt-park-points,nps.pt-hydro-labels,nps.pt-city-labels,nps.pt-park-labels/{level}/{col}/{row}.png"
			private static const ABCD:Array = [ "a", "b", "c", "d" ];

			private var QWTooltip:String = '<p><b>Attention: </b>Please note that these scores should not be used to compare across states, as scores were created on a state by state basis due to differences in sampling protocol and listing thresholds.</p><br/><br/><p>Placeholder for WQ description</p>';
			
				

			//Initialize mapper
			private function setup():void
			{	
				xmlResourceLoader.load(["locale/en_US", "en_US"]);
				
				ExternalInterface.addCallback("rightClick", onRightClick);
				ExternalInterface.addCallback("handleWheel", handleWheel);
				
				scenarioLayerInfos = scenarios.layerInfos;
				scenarioCatchmentsLayerInfos = scenariosCatchments.layerInfos;
				scenarioCatchmentsSmallLayerInfos = scenariosCatchmentsSmall.layerInfos;
				scenarioHUC12LayerInfos = scenariosHUC12.layerInfos;
				
				//fishVisSearchLayerInfos = fishVisSearch.layerInfos;
				
				ToolTipManager.toolTipClass = HTMLToolTip;
				ToolTipManager.hideDelay = Infinity;
			}

			private function mapLoad():void {
				scenarios.addEventListener(FlexEvent.UPDATE_COMPLETE, getScenarioLayerInfos);
				scenariosCatchments.addEventListener(FlexEvent.UPDATE_COMPLETE, getScenariosCatchmentsLayerInfos);
				scenariosHUC12.addEventListener(FlexEvent.UPDATE_COMPLETE, getScenariosHUC12LayerInfos);
				climateStreamflow.addEventListener(FlexEvent.UPDATE_COMPLETE, getClimateStreamflowLayerInfos);
				//fishVisSearch.addEventListener(FlexEvent.UPDATE_COMPLETE, getFishVisSearchLayerInfos);
			}

			private function loadingScreenEnable():void {
				mapLoadingScreen.visible = true;
			}

			private function getScenarioLayerInfos(event:FlexEvent):void {
				if (scenarioLayerInfos == null) {
					scenarioLayerInfos = scenarios.layerInfos;
				} else {
					scenarios.removeEventListener(FlexEvent.UPDATE_COMPLETE, getScenarioLayerInfos);
				}
			}

			private function getScenariosCatchmentsLayerInfos(event:FlexEvent):void {
				if (scenarioCatchmentsLayerInfos == null) {
					scenarioCatchmentsLayerInfos = scenariosCatchments.layerInfos;
				} else {
					scenariosCatchments.removeEventListener(FlexEvent.UPDATE_COMPLETE, getScenariosCatchmentsLayerInfos);
				}
			}

			private function getScenariosHUC12LayerInfos(event:FlexEvent):void {
				if (scenarioHUC12LayerInfos == null) {
					scenarioHUC12LayerInfos = scenariosHUC12.layerInfos;
				} else {
					scenariosHUC12.removeEventListener(FlexEvent.UPDATE_COMPLETE, getScenariosHUC12LayerInfos);
				}
			}

			private function getClimateStreamflowLayerInfos(event:FlexEvent):void {
				if (climateStreamflowLayerInfos == null) {
					climateStreamflowLayerInfos = climateStreamflow.layerInfos;
				} else {
					climateStreamflow.removeEventListener(FlexEvent.UPDATE_COMPLETE, getClimateStreamflowLayerInfos);
				}
			}

			private function getFishVisSearchLayerInfos(event:FlexEvent):void {
				if (fishVisSearchLayerInfos == null) {
					//fishVisSearchLayerInfos = fishVisSearch.layerInfos;
				} else {
					//fishVisSearch.removeEventListener(FlexEvent.UPDATE_COMPLETE, getFishVisSearchLayerInfos);
				}
			}

			private function onRightClick():void {
				//Recenter at mouse location
				var cursorLocation:Point = new Point(contentMouseX, contentMouseY);
				map.centerAt(map.toMap(cursorLocation));
				//Zoom out
				map.zoomOut();
			}
			
			public function handleWheel(event:Object): void {
				var obj:InteractiveObject = null;
				var objects:Array = getObjectsUnderPoint(new Point(event.x, event.y));
				for (var i:int = objects.length - 1; i >= 0; i--) {
					if (objects[i] is InteractiveObject) {
						obj = objects[i] as InteractiveObject;
						break;
					} else {
						if (objects[i] is Shape && (objects[i] as Shape).parent) {
							obj = (objects[i] as Shape).parent;
							break;
						}
					}
				}
				if (obj) {
					var mEvent:MouseEvent = new MouseEvent(MouseEvent.MOUSE_WHEEL, true, false,
						event.x, event.y, obj,
						event.ctrlKey, event.altKey, event.shiftKey,
						false, -Number(event.delta));
					obj.dispatchEvent(mEvent);
				}
				
			}    	

			private function onExtentChange(event:ExtentEvent):void {
				trace(map.extent);
				trace(map.level);
			}

			private function waterqualimp_clickHandler(event:MouseEvent):void
			{
				northAppEco.selected = true;
				southAppCoastEco.selected = true;
				tempPlainsEco.selected = true;
				upperMidEco.selected = true;
				
				creek.selected = true;
				river.selected = true;
			}

			private function scenarioClear():void {
				//will need code for resetting to entire great lakes basin
				
				//displayByOpt.selectedValue = null;
				//topicOpt.selectedValue = null;
				//speciesSelect.selectedIndex = -1;
				//indSpeciesSelect.selectedIndex = -1;
				//climateVariable.selectedIndex = -1;
				//timeOpt.selectedValue = null;
				
				/*fishResponseLate20Select.selectedIndex = -1;
				indFishResponseLate20Select.selectedIndex = -1;
				groupFishResponseFutureSelect.selectedIndex = -1;
				
				indFishResponseFutureSelect.selectedIndex = -1;
				streamTempResponseSelect.selectedIndex = -1;
				futureStreamTempResponseSelect.selectedIndex = -1;
				
				streamflowReach.selectedIndex = -1;
				streamflowCatch.selectedIndex = -1;
				
				airTempResponses.selectedIndex = -1;
				airTempResponsesFuture.selectedIndex = -1;
				precipitationResponses.selectedIndex = -1;
				precipitationResponsesFuture.selectedIndex = -1;
				
				hucFishResponseTypeSelect.selectedIndex = -1;
				hucFishResponseProbFutureSelect.selectedIndex = -1;
				hucFishResponseAbsFutureSelect.selectedIndex = -1;
				hucFishResponsePercentFutureSelect.selectedIndex = -1;
				hucStreamTempResponseSelect.selectedIndex = -1;
				hucFutureStreamTempResponseSelect.selectedIndex = -1;*/
				
				//indSpeciesSelect.dataProvider = null;
				
				scenarioUpdate('clear');
			}
	
			private function scenarioUpdate(buttonLabel:String):void {
				
				if (buttonLabel == 'go') {
					streamBufferToggle.selected = false;
					nhdStreamsToggle.selected = false;
					nhdLakesToggle.selected = false;
					modelLimitInfo.visible = false;
				} else if (buttonLabel == 'clear') {
					fishSampleLocationsToggle.selected = false;
					streamBufferToggle.selected = false;
					nhdStreamsToggle.selected = false;
					nhdLakesToggle.selected = false; 
					catchmentsToggle.selected = false;
					huc12Toggle.selected = false;
					padusToggle.selected = false;
					landCoverToggle.selected = false;
					disturbanceToggle.selected = false;
					
					northAppEco.selected = false;
					southAppCoastEco.selected = false;
					tempPlainsEco.selected = false;
					upperMidEco.selected = false;
					creek.selected = false;
					river.selected = false;
					landUseSelect.selectedIndex = -1;
					stateSelect.selectedIndex = -1;
					
					scenariosCatchments.visible = false;
				}
				
				//return;
				
				//var speciesSelectVal:String = speciesSelect.selectedItem;
				//var indSpeciesSelectVal:String = indSpeciesSelect.selectedItem;
				//var timePeriodSelectVal:String = timeOpt.selectedValue.toString();
				//var responseSelectVal:String = fishResponseLate20Select.selectedItem;
				
				var layerName:String = "";
				var speciesCode:String = "";
				var timePeriodCode:String = "";
				var responseCode:String = "";
				var responseCodeSuff:String = "";
				
				var A_responseType:String = "";
				var B_responseSubtype:String = "";
				var C_timePeriod:String = "";
				var D_response:String = "";
				var E_responseSub:String = "";
				var F_addInfo:String = "";
				
				scenarios.visibleLayers = new ArrayCollection();
				scenarios.refresh();
				scenariosSmall.visibleLayers = new ArrayCollection();
				scenariosSmall.refresh();
				scenariosCatchments.visibleLayers = new ArrayCollection();
				scenariosCatchments.refresh();
				scenariosCatchmentsSmall.visibleLayers = new ArrayCollection();
				scenariosCatchmentsSmall.refresh();
				scenariosHUC12.visibleLayers = new ArrayCollection();
				scenariosHUC12.refresh();
				climateStreamflow.visibleLayers = new ArrayCollection();
				climateStreamflow.refresh();
				climateStreamflowSmall.visibleLayers = new ArrayCollection();
				climateStreamflowSmall.refresh();
				
				/*if (indSelectGroup.visible == false) {
					if (speciesSelectVal == "Cold water species") {
						speciesCode = "Cd";
					} else if (speciesSelectVal == "Warm water species") {
						speciesCode = "Wm";
					} else if (speciesSelectVal == "Cool water species") {
						speciesCode = "Cl";
					}
					A_responseType = speciesSelectVal;
				} else {
					if (indSpeciesSelectVal == "Brook Trout") {
						speciesCode = "S1";
					} else if (indSpeciesSelectVal == "Brown Trout") {
						speciesCode = "S2";
					} else if (indSpeciesSelectVal == "Mottled Sculpin") {
						speciesCode = "S3";
					} else if (indSpeciesSelectVal == "Rainbow Trout") {
						speciesCode = "S4";
					} else if (indSpeciesSelectVal == "Slimy Sculpin") {
						speciesCode = "S5";
					} else if (indSpeciesSelectVal == "Blackchin Shiner") {
						speciesCode = "S6";
					} else if (indSpeciesSelectVal == "Brook Stickleback") {
						speciesCode = "S7";
					} else if (indSpeciesSelectVal == "Northern Hogsucker") {
						speciesCode = "S8";
					} else if (indSpeciesSelectVal == "Northern Pike") {
						speciesCode = "S9";
					} else if (indSpeciesSelectVal == "Redside Dace") {
						speciesCode = "S10";
					} else if (indSpeciesSelectVal == "White Sucker") {
						speciesCode = "S11";
					} else if (indSpeciesSelectVal == "Common Carp") {
						speciesCode = "S12";
					} else if (indSpeciesSelectVal == "Green Sunfish") {
						speciesCode = "S13";
					} else if (indSpeciesSelectVal == "Iowa Darter") {
						speciesCode = "S14";
					} else if (indSpeciesSelectVal == "Smallmouth Bass") {
						speciesCode = "S15";
					} else if (indSpeciesSelectVal == "Stonecat") {
						speciesCode = "S16";
					} 
					if (indSpeciesSelect.selectedIndex != -1) {
						if (indSpeciesSelect.selectedItem is String == false) {
							A_responseType = indSpeciesSelect.selectedItem.label;
						} else {
							A_responseType = indSpeciesSelectVal;
						}	
					}
				}*/
				
				/*if (timePeriodSelectVal == "Current") {
					timePeriodCode = "T20";
					C_timePeriod = "Late 20th Century (1961-2000)";
				} else if (timePeriodSelectVal == "2046 - 2065") {
					timePeriodCode = "T20F1";
					C_timePeriod = "Mid 21st Century (2046-2065)";
				} else if (timePeriodSelectVal == "2081 - 2100") {
					timePeriodCode = "T20F2";
					C_timePeriod = "Late 21st Century (2081-2100)";
				}*/
				
				var displayByVal:String = displayByOpt.selectedValue.toString();
				var responseInd:String = topicOpt.selectedValue.toString();
				var speciesOpt:String = "AS";
				/*if (speciesSelect.selectedItem = "All species") {
					speciesOpt = "AS";
				}*/
				
				layerName = displayByVal + responseInd + speciesOpt;
				
				layerDef = "1 = 1";
				
				if (responseInd == "QW" && stateSelect.selectedIndex != -1) {
					layerDef += " AND Statecode = '" + stateSelect.selectedItem.value + "'";
				}
				
				var ecoRegionArr:Array = [];
				
				if (southAppCoastEco.selected) {
					ecoRegionArr.push('SAP');
					ecoRegionArr.push('CPL');
				} 
				if (tempPlainsEco.selected) {
					ecoRegionArr.push('TPL');
				} 
				if (northAppEco.selected) {
					ecoRegionArr.push('NAP');
				} 
				if (upperMidEco.selected) {
					ecoRegionArr.push('UMW');
				}
				
				var ecoSqlArr:String = "('";
				for (var i=0; i<ecoRegionArr.length; i++) {
					if (i == ecoRegionArr.length-1) {
						ecoSqlArr += ecoRegionArr[i] + "')"; 
					} else {
						ecoSqlArr += ecoRegionArr[i] + "','";
					}
				}
				
				if (catchment.selected) {
					layerDef += " AND EcoregCode IN " + ecoSqlArr;
				} else if (streamReach.selected) {
					layerDef += " AND Ecoreg_Code IN " + ecoSqlArr;
				}
				
				
				var rivArr:Array = [];
				
				if (creek.selected) {
					rivArr.push('C');
				} 
				if (river.selected) {
					rivArr.push('R');
				} 
				
				var rivSqlArr:String = "('";
				for (var i=0; i<rivArr.length; i++) {
					if (i == rivArr.length-1) {
						rivSqlArr += rivArr[i] + "')"; 
					} else {
						rivSqlArr += rivArr[i] + "','";
					}
				}
				
				layerDef += " AND Creek_River IN " + rivSqlArr;
				
				if (huc12.selected) {
					/*if (streamtemp.selected) {
						if (timePeriodCode == "T20" && hucStreamTempResponseSelect.selectedItem == "Thermal class (length-weighted)") {
							layerName = "WSLJTCX";
							F_addInfo = "(July mean)";
							D_response = hucStreamTempResponseSelect.selectedItem;
						} else if (timePeriodCode == "T20F1") {
							if (hucFutureStreamTempResponseSelect.selectedItem == "Thermal class (length-weighted)") {
								layerName = "WSLJTCXF1";
								F_addInfo = "(July mean)";
							} else if (hucFutureStreamTempResponseSelect.selectedItem == "Change in thermal class (length-weighted)") {
								layerName = "WSTCCHX";
								F_addInfo = "(July mean)";
							} else if (hucFutureStreamTempResponseSelect.selectedItem == "Change in degrees (length-weighted)") {
								layerName = "WSLCH_JULX";
								F_addInfo = "(July mean, degrees Celsius)";
							}
							D_response = hucFutureStreamTempResponseSelect.selectedItem;
						} else if (timePeriodCode == "T20F2") {
							if (hucFutureStreamTempResponseSelect.selectedItem == "Thermal class (length-weighted)") {
								layerName = "WSLJUTCXF2";
								F_addInfo = "(July mean)";
							} else if (hucFutureStreamTempResponseSelect.selectedItem == "Change in thermal class (length-weighted)") {
								layerName = "WSTCCHXF2";
								F_addInfo = "(July mean)";
							} else if (hucFutureStreamTempResponseSelect.selectedItem == "Change in degrees (length-weighted)") {
								layerName = "WSLCHJXF2";
								F_addInfo = "(July mean, degrees Celsius)";
							}
							D_response = hucFutureStreamTempResponseSelect.selectedItem;
						}
						//A_responseType = "Stream temperature";
						
					} else if (fish.selected) {
						// first get response type
						/*if (hucFishResponseTypeSelect.selectedItem == "Probability of occurrence (length-weighted)" && late20.selected) {
							responseCode = "WSL";
							responseCodeSuff = "AP";
						} else if (hucFishResponseTypeSelect.selectedItem == "Absolute miles of fish occurrence" && late20.selected) {
							responseCode = "M";
							responseCodeSuff = "PPPA46";
						} else if (hucFishResponseTypeSelect.selectedItem == "Percent miles of fish occurrence" && late20.selected) {
							responseCode = "P";
							responseCodeSuff = "PPPA46";
						} else if (hucFishResponseTypeSelect.selectedItem == "Probability of occurrence (length-weighted)" && hucFishResponseProbFutureSelect.selectedItem == "Probability of occurrence") {
							responseCode = "WSL";
							if (timePeriodCode == "T20F1") {
								responseCodeSuff = "AP";
							} else if (timePeriodCode == "T20F2") {
								responseCodeSuff = "AP";
							}
						} else if (hucFishResponseTypeSelect.selectedItem == "Probability of occurrence (length-weighted)" && hucFishResponseProbFutureSelect.selectedItem == "Change in probability of occurrence") {
							responseCode = "CHWSL";
							if (timePeriodCode == "T20F1") {
								responseCodeSuff = "";
							} else if (timePeriodCode == "T20F2") {
								responseCodeSuff = "";
							}
							E_responseSub = hucFishResponseProbFutureSelect.selectedItem;
						} else if (hucFishResponseTypeSelect.selectedItem == "Absolute miles of fish occurrence") {
							responseCode = "M";
							if (hucFishResponseAbsFutureSelect.selectedItem == "Miles of fish occurrence") {
								responseCodeSuff = "PPAP";
							} if (hucFishResponseAbsFutureSelect.selectedItem == "Miles lost") {
								responseCodeSuff = "AP";
							} if (hucFishResponseAbsFutureSelect.selectedItem == "Miles gained") {
								responseCodeSuff = "PA";
							} if (hucFishResponseAbsFutureSelect.selectedItem == "Miles unchanged") {
								responseCodeSuff = "PP";
							} if (hucFishResponseAbsFutureSelect.selectedItem == "Miles lost or gained") {
								responseCodeSuff = "PAAP";
							}
							E_responseSub = hucFishResponseAbsFutureSelect.selectedItem;
						} else if (hucFishResponseTypeSelect.selectedItem == "Percent miles of fish occurrence") {
							responseCode = "P";
							if (hucFishResponsePercentFutureSelect.selectedItem == "Miles of fish occurrence (percent)") {
								responseCodeSuff = "PPAP";
							} if (hucFishResponsePercentFutureSelect.selectedItem == "Miles lost (percent)") {
								responseCodeSuff = "AP";
							} if (hucFishResponsePercentFutureSelect.selectedItem == "Miles gained (percent)") {
								responseCodeSuff = "PA";
							} if (hucFishResponsePercentFutureSelect.selectedItem == "Miles unchanged (percent)") {
								responseCodeSuff = "PP";
							} if (hucFishResponsePercentFutureSelect.selectedItem == "Miles lost or gained (percent)") {
								responseCodeSuff = "PAAP";
							}
							E_responseSub = hucFishResponsePercentFutureSelect.selectedItem;
						}
						
						var timeCodeSuff:String = "";
						if (timePeriodCode == "T20F1") {
							timeCodeSuff = "46";
						} else if (timePeriodCode == "T20F2") {
							timeCodeSuff = "81";
						}
						
						layerName = responseCode+speciesCode+responseCodeSuff+timeCodeSuff;
						D_response = hucFishResponseTypeSelect.selectedItem;
						
					}*/
					
					
				} else {
					/*if (streamtemp.selected) {
						if (timePeriodCode == "T20" && streamTempResponseSelect.selectedItem == "Thermal class") {
							layerName = "JULclass";
							D_response = streamTempResponseSelect.selectedItem;
						} else if (timePeriodCode == "T20F1") {
							if (futureStreamTempResponseSelect.selectedItem == "Thermal class") {
								layerName = "JLCLF1";
							} else if (futureStreamTempResponseSelect.selectedItem == "Change in thermal class") {
								layerName = "CHJLCLF1";
							}
							D_response = futureStreamTempResponseSelect.selectedItem;
						} else if (timePeriodCode == "T20F2") {
							if (futureStreamTempResponseSelect.selectedItem == "Thermal class") {
								layerName = "JLCLF2";
							} else if (futureStreamTempResponseSelect.selectedItem == "Change in thermal class") {
								layerName = "CHJLCLF2";
							}
							D_response = futureStreamTempResponseSelect.selectedItem;
						}
						A_responseType = "Stream temperature";
						F_addInfo = "(July mean)";
					} else if (fish.selected) {
						if (indSelectGroup.visible == false) {
							if (timePeriodSelectVal == "Current") {
								if (fishResponseLate20Select.selectedItem == "Predicted occurrence") {
									responseCodeSuff = "PA";
								}
								D_response = fishResponseLate20Select.selectedItem;
							} else if (timePeriodSelectVal == "2046 - 2065") {
								if (groupFishResponseFutureSelect.selectedItem == "Number of species lost") {
									responseCode = "Ab";
									responseCodeSuff = "V";
								} else if (groupFishResponseFutureSelect.selectedItem == "Number of species gained") {
									responseCode = "Ab";
									responseCodeSuff = "O";
								} else if (groupFishResponseFutureSelect.selectedItem == "Number of species lost or gained") {
									responseCode = "Ab";
									responseCodeSuff = "S";
								} else if (groupFishResponseFutureSelect.selectedItem == "Percent of species lost") {
									responseCode = "AbP";
									responseCodeSuff = "V";
								} else if (groupFishResponseFutureSelect.selectedItem == "Percent of species gained") {
									responseCode = "AbP";
									responseCodeSuff = "O";
								} else if (groupFishResponseFutureSelect.selectedItem == "Predicted occurrence") {
									responseCode = "";
									responseCodeSuff = "PA46";
								} else if (groupFishResponseFutureSelect.selectedItem == "Vulnerability") {
									responseCode = "V";
									responseCodeSuff = "T20F1";
									F_addInfo = ": percent of Global Climate Models that indicate loss";
								} else if (groupFishResponseFutureSelect.selectedItem == "Opportunity") {
									responseCode = "O";
									responseCodeSuff = "T20F1";
									F_addInfo = ": percent of Global Climate Models that indicate gain";
								} else if (groupFishResponseFutureSelect.selectedItem == "Sensitivity") {
									responseCode = "S";
									responseCodeSuff = "T20F1";
									F_addInfo = ": percent of Global Climate Models that indicate a change, either loss or gain";
								} 
								D_response = groupFishResponseFutureSelect.selectedItem;
							} else if (timePeriodSelectVal == "2081 - 2100") {
								if (groupFishResponseFutureSelect.selectedItem == "Number of species lost") {
									responseCode = "Ab";
									responseCodeSuff = "VF2";
								} else if (groupFishResponseFutureSelect.selectedItem == "Number of species gained") {
									responseCode = "Ab";
									responseCodeSuff = "OF2";
								} else if (groupFishResponseFutureSelect.selectedItem == "Number of species lost or gained") {
									responseCode = "Ab";
									responseCodeSuff = "SF2";
								} else if (groupFishResponseFutureSelect.selectedItem == "Percent of species lost") {
									responseCode = "AbP";
									responseCodeSuff = "VF2";
								} else if (groupFishResponseFutureSelect.selectedItem == "Percent of species gained") {
									responseCode = "AbP";
									responseCodeSuff = "OF2";
								} else if (groupFishResponseFutureSelect.selectedItem == "Predicted occurrence") {
									responseCode = "";
									responseCodeSuff = "PA81";
								} else if (groupFishResponseFutureSelect.selectedItem == "Vulnerability") {
									responseCode = "V";
									responseCodeSuff = "T20F2";
									F_addInfo = ": percent of Global Climate Models that indicate loss";
								} else if (groupFishResponseFutureSelect.selectedItem == "Opportunity") {
									responseCode = "O";
									responseCodeSuff = "T20F2";
									F_addInfo = ": percent of Global Climate Models that indicate gain";
								} else if (groupFishResponseFutureSelect.selectedItem == "Sensitivity") {
									responseCode = "S";
									responseCodeSuff = "T20F2";
									F_addInfo = ": percent of Global Climate Models that indicate a change, either loss or gain";
								}
								D_response = groupFishResponseFutureSelect.selectedItem;
							} 
						} else {
							if (timePeriodSelectVal == "Current") {
								if (indFishResponseLate20Select.selectedItem == "Predicted occurrence") {
									responseCodeSuff = "A";
								} else if (indFishResponseLate20Select.selectedItem == "Probability of occurrence") {
									responseCodeSuff = "AP";
								}
								D_response = indFishResponseLate20Select.selectedItem;
							} else if (timePeriodSelectVal == "2046 - 2065") {
								if (indFishResponseFutureSelect.selectedItem == "Predicted occurrence") {
									responseCode = "";
									responseCodeSuff = "A46";
								} else if (indFishResponseFutureSelect.selectedItem == "Probability of occurrence") {
									responseCode = "";
									responseCodeSuff = "AP46X";
								} else if (indFishResponseFutureSelect.selectedItem == "Change in probability of occurrence") {
									responseCode = "";
									responseCodeSuff = "APCH46";
								} else if (indFishResponseFutureSelect.selectedItem == "Vulnerability") {
									responseCode = "V";
									responseCodeSuff = "T20F1";
									F_addInfo = ": percent of Global Climate Models that indicate loss";
								} else if (indFishResponseFutureSelect.selectedItem == "Opportunity") {
									responseCode = "O";
									responseCodeSuff = "T20F1";
									F_addInfo = ": percent of Global Climate Models that indicate gain";
								} else if (indFishResponseFutureSelect.selectedItem == "Sensitivity") {
									responseCode = "S";
									responseCodeSuff = "T20F1";
									F_addInfo = ": percent of Global Climate Models that indicate a change, either loss or gain";
								}
								D_response = indFishResponseFutureSelect.selectedItem;
							} else if (timePeriodSelectVal == "2081 - 2100") {
								if (indFishResponseFutureSelect.selectedItem == "Predicted occurrence") {
									responseCode = "";
									responseCodeSuff = "A81";
								} else if (indFishResponseFutureSelect.selectedItem == "Probability of occurrence") {
									responseCode = "";
									responseCodeSuff = "AP81X";
								} else if (indFishResponseFutureSelect.selectedItem == "Change in probability of occurrence") {
									responseCode = "";
									responseCodeSuff = "APCH81";
								} else if (indFishResponseFutureSelect.selectedItem == "Vulnerability") {
									responseCode = "V";
									responseCodeSuff = "T20F2";
									F_addInfo = ": percent of Global Climate Models that indicate loss";
								} else if (indFishResponseFutureSelect.selectedItem == "Opportunity") {
									responseCode = "O";
									responseCodeSuff = "T20F2";
									F_addInfo = ": percent of Global Climate Models that indicate gain";
								} else if (indFishResponseFutureSelect.selectedItem == "Sensitivity") {
									responseCode = "S";
									responseCodeSuff = "T20F2";
									F_addInfo = ": percent of Global Climate Models that indicate a change, either loss or gain";
								}
								D_response = indFishResponseFutureSelect.selectedItem;
							} 
							
						}
						
						layerName = responseCode+speciesCode+responseCodeSuff;
						trace("layerName: " + layerName);
					} else if (streamflow.selected) {
						if (timePeriodSelectVal == "2046 - 2065") {
							responseCodeSuff = "F1";
						} else if (timePeriodSelectVal == "2081 - 2100") {
							responseCodeSuff = "F2";
						} 
						if (streamflowReach.visible && streamflowReach.selectedIndex != -1) {
							responseCode = streamflowReach.selectedItem.value;
							D_response = streamflowReach.selectedItem.text;
							F_addInfo = "(cubic feet per second)";
						} else if (streamflowCatch.visible && streamflowCatch.selectedIndex != -1) {
							responseCode = streamflowCatch.selectedItem.value;
							D_response = streamflowCatch.selectedItem.text;
							F_addInfo = "(cubic feet per second per square mile)";
						}
						layerName = responseCode + responseCodeSuff;
						A_responseType = "Streamflow exceedance";
					} else if (climateProj.selected) {
						var suff:String = "";
						if (timePeriodSelectVal == "2046 - 2065") {
							responseCodeSuff = "F1";
						} else if (timePeriodSelectVal == "2081 - 2100") {
							responseCodeSuff = "F2";
						} 
						if (timePeriodSelectVal == "Current") {
							if (airTempResponses.visible && airTempResponses.selectedIndex != -1) {
								responseCode = airTempResponses.selectedItem.value;
								D_response = airTempResponses.selectedItem.text;
								F_addInfo = "(degrees Fahrenheit)";
							} else if (precipitationResponses.visible && precipitationResponses.selectedIndex != -1) {
								responseCode = precipitationResponses.selectedItem.value;
								D_response = precipitationResponses.selectedItem.text;
								F_addInfo = "(inches)";
							}
						} else {
							if (airTempResponsesFuture.visible && airTempResponsesFuture.selectedIndex != -1) {
								responseCode = airTempResponsesFuture.selectedItem.value;
								suff = airTempResponsesFuture.selectedItem.suff;
								D_response = airTempResponsesFuture.selectedItem.text;
								F_addInfo = "(degrees Fahrenheit)";
							} else if (precipitationResponsesFuture.visible && precipitationResponsesFuture.selectedIndex != -1) {
								responseCode = precipitationResponsesFuture.selectedItem.value;
								suff = precipitationResponsesFuture.selectedItem.suff;
								D_response = precipitationResponsesFuture.selectedItem.text;
								F_addInfo = "(inches)";
							}
						}
						layerName = responseCode + responseCodeSuff + suff;
						A_responseType = climateVariable.selectedItem;
					}*/
					
				}
				
				//code for legend title
				var legendTitleParts:Array = [A_responseType, B_responseSubtype, C_timePeriod, D_response, E_responseSub, F_addInfo];
				var legendTitle:String = legendTitleParts[0];
				
				for (i = 1; i < legendTitleParts.length; i++) {
					var newPart:String = '';
					if (legendTitleParts[i] != '' && legendTitle != '') {
						if (legendTitleParts[i-2] != "Vulnerability" && legendTitleParts[i-2] != "Opportunity" && legendTitleParts[i-2] != "Sensitivity") {
							newPart = ", " + legendTitleParts[i]
						} else {
							newPart = legendTitleParts[i];
						}
						
						legendTitle += newPart;
					} else {
						newPart = legendTitleParts[i]
						legendTitle += newPart;
					}
				}
				
				var respInd:String = "";
				switch (responseInd) {
					case "LU":
						respInd = "land use";
						break;
					case "FR":
						respInd = "fragmentation by dams and road crossings";
						break;
					case "QW":
						respInd = "303d listed streams";
						break;
				}
				
				legendTitle = "Risk of habitat degradation due to " + respInd;
				
				/*if (buttonLabel == 'go') {
					browseWarning.visible = true;
				} else if (buttonLabel == 'clear') {
					browseWarning.visible = false;
				}*/
				
				var needBrowseWarning:Boolean = true;
				
				//Code for determining layers and updating appropriate layers
				if (streamReach.selected) {
					var i:int;
					if (scenarioLayerInfos != null) {
						for (i = 0; i < scenarioLayerInfos.length; i++) {
							if (scenarioLayerInfos[i].name == layerName) {
								scenarios.visibleLayers = new ArrayCollection([scenarioLayerInfos[i].layerId]);
								var layerDefs:Array = [];
								layerDefs[scenarioLayerInfos[i].layerId] = layerDef;
								scenarios.layerDefinitions = layerDefs;
								scenarios.visible = true;
								scenarios.refresh();
								//scenariosSmall.visibleLayers = new ArrayCollection([scenarioLayerInfos[i].layerId]);
								//scenariosSmall.refresh();
								needBrowseWarning = false;
								break;
							} else {
								scenarios.visibleLayers = new ArrayCollection();
								scenarios.refresh();
								scenariosSmall.visibleLayers = new ArrayCollection();
								scenariosSmall.refresh();
							}
						}
						scenariosLegend.aLegendService.send();
						//scenariosSmallLegend.aLegendService.send();
						scenariosSmallLegend.legendTitle = legendTitle;
						scenariosLegend.legendTitle = legendTitle;
					}
				}
				
				if (catchment.selected) {
					var i:int;
					if (scenarioCatchmentsLayerInfos != null) {
						for (i = 0; i < scenarioCatchmentsLayerInfos.length; i++) {
							if (scenarioCatchmentsLayerInfos[i].name == layerName) {
								scenariosCatchments.visibleLayers = new ArrayCollection([scenarioCatchmentsLayerInfos[i].layerId]);
								scenariosCatchmentsSmall.visibleLayers = new ArrayCollection([scenarioCatchmentsLayerInfos[i].layerId]);
								if (responseInd == "QW" && stateSelect.selectedIndex == -1) {
									break;
								}
								var layerDefs:Array = [];
								layerDefs[scenarioCatchmentsLayerInfos[i].layerId] = layerDef;
								scenariosCatchments.layerDefinitions = layerDefs;
								scenariosCatchments.visible = true;
								scenariosCatchments.refresh();
								scenariosCatchmentsSmall.layerDefinitions = layerDefs;
								scenariosCatchmentsSmall.visible = true;
								scenariosCatchmentsSmall.refresh();
								needBrowseWarning = false;
								break;
							} else {
								scenariosCatchments.visibleLayers = new ArrayCollection();
								scenariosCatchments.refresh();
							}
						}
						scenariosCatchmentsLegend.aLegendService.send();
						scenariosCatchmentsLegend.legendTitle = legendTitle;
						scenariosCatchmentsSmallLegend.legendTitle = legendTitle;
					}
				}
				
				if (huc12.selected) {
					var i:int;
					if (scenarioHUC12LayerInfos != null) {
						for (i = 0; i < scenarioHUC12LayerInfos.length; i++) {
							if (scenarioHUC12LayerInfos[i].name == layerName) {
								scenariosHUC12.visibleLayers = new ArrayCollection([scenarioHUC12LayerInfos[i].layerId]);
								scenariosHUC12.refresh();
								needBrowseWarning = false;
								break;
							} else {
								scenariosHUC12.visibleLayers = new ArrayCollection();
								scenariosHUC12.refresh();
							}
						}
						scenariosHUC12Legend.aLegendService.send();
						scenariosHUC12Legend.legendTitle = legendTitle;
					}
				}
				
				/*if (streamflow.selected || climateProj.selected) {
					var i:int;
					if (climateStreamflowLayerInfos != null) {
						for (i = 0; i < climateStreamflowLayerInfos.length; i++) {
							if (climateStreamflowLayerInfos[i].name == layerName) {
								climateStreamflow.visibleLayers = new ArrayCollection([climateStreamflowLayerInfos[i].layerId]);
								climateStreamflow.refresh();
								climateStreamflowSmall.visibleLayers = new ArrayCollection([climateStreamflowLayerInfos[i].layerId]);
								climateStreamflowSmall.refresh();
								needBrowseWarning = false;
								break;
							} else {
								climateStreamflow.visibleLayers = new ArrayCollection();
								climateStreamflow.refresh();
								climateStreamflowSmall.visibleLayers = new ArrayCollection();
								climateStreamflowSmall.refresh();
							}
						}
						climateStreamflowLegend.aLegendService.send();
						climateStreamflowLegend.legendTitle = legendTitle;
						climateStreamflowSmallLegend.aLegendService.send();
						climateStreamflowSmallLegend.legendTitle = legendTitle;
					}
				}*/
				
				if (needBrowseWarning == true && buttonLabel == 'go') {
					Alert.show("You have not entered enough information to display a map. Check your selections and try again.");
				}
				
				
				/*if (climateProj.selected) {
					var i:int;
					if (climateStreamflowLayerInfos != null) {
						for (i = 0; i < climateStreamflowLayerInfos.length; i++) {
							if (climateStreamflowLayerInfos[i].name == layerName) {
								climateStreamflow.visibleLayers = new ArrayCollection([climateStreamflowLayerInfos[i].layerId]);
								climateStreamflow.refresh();
								break;
							} else {
								climateStreamflow.visibleLayers = new ArrayCollection();
								climateStreamflow.refresh();
							}
						}
						climateStreamflowLegend.aLegendService.send();
						climateStreamflowLegend.legendTitle = legendTitle;
					}
				}*/
				
			}

			/*private function exportStart(event:MouseEvent):void {
				var count:Number = Number(removeComma(resultsCount.text));
				if (count == 0) {
					Alert.show('There are no search results to export.');
				} else {
					if (count > 25000) {
						Alert.show('Your search has exceeded 25,000 results. Please narrow your search to enable export.');
					} else {
						Alert.show("Your search results will export as a .csv file. The first row of the .csv file will contain a record of your search parameters.","", 0, null, writeCSV);
					}
				}
			}*/

			private function removeComma(resultsText:String):String {
				var count:String = "";
				var array:Array = resultsText.split(",");
				
				for (var i:int = 0; i < array.length; i++) {
					count += array[i];
				}
				
				return count;
			}

			/*private function expandCollapse(event:MouseEvent):void {
				
				var imgID:String = event.currentTarget.id
				
				switch (imgID) {
					case "late20Ex": 
						imgSequence.target = late20Ex;
						scaleSequence.target = late20ExContent;
						break;
					case "mid21Ex":
						imgSequence.target = mid21Ex;
						scaleSequence.target = mid21ExContent;
						break;
					case "late21Ex":
						imgSequence.target = late21Ex;
						scaleSequence.target = late21ExContent;
						break;
				}
				
				if (scaleSequence.target.scaleY > 0) {
					
					scaleYAnimation.fromValue = 1;
					scaleYAnimation.toValue = 0;
					
					imgRotateAnimation.toValue = 0;
					
				} else {
					
					scaleYAnimation.fromValue = 0;
					scaleYAnimation.toValue = 1;
					
					
					imgRotateAnimation.toValue = 90;  	
				}
				
				scaleSequence.play();
			}*/

			/*private function searchResultClear():void {
				stateSelect.selectedIndex = -1;
				hucSelect.selectedIndex = -1;
				
				late20thSpeciesSelect.selectedIndex = -1;
				late20thPASelect.selectedIndex = -1;
				late20thCold.selected = false;
				late20thColdTransition.selected = false;
				late20thWarm.selected = false;
				late20thWarmTransition.selected = false;
				
				headwaterSize.selected = false;
				smallSize.selected = false;
				mediumSize.selected = false;
				largeSize.selected = false;
				
				landUseCatchmentType.selectedIndex = -1;
				landUseType.selectedIndex = -1
				landUseOperator.selectedIndex = -1
				landUsePct.text = '';
				
				landStewardshipCatchmentType.selectedIndex = -1;
				landStewardshipType.selectedIndex = -1
				landStewardshipOperator.selectedIndex = -1
				landStewardshipPct.text = '';
				
				humanDist.selectedIndex = -1;
				
				mid21stSpeciesSelect.selectedIndex = -1;
				mid21stPASelect.selectedIndex = -1;
				mid21stCold.selected = false;
				mid21stColdTransition.selected = false;
				mid21stWarm.selected = false;
				mid21stWarmTransition.selected = false;
				
				late21stSpeciesSelect.selectedIndex = -1;
				late21stPASelect.selectedIndex = -1;
				late21stCold.selected = false;
				late21stColdTransition.selected = false;
				late21stWarm.selected = false;
				late21stWarmTransition.selected = false;
				
				//searchResultUpdate('clear');
			}*/

			/*private function habitatUpdate():void {
				var habitatSelectVal:String = habitatSelect.selectedItem;
				var timePeriodSelectVal:String = habitatTimePeriodSelect.selectedItem;
				var responseSelectVal:String = habitatResponseSelect.selectedItem;
				
				var layerName:String;
				var habitatCode:String;
				var timePeriodCode:String;
				var responseCode:String;
				
				if (habitatSelectVal == "Stream temperature") {
					habitatCode = "ST";
				}
				
				if (timePeriodSelectVal == "Current") {
					timePeriodCode = "";
				} else if (timePeriodSelectVal == "2046 - 2065") {
					timePeriodCode = "F1";
				} else if (timePeriodSelectVal == "2081 - 2100") {
					timePeriodCode = "F2";
				}
				
				if (responseSelectVal == "Thermal class (July mean)") {
					responseCode = "JLCL";
				} else if (responseSelectVal == "Change in thermal class (July mean)") {
					responseCode = "JLCLCH";
				} else if (responseSelectVal == "Change in degrees (July mean)") {
					responseCode = "JLCLCHD";
				}
				
				layerName = habitatCode+responseCode+timePeriodCode;
				trace("layerName: " + layerName);
				streamTempLegend.legendTitle = habitatSelectVal + ", " + timePeriodSelectVal + ", " + responseSelectVal;
				
				var i:int;
				if (streamTempLayerInfos != null) {
					for (i = 0; i < streamTempLayerInfos.length; i++) {
						if (streamTempLayerInfos[i].name == layerName) {
							streamTemp.visibleLayers = new ArrayCollection([streamTempLayerInfos[i].layerId]);
							streamTemp.refresh();
							break;
						} else {
							streamTemp.visibleLayers = new ArrayCollection();
							streamTemp.refresh();
						}
					}
				}
			}*/
	
			/*private function onToggleClick(toggleClicked:LayerToggle):void {
				/*if (toggleClicked == studyAreaToggle && studyAreaToggle.selected) {
					//scenariosToggle.selected = false;
					if (streamTempToggle != null) {
						streamTempToggle.selected = false;
					}
				} else if ((toggleClicked == nhdStreamsToggle && nhdStreamsToggle.selected) || (toggleClicked == nhdLakesToggle && nhdLakesToggle.selected)) {
					//scenariosToggle.selected = false;
					if (streamTempToggle != null) {
						streamTempToggle.selected = false;
					}
				} else if (toggleClicked == scenariosToggle && scenariosToggle.selected) {
					studyAreaToggle.selected = false;
					nhdStreamsToggle.selected = false;
					nhdLakesToggle.selected = false;
					if (streamTempToggle != null) {
						streamTempToggle.selected = false;
					}
				} else if (streamTempToggle != null) {
					if (toggleClicked == streamTempToggle && streamTempToggle.selected) {
						//scenariosToggle.selected = false;
						studyAreaToggle.selected = false;
						nhdStreamsToggle.selected = false;
						nhdLakesToggle.selected = false;
					}
				}*/
			//}

			//Handles click requests for map layer info
    		private function onMapClick(event:MapMouseEvent):void
    		{
    			//if (censusDataCB.selected) {
	    			
	    			queryGraphicsLayer.clear();
	    			infoGraphicsLayer.clear();
					PopUpManager.removePopUp(_queryWindow);
	    			
	    			var infoGraphicsSymbol:InfoSymbol = singleGraphicSym;	    							    	
	    				
	    			
    				if ((scenarios.visibleLayers != null && scenarios.visibleLayers.length > 0) || (scenariosCatchments.visibleLayers != null && scenariosCatchments.visibleLayers.length > 0)
						|| (climateStreamflow.visibleLayers != null && climateStreamflow.visibleLayers.length > 0) || (climateStreamflowSmall.visibleLayers != null && climateStreamflowSmall.visibleLayers.length > 0)) {
					
						//Create query object to for currently selected layer    			
		    		
						var identifyParameters:IdentifyParameters = new IdentifyParameters();
						identifyParameters.returnGeometry = true;
						identifyParameters.tolerance = 4;
						identifyParameters.width = map.width;
						identifyParameters.height = map.height;
						identifyParameters.layerOption = "all";
						identifyParameters.geometry = event.mapPoint;
						identifyParameters.mapExtent = map.extent;
						identifyParameters.spatialReference = map.spatialReference;	
						
						if (scenarios.visibleLayers != null && scenarios.visibleLayers.length > 0) {
							var identifyTask:IdentifyTask = new IdentifyTask(resourceManager.getString('urls', 'streamsForQueryUrl'));
							identifyTask.showBusyCursor = true;
							identifyTask.execute( identifyParameters, new AsyncResponder(infoSingleResult, infoFault, new ArrayCollection([{eventX: event.stageX, eventY: event.stageY}])) );
						} else if (scenariosCatchments.visibleLayers != null && scenariosCatchments.visibleLayers.length > 0) {
							var identifyTask:IdentifyTask = new IdentifyTask(resourceManager.getString('urls', 'scenariosCatchmentsUrl'));
							identifyParameters.layerOption = "top";
							identifyParameters.layerIds = [0];
							identifyTask.showBusyCursor = true;
							identifyTask.execute( identifyParameters, new AsyncResponder(infoSingleResult, infoFault, new ArrayCollection([{eventX: event.stageX, eventY: event.stageY}])) );
						} else if (climateStreamflow.visibleLayers != null && climateStreamflow.visibleLayers.length > 0 && climateStreamflow.visible == true && streamReach.selected) {
							var identifyTask:IdentifyTask = new IdentifyTask(resourceManager.getString('urls', 'climateStreamflow'));
							identifyParameters.layerOption = "top";
							identifyParameters.layerIds = [0];
							identifyTask.showBusyCursor = true;
							identifyTask.execute( identifyParameters, new AsyncResponder(infoSingleResult, infoFault, new ArrayCollection([{eventX: event.stageX, eventY: event.stageY}])) );
						} else if (climateStreamflow.visibleLayers != null && climateStreamflow.visibleLayers.length > 0 && climateStreamflow.visible == true && catchment.selected) {
							var identifyTask:IdentifyTask = new IdentifyTask(resourceManager.getString('urls', 'climateStreamflow'));
							identifyParameters.layerOption = "top";
							identifyParameters.layerIds = [climateStreamflow.layerInfos.length-1];
							identifyTask.showBusyCursor = true;
							identifyTask.execute( identifyParameters, new AsyncResponder(infoSingleResult, infoFault, new ArrayCollection([{eventX: event.stageX, eventY: event.stageY}])) );
						} else if (climateStreamflowSmall.visibleLayers != null && climateStreamflowSmall.visibleLayers.length > 0 && climateStreamflowSmall.visible == true && streamReach.selected) {
							var identifyTask:IdentifyTask = new IdentifyTask(resourceManager.getString('urls', 'climateStreamflowSmall'));
							identifyParameters.layerOption = "top";
							identifyParameters.layerIds = [0];
							identifyTask.showBusyCursor = true;
							identifyTask.execute( identifyParameters, new AsyncResponder(infoSingleResult, infoFault, new ArrayCollection([{eventX: event.stageX, eventY: event.stageY}])) );
						} else if (climateStreamflowSmall.visibleLayers != null && climateStreamflowSmall.visibleLayers.length > 0 && climateStreamflowSmall.visible == true && catchment.selected) {
							var identifyTask:IdentifyTask = new IdentifyTask(resourceManager.getString('urls', 'climateStreamflowSmall'));
							identifyParameters.layerOption = "top";
							identifyParameters.layerIds = [climateStreamflow.layerInfos.length-1];
							identifyTask.showBusyCursor = true;
							identifyTask.execute( identifyParameters, new AsyncResponder(infoSingleResult, infoFault, new ArrayCollection([{eventX: event.stageX, eventY: event.stageY}])) );
						} 
					} else if (scenariosHUC12.visibleLayers != null && scenariosHUC12.visibleLayers.length > 0) {
						var identifyParameters:IdentifyParameters = new IdentifyParameters();
						identifyParameters.returnGeometry = true;
						identifyParameters.tolerance = 4;
						identifyParameters.width = map.width;
						identifyParameters.height = map.height;
						//identifyParameters.layerIds = [scenariosHUC12.visibleLayers[0]];
						identifyParameters.layerIds = [0];
						identifyParameters.geometry = event.mapPoint;
						identifyParameters.mapExtent = map.extent;
						identifyParameters.spatialReference = map.spatialReference;	
						
						var identifyTask:IdentifyTask = new IdentifyTask(resourceManager.getString('urls', 'scenariosHUC12Url'));
						identifyTask.execute( identifyParameters, new AsyncResponder(huc12Result, infoFault, new ArrayCollection([{eventX: event.stageX, eventY: event.stageY}])) );
					}
			    	
			}
    		
			private function queryFault(info:Object, token:Object = null):void
			{
				Alert.show(info.toString());
			}
    		
    		
    		/* Query tooltip methods */
    		    	   		   		    		   
    		private function infoSingleResult(resultSet:Array, configObjects:ArrayCollection):void
    		{

    			if (resultSet.length != 0) {
					
					var newData:Array = new Array();

					newData.push(resultSet[0].feature.attributes);
					
					// find item with abs scores using COMID from resultSet[0]
					var comid:String = newData[0].COMID;
					
					for (var i:int = 1; i < resultSet.length; i++) {
						if (resultSet[i].feature.attributes.COMID == comid) {
							newData.push(resultSet[i].feature.attributes);
						}
					}
					
					var aGraphic:Graphic = new Graphic(resultSet[0].feature.geometry);
					
					if (resultSet[0].feature.geometry.type == "esriGeometryPolygon") {
						aGraphic.symbol = hucQuerySym;
						newData[0].state = "catchments";
					} else if (resultSet[0].feature.geometry.type == "esriGeometryPolyline") {
						aGraphic.symbol = streamQuerySym;
						newData[0].state = "streams";
					}
					
					//newData[0].
					
		            queryGraphicsLayer.add(aGraphic);
						
					_queryWindow = PopUpManager.createPopUp(map, StreamInfo, false) as WiMInfoWindow;
					_queryWindow.setStyle("skinClass", WiMInfoWindowSkin);
					_queryWindow.x = configObjects.getItemAt(0).eventX;
					_queryWindow.y = configObjects.getItemAt(0).eventY;
					_queryWindow.addEventListener(CloseEvent.CLOSE, closePopUp);
					
					_queryWindow.data = newData;
						
				} 
			}  

			private function huc12Result(resultSet:Array, configObjects:ArrayCollection):void
			{
				
				if (resultSet.length != 0) {
					
					var newData:Array = new Array();
					
					newData.push(resultSet[0].feature.attributes);
					
					// find item with abs scores using COMID from resultSet[0]
					var huc12:String = newData[0].HUC_12;
					
					for (var i:int = 1; i < resultSet.length; i++) {
						if (resultSet[i].feature.attributes.HUC_12 == huc12) {
							newData.push(resultSet[i].feature.attributes);
						}
					}
					
					var aGraphic:Graphic = new Graphic(resultSet[0].feature.geometry);
					
					aGraphic.symbol = hucQuerySym;
					queryGraphicsLayer.add(aGraphic);
					
					_queryWindow = PopUpManager.createPopUp(map, StreamInfoHUC12, false) as WiMInfoWindow;
					_queryWindow.setStyle("skinClass", WiMInfoWindowSkin);
					_queryWindow.x = configObjects.getItemAt(0).eventX;
					_queryWindow.y = configObjects.getItemAt(0).eventY;
					_queryWindow.addEventListener(CloseEvent.CLOSE, closePopUp);
					
					_queryWindow.data = newData;
				} 
			}
			
    		private function infoFault(info:Object, token:Object = null):void
    		{
    			Alert.show(info.toString());
    		}
    		   	
		 	/* End query tooltip methods */
		
			public function closePopUp(event:CloseEvent):void {
				PopUpManager.removePopUp(event.currentTarget as WiMInfoWindow);
				queryGraphicsLayer.clear();
			}
    			
    		private function baseSwitch(event:FlexEvent):void            
    		{                
				var tiledLayer:TiledMapServiceLayer = event.target as TiledMapServiceLayer;                
				if ((tiledLayer != null) && (tiledLayer.tileInfo != null) && (tiledLayer.id != "labelsMapLayer")) {
					map.lods = tiledLayer.tileInfo.lods;
				}
    		}

			private function getHUCs(event:FlexEvent):void {
				var hucQuery:Query = new Query();
				hucQuery.where = "OBJECTID > 0";
				hucQuery.returnDistinctValues = true;
				hucQuery.returnGeometry = false;
				hucQuery.outFields = ["HUC4", "HUC_4_NAME"];
				
				var hucQueryTask:QueryTask = new QueryTask();
				hucQueryTask.disableClientCaching = true;
				hucQueryTask.useAMF = false;
				hucQueryTask.url = resourceManager.getString('urls', 'scenariosUrl')+"/0";
				hucQueryTask.execute(hucQuery, new AsyncResponder(hucResult, hucFault));
			}

			private function hucResult(featureSet:FeatureSet, token:Object = null):void {
				var hucAC:ArrayCollection = new ArrayCollection();
				
				for (var i:int = 0; i < featureSet.features.length; i++) {
					hucAC.addItem({inputText: featureSet.features[i].attributes.HUC4 + " (" + featureSet.features[i].attributes.HUC_4_NAME + ")", hucNumber: featureSet.features[i].attributes.HUC4});
				}
				
				var hucSortField:SortField = new SortField();
				hucSortField.name = "hucNumber";
				var hucSort:Sort = new Sort();
				hucSort.fields = [hucSortField];
				
				hucAC.sort = hucSort;
				hucAC.refresh();
				
				//hucSelect.dataProvider = hucAC;
			}

			private function hucFault(info:Object, token:Object = null):void
			{
				Alert.show("Error: " + info.toString(), "problem with request");
			}
    		
    		
    		
    		/* Geo-coding methods */
			//Original code taken from ESRI sample: http://resources.arcgis.com/en/help/flex-api/samples/index.html#/Geocode_an_address/01nq00000068000000/
			//Adjusted for handling lat/lng vs. lng/lat inputs
			private function geoCode(searchCriteria:String):void
			{
				var parameters:AddressToLocationsParameters = new AddressToLocationsParameters();
				//parameters such as 'SingleLine' are dependent upon the locator service used.
				parameters.address = { SingleLine: searchCriteria };
				
				// Use outFields to get back extra information
				// The exact fields available depends on the specific locator service used.
				parameters.outFields = [ "*" ];
				
				locator.addressToLocations(parameters, new AsyncResponder(onResult, onFault));
				function onResult(candidates:Array, token:Object = null):void
				{
					if (candidates.length > 0)
					{
						var addressCandidate:AddressCandidate = candidates[0];
						
						map.extent = com.esri.ags.utils.WebMercatorUtil.geographicToWebMercator(new Extent(addressCandidate.attributes.Xmin, addressCandidate.attributes.Ymin,  addressCandidate.attributes.Xmax, addressCandidate.attributes.Ymax, map.spatialReference)) as Extent;
						
					}
					else
					{
						Alert.show("Sorry, couldn't find a location for this address"
							+ "\nAddress: " + searchCriteria);
					}
				}
				
				function onFault(info:Object, token:Object = null):void
				{
					//myInfo.htmlText = "<b>Failure</b>" + info.toString();
					Alert.show("Failure: \n" + info.toString());
				}
			}
			
			/* End geo-coding methods */
    					

    		private function onFault(info:Object, token:Object = null):void
    		{
    			Alert.show("Error: " + info.toString(), "problem with Locator");
    		}
    		
    		/* End geo-coding methods */

			/* Dynamic Legend methods */
			private function legendResults(resultSet:ResultEvent, aLegendContainer:SkinnableContainer, layerIDs:ArrayCollection, singleTitle:String = null):void
			{
				
				if (resultSet.statusCode == 200) {
					//Decode JSON result
					var decodeResults:Object = com.esri.ags.utils.JSON.decode(resultSet.result.toString());
					var legendResults:Array = decodeResults["layers"] as Array;
					//Clear old legend
					aLegendContainer.removeAllElements();	
					
					//if single title is specified use that
					if (singleTitle != null || aLegendContainer.id == 'siteLegend') {
						//Add outline with flash effect   
						var singleGroupDescription:spark.components.Label = new spark.components.Label();
						singleGroupDescription.setStyle("verticalAlign", "middle");
						singleGroupDescription.setStyle("fontSize", "11");
						singleGroupDescription.height = 20;
						singleGroupDescription.top = 10;
						aLegendContainer.addElement(	singleGroupDescription );
					}
					
					for(var i:int = 0; i < legendResults.length; i++) {											
						if (layerIDs.contains(legendResults[i]["layerId"])) {
							//Add outline with flash effect   
							var groupDescription:spark.components.Label = new spark.components.Label();
							
							//if singleTitle is not specified, Add name with USGS capitalization, first letter only
							if (singleTitle == null) {
								var layerName:String = legendResults[i]["layerName"];
								groupDescription.text = layerName; //.charAt(0).toUpperCase() + layerName.substr(1, layerName.length-1).toLowerCase();
								//TODO: Move this to a single style
								groupDescription.setStyle("verticalAlign", "middle");
								groupDescription.setStyle("fontSize", "11");
								groupDescription.width = 300;
								groupDescription.top = 10;
								aLegendContainer.addElement(	groupDescription );
							}
							
							for each (var aLegendItem:Object in legendResults[i]["legend"]) {
								//Decode base 64 image data
								var b64Decoder:Base64Decoder = new Base64Decoder();							
								b64Decoder.decode(aLegendItem["imageData"].toString());
								//Make new image for decoded bytes
								var legendItemImage:Image = new Image();
								legendItemImage.load( b64Decoder.toByteArray() );
								var aLabel:String = aLegendItem["label"];
								//If singleTitle is specified and there is a single legend item with no label, use the layerName 
								if ((singleTitle != null) && (aLabel.length == 0) && ((legendResults[i]["legend"] as Array).length <= 1)) { aLabel = legendResults[i]["layerName"]; }
								//Use USGS sentance capitalization on labels
								aLabel = aLabel.charAt(0).toUpperCase() + aLabel.substr(1, aLabel.length-1).toLowerCase();								
								var legendItem:HGroup = 
									makeLegendItem( 
										legendItemImage, 
										aLabel
									);
								legendItem.paddingLeft = 20;
								aLegendContainer.addElement( legendItem );
								
							}			
						}
					} 
					
					
				}  else {
					Alert.show("No legend data found.");
				}		
				
				//Remove wait cursor
				CursorManager.removeBusyCursor();
			}
			
			private function makeLegendItem(swatch:UIComponent, label:String):HGroup {
				var container:HGroup = new HGroup(); 
				var layerDescription:spark.components.Label = new spark.components.Label();
				layerDescription.text = label;
				layerDescription.setStyle("verticalAlign", "middle");
				layerDescription.percentHeight = 100;
				container.addElement(swatch);
				container.addElement(layerDescription);
				
				return container;
			}

			private function getLegends(event:FlexEvent):void {
				fishSampleLocationsLegend.getLegends(event);
				catchmentsLegend.getLegends(event);
			}

			private function layerUpdateComp(layer:ArcGISDynamicMapServiceLayer):void {
				if (layer.visible) {
					mapLoadingScreen.visible = false;
				}
				
				/*if (layer == scenarios) {
					//scenariosLegend.getLegends(FlexEvent.
				} else if (layer == streamTemp) {
					//streamTempLegend.getLegends(evt)
				}*/
			}

			protected function showUSGSPopUpBox(event:MouseEvent, popupName:String):void
			{
				popUpBoxes[ popupName ] = PopUpManager.createPopUp(this, Group) as Group;
				popUpBoxes[ popupName ].addElement( this[ popupName ] );
				popUpBoxes[ popupName ].x = 20
				popUpBoxes[ popupName ].y = 20
			}
			
			
			protected function popUp_mouseOutHandler(event:MouseEvent, popupName:String):void
			{
				if (!popUpBoxes[ popupName ].hitTestPoint(event.stageX, event.stageY, true)) {
					PopUpManager.removePopUp(popUpBoxes[ popupName ]);
				}
			}

			//Custom USGS info/links popup function that locks the popup into an X-Y position no matter where you click on the icon to display it.
			//keeps the popup window from running off the screen if you click in the left side of the USGS icon.
			protected function showPopUpBox(event:MouseEvent, popupName:String):void
			{
				popUpBoxes[ popupName ] = PopUpManager.createPopUp(this, Group) as Group;
				popUpBoxes[ popupName ].addElement( this[ popupName ] );
				if (popupName == "FishVisLinkBox") {
					popUpBoxes[ popupName ].x = 615;
					popUpBoxes[ popupName ].y = 20;
				} else {
					popUpBoxes[ popupName ].x = 20;
					popUpBoxes[ popupName ].y = 20;
				}
			}
    		
    		
    		
    	
    		