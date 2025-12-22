-- NEW DOCS AT https://screenlab.gitbook.io/screenlab

--[[
	ScreenLAB is a engine made for making 2D games in the roblox 3d engine
	I aim to make this engine as easy to work with but as powerfull as I can within the roblox gui limitations

	Use scale for all ui positions and sizes
	Any of the functions defined below are engine functions
	Ex. to change the position of a sprite it would be Sprite.Object.Position, not Sprite.Position because Position is a roblox engine function, not a screenlab function

	Engine:
		GetCurrentDeviceType [FUNC] - Returns the current DeviceType
		GetVersion [FUNC] - Returns screenlab version string
		ShowIntroInStudio [BOOL] - shows into when playing in studio, call this before RegisterPlayer
		RegisterPlayer (DEPRECIATED) [FUNC] - passes the player to the game engine (only call this once), (THIS IS AUTOMATICALLY CALLED ON ENGINE LOAD) [Not in types]
		CreatePlayerUI (DEPRECIATED) [FUNC] - Creates ui for registred player (only call this once), (THIS IS AUTOMATICALLY CALLED ON ENGINE LOAD) [Not in types]
		LockPlayer [FUNC] - OPTIONAL: easy way to lock the 3d player movement and camera movement, (THIS IS AUTOMATICALLY CALLED ON ENGINE LOAD) [Not in types]
		Sprites [TABLE] - table containing all sprites 
		GetSpriteFromUniqueId [FUNC] - returns the sprite with the UniqueId specified
		Console [INSTANCE] - This is the custom console instance, is null if UseCustomConsole is false
		AllowRuntimeCodeExecution [BOOL] - Allows you to execute code as a string at runtime when enabled
		GraphicsDeltaTime[NUM] - The delta time from the graphics driver. Will stay at 0 if graphics engine is not required to run
		EnableDebugKeys[BOOL] - allow players to use function keys for debug view
		
		DeviceType [ENUM]:
			Console
			Pc
			Mobile
			Unknown
		
		ConsoleSettings [TABLE]:
			UseCustomConsole [BOOL] - If set to true, replace default F9 console with the screenlab console (default true)
			ShowCallstackInGame [BOOL] - Shows the callstack of the printed line in the custom console when not in studio (default true)

		playerData [TABLE]:
			contains info passed to components and other helpfull references
			
			ScreenLabWindow [INSTANCE] - ScreenLabBase frame
			PlayerInstance [INSTANCE] - Player object
			ScreenLabBaseUI [INSTANCE] - ScreenLabUI screengui
			ScreenlabCore [TABLE] - returns engine modulescript
			Sprites [INSTANCE] - sprites folder
			Tmp [INSTANCE] - tmp folder
			Topbar [INSTANCE] - screenlabs topbar
	
	Scenes:
		BETA
		
		Used to create and manage sprites in an easy way
		
		self.Sprite.new [FUNC] - creates new sprite in scene
		Load [FUNC] - loads scene
		Unload [FUNC] - unloads scene
		Destroy [FUNC] - destroys scene
		Reload [FUNC] - reloads scene
	
    Sprites:
    	Sprites are objects recognised by the game engine.    	
    	
    	Sprite.new - Creates new sprite
    	
    		GetObject [FUNC] (INTERNAL) - returns the sprites instance [Not in types]
    		SetParent [FUNC] - Sets sprites parent to another sprite
    		Components [TABLE] (INTERNAL) - Table with all components of the sprite. THIS IS FOR ENGINE USE ONLY, CALLING OBJECT FUNCTIONS DIRECTLY COULD CAUSE COMPONENT ISSUES [Not in types]
    		CreateFunctionHook [FUNC] (INTERNAL) - Creates a function hook that can override object functions. THIS IS FOR ENGINE USE ONLY, ALLOWS YOU TO OVVERWRIDE FUNCTION OR JUST HOOK IT WITH RETURN VALUE [Not in types]
    		AddComponent [FUNC] - Adds component with argument name. if a screenlab component isent found, attempt to add a defult roblox component (Instance.New)
    		RemoveComponent [FUNC] - Removes component with instance
    		GetComponentsByType [FUNC] - returns a table with all the components with the specified type
    		ReadOnly [TABLE]:
    		    A readonly table containing some sprite values
    		    
    			UniqueId [NUMBER] - A unique readonly number given to each sprite, starting at 1
    			
    		REGISTER [FUBCTION] - called to register a sprite for roblox. DO NOT CALL THIS, ENGINE FUNC [Not in types]
    		
    		Service:
    			use this instead of Game:GetService() to modify sprites
    			(ex. logo:Service("TweenService"):Send("Create",logo, TweenInfo.new(2), {BacgroundTransparency = 1}):Play())
    			
    			Send:
    				this function sends the specified function witrh the arguments and returns the output
    				
    			
    Components:
    	Each component has its own functions depending on what they do, Add and Remove are in every component. You can remove a component by calling Remove but this is not recomended (please use sprite.RemoveComponent). Do not call Add
    	A component is a script that does somthing for a sprite (ex. render image, play sound).
    	Add is called with the sprite and the engine playerData
    	Remove is called with the sprite
    	
    	Add [FUNC] - Do not call this, Called by engine after the component is registered passsing some info to the component [Not in types]
    	Remove [FUNC] - Use sprite.RemoveComponent instead, game engine calls this after component has been unregistered so the component can remove itself [Not in types]
    	New [FUNC] - Creates new instance of the component [Not in types]
    	ScreenLabComponentInstance [INS] [DEVELOPER] - The name of the component. do Component["ScreenLabComponentInstance"] [Not in types]
    	Max [NUM] - The maximum number of that type of component allowed on one sprite
    	
    	Components: [Not in types]
    		
    	
    		Empty:
    			A template component
    		
    		Image:
    			Puts a image on a sprite
    			
    			Create [FUNC] - adds the image with the specified image id, returns the image object
    		
    		Text:
    			Puts a text on a sprite
    			    			
    			Create [FUNC] - Creates and returns textlabel

			Lighting:
				(WIP) Creates light and shadows from the object
				
				Lighting.Settings:
					The objects lighting settings
					
					Intensity[NUM] - The number of pixels to cast the light out (Default = Math.Huge)
    				Data [TABLE] - Spritedata passed to component

					
    		UiMaterial:
    			Max: 1
    			Renders a 3d material to a ui object
    			
    			SetMaterial [FUNC] - sets the ui object to the specfied enum material
    			
    		Sound:
    			Adds a sound to a sprite. You can only have one active audio at a time
    			
    			CreateSound [FUNC] - adds the sound to the sprite with the specified sound id plays in either 2d or 3d space
    			
    		SpriteAnimator:
    		
    			Allows you to create a sprite image from a spritesheet
    			
    			CreateAnimatedImage [FUNC] - modifies the passed image component to work with a spritesheet with the given dimentions
    			SetFrame [FUNC] - sets the frame displayed from the spritesheet 
    		
    		Physics:
    			Max: 1
    			A component that allows a sprite to be affected by gravity, velocity, and other objects with a physics component
    			All sprites start with a static physics component. This can be removed
    			
    			Physics.Settings:
    				Simulate [BOOL] - Is the sprite effected by forces, default false. Objects can have this enabled at any time but only apply forces that were made after simulate was enabled (gravity/velocity/other objects)
    				OnTouchedEvent [FUNC] - OPTIONAL: triggered when object collides with a non static object and Simulate is true
    				Register [BOOL] - Used by engine, used to make sure component is still added
    				Data [TABLE] - Spritedata passed to component
    				CollisionGroup	[STRING] - Objects with a set collisiongroup will only collide with other objects set to the same collisiongroup (Default = "Default")
    				printdbg [BOOL] - print debug info for that object
    				
    			Physics.Forces:
    				used to change the position and velocity of a simulated object
    				
    				Enable [BOOL] - Allow forces to interact with object (gravity, other objects. etc)
    				VelocityEvent [EVENT] - Velocity Event
    				PositionEvent [EVENT] - Position Event
    				Grounded [BOOL] - this is set to true when object is on top of another physics object
    				
    			ApplyVelocity [FUNC] - Applies velocity
    			SetPosition [FUNC] - Sets position

    		Networking:
    			Max: 1
    			This component replicates a sprites properties between clients. The sprite must have the same ObjectNetworkId on both clients 
    			
    			ClaimObject [FUNC] - Attempts to claim the object for target client/s. returns true/false
    			UnclaimObject [FUNC]  - Attempts to unclaim the object for target client/s. returns true/false
    			Start [FUNC] - Starts sending or recieving object data from remote clients
    			
    			Networking.Settings:
    				ReplicatedProperties [TABLE] - The string values of all the object properties you want to be replicated accross clients
    				ObjectNetworkId [NUMBER] - The network id number that represents the sprite. Must be the same on both clients for correct sprite to be updated. The defult value is the sprites UniqueId
    				Target [STRING/PLAYER] - The player that will recieve the objects data. Either "ALL" or a playerinstance (default "ALL")
    				
    		ParticleEmitter:
    			Emits particles from the sprite
    		    			
    			ParticleEmitter.Settings:
    				size [UDIM2]  - the size of each particle
    				startposition [UDIM2] - the relative start position of the particles
    				particletransparency [NUMBER] - transparency of the particles
    				lifespan [NUMBER] - how long the particle lasts
    				image [STRING] - the image id
    				maxparticles [NUMBER] - how many particles can be on screen at once
    				spawnrange [VECTOR2] - the angle of the particles that spawn
    				spawntime [NUMBER] - the time between each particle spawn
    				acceleration [VECTOR2] - the direction the particles go to
    				velocity [NUMBER] - the velocity of the particles
    				starttime [NUMBER] - how far the particles start into the acceleration
    				locktoparent [BOOL] - if true, the particles will stay relative to the parent object, if false they will stay relative to the screen
    
    Server:
    	The serverside of ScreenLAB is used for networking and some of the early setup stages
    	
    	StartScript moves screenlab to ReplicatedStorage and calls ServerManager.Init with the new location of the ScreenLAB folder
    	ServerManager recieves the remote events and processes them 
    	
    	P2P:
    		P2P normally stands for Peer To Peer communication where the clients communicate diretly between eachother. yourclient -> Client2
    		Roblox does not allow for this so we have to send the data to the server before sending it back to the client. yourclient -> Server -> Client2
    		I called these events p2p because they are being sent from a client to another client while only having the server process them
    	
    		In ServerManager, the RegisteredEvents table is setup so that when the event is called with the specified name in the first part of the table, the module specified in the second part of the table is called with (yourmodule).OnEvent(plr,target,data,v)
    		Ex.  
				local RegisteredEvents = {
					{"MyEventNameHere", require(MyModuleScriptHere)}
				}
    	
    		If a event is called that is not specified in RegisteredEvents, it will send the data to the target clients without modification
    		
    	Server:
    		I intend to use the events in this folder in the future to communicate directly from the server to client. yourclient -> server -> yourclient
    	
    Dependencies:
    	These are scripts that were collected from the internet to help the engine work. Mostly used by components (ex. UiMaterial)
    
    Depreciated:
    	Old scripts that still work but have been replaced
    
    Editor:
    	Scripts used in the editor
    
    Editor.Screenlab.Types:
    	Used to define custom types for Intellisense, no code function
    
    Screenlab.Hooking:
    	A engine resouce used for redirecting functions in other modulescripts to a function in the current modulescript
    	ex. used in redirecting component.remove to sprite.remove
    
    Screenlab.Runtime
    	Runtime funcs for screenlab
    	
    	module.Execute:
    		Executes code in string format at runtime
    		You must enable ScreenLabCore.AllowRuntimeCodeExecution to work
    		
    
    Screenlab.Util:
    	A script containing widely used functions throught the engine
    	
    Screenlab.Lighting:
    	The script that runs the lighting engine
    	
    	AddLight [FUNC] [EngineFunc] - Adds light to lighting engine [Not in types]
    	RemoveLight [FUNC] [EngineFunc]  - Removes light from lighting engine [Not in types]

    	Settings:
    		
    		RaycastStep [NUM] - The accuracy of the light casting. 1 would be the most accurate but also very laggy
    		Ignorelayer [NUM] - If a sprite is on this ZIndex, it will be ignored
    
    Screenlab.Camera
    	Screenlabs 2d camera module
    	
    	CurrentCamera [TBL]
    		The current 2d camera
    		
    		Position[TBL] - Camera position
    			vector2 [VEC2] - vector 2 position
    			udim2 [UDIM2] - Udim2 position
    			
    		Size[TBL] - Camera size
    			vector2 [VEC2] - vector 2 size
    			udim2 [UDIM2] - Udim2 size
    
    	SetPosition [FUNC] - Sets camera pos with a vector 2
    	SetSize [FUNC] - Sets camera size with a vector 2
		TweenCamera [FUNC] - Tweens player camera to a position
    
    Screenlab.Raycast:
		The module used to 2D raycast
		
		Cast [FUNC] - this is used to cast from a specified position in a specified direction with a ignore zindex layer and return the hit elements in order

    Screenlab.Console:
    	The customconsole class
    	
    	module.Start:
    		This is what creates the console and returns the instance, this function is called by the engine
    		
    		Print [FUNC] - The command that allows you to print to console with custom color and timestamp, returns linenumber, you can also use roblox print functions but they will be the defult color
    		UpdateLine [FUNC] - Updates the specified line number without effecting the other lines with the specified text
    	
    Screenlab.Physics:
    	Used by the phyisics component to run the physics simulation
    	Setting gravity to 0 will still have a gravity effect due to friction. Set gravity to 0 and friction to any humber higher than 0 for zero gravity effect
    	
    	module.Gravity [NUM] - The gravity scale of all objects (higher is more gravity)
		module.Friction [NUM] - How much friction objects have (higher is more Friction), friction is only applied when the object is in contact with another object
		module.AirResistance [NUM] - Friction in air
		module.TerminalVelocity [NUM]= Termanal velocity

	Screenlab.Event
		A module used by the engine to create internal bindable events
		
		module:New [FUNC] - Creates new event
		module:Fire [FUNC] - Fires the event with perimiters
		module:Connect [FUNC] - Listens to the event
		module:Destroy [FUNC] - Destroys event
		
	Screenlab.GlobalEvent
		A module that holds internal events for screenlab
		
		Events [TBL] - The table that holds the events
			NewObj - Fired when new sprite is created
		
	Screenlab.Input
		Used to similify inputs on all devices
		
		module.UnifiedInput [TBL] - a table with unified functions (Ex. Left, Right, Jump)
		module.CreateBind [FUNC] - Creates a custom unified input bind
		module.GetBinding [FUNC] - Gets a binding by name
		module.SetBinding [FUNC] - Sets a binding by name
	
		Each unified input contains its own events and functions
		InputBinding type
			
			Down [EVENT] - When the key or button is pressed down
			Up [EVENT] - When the key or button is released
			Changed [EVENT] - When the key or button InputState is changed
			Destroy [FUNC] - Destroyes the binding

    Drivers:
    	These are scripts that are used to control components of your computer such as sound, graphics, etc
    	Many of these expand on the roblox engine or use untraditional methods
    	You should not have to use these functions as they are for internal screenlab use, use components instead 
    	
    Screenlab.Drivers.Graphics:
    	The graphics driver for Screenlab to render more advanced 2d graphics than roblox normally allows
    	F2 for debug view
    	
    	Graphics.RenderLayers[TBL]
    		A table with all active render layers
    	
    	Graphics.Settings
    		Graphics engine settings
    		
    		DbgPolys [BOOL] - Shows poly render debug view
    	
    	Graphics.Delaunay
    		A reference to Delaunay for point rendering
    		
    	Graphics.RenderPoly
    		Renders a polygon to the RenderLayer
    	
    	Graphics.RenderLine
    		Renders a line to the RenderLayer
    		
    	Graphics.NewRenderLayer
    		A render layer is used to only update the polys when needed instead of the entire scene
    		EX.
    			If you have 22 lights, and each light has its own render layer, you can redraw the polys made by that light instead of 
    			recalulating all 22 lights
    		
    		Destroying [BOOL] - Set to true before destorying so no more renders can be done on this layer
    		Linebuffer [TBL] - The render layers lines from last frame
    		Lines [TBL] - The render layers lines for current frame
    		LayerPos [NUM] - Position of layer in renderlayers table 
    		PolyBuffer [TBL] - The render layers Polys from last frame
    		Polys [TBL] - The render layers Polys for current frame			
			NewFrame [FUNC] - Call to clear all polys on render layer
			Remove [FUNC] - Removes renderlayer from renderlayers list and clears polys
			
    
    Screenlab.Drivers.Audio:
    	The audio driver used by screenlab
    	If function isent part of the driver, it is automatically passed to the sound component as normal (ex. :Play())
    	
    	Audio.PanDistance[NUM]
    		The distance from the audio source to the camera (0 will be left right and center only, the higer the number the more it blends the three)
    	
    	Audio.NewSound3d[FUNC]:
    		Create a 3d sound object
    		
    		Destroy[FUNC] - Same as :Destroy() on the audio object
    		
    	Audio.NewSound2d[FUNC]:
    		Create a 2d sound object
    		
    		Pan [FUNC] - pans audio left and right (between -1 and 1)
    		Destroy[FUNC] - Same as :Destroy() on the audio object
]]