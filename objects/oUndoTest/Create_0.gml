/**
 * @desc
 */

self.width = 800;
self.height = 600;

/**
 * The current canvas state as drawable.
 */
self.canvas = surface_create(self.width, self.height);

/**
 * The canvas state as it was, max `self.maxUndoSteps` ago.
 */
self.baseCanvas = buffer_create(surface_get_buffersize(self.width, self.height), buffer_fixed, 1);

/**
 * The number of undos permitted.
 */
self.maxUndoSteps = 10;

/**
 * Command history. Each command performs some kind of action upon the canvas, modifying it.
 */
self.history = [];

/**
 * The number of steps in the history to be executed. If this value is less than the history length,
 * we must be at an undo step.
 * 
 * In this case, 
 */
self.historyStepCount = 0;

FEATHERHINT {
	array_push(self.history, /** @param {Id.Surface} canvas */ function(canvas) {});
}

/**
 * Restore the canvas from the base canvas and history if it was lost.
 * If the canvas is already present, this has no effect.
 */
ensureCanvas = function() {
	
	if (surface_exists(self.canvas)) {
		return;
	}
	
	self.canvas = surface_create(self.width, self.height);
	buffer_set_surface(self.baseCanvas, self.canvas, 0);
	
	self.applyCommands();
	
}

/**
 * Apply the command list.
 * 
 * Uses the base surface as well, the base, and works forwards to bring
 * `self.canvas` up to date.
 * 
 * #### Notes
 * 
 * This function expects that `self.canvas` is already at an equivalent state to the base. If
 * this is not true, unexpected results will occur.
 * 
 * @param {Real} offset Offset into the command list to begin from. Increase to only execute a sub-portion.
 */
applyCommands = function(offset = 0) {
	
	Draw.pushSurface(self.canvas);
		
		array_foreach(self.history, function(command) {
			command(self.canvas);
		}, offset, self.historyStepCount - offset);
		
	Draw.popSurface();
	
};

/**
 * Append a command to the history. If the history length would overflow by doing this operation, the
 * oldest entry is removed and the base state is moved forwards.
 * 
 * @param {Function} command `() -> undefined` The command to be appended.
 */
appendCommand = function(command) {
	
	if (array_length(self.history) > self.historyStepCount) {
		// Erase the future!
		array_delete(self.history, self.historyStepCount + 1, array_length(self.history) - self.historyStepCount);
	}
	
	if (self.historyStepCount == self.maxUndoSteps) {
		
		var oldest = array_shift(self.history);
		
		buffer_set_surface(self.baseCanvas, self.canvas, 0);
		
		Draw.pushSurface(self.canvas);
			oldest(self.canvas);
		Draw.popSurface();
		
		buffer_get_surface(self.baseCanvas, self.canvas, 0);
		
	} else {
		self.historyStepCount ++;
	}
	
	array_push(self.history, command);
	self.applyCommands();
	
};

/**
 * Undo the latest command.
 */
undo = function() {
	
	if (self.historyStepCount == 0) {
		return;
	}
	
	buffer_set_surface(self.baseCanvas, self.canvas, 0);
	self.historyStepCount --;
	
	self.applyCommands();
	
}

/**
 * Produce a rectangle command to be executed.
 * 
 * @param {Real} x
 * @param {Real} y
 * @param {Real} width
 * @param {Real} height
 * @param {Constant.Color} colour
 */
rect = function(x, y, width, height, colour) {
	return method({ x, y, width, height, colour }, function() {
		Draw.pushColour(colour);
			draw_rectangle(x, y, x + width, y + height, false);
		Draw.popColour();
	});
};


