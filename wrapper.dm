world
	version = 40 // Turn off debug before release!

	view = 21

	New()
		. = ..()
		name = "Casual Quest - Version 1.[version]"

		game = new()

#ifdef DEBUG
		spawn(20)
			// A secret warning so I don't forget to disable debug mode
			world<<"<span style='font-weight:bold;color:#DD0000'>What a beautiful day in the world of Illuna!</span>"
#endif

var/server_name

mob/density = 0

client
	#ifndef DEBUG
	control_freak = TRUE
	#endif

	preload_rsc = "http://files.byondhome.com/iainperegrine/casual_quest_rsc_38.zip"

	verb
		force_reboot()
			set name = ".force_reboot"
#ifndef DEBUG
			if(!(ckey in list("iainperegrine", "cauti0n","williferd", "darkcampainger")))
				return
#endif
			var/phrase = input(src, "Type the word \"reboot\" to reboot the world","CQ Admin Panel") as null|text
			if(lowertext(phrase) == "reboot") world.Reboot()

		forcereboot()
			set name = ".forcereboot"
			force_reboot()

		change_class()
			set name = ".change"
#ifndef DEBUG
			if(!(ckey in list("iainperegrine", "cauti0n","williferd")))
				return
#endif
			var/class_path = input(src,"Select a class","CQ Admin Panel") as null|anything in (typesof(/game/hero)-/game/hero)
			if(!class_path) return

			game.add_hero(src, class_path)
			src.hero.output_class_link(world, src)

		change_other()
			set name = ".other"
#ifndef DEBUG
			if(!(ckey in list("iainperegrine", "cauti0n","williferd")))
				return
#endif
			var/list/clients = new()
			for(var/client/C)
				clients.Add(C)

			var/client/who = input(src, "Pick a player to change", "CQ Admin Panel") as null|anything in clients
			if(!who) return

			var/class_path = input(src,"Select a class","CQ Admin Panel") as null|anything in (typesof(/game/hero)-/game/hero)
			if(!class_path) return

			game.add_hero(who, class_path)
			who.hero.output_class_link(world, who)

		start_wave()
			set name = ".wave"
#ifndef DEBUG
			if(!(ckey in list("iainperegrine", "cauti0n","williferd")))
				return
#endif
			var/start_wave = input(src, "Choose a Starting Wave", "Yada Yada", 100) as num
			start_wave = round(start_wave)
			start_wave = max(1, start_wave)
			game.join(src, start_wave)

	East(     ) return
	Southeast() return
	South(    ) return
	Southwest() return
	West(     ) return
	Northwest() return
	North(    ) return
	Northeast() return

game/map/mover
	icon = 'rectangles.dmi'
	icon_state = "square-grey_32"


game/map/mover/gridded{
	translate(x_amo, y_amo){
		if(     x_amo && !y_amo){
			var/asdf = c.y % (TILE_HEIGHT/2)
			if(asdf){
				if((asdf - (TILE_HEIGHT/4)) >= 0){
					y_amo++
					}
				else{
					y_amo--
					}
				}
			}
		else if(y_amo && !x_amo){
			var/asdf = c.x % (TILE_WIDTH/2)
			if(asdf){
				if((asdf - (TILE_WIDTH/4)) >= 0){
					x_amo++
					}
				else{
					x_amo--
					}
				}
			}
		. = ..()
		}
	}

#include "Gamepad.dm"

client
	var game/hero/hero

	// Movement input. Each are either -1, 0, or 1. 
	var input_x
	var input_y

	// Button inputs.
	var input_primary
	var input_secondary
	var input_tertiary
	var input_quaternary
	var input_help

	proc
		check_inputs()
			var key_dirs = key_state | key_pressed
			
			// Determine movement input from the keyboard.
			input_x = !!(key_dirs & EAST) - !!(key_dirs & WEST)
			input_y = !!(key_dirs & NORTH) - !!(key_dirs & SOUTH)

			// Determine movement input from diagonal buttons.
			if(!(input_x || input_y))
				var northeast = GetButton("Northeast")
				var northwest = GetButton("Northwest")
				var southeast = GetButton("Southeast")
				var southwest = GetButton("Southwest")
				input_x = (northeast || southeast) - (northwest || southwest)
				input_y = (northeast || northwest) - (southeast || southwest)

			// Determine movement input from the gamepad. 
			if(!(input_x || input_y))
				// Read values from the left analog stick. 
				input_x = GetLeftAnalogX()
				input_y = GetLeftAnalogY()

				// Deadzone
				if(input_x * input_x + input_y * input_y < 0.04)
					input_x = 0
					input_y = 0

				else
					// "Round" to the nearest 8-direction ("improved general direction proc").
					if(input_x && input_y)
						var ax = abs(input_x)
						var ay = abs(input_y)
						if(ax >= ay * 2)
							input_y = 0
						else if(ay >= ax * 2)
							input_x = 0

					// Normalize inputs.
					if(input_x)
						input_x /= abs(input_x)
					if(input_y)
						input_y /= abs(input_y)
			
			// Determine button inputs. 
			input_primary = !!(PRIMARY & key_pressed) || GetButton("GamepadFace1")
			input_secondary = !!(SECONDARY & key_pressed) || GetButton("GamepadFace3")
			input_tertiary = !!(TERTIARY & key_pressed) || GetButton("GamepadFace4")
			input_quaternary = !!(QUATERNARY & key_pressed) || GetButton("GamepadFace2")
			input_help = !!(HELP_KEY & key_pressed) || \
				GetButton("GamepadL2") || \
				GetButton("GamepadR2")
			
		intelligence(var/game/map/mover/M)
			if(!hero.projectile)
				// Move according to the movement inputs and the hero's speed.
				var x_translate = input_x * hero.speed
				var y_translate = input_y * hero.speed
				M.px_move(x_translate, y_translate)

				// Respond to button inputs.
				if(input_primary)
					hero.shoot()
				else if(input_secondary && hero.skill1)
					if(hero.aura >= hero.skill1_cost)
						hero.adjust_aura(-hero.skill1_cost)
						var/game/hero/skill/skill1 = new hero.skill1(hero)
						skill1.activate()
				else if(input_tertiary && hero.skill2)
					if(hero.aura >= hero.skill2_cost)
						hero.adjust_aura(-hero.skill2_cost)
						var/game/hero/skill/skill2 = new hero.skill2(hero)
						skill2.activate()
				else if(input_quaternary && hero.skill3)
					if(hero.aura >= hero.skill3_cost)
						hero.adjust_aura(-hero.skill3_cost)
						var/game/hero/skill/skill3 = new hero.skill3(hero)
						skill3.activate()
				else if(input_help)
					hero.call_help()

			clear_keys()
