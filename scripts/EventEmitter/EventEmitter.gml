
/**
* Abstract class for something that emits subscribable events.
* 
* @param {Array<String>} event_names List of event names to register
*/
function EventEmitter(event_names) constructor {
	
	events = {};
	
	/**
	* Subscribe to an event as a listener.
	* 
	* ### Exceptions
	* 
	* Throws if the given event name is invalid.
	* 
	* @param {String} event Event to listen to.
	* @param {Function} listener Callback to listen with.
	*/
	static on = function(event, listener) {
	
		if (!struct_exists(events, event)) {
			throw new Err($"Cannot subscribe to non-registered event `{event}`");
		}
		
		array_push(events[$ event], listener);
	}
	
	/**
	* Remove a subscription to an event.
	* 
	* Returns whether the subscription was removed. If this is false, no such subscription existed.
	* 
	* ### Exceptions
	* 
	* Throws if the given event name is invalid.
	* 
	* @param {String} event Event listening to.
	* @param {Function} listener Callback to remove from the list.
	* @returns {Bool}
	*/
	static off = function(event, listener) {
		
		var listeners = events[$ event];
		
		if (is_undefined(listeners)) {
			throw new Err($"Cannot unsubscribe from non-registered event `{event}`");
		}
		
		var idx = array_find_index(listeners, method({ listener }, function(it) {
			return it == listener;
		}));
		
		if (idx < 0) {
			return false;
		}
		
		array_delete(listeners, idx, 1);
		
		return true;
	}
	
	/**
	* **[Protected]** Emit a given event name to all listeners.
	* 
	* ### Exceptions
	* 
	* Throws if the given event name is invalid.
	* 
	* @param {String} event Event name to emit.
	* @param {Struct|undefined} [params] Parameters to send
	*/
	static emit = function(event, params = undefined) {
		
		if (!struct_exists(events, event)) {
			throw new Err($"Cannot emit non-registered event `{event}`");
		}
		
		array_foreach(events[$ event], method({ params }, function(listener) {
			listener(params);
		}));
	}
	
	/**
	* **[Protected]** Add an event name to the list of events.
	* 
	* ### Exceptions
	* 
	* Throws if the given event name is already registered.
	* 
	* @param {String} event Event name to add.
	* @returns {Enum.EventAddResult}
	*/
	static register = function(event) {
		
		if (struct_exists(events, event)) {
			throw new Err($"Event name `{event}` is already registered");
		}
		
		events[$ event] = [];
	}
	
	// Register the passed in events immediately
	array_foreach(event_names, register);
	
}


