local Teams = game:GetService("Teams")

local function findAudioInput(forPlayer : Player) : AudioDeviceInput?
	-- Assumes there is only one AudioDeviceInput per player, parented to the Player object
	-- This is provided for you if VoiceChatService.EnableDefaultVoice is true
	-- May need to be reworked for generality if your place puts AudioDeviceInput objects elsewhere
	return forPlayer:FindFirstChildWhichIsA("AudioDeviceInput")
end

local function onTeamChanged(player : Player)
	local team = player.Team
	if not team then return end

	local device = findAudioInput(player)
	if not device then return end
	
	-- Only permit teammates to hear each other
	device.AccessType = Enum.AccessModifierType.Allow
	local allowed = {}
	for _, player : Player in team:GetPlayers() do
		table.insert(allowed, player.UserId)
	end

	device:SetUserIdAccessList(allowed)
end

local function onTeamAdded(team : Team)
	team.PlayerAdded:Connect(onTeamChanged)
	team.PlayerRemoved:Connect(onTeamChanged)
end

for _, team : Team in Teams:GetTeams() do
	onTeamAdded(team)
end

Teams.ChildAdded:Connect(function(child : Instance)
	if child:IsA("Team") then
		onTeamAdded(child)
	end
end)
