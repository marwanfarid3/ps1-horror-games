extends SceneTree
## Turns a line of text into one SVG path (outlined glyphs, kerned, with tracking).
## godot --headless -s outline_text.gd -- FONT SIZE TRACKING_EM "TEXT" OUT.json [WEIGHT]

func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var font := FontFile.new()
	font.load_dynamic_font(a[0])
	var size := int(a[1])
	var tracking := float(a[2]) * size
	var text: String = a[3]
	var ts := TextServerManager.get_primary_interface()
	var rid: RID = font.get_rids()[0]
	if a.size() > 5:
		# Variable fonts: pick the weight (e.g. 700 for bold) through a FontVariation.
		var fv := FontVariation.new()
		fv.base_font = font
		fv.variation_opentype = {ts.name_to_tag("wght"): float(a[5])}
		rid = fv.get_rids()[0]
		set_meta("keep", fv)
	var shaped := ts.create_shaped_text()
	ts.shaped_text_add_string(shaped, text, [rid], size)
	ts.shaped_text_shape(shaped)
	var glyphs: Array = ts.shaped_text_get_glyphs(shaped)
	var d := ""
	var pen := 0.0
	for g in glyphs:
		var idx: int = g["index"]
		var ox: float = pen + float(g.get("x_off", 0.0))
		var c: Dictionary = ts.font_get_glyph_contours(rid, size, idx)
		if not c.is_empty():
			d += _path(c, ox)
		pen += float(g["advance"]) + tracking
	pen -= tracking
	var asc := ts.font_get_ascent(rid, size)
	var desc := ts.font_get_descent(rid, size)
	# Cap height: bounds of "H" give a tight vertical box for layout.
	var f := FileAccess.open(a[4], FileAccess.WRITE)
	f.store_string(JSON.stringify({"d": d, "width": pen, "ascent": asc, "descent": desc}))
	f.close()
	quit()

func _p(v: Vector3, ox: float) -> String:
	return "%.2f %.2f" % [v.x + ox, v.y]

func _path(c: Dictionary, ox: float) -> String:
	var pts: PackedVector3Array = c["points"]
	var ends: PackedInt32Array = c["contours"]
	var out := ""
	var start := 0
	for end in ends:
		var n := end - start + 1
		var ring: Array = []
		for i in range(n): ring.append(pts[start + i])
		start = end + 1
		# Rotate so the ring starts on an on-curve point.
		var first := 0
		for i in range(n):
			if int(ring[i].z) == 1:
				first = i
				break
		ring = ring.slice(first) + ring.slice(0, first)
		out += "M" + _p(ring[0], ox)
		var i := 1
		while i <= n:
			var p: Vector3 = ring[i % n]
			var tag := int(p.z)
			if tag == 1:
				out += "L" + _p(p, ox)
				i += 1
			elif tag == 2:
				var p2: Vector3 = ring[(i + 1) % n]
				var p3: Vector3 = ring[(i + 2) % n]
				out += "C" + _p(p, ox) + " " + _p(p2, ox) + " " + _p(p3, ox)
				i += 3
			else:
				var q: Vector3 = ring[(i + 1) % n]
				var endp: Vector3 = q
				if int(q.z) == 0:
					endp = (p + q) * 0.5
					endp.z = 1
					out += "Q" + _p(p, ox) + " " + _p(endp, ox)
					i += 1
				else:
					out += "Q" + _p(p, ox) + " " + _p(q, ox)
					i += 2
		out += "Z"
	return out
