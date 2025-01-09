/**
 * @desc
 */

draw_text(4, 4, $"Command History: {json_stringify(array_map(self.history, script_get_name), true)}\nHistory Step Count: {self.historyStepCount}");
