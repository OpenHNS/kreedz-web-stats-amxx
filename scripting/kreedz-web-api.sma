#include <amxmodx>
#include <grip>

#define MAX_MAP_NAME_LENGTH 32

new ApiServer[] = "http://0.0.0.0:8080"
new ApiKey[] = "school-21-sber";

enum API_MAP {
	bool:MAP_INIT,
	MAP_ID
}

new g_eApiMapData[API_MAP];

enum API_USER {
	bool:USER_INIT,
	USER_ID
}

new g_eApiUserata[MAX_PLAYERS + 1][API_USER];

public plugin_natives() {
	register_native("api_get_map_id", "native_get_map_id");
	register_native("api_get_user_id", "native_get_user_id");
}

public native_get_map_id(amxx, params) {
	if (!g_eApiMapData[MAP_INIT]) {
		return -1;
	}

	return g_eApiMapData[MAP_ID];
}

public native_get_user_id(amxx, params) {
	enum { getId = 1 };

	new id = get_param(getId);

	// TODO: Check id

	if (!g_eApiUserata[id][USER_INIT]) {
		return -1;
	}

	return g_eApiUserata[id][USER_ID];
}

public plugin_init() {
	register_plugin("Kreedz web api", "dev", "OpenHNS");

	APILoadMap();
}

public client_authorized(id) {
	if (is_user_bot(id) || is_user_hltv(id)) {
		return;
	}

	APILoadPlayer(id);
}

public APILoadMap() {
	new GripRequestOptions:hRequestOptions = grip_create_default_options(.timeout = -1.0);
	grip_options_add_header(hRequestOptions, "Content-Type", "application/json");
	grip_options_add_header(hRequestOptions, "X-API-Key", ApiKey);
	
	new szMapName[MAX_MAP_NAME_LENGTH]; get_mapname(szMapName, MAX_MAP_NAME_LENGTH);

	new GripJSONValue:hJSONValue = grip_json_init_object();
	grip_json_object_set_string(hJSONValue, "name", szMapName);

	new GripBody:hBody = grip_body_from_json(hJSONValue);

	grip_request(fmt("%s/api/map", ApiServer), hBody, GripRequestTypePost, "APIMapRequest", hRequestOptions);
	
	grip_destroy_options(hRequestOptions);
	grip_destroy_json_value(hJSONValue);
	grip_destroy_body(hBody);
}

public APIMapRequest() {
	/* TODO: Вынести отдельно */
	new GripResponseState:rState = grip_get_response_state();
	if (rState == GripResponseStateError) {
		// TODO: Debugger
		return;
	}

	new GripHTTPStatus:rHTTPStatus = GripHTTPStatus:grip_get_response_status_code();
	if (rHTTPStatus != GripHTTPStatusOk) {
		// TODO: Debugger
		return;
	}

	new szError[128];
	new GripJSONValue:rData = grip_json_parse_response_body(szError, charsmax(szError));
	if (rData == Invalid_GripJSONValue) {
		// TODO: Debugger szError
		return;
	}
	/* TODO: Вынести отдельно */

	new tempMapID = grip_json_object_get_number(rData, "id");

	g_eApiMapData[MAP_INIT] = true;
	g_eApiMapData[MAP_ID] = tempMapID;
}

public APILoadPlayer(id) {
	new GripRequestOptions:hRequestOptions = grip_create_default_options(.timeout = -1.0);
	grip_options_add_header(hRequestOptions, "Content-Type", "application/json");
	grip_options_add_header(hRequestOptions, "X-API-Key", ApiKey);
	
	new szUserSteamID[MAX_MAP_NAME_LENGTH]; get_user_authid(id, szUserSteamID, MAX_AUTHID_LENGTH);
	new szUserName[MAX_MAP_NAME_LENGTH]; get_user_name(id, szUserName, MAX_NAME_LENGTH);

	new GripJSONValue:hJSONValue = grip_json_init_object();
	grip_json_object_set_string(hJSONValue, "steam_id", szUserSteamID);
	grip_json_object_set_string(hJSONValue, "name", szUserName);

	new GripBody:hBody = grip_body_from_json(hJSONValue);

	grip_request(fmt("%s/api/user", ApiServer), hBody, GripRequestTypePost, "APIUserRequest", hRequestOptions, id);
	
	grip_destroy_options(hRequestOptions);
	grip_destroy_json_value(hJSONValue);
	grip_destroy_body(hBody);
}

public APIUserRequest(id) {
	/* TODO: Вынести отдельно */
	new GripResponseState:rState = grip_get_response_state();
	if (rState == GripResponseStateError) {
		// TODO: Debugger
		return;
	}

	new GripHTTPStatus:rHTTPStatus = GripHTTPStatus:grip_get_response_status_code();
	if (rHTTPStatus != GripHTTPStatusOk) {
		// TODO: Debugger
		return;
	}

	new szError[128];
	new GripJSONValue:rData = grip_json_parse_response_body(szError, charsmax(szError));
	if (rData == Invalid_GripJSONValue) {
		// TODO: Debugger szError
		return;
	}
	/* TODO: Вынести отдельно */

	new tempUserID = grip_json_object_get_number(rData, "id");

	g_eApiUserata[id][USER_INIT] = true;
	g_eApiUserata[id][USER_ID] = tempUserID;
}