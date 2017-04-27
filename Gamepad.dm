client
	var
		_left_analog_x = 0
		_left_analog_y = 0
		list/_is_button_pressed = new

	verb
		gamepad_left_analog(x as num, y as num)
			set name = ".gamepad left analog", instant = TRUE
			_left_analog_x = x
			_left_analog_y = y
		
		button_press(button_name as text)
			set name = ".button press", instant = TRUE
			_is_button_pressed[button_name] = TRUE

			if(button_name == "GamepadL1") card(1)
			else if(button_name == "GamepadR1") card(2)
			
		button_release(button_name as text)
			set name = ".button release", instant = TRUE
			_is_button_pressed[button_name] = FALSE
	
	proc
		GetLeftAnalogX()
			return _left_analog_x
		
		GetLeftAnalogY()
			return _left_analog_y

		GetButton(button_name)
			return _is_button_pressed[button_name] || FALSE

		ClearGamepadInputs()
			_left_analog_x = 0
			_left_analog_y = 0
			_is_button_pressed.Remove(
				"GamepadL1", "GamepadL2", "GamepadL3",
				"GamepadR1", "GamepadR2", "GamepadR3",
				"GamepadFace1", "GamepadFace2", "GamepadFace3", "GamepadFace4",
				"GamepadSelect", "GamepadStart")
