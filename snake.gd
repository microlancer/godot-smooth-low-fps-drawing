extends Node2D

var circles: Array[Vector2] = []



# Called when the node enters the scene tree for the first time.
func _ready():
	$Line2D.show()
	var curved_line = smoothen_line($Line2D, 0.2, Color.RED)
	#curved_line.hide()
	var curved_line2 = smoothen_line(curved_line, 0.1, Color.GREEN)
	#curved_line2.hide()
	var curved_line3 = smoothen_line(curved_line2, 0.02, Color.ORANGE)
	
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
	
func smoothen_line(line: Line2D, extension: float = 0.4, color = Color.BLACK):
	
	var pts = []
	
	var curved_line = Line2D.new()
	curved_line.default_color = color
	add_child(curved_line)
	
	# we use -1 to ignore the last point
	for i in range(line.points.size() - 1):
		var p: Vector2 = line.points[i] as Vector2
		var p_next: Vector2 = line.points[i+1] as Vector2
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
		
		#print("i:" + str(i) + " p:" + str(p))
		
		var angle = p.angle_to_point(p_next)
		#var angle_next = p_next.angle_to_point(p_next_next)
		
		#print("angle: " + str(angle))
		
		
			
		var o: Vector2 = p.orthogonal() as Vector2
		
		var dist = p.distance_to(p_next)
		
		var lerp = p.lerp(p_next, 0.5)
		#print("lerp: " + str(lerp))
		
		
		
		#var perp = Vector2(-line_vector.y, line_vector.x)
		var perp = p_next.orthogonal()
		
		#print("p:" + str(p) + " p_next:" + str(p_next) + " perp: " + str(perp))
		
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
		
		# check which perpendicular_end_point is further away from the next point
		
		#var dist1 = p_next_next.distance_to(perpendicular_end_point)
		#var dist2 = p_next_next.distance_to(perpendicular_end_point2)
		#var dist3 = p_previous.distance_to(perpendicular_end_point)
		#var dist4 = p_previous.distance_to(perpendicular_end_point2)
		#
		#var dist1_is_largest = dist1 > dist2 and dist1 > dist3 and dist1 > dist4
		#var dist2_is_largest = dist2 > dist1 and dist2 > dist3 and dist2 > dist4
		#var dist3_is_largest = dist3 > dist2 and dist3 > dist1 and dist3 > dist4
		#var dist4_is_largest = dist4 > dist3 and dist4 > dist2 and dist4 > dist1
		
		#if dist2_is_largest:
			#perpendicular_end_point = perpendicular_end_point2
		#elif dist4_is_largest:
			#perpendicular_end_point = perpendicular_end_point2
		
		# Figure out which perpendicular creates a sharper angle, and avoid that	
		#var angle1 = perpendicular_end_point.angle_to_point(p_next) - p_next.angle_to_point(p_next_next)
		#var angle2 = perpendicular_end_point2.angle_to_point(p_next) - p_next.angle_to_point(p_next_next)
		
		#if angle1 > angle2:
		#	perpendicular_end_point = perpendicular_end_point2
			
		# Calculate the angles between the new line and the existing next segment for both perpendicular points
		var angle1 = abs(perpendicular_end_point.angle_to_point(p_next) - p_next.angle_to_point(p_next_next))
		var angle2 = abs(perpendicular_end_point2.angle_to_point(p_next) - p_next.angle_to_point(p_next_next))

		# Ensure angles are within the range of -180 to 180 degrees
		angle1 = fmod(angle1 + 180, 360) - 180
		angle2 = fmod(angle2 + 180, 360) - 180
		
		var ang1 = angle_between_vectors(p_previous, p, perpendicular_end_point)
		var ang2 = angle_between_vectors(perpendicular_end_point, p_next, p_next_next)
		
		var ang3 = angle_between_vectors(p_previous, p, perpendicular_end_point2)
		var ang4 = angle_between_vectors(perpendicular_end_point2, p_next, p_next_next)
		
		var com1 = ang1 + ang2
		var com2 = ang3 + ang4
		
		print("ang1: " + str(ang1) + " ang2: " + str(ang2))
		print("ang3: " + str(ang3) + " ang4: " + str(ang4))
		print("com1: " + str(com1) + " com2: " + str(com2))
		
		#print("a1: " + str(angle1) + " a2: " + str(angle2))# + " a3: " + str(angle3) + " a4: " + str(angle4))

		# Compare the absolute values of the angles
		if com1 < com2:
			perpendicular_end_point = perpendicular_end_point2
		
		#if dist1 > dist2: 
			#print("dist1 further")
		#else:
			#print("dist2 further")
			#perpendicular_end_point = perpendicular_end_point2

		#var angle_sub = angle_next - angle
		#print("angle_sub:" + str(angle_next - angle))
		#if angle_sub > 0:
			#print("greater")
			#var to_rotate_line_vector = perpendicular_end_point - lerp
			#var rotated_vector = to_rotate_line_vector.rotated(-PI)
			#var rotated_end_point = lerp + rotated_vector
			#perpendicular_end_point = rotated_end_point
		#else:
			#print("less")
			
		#var p_line = Line2D.new()
		#p_line.add_point(lerp)
		#p_line.add_point(perpendicular_end_point)
		#add_child(p_line)
		
		circles.append(perp)
		circles.append(lerp)
		
		curved_line.add_point(p)
		curved_line.add_point(perpendicular_end_point)
		
		if i == line.points.size() - 2:
			curved_line.add_point(p_next)
		
		pts.append(i)
	
	return curved_line
	
	pass # Replace with function body.

func _draw():
	#print("drawing")
	draw_circle(Vector2(0,0), 100, Color.RED)
	for i in circles:
		print("drawing: " + str(i))
		#draw_circle(i, 10, Color.RED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
