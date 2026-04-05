--- Author: COMT

--[[

	DynamicMesh - A module for creating and editing meshes at runtime.

]]

--!native
--!optimize 2
--!strict


-- -- State

local AssetService = game:GetService("AssetService")

local Module = {}
Module.__index = Module

export type DynamicMesh = typeof(setmetatable({} :: {
	EditableMesh: EditableMesh,
	SpatialDictionary: {number}
}, Module))


-- -- Helpers

local content_fromObject = Content.fromObject

local table_clear = table.clear
local table_create = table.create

local vector3_new = Vector3.new -- I would use vector.create but Luau doesn't recognize that type as a Vector3.


-- -- Functions

function Module.new(editableMesh: EditableMesh?): DynamicMesh
	editableMesh = editableMesh or AssetService:CreateEditableMesh()
	return setmetatable({
		EditableMesh = editableMesh,
		SpatialDictionary = {}
	}, Module)
end


-- -- Methods

function Module.addTriangles(self: DynamicMesh, vertexIDs: {number}): {number}
	local vertexCount = #vertexIDs
	if vertexCount % 3 ~= 0 then
		error(`Number of vertices must be a multiple of 3; got {vertexCount}`)
	end
	
	local editableMesh = self.EditableMesh
	local triangleIdentities = table_create(vertexCount, 0)
	for index = 1, vertexCount, 3 do
		triangleIdentities[index] = editableMesh:AddTriangle(vertexIDs[index], vertexIDs[index + 1], vertexIDs[index + 2])
	end
	
	return triangleIdentities
end

--[[
	Create a MeshPart from the EditableMesh.
]]
function Module.meshPart(self: DynamicMesh): MeshPart
	return AssetService:CreateMeshPartAsync(content_fromObject(self.EditableMesh))
end

--[[
	Create a copy of the EditableMesh.
]]
function Module.staticCopy(self: DynamicMesh): EditableMesh
	return AssetService:CreateEditableMeshAsync(content_fromObject(self.EditableMesh))
end

function Module.renew(self: DynamicMesh)
	self.EditableMesh:Destroy()
	self.EditableMesh = assert(AssetService:CreateEditableMesh(), "Memory budget exhausted.")
	table_clear(self.SpatialDictionary)
end

function Module.toContent(self: DynamicMesh): Content
	return content_fromObject(self.EditableMesh)
end

--[[
	If the vertex exists at the position, return the vertexID.  Otherwise, create a new vertex at the position and return its vertexID.
]]
function Module.upsertVertex(self: DynamicMesh, x: number, y: number, z: number): number
	local key = ((x * 1000 + .5) // 1 + 1024576) + ((y * 1000 + .5) // 1 + 1024000) * 2097152 + ((z * 1000 + .5) // 1 + 1024576) * 4398046511104
	
	local spatialDictionary = self.SpatialDictionary
	local vertexID: number? = spatialDictionary[key]
	if vertexID then
		return vertexID
	end

	vertexID = self.EditableMesh:AddVertex(vector3_new(x, y, z))
	spatialDictionary[key] = vertexID

	return vertexID
end

--[[
	Get the vertex at a position if it exists.
]]
function Module.vertexAtPosition(self: DynamicMesh, x: number, y: number, z: number): number?
	return self.SpatialDictionary[((x * 1000 + .5) // 1 + 1024576) + ((y * 1000 + .5) // 1 + 1024000) * 2097152 + ((z * 1000 + .5) // 1 + 1024576) * 4398046511104]
end


-- -- End

return Module
