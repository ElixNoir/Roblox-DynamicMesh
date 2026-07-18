--- Author: COMT

--[[

	DynamicMesh - A module for creating and editing meshes at runtime.

]]

--!native
--!strict


-- -- State

local AssetService = game:GetService("AssetService")

local Module = {}
Module.__index = Module

export type ColorID = number
export type NormalID = number
export type TextureID = number
export type TriangleID = number
export type UVID = number
export type VertexID = number

export type DynamicMesh = typeof(setmetatable({} :: {
	EditableMesh: EditableMesh
}, Module))


-- -- Helpers

local Content_fromObject = Content.fromObject
local Content_fromUri = Content.fromUri

local Table_create = table.create


-- -- Functions

--[[
	Clone the DynamicMesh.
]]
function Module.fromDynamicMesh(self: DynamicMesh): DynamicMesh
	return setmetatable({
		EditableMesh = AssetService:CreateEditableMeshAsync(Content_fromObject(self.EditableMesh))
	}, Module)
end

function Module.fromMeshPart(meshPart: MeshPart): DynamicMesh
	return setmetatable({
		EditableMesh = AssetService:CreateEditableMeshAsync(Content_fromUri(meshPart.MeshId))
	}, Module)
end

function Module.new(): DynamicMesh
	return setmetatable({
		EditableMesh = AssetService:CreateEditableMesh()
	}, Module)
end


-- -- Methods

function Module.addColor(self: DynamicMesh, color3: Color3, alpha: number): ColorID
	return self.EditableMesh:AddColor(color3, alpha)
end

function Module.addTriangleByIDs(self: DynamicMesh, vertexID1: VertexID, vertexID2: VertexID, vertexID3: VertexID): TriangleID
	return self.EditableMesh:AddTriangle(vertexID1, vertexID2, vertexID3)
end

function Module.addTriangleByVectors(self: DynamicMesh, vertex1: vector, vertex2: vector, vertex3: vector): TriangleID
	local editableMesh = self.EditableMesh
	return editableMesh:AddTriangle(e:AddVertex(vertex1), e:AddVertex(vertex2), e:AddVertex(vertex3))
end

--[[
	vertexIDs: an array, whose length must be a multiple of 3, of vertex IDs 
]]
function Module.addTrianglesByIDs(self: DynamicMesh, vertexIDs: {number}): {TriangleID}
	local editableMesh = self.EditableMesh
	local triangleIDs = Table_create(vertexCount, 0)
	for index = 1, vertexCount, 3 do
		triangleIDs[index] = editableMesh:AddTriangle(vertexIDs[index], vertexIDs[index + 1], vertexIDs[index + 2])
	end
	
	return triangleIDs
end

function Module.addUV(self: DynamicMesh, vector2: Vector2): UVID
	return self.EditableMesh:AddUV(vector2);
end

--[[
	Create a MeshPart from the EditableMesh.
]]
function Module.createMeshPart(self: DynamicMesh): MeshPart
	return AssetService:CreateMeshPartAsync(Content_fromObject(self.EditableMesh))
end

function Module.toContent(self: DynamicMesh): Content
	return Content_fromObject(self.EditableMesh)
end


-- -- End

return Module
