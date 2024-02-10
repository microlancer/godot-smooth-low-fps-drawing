extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():	
	# Usage:
	var line = $Line2D
	var threshold_degrees = 35  # Angle threshold in degrees
	var reduction_factor = 0.08  # Factor to reduce sharpness by 10%
	var repeat = 5
	var line2 = reduce_angle_sharpness(line, threshold_degrees, Color.RED, reduction_factor, repeat)
	#var line3 = reduce_angle_sharpness(line2, threshold_degrees, Color.PURPLE, reduction_factor, repeat)
	line2.show()
	$Line2D.hide()
	#line2.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func reduce_angle_sharpness(line: Line2D, threshold_degrees: float, color: Color = Color.ORANGE, reduction_factor: float = 0.1, repeat: int = 1):
	
	var line_copy = line
	var new_line
	
	for x in range(repeat):
	
		var new_points: Array[Vector2]
		
		for i in range(line_copy.get_point_count()):
			var p1 = line_copy.get_point_position(i)
			new_points.append(p1)	
			if i == line_copy.get_point_count() - 1:
				break
			var p2 = line_copy.get_point_position(i + 1)		
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
	
	return new_line

func angle_between_segments(p1: Vector2, p2: Vector2, p3: Vector2) -> float:
	var v1 = (p2 - p1).normalized()
	var v2 = (p3 - p2).normalized()
	#return abs(v1.angle_to(v2)) * RADTODEG
	var deg = rad_to_deg(abs(v1.angle_to(v2)))
	#print(deg)
	return deg
