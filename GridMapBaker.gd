tool
class_name StaticGridMap extends GridMap


export (bool) var btn_bake_meshes: bool setget bake_meshes


var material_counter: int


func _ready() -> void:
	hide()


func bake_meshes(value: bool) -> void:
	var data: Array = get_meshes()
	material_counter = 0
	
	if data:
		var new_mesh := ArrayMesh.new()
		var data_transform: Transform
		
		var baked_mesh := MeshInstance.new()
		get_parent().add_child_below_node(self, baked_mesh)
		baked_mesh.owner = get_tree().edited_scene_root
		
		for mesh_data in data:
			if mesh_data is Mesh:
				new_mesh = extract_mesh(mesh_data, new_mesh, data_transform)
			else:
				data_transform = mesh_data
		
		new_mesh = combine_materials(new_mesh)
		
		baked_mesh.mesh = new_mesh
		baked_mesh.name = "Baked_" + name
		hide()


func extract_mesh(old_mesh: Mesh, new_mesh: ArrayMesh, mesh_transform: Transform) -> ArrayMesh:
	for i in range(old_mesh.get_surface_count()):
		var surf_tool := SurfaceTool.new()
		surf_tool.append_from(old_mesh, i, mesh_transform)
		
		new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surf_tool.commit_to_arrays())
		new_mesh.surface_set_material(material_counter, old_mesh.surface_get_material(i))
		material_counter +=1
		
	return new_mesh


func combine_materials(mesh: ArrayMesh) -> ArrayMesh:
	var result_mesh := ArrayMesh.new()
	var mat_counter := 0
	var materials: Array
	
	for i in range(mesh.get_surface_count()):
		if not materials.has(mesh.surface_get_material(i)):
			materials.append(mesh.surface_get_material(i))
	
	for mat in materials:
		var surf_tool := SurfaceTool.new()
		
		for i in range(mesh.get_surface_count()):
			if mat == mesh.surface_get_material(i):
				surf_tool.append_from(mesh, i, transform)
		
		result_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surf_tool.commit_to_arrays())
		result_mesh.surface_set_material(mat_counter, mat)
		mat_counter += 1
	
	return result_mesh
