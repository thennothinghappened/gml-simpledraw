
function Preferences() constructor {
	
	static filename = "preferences.json";
	
	/// Preferences data.
	self.data = new PrefsData();
	
	/// Setup preferences.
	static init = function() {
		
		var prefs_load_result = self.load();

		if (is_instanceof(prefs_load_result, Err)) {
			show_message($"Failed to load preferences, using defaults:\n{prefs_load_result}");
		}
	}
	
	/// Attempt to load the preferences file.
	/// @returns {Struct.Err|undefined}
	static load = function() {
		
		if (!file_exists(filename)) {
			return;
		}
		
		var buf = buffer_load(filename);
		
		if (!buffer_exists(buf)) {
			return new Err($"Failed to read preferences file `{filename}` synchronously!");
		}
		
		var text = buffer_read(buf, buffer_text);
		
		buffer_delete(buf);
		
		var json;
		
		try {
			json = json_parse(text);
		} catch (err) {
			return new Err("Failed to read preferences file as JSON - is it valid JSON?", err);
		}
		
		if (!is_struct(json)) {
			return new Err("Preferences file was not a valid JSON object.");
		}
		
		var keys = struct_get_names(json);
		
		for (var i = 0; i < array_length(keys); i ++) {
			
			var key = keys[i];
			var type = typeof(json[$ key]);
			
			if (!struct_exists(self.data, key)) {
				return new Err($"Unknown key `{key}` in preferences file.");
			}
			
			var expected_type = typeof(self.data[$ key]);
			
			if (type != expected_type) {
				return new Err($"Key `{key}` of preferences file expected to be type `{expected_type}`, found `{type}`");
			}
			
			self.data[$ key] = json[$ key];
			
		}
		
		return;
		
	}

	/// Attempt to save the preferences file.
	static save = function() {
		
		var text = json_stringify(self.data);
		var size = string_byte_length(text);
		
		var buf = buffer_create(size, buffer_fixed, 1);
		buffer_write(buf, buffer_text, text);
		
		try {
			buffer_save(buf, filename);
		} catch (err) {
		
			buffer_delete(buf);
			
			return new Err($"Failed to save preferences file `{filename}`!", err);
		}
		
		buffer_delete(buf);
		
		return;
		
	}
	
}

function PrefsData(
	camRotSpeed = 0.01,
	camZoomSpeed = 0.1,
	camZoomMax = 100,
	camZoomMin = 0.1,
	frameRate = 170
) constructor {
	
	/// How fast the camera rotates.
	self.camRotSpeed = camRotSpeed;

	/// How fast the camera zooms.
	self.camZoomSpeed = camZoomSpeed;

	/// Maximum camera distance.
	self.camZoomMax = camZoomMax;

	/// Minimum camera distance.
	self.camZoomMin = camZoomMin;
	
	/// The frame rate to use... duh.
	self.frameRate = frameRate;
	
}
