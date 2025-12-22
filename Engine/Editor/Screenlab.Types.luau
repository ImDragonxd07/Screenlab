local Types = {}

-- ## Core

export type Engine = {
	GetCurrentDeviceType : () -> string,
	GetVersion : () -> string,
	ShowIntroInStudio : boolean,
	Sprite : Sprite,
	GetSpriteFromUniqueId : () -> number,
	Console : Console,
	GraphicsDeltaTime : number,
	DeviceType : DeviceType,
	Space : Space,
	ConsoleSettings : ConsoleSettings,
	playerData : playerData,
	CreateScene : (self, () -> ()) -> (Scene),
}

export type playerData = {
	ScreenLabWindow : Frame,
	PlayerInstance : Player,
	ScreenLabBaseUI : ScreenGui,
	ScreenlabCore : {},
	Sprites : Instance,
	Tmp : Folder,
	Topbar : Frame
}

export type ConsoleSettings = {
	UseCustomConsole : boolean,
	ShowCallstackInGame : boolean
}

export type DeviceType = {
	Console : "Console",
	PC : "PC",
	Mobile : "Mobile",
	Unknown : "Unknown"
}

export type Space = {
	World : "World",
	Screen : "Screen"
}

-- ADD COMPONENT LATER

export type Sprite = {
	new : (table) -> {
		SetParent : (Instance: ParentObject) -> (),
		AddComponent: (Instance: Componentinstance,  Properties: {}) -> (Component);
		RemoveComponent : (string: ComponentName) -> (Component),
		SetSpace : (Space : Space) -> (),
		GetSpace : () -> (Space),
		GetComponentsByType : (string: ComponentName) -> (),
		ReadOnly : {
			UniqueId : number
		},
		Service : (string: ServiceName) -> (),
		
	} & Frame
}

export type Component = {
	Max : number
}

export type Scene = {
	Sprite : (Sprite),
	Load: (self, () -> ()) -> (),
	Unload: (self, () -> ()) -> (),
	Destroy: (self, () -> ()) -> (),
	Reload: (self, () -> ()) -> (),
}

-- ## Event

export type Event = {
	Connect: (self: Event, () -> ()) -> ()
}

-- ## Input
export type InputBinding = {
	Down: {} & Event,
	Up: {} & Event,
	IsDown: {} & Event,
	Changed: {} & Event,
	Destroy: (self: InputBinding) -> ()
}


return Types

