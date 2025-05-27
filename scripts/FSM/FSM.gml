
/**
 * An object which can exist in one or more defined states, and move between
 * those states, executing logic specific to each state.
 * 
 * States can be referred to by either strings, or enum members, depending on
 * which is preferred.
 * 
 * @param {String|Real} initialStateName Name of the state to execute first.
 */
function FSM(initialStateName) constructor {
	
	/**
	 * @ignore
	 */
	self.states = {};
	self.currentStateName = initialStateName;
	
	/**
	 * How long the current state has been running for, in frames.
	 * 
	 * @type {Real}
	 * @ignore
	 */
	self.timeInState = 0;
	
	/**
	 * Define a state with a given name. If this state is the specified initial state, the `enter`
	 * event for this state is immediately executed.
	 * 
	 * An `enter` event may return the name of another state. This is useful in such a case to define
	 * a "transition" between states, where an intermediate state only defines an `enter` method, which
	 * produces any necessary transitional side effects, and this method returns the name of the desired
	 * "end" state.
	 * 
	 * The `leave` event is passed the name of the next target state, so it may apply any relevant logic.
	 * This is an alternative option to transitions, where it makes sense to keep logic contained to the
	 * state itself.
	 * 
	 * ### Exceptions
	 * 
	 * Throws if the name is taken.
	 * 
	 * @param {String|Real} name
	 * @param {Struct} struct
	 */
	static state = function(name, state) {
		
		if (variable_struct_exists(self.states, name)) {
			throw new Err(string("State name `{0}` is taken", name));
		}
		
		// Bind state methods to the caller, instead of the struct.
		var eventNames = variable_struct_get_names(state);
		
		for (var i = 0; i < array_length(eventNames); i ++) {
			var key = eventNames[i];
			state[$ key] = method(other, state[$ key]);
		}
		
		if (name == self.currentStateName) {
			var enter = state[$ "enter"];
			
			if (!is_undefined(enter)) {
				enter();
			}
		}
		
		self.states[$ name] = state;
		
	};
	
	/**
	 * Run the event of the given name, for the current state.
	 * 
	 * If the event executed has the name `step`, `event`, or `tick` - or any others you may wish to
	 * add to this list, it will increment the event's duration every time it is executed.
	 * 
	 * @param {String|Real} name
	 * @returns {String|Real}
	 */
	static run = function(name) {
		
		var currentState = self.states[$ self.currentStateName];
		var event = currentState[$ name];
		
		if (is_undefined(event)) {
			return self.currentStateName;
		}
		
		var newStateName = event(self.timeInState);

		if (name == "step" || name == "tick" || name == "update") {
			self.timeInState ++;
		}
		
		if (is_undefined(newStateName)) {
			return self.currentStateName;
		}
		
		return self.change(newStateName);
		
	};
	
	/**
	 * Change to a new state.
	 * 
	 * ### Exceptions
	 * 
	 * Throws if the new state does not exist.
	 * 
	 * @param {String|Real} newStateName
	 */
	static change = function(newStateName) {
		
		if (newStateName == self.currentStateName) {
			return self.currentStateName;
		}
		
		if (!variable_struct_exists(self.states, newStateName)) {
			throw new Err(string("Cannot change to non-existent state `{0}`", newStateName));
		}
		
		var currentState = self.states[$ self.currentStateName];
		
		self.currentStateName = newStateName;
		self.timeInState = 0;
		
		var leave = currentState[$ "leave"];
		
		if (!is_undefined(leave)) {
			leave(newStateName);
		}
		
		var newState = self.states[$ self.currentStateName];
		var enter = newState[$ "enter"];
		
		if (!is_undefined(enter)) {

			var potentialNewStateName = enter();

			if (potentialNewStateName != undefined) {
				return self.change(potentialNewStateName);
			}

		}
		
		return newStateName;
		
	}
	
}
