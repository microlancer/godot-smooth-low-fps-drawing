extends Node2D

var is_drawing: bool = false
var last_point: Vector2 = Vector2(0, 0)
var drawing_line: Line2D = null

var all_lines: Array[Line2D] = []

var window_offset = 0

var frame = 0
var drawable_frame: int = 0

var curve: Curve2D = null
var extra_line: Line2D = null

func _on_window_resized():
	# Calculate the position relative to the screen size and the node size
	var half_screen_width = DisplayServer.window_get_size().x / 2
	#print("x: " + str(DisplayServer.window_get_size().x))
	#print(half_screen_width)
	var half_node_width = $ColorRect.size.x / 2
	#print(half_node_width)
	var x_position = max(0, half_screen_width - half_node_width)
	#print(x_position)
	# Set the position of the node
	self.global_position.x = x_position	
	window_offset = x_position
	#print(window_offset)
	
func _process(delta):
	var milliseconds = int(delta * 1000)
	frame += milliseconds
	frame = frame % 100
	$ColorRect/Label.text = "Frame: " + str(milliseconds)

func _unhandled_input(event: InputEvent):	
#func _input(event: InputEvent):

	var pos = null
	
	if event is InputEventScreenTouch:
		pass
	
	if event is InputEventMouseButton:
		pos = Vector2(event.position.x - window_offset, event.position.y)
		if not is_drawing and event.is_pressed():
			print("Mouse Click at: ", event.position)
			var brush_top = Sprite2D.new()
			brush_top.texture = preload("res://brush_top2.png")
			brush_top.position = event.position + Vector2(-14, -15)
			brush_top.centered = false
			brush_top.set_scale(Vector2(0.2, 0.2))
			add_child(brush_top)
			check_is_start(pos)
		elif is_drawing and not event.is_pressed():
			add_drawing_point(pos)
			check_is_finish(pos)
			print("Mouse unClick at: ", event.position)
			print("total points: " + str(drawing_line.get_point_count()))
			#drawing_line.hide()
			#var smooth_line = smoothen_line(drawing_line, 0.3, 150, Color.RED)
			var threshold_degrees = 15  # Angle threshold in degrees
			var reduction_factor = 0.08  # Factor to reduce sharpness by 10%
			var repeat = 4
			#drawing_line.hide()
			#var smooth_line = reduce_angle_sharpness(drawing_line, threshold_degrees, Color.BLACK, reduction_factor, repeat)
			
			var brush_top = Sprite2D.new()
			brush_top.texture = preload("res://brush_bottom.png")
			brush_top.position = event.position + Vector2(-14, -12)
			brush_top.centered = false
			brush_top.set_scale(Vector2(0.2, 0.2))
			add_child(brush_top)
			#smooth_line.hide()
			#var smooth_line2 = smoothen_line(smooth_line, 0.05, 20, Color.BLACK)
			
	drawable_frame += 1
	if drawable_frame == 5:
		drawable_frame = 0
		
	if event is InputEventMouseMotion:
		pos = Vector2(event.position.x - window_offset, event.position.y)		
		var enough_distance = pos.distance_squared_to(last_point) > 1
		
		if is_drawing and last_point != pos and enough_distance:
			#print(pos.distance_squared_to(last_point))	
			#print(event.position)
			add_drawing_point(pos)
			if check_wall_collision(last_point, pos):
				# if there is a collision, don't bother to check finish point
				return
			last_point = pos
			#check_is_finish(pos)

	#root_node().draw_circle(Vector2(100,100), 100, Color.RED)
	
func _drawX():
	print("_draw")
	#draw_circle(Vector2(400, 300), 50, Color.RED)
	var line = Line2D.new()
	var curve = Curve2D.new()
	#curve.bake_resolution = 100
	line.add_point(Vector2(0,0))
	line.add_point(Vector2(500,500))
	line.add_point(Vector2(1000,0))
	
	line.default_color = Color(1, 1, 1, 0.2)
	add_child(line)
	
	
	for p in line.points:
		curve.add_point(p)
		
	var cp1 = Vector2(250,600)
	var cp2 = Vector2(750,600)
	
	curve.set_point_out(0, cp1)
	curve.set_point_out(100, cp2)
	#curve.set_point_in(2, Vector2(1200,1200))
		
	draw_circle(cp1, 10, Color.GREEN)
	draw_circle(cp2, 10, Color.GREEN)
	#draw_circle(Vector2(1200,1200), 10, Color.GREEN)
	
	curve.bake_interval = 30
	var curved_line = Line2D.new()
	for p in curve.get_baked_points():
		print("point: " + str(p))
		draw_circle(p, 3, Color.RED)
		
# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().size_changed.connect(_on_window_resized)
	_on_window_resized()
	extra_line = Line2D.new() as Line2D
	extra_line.default_color = Color.BLACK
	add_child(extra_line)
	
	var line = Line2D.new()
	#var curve = Curve2D.new()
	#curve.bake_resolution = 100
	#line.add_point(Vector2(0,0))
	#line.add_point(Vector2(50,50))
	#line.add_point(Vector2(100,0))
	#for p in line.points:
	#	curve.add_point(p)
	#curve.bake_interval = 30
	#var curved_line = Line2D.new()
	#for p in curve.get_baked_points():
	#	print("point: " + str(p))
	#	draw_circle(p, 3, Color.RED)
		#curved_line.add_point(p)
		
	#add_child(curved_line)
	
	#draw_circle(p, 3, Color.RED)
	#drawing_line = Line2D.new() as Line2D
	#add_child(drawing_line)

func check_is_start(point: Vector2):
	is_drawing = true
	
	drawing_line = Line2D.new() as Line2D
	#curve = Curve2D.new() as Curve2D
	#curve.bake_interval = 0.1
	all_lines.append(drawing_line)
	
	drawing_line.default_color = Color.BLACK
	drawing_line.add_point(point)	
	#curve.add_point(point)
	add_child(drawing_line)
		
	last_point = Vector2(point)
	pass

func check_is_finish(point: Vector2):
	is_drawing = false
	pass
	
func check_wall_collision(last, pos):
	return false
	

func add_drawing_point(point: Vector2):
	drawing_line.add_point(point)		
	#curve.add_point(point)
	#var interpolated_points = curve.interpolate_baked(0.1)
	#curve.bake_interval = 0.1
	#extra_line.clear_points()
	#print("points: " + str(curve.get_baked_length()))
	#print("size: " + str(curve.get_baked_points().size()))
	#for p in curve.get_baked_points():
		#print("adding baked point: " + str(p))
	#	extra_line.add_point(p)
	
	#curve.clear_points()

func angle_between_vectors(v1: Vector2, v2: Vector2, v3: Vector2) -> int:
	# Calculate the direction vectors of the two sides of the triangle
	var side1 = v1 - v2
	var side2 = v3 - v2

	# Calculate the dot product of the two sides
	var dot_product = side1.dot(side2)

	# Calculate the magnitudes of the vectors
	var magnitude1 = side1.length()
	var magnitude2 = side2.length()

	# Calculate the angle between the vectors using the law of cosines
	var cos_angle = dot_product / (magnitude1 * magnitude2)
	var angle_rad = acos(cos_angle)

	# Convert the angle to degrees and return
	return int(rad_to_deg(angle_rad)) % 180
	
func smoothen_line(line: Line2D, extension: float = 0.4, min_dist: int = 100, color = Color.BLACK):
	
	var curved_line = Line2D.new()
	curved_line.default_color = color
	add_child(curved_line)
	#print("gonna smooth")
	# we use -1 to ignore the last point
	#print(line.points.size())
	for i in range(line.points.size() - 1):
		#print(i)
		var p: Vector2 = line.points[i] as Vector2
		var p_next: Vector2 = line.points[i+1] as Vector2
		
		if p.distance_to(p_next) < min_dist:
			curved_line.add_point(p)
			continue
		
		var p_previous: Vector2
		if i == 0:
			# use same initial point as previous
			p_previous = line.points[0] as Vector2
		else:
			p_previous = line.points[i-1] as Vector2
		
		var p_next_next: Vector2
		if i == line.points.size() - 2:
			# look backwards at the end of the list
			p_next_next = line.points[i-1] as Vector2
		else:
			p_next_next = line.points[i+2] as Vector2
		
		var lerp = p.lerp(p_next, 0.5)
		
		# Calculate the vector representing the line segment
		var line_vector = p_next - lerp
		# Calculate the length of the original line segment
		var line_length = line_vector.length()
		# Calculate the perpendicular vector by rotating the line vector by 90 degrees
		var perpendicular_vector = Vector2(-line_vector.y, line_vector.x)
		# Calculate the end point of the perpendicular line segment
		var perpendicular_end_point = lerp + perpendicular_vector.normalized() * line_length*extension
		
		var to_rotate_line_vector = perpendicular_end_point - lerp
		var rotated_vector = to_rotate_line_vector.rotated(-PI)
		var rotated_end_point = lerp + rotated_vector		
		var perpendicular_end_point2 = rotated_end_point
		
		var ang1 = angle_between_vectors(p_previous, p, perpendicular_end_point)
		var ang2 = angle_between_vectors(perpendicular_end_point, p_next, p_next_next)
		
		var ang3 = angle_between_vectors(p_previous, p, perpendicular_end_point2)
		var ang4 = angle_between_vectors(perpendicular_end_point2, p_next, p_next_next)
		
		var com1 = ang1 + ang2
		var com2 = ang3 + ang4

		# Compare the absolute values of the angles
		if com1 < com2:
			perpendicular_end_point = perpendicular_end_point2
		print("com1: " + str(com1) + " com2: " + str(com2))
		curved_line.add_point(p)
		curved_line.add_point(perpendicular_end_point)
		
		if i == line.points.size() - 2:
			curved_line.add_point(p_next)
		
	return curved_line
	

func reduce_angle_sharpness(line: Line2D, threshold_degrees: float, color: Color = Color.ORANGE, reduction_factor: float = 0.1, repeat: int = 1):
	
	var line_copy = line
	var new_line
	print("reducing")
	for x in range(repeat):
	
		var new_points: Array[Vector2]
		
		for i in range(line_copy.get_point_count()):
			var p1 = line_copy.get_point_position(i)
			new_points.append(p1)	
			if i == line_copy.get_point_count() - 1:
				break
			var p2 = line_copy.get_point_position(i + 1)		
			if p1.distance_to(p2) < 10:
				# skip short segments
				continue
			var lerp = p1.lerp(p2, 0.5)
			#print("adding")
			new_points.append(lerp)
			
		#print(new_points)
		
		for i in range(new_points.size() - 2):
			var p1 = new_points[i]
			var p2 = new_points[i+1]
			var p3 = new_points[i+2]
			#print(p1)
			
			# Calculate angle between segments
			var angle = angle_between_segments(p1, p2, p3)
			
			# If angle is sharper than the threshold, insert intermediate points
			if angle > threshold_degrees:
				# Move the middle point p2 at a perpendicular angle to the angle of the line
				# that connects p1 and p3 to 10% of the distance closer.
				# Calculate vectors between points
				var v1 = p2 - p1
				var v2 = p3 - p2

				var line_vector = p3 - p1
				var line_length = line_vector.length()
				# Calculate the perpendicular vector by rotating the line vector by 90 degrees
				var perpendicular_vector = Vector2(-line_vector.y, line_vector.x)
				# Calculate the end point of the perpendicular line segment
				#print("angle: " + str(angle))
				#reduction_factor = max(0.4, 0.5*angle/90 * reduction_factor)
				var srf = reduction_factor;
				if angle > 100:
					srf = reduction_factor * 6
				elif angle > 90:
					srf = reduction_factor * 3
				elif angle > 45:
					srf = reduction_factor * 1
					
				#print(srf)
				
				var perpendicular_end_point = p2 + perpendicular_vector.normalized() * line_length*srf
				var perpendicular_end_point2 = p2 + perpendicular_vector.normalized() * -line_length*srf
				
				var d1 = perpendicular_end_point.distance_to(p1)
				var d2 = perpendicular_end_point2.distance_to(p1)
				
				new_points.remove_at(i+1)
				if d1 < d2:
					#print("use pep")
					new_points.insert(i+1, perpendicular_end_point)
				else:
					#print("use pep2")
					new_points.insert(i+1, perpendicular_end_point2)
		
		#print(new_points)
		new_line = Line2D.new()	
		new_line.hide() # hide by default
		new_line.default_color = color
		#print(str(new_points))
		for i in new_points:
			new_line.add_point(i)
			
		add_child(new_line)
		
		line_copy = new_line
	
	new_line.show()
	return new_line

func angle_between_segments(p1: Vector2, p2: Vector2, p3: Vector2) -> float:
	var v1 = (p2 - p1).normalized()
	var v2 = (p3 - p2).normalized()
	#return abs(v1.angle_to(v2)) * RADTODEG
	var deg = rad_to_deg(abs(v1.angle_to(v2)))
	#print(deg)
	return deg
