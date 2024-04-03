enum EventEmitResult {    Ok,
    EventDoesntExist
}

enum EventAddResult {
    Ok,
    EventAlreadyAdded
}

enum EventAddListenerResult {
    Ok,
    EventDoesntExist
}

enum EventRemoveListenerResult {
    Ok,
    EventDoesntExist,
    ListenerDoesntExist
}

/// Abstract class for something that emits listenable events.
/// @param {Array<String>} event_names List of event names to register
function EventEmitter(event_names) constructor {
    
    events = {};
    
    /// Subscribe to an event as a listener.
    /// @param {String} event Event to listen to.
    /// @param {Function} listener Callback to listen with.
    /// @returns {Enum.EventAddListenerResult}
    on = function(event, listener) {
        if (!struct_exists(events, event)) {
            return EventAddListenerResult.EventDoesntExist;
        }
        
        array_push(events[$ event], listener);
        return EventAddListenerResult.Ok;
    }
    
    /// Remove a listen to an event.
    /// @param {String} event Event listening to.
    /// @param {Function} listener Callback to remove from the list.
    /// @returns {Enum.EventRemoveListenerResult}
    off = function(event, listener) {
        if (!struct_exists(events, event)) {
            return EventRemoveListenerResult.EventDoesntExist;
        }
        
        var listeners = events[$ event];
        var idx = array_find_index(listeners, method({ desired_listener: listener }, function(listener) {
            return listener == desired_listener;
        }));
        
        if (idx == -1) {
            return EventRemoveListenerResult.ListenerDoesntExist;
        }
        
        array_delete(listeners, idx, 1);
        return EventRemoveListenerResult.Ok;
    }
    
    /// [Protected] Emit a given event name to all listeners.
    /// @param {String} event Event name to emit.
    /// @param {Struct|undefined} [params] Parameters to send
    /// @returns {Enum.EventEmitResult}
    emit = function(event, params) {
        
        if (!struct_exists(events, event)) {
            return EventEmitResult.EventDoesntExist;
        }
        
        array_foreach(events[$ event], method({ params }, function(listener) {
            listener(params);
        }));
        
        return EventEmitResult.Ok;
    }
    
    /// [Protected] Add an event name to the list of events.
    /// @param {String} event Event name to add.
    /// @returns {Enum.EventAddResult}
    register = function(event) {
        if (struct_exists(events, event)) {
            return EventAddResult.EventAlreadyAdded;
        }
        
        events[$ event] = [];
        return EventAddResult.Ok;
    }
    
    // Register the passed in events immediately
    array_foreach(event_names, register);
    
}