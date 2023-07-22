for i, v in pairs(getconnections(game:GetService("ScriptContext").Error)) do 
   v:Disable()
end

local ws, rs,lp = game:GetService('Workspace'), game:GetService('RunService'),game:GetService('Players').LocalPlayer
local names = {'MeshPart', 'UnionOperation', 'Part'}
local trinket_dep = {}

function isTrinketInTable(parent)
	for _, v in pairs(trinket_dep) do
		if v.Parent == parent then
			return true
		end
	end
	return false
end

function onChildAdded(child)
	if table.find(names, child.ClassName) then
		for _, v2 in pairs(child:GetDescendants()) do
			if v2:IsA('ClickDetector') and v2.MaxActivationDistance <= 10 and not isTrinketInTable(v2.Parent) then
				table.insert(trinket_dep, {Parent = v2.Parent, Activated = false})
			end
		end
	end
end

pcall(onChildAdded)
ws.ChildAdded:Connect(onChildAdded)

function potential_trinkets()
	local dist = 10
	if not (ws and rs and lp) then
		lp:Kick('Error: Missing required services')
		return
	end
	local hrpp = lp.Character and lp.Character:FindFirstChild('HumanoidRootPart')
	if not hrpp and lp.Character:FindFirstChild('Humanoid') and lp.Character.Humanoid.Health ~= 0 then
		lp:Kick('Error: HumanoidRootPart not found')
	end
	local function runner()
		for _, trinket in pairs(ws:GetChildren()) do 
			if table.find(names, trinket.ClassName) then 
				for _, v2 in pairs(trinket:GetDescendants()) do 
					if v2:IsA('ClickDetector') and v2.MaxActivationDistance <= 10 and not isTrinketInTable(v2.Parent) then
						table.insert(trinket_dep, {Parent = v2.Parent, Activated = false})
					end
				end
			end
		end
		rs:BindToRenderStep("TrinketRunner", Enum.RenderPriority.Last.Value, function()
			if not lp.Character then
				return
			end
			hrpp = lp.Character:FindFirstChild('HumanoidRootPart')
			if not hrpp then
				return
			end
			for _, v in pairs(trinket_dep) do
				if not v.Parent.Position then
					return
				else
					if (hrpp.Position - v.Parent.Position).Magnitude <= dist and not v.Activated then
						print('Distance:', (hrpp.Position - v.Parent.Position).Magnitude)
						v.Activated = true
						fireclickdetector(v.Parent:WaitForChild('ClickDetector'))
						v.Activated = false
					end
				end
			end
		end)
	end
	game:GetService('Players').LocalPlayer.CharacterAdded:Connect(runner)
	game:GetService('Players').LocalPlayer.CharacterRemoving:Connect(function()
		trinket_dep = {}
		rs:UnbindFromRenderStep("TrinketRunner")
	end)
	runner()
end

local success, err = pcall(potential_trinkets)

if not success then 
	game:GetService('Players').LocalPlayer:Kick('Error somewhere in the code: ' .. err)
end
