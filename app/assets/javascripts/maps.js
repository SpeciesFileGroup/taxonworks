//<script src="http://maps.google.com/maps/api/js?sensor=false"></script>
//    <script src="http://cdn.leafletjs.com/leaflet-0.6.4/leaflet.js"></script>
//    <link rel="stylesheet" href="http://cdn.leafletjs.com/leaflet-0.6.4/leaflet.css" />
//    <script src="http://cdn.leafletjs.com/leaflet-0.6.4/leaflet.js"></script>
//	<script>
//		CM_ATTR = 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
//				'<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
//				'Imagery © <a href="http://cloudmade.com">CloudMade</a>';

//		CM_URL = 'http://{s}.tile.cloudmade.com/121c86d2baf84dd383f0f5d3eff472fb/{styleId}/256/{z}/{x}/{y}.png';

//		OSM_URL = 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
//		OSM_ATTRIB = '&copy; <a href="http://openstreetmap.org/copyright">OpenStreetMap</a> contributors';
//	</script>
//<script src="all_items.json"></script>
//	<script>
		var map;	//google map object
		var LJSpolygon	//leafletjs map object
//		var infoWindow;	// unused
//		var bounds;			// at this point
		var gPoints = [];		//googlemaps arrays
		var gLinePoints = [];
		var gPolyPoints = [];

		var lPolyPoints = [];	//leafletjs arrays
		var lPoints = [];
		var lLinePoints = [];

		function leafInit() {
			var LJSmap = L.map('Lmap').setView([document.form1.Slat.value, document.form1.Slon.value], 4);
			L.tileLayer('http://{s}.tile.cloudmade.com/121c86d2baf84dd383f0f5d3eff472fb/997/256/{z}/{x}/{y}.png', {
				attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://cloudmade.com">CloudMade</a>[…]',
				maxZoom: 18
			}).addTo(LJSmap);		//key following cloudmade.com is issued to jrflood@illinois.edu

			if (typeof (data) != 'undefined') {		//make sure data is in
				if (typeof (lPoints) != 'undefined') {
					var lPoint;
					for (var k = 0; k < lPoints.length; k++) {
						lPoint = createPointL(lPoints[k], "#880000");
						lPoint.addTo(LJSmap);
					};
				};

				if (typeof (lLinePoints) != 'undefined') {
					for (var k = 0; k < lLinePoints.length; k++) {		//iterate for all simple linestrings collected from linestrings and multilinestrings
//						var lLine = createLineL(lLinePoints[k]);//did not work!!!??!!!???
						var lLine = new L.Polyline(lLinePoints[k], { color: '#FF0000', weight: 1, opacity: 0.5 }); //,  smoothFactor: 1
						lLine.addTo(LJSmap);	
					};
				};

				for (var kk = 0; kk < lPolyPoints.length; kk++)		//iterate for all simple polygons collected from polygons and multipolygons
				 {
					LJSpolygon = null;
					LJSpolygon = createPolygonL(lPolyPoints[kk], {color: '#00FF00', fillColor: '#FF0000', weight: 1, opacity: 1.0 }).addTo(LJSmap);  //, fillColor: '#f03', fillOpacity: 0.5 }).addTo(LJSmap);
				};
			};
		}   //leafInit

		function initialize() {
			var myLatLng = new google.maps.LatLng(document.form1.Slat.value, document.form1.Slon.value);
			// var myLatLng = new google.maps.LatLng(40.0911, -88.2382);  //shampoo banana
			var myOptions = {
				zoom: 4,
				center: myLatLng,
				mapTypeControl: true,
				mapTypeControlOptions: { style: google.maps.MapTypeControlStyle.DROPDOWN_MENU },
				navigationControl: true,
				mapTypeId: google.maps.MapTypeId.TERRAIN
			};
			map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
			//    bounds = new google.maps.LatLngBounds();
			getdata();
			//    if (data == null) return;

			if (typeof (gPoints) != 'undefined') {
				var gPoint;
				for (var k = 0; k < gPoints.length; k++) {
					gPoint = createPoint(gPoints[k], "#880000");
					gPoint.setMap(map);
				};
			};

			if (typeof (gLinePoints) != 'undefined') {
				for (var k = 0; k < gLinePoints.length; k++) {
//					var gLine = createLine(gLinePoints[k], "black");	//did not work!!!??!!!???
					var gLine = new  google.maps.Polyline({
						path: gLinePoints[k],
						geodesic: false,
						strokeColor: '#FF0000',
						strokeOpacity: 0.5,
						strokeWeight: 1
					});
					gLine.setMap(map);
				};
			};

			if (typeof (gPolyPoints) != 'undefined') {
				var gPoly;
				for (var k = 0; k < gPolyPoints.length; k++) {
					gPoly = createPolygon(gPolyPoints[k], "#880000");
					gPoly.setMap(map);
				};
			};
			//    map.fitBounds(bounds);
		};	//google initialize

		function Report(event) {
			x = event.clientX; y = event.clientY;
			Xmin = -180; Xmax = 180; Ymin = -90; Xsize = document.form1.Xwidth.value; Ymax = 90; Ysize = 0.5 * Xsize; //Ymax = 83.6236
			if ((x <= Xsize) && (x >= 12) && (y <= Ysize) && (y >= 18))    //is the click inside the map?
			{
				Xlon = (Xmax - Xmin) * (((x - 12) / Xsize) - 0.5);
				Ylat = -(Ymax - Ymin) * (((y - 18) / Ysize) - 0.5);
				document.form1.Slat.value = Ylat; document.form1.Slon.value = Xlon; document.form1.submit();
			}
		};

	function getdata() {
		/*		get data object encoded as geoJSON and disseminate to google and leaflet arrays
	Assumptions:
		data is a hash
		Multi- geometry types are composed of simple (homogeneous) types: Point, LineString, Polygon
		these are collected as xPoints[], xLinePoints[], xPolyPoints[]; x = g | l for google and leafletjs respectively
		this leaves ambiguous the association of attributes to the objects (e.g., color, etc.)
		New realization: there may or may not be GeometryCollections, which may contain any type, including GeometryCollection !  $#!+
		*/
		if (typeof (data) != 'undefined') {
			if (typeof (data.type) != "undefined") {
				if (data.type == "GeometryCollection") {
					for (var i = 0; i < data.geometries.length; i++) {
						getTypeData(data.geometries[i]);
					};  //for i
				}
				else
				{
					getTypeData(data);
				}   //data.type
			};     //data != undefined
		};     //data != undefined
	};

	function getTypeData(thisType) {		//detect and extract geometry types from higher level enumerator, recursible

		if (thisType.type == "GeometryCollection") {
			for (var i = 0; i < thisType.geometries.length; i++) {
				if (typeof (thisType.geometries[i].type) != "undefined") {
					getTypeData(thisType.geometries[i]);		//  recurse if GeometryCollection
				};     //thisType != undefined
			};  //for i
		};

		if (thisType.type == "Point") {
			gPoints.push(new google.maps.LatLng(thisType.coordinates[1], thisType.coordinates[0]));
			lPoints.push([thisType.coordinates[1], thisType.coordinates[0]]);   // x:=0; y:=1; (z:=2;)
		};

		if (thisType.type == "MultiPoint") {
			for (var l = 0; l < thisType.coordinates.length; l++) {
			gPoints.push(new google.maps.LatLng(thisType.coordinates[l][1], thisType.coordinates[l][0]));
			lPoints.push([thisType.coordinates[l][1], thisType.coordinates[l][0]]);
			};
		};

		if (thisType.type == "LineString") {
			var m = gLinePoints.length
			var n = lLinePoints.length
			gLinePoints[m] = [];
			lLinePoints[n] = [];
			for (var l = 0; l < thisType.coordinates.length; l++) {
				gLinePoints[m].push(new google.maps.LatLng(thisType.coordinates[l][1], thisType.coordinates[l][0]));
				lLinePoints[n].push(new L.latLng(thisType.coordinates[l][1], thisType.coordinates[l][0]));
				//};
			};
		};

		if (thisType.type == "MultiLineString") {
			for (var k = 0; k < thisType.coordinates.length; k++) {   //k enumerates linestrings, l enums points
			var m = gLinePoints.length
			var n = lLinePoints.length
			gLinePoints[m] = [];
			lLinePoints[n] = [];
				for (var l = 0; l < thisType.coordinates[k].length; l++) {
				gLinePoints[m].push(new google.maps.LatLng(thisType.coordinates[k][l][1], thisType.coordinates[k][l][0]));
				lLinePoints[n].push(new L.latLng(thisType.coordinates[k][l][1], thisType.coordinates[k][l][0]));
				};
			};
		};

		if (thisType.type == "Polygon") {
			for (var k = 0; k < thisType.coordinates.length; k++) {
				// k enumerates polygons, l enumerates points
				var m = gPolyPoints.length
				var n = lPolyPoints.length
				gPolyPoints[m] = [];		//create a new coordinate/point array for this (m/n) polygon
				lPolyPoints[n] = [];
				for (var l = 0; l < thisType.coordinates[k].length; l++) {
					gPolyPoints[m].push(new google.maps.LatLng(thisType.coordinates[k][l][1], thisType.coordinates[k][l][0]));
					lPolyPoints[n].push(new L.latLng(thisType.coordinates[k][l][1], thisType.coordinates[k][l][0]));
				};
			};
		};
		
		if (thisType.type == "MultiPolygon") {
			for (var j = 0; j < thisType.coordinates.length; j++) {		// j iterates over multipolygons
				for (var k = 0; k < thisType.coordinates[j].length; k++) {  //k iterates over polygons
					var m = gPolyPoints.length
					var n = lPolyPoints.length
					gPolyPoints[m] = []; //create a new coordinate/point array for this (m/n) polygon
					lPolyPoints[n] = [];
					for (var l = 0; l < thisType.coordinates[j][k].length; l++) {
						gPolyPoints[m].push(new google.maps.LatLng(thisType.coordinates[j][k][l][1], thisType.coordinates[j][k][l][0]));
						lPolyPoints[n].push(new L.latLng(thisType.coordinates[j][k][l][1], thisType.coordinates[j][k][l][0]));
					};
				};
			};
		};
	};        //getTypeData

		function createPoint(coords, color) {
			return new google.maps.Marker({
				position: coords,
				map: map
			});
		};

//		function createLine(coords, color) {
//			return new google.maps.Polyline({
//				paths: coords,
//				geodesic: false,
//				strokeColor: "#FF0000",
//				strokeOpacity: 0.5,
//				strokeWeight: 3
//			});
//		};

		function createPolygon(coords, color) {
			return new google.maps.Polygon({
				paths: coords,
				strokeColor: "black",
				strokeOpacity: 0.8,
				strokeWeight: 1,
				fillColor: color,
				fillOpacity: 0.3
			});
		};

		function createPointL(coords, color) {
			return new L.marker(coords, { color: color });
			var marker = L.marker([51.5, -0.09]).addTo(map);
		};

//		function createLineL(coords, color) {
//			return new L.Polyline(coords, { color: color });
//		};

		function createPolygonL(coords, color) {
			return new L.Polygon(coords, { color: color });
		};

//	</script>
/*
 	 <div id="map_canvas" style="width: 1024px; height: 1024px;">
	 <script type="text/javascript">
	 	initialize();
	 </script>
	 </div>
 <div id="Lmap" class="map" style="width: 1024px; height: 1024px">
 <script type="text/javascript">
 	leafInit();
 </script>
 </div>
   </form>
</body>
</html>
*/
