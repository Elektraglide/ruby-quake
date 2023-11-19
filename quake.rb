# encoding: UTF-8

$LOAD_PATH.push File.dirname(__FILE__)

def reloadbits
	load __FILE__
end

if not defined?(BitStruct)
require 'bit-struct/bit-struct'
require 'bit-struct/fields'
end

module QuakeImporter

class QImage
	@@empty = [255,128,64,255]
	def initialize(w,h)
		@width = w
		@height = h
		@pixels = Array.new
		for y in 0...h
			@pixels[y] = @@empty * w 
		end
	end

	def width
		@width
	end
	
	def height
		@height
	end

	def transparent(x,y)
		@pixels[y % @height][(x % @width)*4+3] = Integer(0)
	end

	
	def plot(x,y, color)
		@pixels[y % @height][(x % @width)*4+0] = Integer(color[2])	# BGRA
		@pixels[y % @height][(x % @width)*4+1] = Integer(color[1])
		@pixels[y % @height][(x % @width)*4+2] = Integer(color[0])
		@pixels[y % @height][(x % @width)*4+3] = Integer(255)
	end

	def pixels=(arr)
		@pixels = arr
	end

	def pixels
		@pixels
	end

	def writeTGA(filename)
	
		puts "writeTGA: " + filename
		
		aFile = File.new(filename, "wb")
		header = [0,0,2, 0,0,0,0,0].pack("C*")
		header += [0,0, @width, @height].pack("v*")
		header += [32, 0].pack("C*")	
		aFile.print header

		for y in 0...@height
			aFile.print @pixels[y].pack("C*")
		end	
		aFile.close
	end
end

def QuakeImporter.pdot(a,v)
	a.x * v.x + a.y * v.y + a.z * v.z
end

if not defined?(Lump_t)

class Lump_t < BitStruct
	default_options :endian => :little
	
	 unsigned :offset0,	32
	 unsigned :size0,	32
end

class Dheader_t < BitStruct
	default_options :endian => :little
	
	 unsigned	:version,	32
	 nest		:lump_entities,		Lump_t
	 nest		:lump_planes,		Lump_t
	 nest		:lump_textures,		Lump_t
	 nest		:lump_vertexes,		Lump_t
	 nest		:lump4,		Lump_t
	 nest		:lump_nodes,		Lump_t
	 nest		:lump_texinfo,		Lump_t
	 nest		:lump_faces,		Lump_t
	 nest		:lump8,		Lump_t
	 nest		:lump9,		Lump_t
	 nest		:lump_leafs,	Lump_t
	 nest		:lump_leaffaces,	Lump_t
	 nest		:lump_edges,	Lump_t
	 nest		:lump_surfedges,	Lump_t
	 nest		:lump_models,	Lump_t
end

class Edge_t < BitStruct
	default_options :endian => :little

	unsigned	:v0,	16
	unsigned	:v1,	16

	rest		:next,		Edge_t
end

class Vec3_t < BitStruct
	default_options :endian => :little

	float		:x,		32
	float		:y,		32
	float		:z,		32

	rest		:next,		Vec3_t
end

class ShortVec3_t < BitStruct
	default_options :endian => :little

	signed		:x,		16
	signed		:y,		16
	signed		:z,		16

	rest		:next,		ShortVec3_t
end

class Plane_t < BitStruct
	default_options :endian => :little

	nest		:normal,	Vec3_t
	float		:dist,		32
	signed		:type,		32
	
	rest		:next,		Plane_t
end

class Face_t < BitStruct
	default_options :endian => :little

	unsigned	:plane_id,		16
	unsigned	:side,			16
	signed		:ledge_id,		32
	unsigned	:ledge_num,		16
	unsigned	:texinfo_id,	16
	unsigned	:typelight,		8
	unsigned	:baselight,		8
	unsigned	:light0,		8
	unsigned	:light1,		8
	unsigned	:lightmap,		32

	rest		:next,		Face_t
end

class Texinfo_t < BitStruct
	default_options :endian => :little

	nest		:vectorS,	Vec3_t
	float		:distS,		32
	nest		:vectorT,	Vec3_t
	float		:distT,		32
	
	unsigned	:texture_id,	32
	unsigned	:animated,		32

	rest		:next,		Texinfo_t
end

class Texinfo2_t < BitStruct
	default_options :endian => :little

	nest		:vectorS,	Vec3_t
	float		:distS,		32
	nest		:vectorT,	Vec3_t
	float		:distT,		32
	
	unsigned	:flags,		32
	unsigned	:value,		32
	text		:name,		256
	unsigned	:nexttexinfo,	32

	rest		:next,		Texinfo2_t
end

class Miptex_t < BitStruct
	default_options :endian => :little

	text		:name,		128
	signed		:width,		32
	signed		:height,	32
	signed		:offset1,	32
	signed		:offset2,	32
	signed		:offset4,	32
	signed		:offset8,	32

	rest		:next,		Miptex_t
end

class Mipheader_t < BitStruct
	default_options :endian => :little

	signed		:numtex,	32
	
	rest		:next,		Mipheader_t
end

class Model_t < BitStruct
	default_options :endian => :little

	nest		:min,		Vec3_t
	nest		:max,		Vec3_t
	nest		:origin,	Vec3_t
	
	unsigned	:node_id0,	32
	unsigned	:node_id1,	32
	unsigned	:node_id2,	32
	unsigned	:node_id3,	32
	unsigned	:numleafs,	32
	
	unsigned	:face_id,	32
	unsigned	:face_num,	32
	
	rest		:next,		Model_t
end


class Dleaf_t < BitStruct
	default_options :endian => :little

	 unsigned	:content,	32
	 signed		:cluster,	16
	 signed		:areaflags,	16
	 nest		:mins,	ShortVec3_t
	 nest		:maxs,	ShortVec3_t
	 unsigned	:firstface,	16
	 unsigned	:numfaces,	16
	 unsigned	:firstbrush, 16
	 unsigned	:numbrush,	16
	 signed		:leafdata,	16

	rest		:next,		Dleaf_t
end

class Dnode_t < BitStruct
	default_options :endian => :little

	 unsigned	:planenum,		32
	 signed		:left,	16
	 signed		:right,	16
	 nest		:mins,	ShortVec3_t
	 nest		:maxs,	ShortVec3_t

	 unsigned	:firstface,	16
	 unsigned	:numfaces,	16

	rest		:next,		Dnode_t
end

class MdlIdent_t < BitStruct
	default_options :endian => :little

	 unsigned	:id,		32
	 unsigned	:version,	32
	
	rest		:next,		MdlIdent_t
end

class Mdl_t < BitStruct
	default_options :endian => :little

	nest		:scale,		Vec3_t
	nest		:origin,	Vec3_t
	float		:radius,	32
	nest		:offsets,	Vec3_t
	
	unsigned	:numskins,	32
	unsigned	:skinwidth,	32
	unsigned	:skinheight,32
	unsigned	:numverts,	32
	unsigned	:numtris,	32
	unsigned	:numframes,	32
	
	unsigned	:synctype,	32
	unsigned	:flags,		32
	float		:sizescale,	32

	rest		:next,		Mdl_t
end

class Skin_t < BitStruct
	default_options :endian => :little

	unsigned	:group,		32

	rest		:next,		Skin_t
end

class Skingroup_t < BitStruct
	default_options :endian => :little

	unsigned	:group,		32
	unsigned	:nb,		32
	float		:time,		32
	rest		:next,		Skingroup_t
end

class Stvert_t < BitStruct
	default_options :endian => :little

	unsigned	:onseam,	32
	unsigned	:s,			32
	unsigned	:t,			32

	rest		:next,		Stvert_t
end

class Triangle_t < BitStruct
	default_options :endian => :little

	unsigned	:facesfront,32
	unsigned	:index0,	32
	unsigned	:index1,	32
	unsigned	:index2,	32

	rest		:next,		Triangle_t
end

class Trivert_t < BitStruct
	default_options :endian => :little

	unsigned	:x,			8
	unsigned	:y,			8
	unsigned	:z,			8
	unsigned	:nindex,	8

	rest		:next,		Trivert_t
end

class Frame_t < BitStruct
	default_options :endian => :little

	unsigned	:group,		32

	rest		:next,		Frame_t
end

class Framegroup_t < BitStruct
	default_options :endian => :little

	unsigned	:group,		32
	unsigned	:nb,		32
	nest		:min,		Trivert_t
	nest		:max,		Trivert_t
	float		:time,		32

	rest		:next,		Framegroup_t
end

class Simpleframe_t < BitStruct
	default_options :endian => :little

	nest		:min,		Trivert_t
	nest		:max,		Trivert_t
	text		:name,		128

	rest		:next,		Simpleframe_t
end

# WAD2/3 files
class Wadheader_t < BitStruct
	default_options :endian => :little

	unsigned	:id,		32

	unsigned :numentries,	32
	unsigned :diroffset,	32

	rest		:next,		Wadheader_t
end

class Wadentry_t < BitStruct
	default_options :endian => :little

	unsigned :offset,	32
	unsigned :dsize,	32
	unsigned :msize,	32
	unsigned :type,	8
	unsigned :cmprs,	8
	unsigned :dummy,	16
	text		:name,		128
	
	rest		:next,		Wadentry_t
end

class Studioheader_t < BitStruct
	default_options :endian => :little

	text		:name,		512
	unsigned	:hlength, 32

	nest		:eyeposition,		Vec3_t
	nest		:min,	Vec3_t
	nest		:max,	Vec3_t
	nest		:bbmin,	Vec3_t
	nest		:bbmax,	Vec3_t
	unsigned		:flags,	32

	unsigned		:numbones,	32
	unsigned		:boneindex,	32

	unsigned		:numbonecontrollers,	32
	unsigned		:bonecontrollerindex,	32

	unsigned		:numhitboxes,	32
	unsigned		:hitboxindex,	32

	unsigned		:numseq,	32
	unsigned		:seqindex,	32

	unsigned		:numseqgroups,	32
	unsigned		:seqgroupindex,	32

	unsigned		:numtextures,	32
	unsigned		:textureindex,	32
	unsigned		:texturedataindex,	32

	unsigned		:numskinref,	32
	unsigned		:numskinfamilies,	32
	unsigned		:skinindex,	32

	unsigned		:numbodyparts,	32
	unsigned		:bodypartindex,	32

	unsigned		:numattachments,	32
	unsigned		:attachmentindex,	32

	unsigned		:soundtable,	32
	unsigned		:soundindex,	32
	unsigned		:soundgroups,	32
	unsigned		:soundgroupindex,	32

	unsigned		:numtransitions,	32
	unsigned		:transitionindex,	32

	rest		:next,		Studioheader_t
end

class Studiotexture_t < BitStruct
	default_options :endian => :little

	text		:name,		512
	unsigned	:flags, 32
	unsigned	:width, 32
	unsigned	:height, 32
	unsigned	:texindex, 32

	rest		:next,		Studiotexture_t
end

class Studiobodyparts_t < BitStruct
	default_options :endian => :little

	text		:name,		512
	unsigned	:nummodels, 32
	unsigned	:base, 32
	unsigned	:modelindex, 32

	rest		:next,		Studiobodyparts_t
end

class Studiomodel_t < BitStruct
	default_options :endian => :little

	text		:name,		512
	unsigned	:type, 32
	float	:boundingradius, 32
	
	unsigned	:nummesh, 32
	unsigned	:meshindex, 32

	unsigned	:numverts, 32
	unsigned	:vertinfoindex, 32
	unsigned	:vertindex, 32
	unsigned	:numnorms, 32
	unsigned	:norminfoindex, 32
	unsigned	:normindex, 32

	unsigned	:numgroups, 32
	unsigned	:groupindex, 32

	rest		:next,		Studiomodel_t
end

class Studiomesh_t < BitStruct
	default_options :endian => :little

	unsigned	:numtris, 32
	unsigned	:triindex, 32
	unsigned	:skinref, 32
	unsigned	:numnorms, 32
	unsigned	:normindex, 32

	rest		:next,		Studiomesh_t
end


end 	# DONT DEFINE TWICE


class GameParser

	path = ENV['TEMP'] if ENV['TEMP']
	path = ENV['TMPDIR'] if ENV['TMPDIR']
	TEMP = path + "/"
	puts "writing textures to #{TEMP}"

	def nextentity(current)

		b = current.index('}')
		if b
			tmp = current.slice(b..-1)
			c = tmp.index('{')
			if c
				return tmp.slice(c..-1)
			else
				return nil
			end
		end
		
		# this is a malformed entity defn
	end

	def getkeystring(current, name, defval)

		b = current.index('}')
		current.slice(0..b).split(/\n+/).each do |aline|
			/^\"(\S*)\" \"([^\"]*)\"/.match(aline)
			if $1.to_s == name
				return $2
			end
		end

		defval
	end

	def getkeyint(current, name, defval)
		getkeystring(current, name, defval).to_i
	end

	def getkeyval(current, name, defval)
		getkeystring(current, name, defval).to_f
	end

	def getkeyvector(current, name, defval)
		/(\S*) (\S*) (\S*)/.match(getkeystring(current, name, defval))
		Geom::Vector3d.new($1.to_f,$2.to_f,$3.to_f)
	end

	def AddMarker
	
		group = Sketchup.active_model.entities.add_group

		vertices = []
		for i in 0..7
			vertices.push Geom::Point3d.new((i & 1)>0 ? -2 : 2, (i & 2)>0 ? -2 : 2, (i & 4)>0 ? -2 : 2)
		end

		group.entities.add_face [vertices[0],vertices[1],vertices[3],vertices[2]]
		group.entities.add_face [vertices[5],vertices[4],vertices[6],vertices[7]]
		group.entities.add_face [vertices[0],vertices[1],vertices[5],vertices[4]]
		group.entities.add_face [vertices[3],vertices[2],vertices[6],vertices[7]]
		group.entities.add_face [vertices[1],vertices[3],vertices[7],vertices[5]]
		group.entities.add_face [vertices[0],vertices[4],vertices[6],vertices[2]]
		
		group.casts_shadows = false
		
		return group
	end

	def Parse(rootPath, mapname)

		unless Sketchup.active_model
			puts "Parse: no window open!"
			return
		end

		# NB max file read is 33554432 bytes
		aFile = File.open(rootPath + "/maps/" + mapname,"rb")
		mapbytes = aFile.read(2<<24)
		aFile.close

		# add some handy layers
		layer = Sketchup.active_model.layers["LU_lights"]
		layer = Sketchup.active_model.layers.add "LU_lights" if not layer

		layer = Sketchup.active_model.layers["lights"]
		layer = Sketchup.active_model.layers.add "lights" if not layer
		
		layer = Sketchup.active_model.layers["monsters"]
		layer = Sketchup.active_model.layers.add "monsters" if not layer
		
		layer = Sketchup.active_model.layers["entities"]
		layer = Sketchup.active_model.layers.add "entities" if not layer

		layer = Sketchup.active_model.layers["INFO"]
		layer = Sketchup.active_model.layers.add "INFO" if not layer

		layer = Sketchup.active_model.layers["NODRAW"]
		layer = Sketchup.active_model.layers.add "NODRAW" if not layer


		if mapbytes[0...4] == "IBSP"
			puts "Quake 2 format"
			mapbytes = mapbytes[4..-1]
		end


		if Validate(mapbytes, rootPath)
		
			entities = GetEntities(mapbytes)
			begin
				myfile = File.new(TEMP+"/entities.txt", "w+")
				myfile.puts(entities)
				myfile.close
			rescue
				puts "PROBLEMS"
			end

			current = entities
			while current
				proxy = {}
				if ParseEntity(proxy, current, rootPath)
	
					Sketchup.set_status_text getkeystring(current, "classname", nil)
	
					# build it
					if proxy["model"]
						if proxy["model"][0,1] == '*'
							mesh = AddBrush(mapbytes, proxy["model"][1..-1].to_i)
						else
							mesh = AddModel(rootPath, proxy["model"])
						end
					else
						mesh = AddMarker()
						proxy["model"] = getkeystring(current, "classname", nil)
					end
	
					# instrument it
					DecorateEntity(mesh, proxy, current, rootPath)
	
					# name it
					mesh.name = getkeystring(current, "classname", nil) + "_" + getkeystring(current, "targetname", proxy["model"])
					
					# place it
					origin = getkeyvector(current, "origin", "0 0 0")
					ltm = Geom::Transformation.new(origin)
					if (getkeystring(current, "classname", "").include?("large"))
						ltm = ltm * Geom::Transformation.scaling(2)
						ltm = ltm * Geom::Transformation.translation([0,0,5])
					end
					unless proxy["angle"]
						dir = getkeyval(current, "angle", 0.0) * Math::PI / 180
						ltm = Geom::Transformation.rotation(ltm.origin, Geom::Vector3d.new(0,0,1), dir) * ltm
					end
					mesh.transform!(ltm)
			
					# assign to layer
					mesh.layer = proxy["renderlayer"] if proxy["renderlayer"]
				end
		
				current = nextentity(current)
			end
			
			puts "linking touchers"
			working = Sketchup.active_model.entities.select {|ent| ent.layer.name == "entities"}
			for i in 0...working.length
				ent1 = working[i]
	
				b1 = ent1.bounds
				touchers = [ent1]
				for j in i+1...working.length
					ent2 = working[j]
					b2 = ent2.bounds
					
					# I'll do my own since #intersect is broke
					hasOverlap =
					   ((b2.max[0]+1 >= b1.min[0]) and (b2.min[0]-1 <= b1.max[0]) and
						(b2.max[1]+1 >= b1.min[1]) and (b2.min[1]-1 <= b1.max[1]) and
						(b2.max[2]+1 >= b1.min[2]) and (b2.min[2]-1 <= b1.max[2]))
					
					if hasOverlap
						puts "#{ent1} touching #{ent2}  (#{ent1.name})"
						touchers.push ent2
					end					
				end
				if touchers.length > 1
					linkname = "link" + ent1.name
					puts "renaming #{ent1.name} touchers to #{linkname}"
					touchers.each {|tent| tent.name = linkname}
				end
			end
			
		end
	end

	def ParseEntity(proxy, current, rootPath)

		puts "GameParser::ParseEntity"

		classname = getkeystring(current, "classname", nil)
		#puts "class: " + classname

		proxy["model"] = getkeystring(current, "model", nil) unless proxy["model"]
		proxy["delay"] = getkeyval(current, "delay", 0.25) unless proxy["delay"]
		proxy["wait"] = getkeyval(current, "wait", -1) unless proxy["wait"]
		proxy["target"] = getkeystring(current, "target", nil) unless proxy["target"]
		proxy["targetname"] = getkeystring(current, "targetname", nil) unless proxy["targetname"]
		proxy["spawnflags"] = getkeyint(current, "spawnflags", 0) unless proxy["spawnflags"]

		return false if (proxy["spawnflags"] & 0x200) == 0x200

		if classname == "worldspawn"
			proxy["model"] = "*0"
			proxy["angle"] = getkeyval(current, "angle", 0)
		elsif classname[0,8] == "ambient_"
			proxy["renderlayer"] = "NODRAW"
		elsif classname[0,8] == "trigger_"
			proxy["renderlayer"] = "NODRAW"
		elsif classname[0,5] == "func_"
			proxy["renderlayer"] = "entities"
			proxy["angle"] = getkeyval(current, "angle", -1)
		elsif classname[0,8] == "monster_"
			proxy["renderlayer"] = "monsters"
		elsif classname[0,5] == "info_"
			proxy["renderlayer"] = "INFO"
		elsif classname[0,5] == "path_"
			proxy["renderlayer"] = "INFO"
		elsif classname[0,5] == "item_"
			proxy["renderlayer"] = "entities"
		elsif classname[0,5] == "misc_"
			proxy["model"] = "lavaball"
			proxy["renderlayer"] = "entities"
		elsif classname[0,7] == "weapon_"
			proxy["renderlayer"] = "entities"
		end
		
		return true
	end
end

class Quake1Parser < GameParser
	@qpalette = nil
	@pos = nil

	def WalkNodes(nodes, depth)
		puts "#{nodes.firstface} #{nodes.numfaces}"
		if (nodes.left > 0)
			
		end

	end

	def AddTexture(matname, pixels, mip, palette)

		puts "Quake1Parser::AddTexture: #{matname}"
		
		mat = Sketchup.active_model.materials.add(matname)

		img = QImage.new(mip.width,mip.height)
		for y in 0...mip.height
			for x in 0...mip.width 
				pix = pixels[y*mip.width+x].to_i
				color = Geom::Vector3d.new(palette[pix*3+0],palette[pix*3+1],palette[pix*3+2])
				img.plot(x,y, color)

				# pure blue is chromakey
				if color[0] == 0 && color[1] == 0 && color[2] > 240
					img.transparent(x,y)
				end
			end
		end

		filename = TEMP + matname + ".tga"
		img.writeTGA(filename)

		mat.texture = filename

		return mat
	end
	
	def DecorateMaterial(matname, mat)
	
			puts "Quake1Parser::DecorateMaterial: #{matname}"

				# glow
				if (matname[1,4] == "lava")
					mat.set_attribute(:lmap, :rgbwave, 4)
					mat.set_attribute(:lmap, :rgbamp, 0.4)
					mat.set_attribute(:lmap, :rgbbase, 0.6)
					mat.set_attribute(:lmap, :rgbfreq, 0.75)
				end
				
				# crazy additive scroll
				if (matname[1,8] == "teleport")
					mat.set_attribute(:lmap, :uvwave, 6)
					mat.set_attribute(:lmap, :uvmode, 2)
					mat.set_attribute(:lmap, :uvfreq, 1.0)
					mat.set_attribute(:lmap, :additive, true)
					mat.set_attribute(:lmap, :fullbright, true)
					mat.alpha = 0.9
				end
	
				# large emitters
				if (matname[1,4] == "lava") or (matname[1,5] == "slime") or (matname[1,8] == "teleport")
					mat.set_attribute(:lmap, :emitter, true)
					mat.set_attribute(:lmap, :fullbright, true)
					mat.set_attribute(:lmap, :density, 0.25)
					mat.set_attribute(:lmap, :power, 100.0)
					mat.alpha = 0.7
				end
	
				if (matname[0,3] == "sky")
					mat.set_attribute(:lmap, :noshadow, true)
					mat.set_attribute(:lmap, :fullbright, true)
					mat.set_attribute(:lmap, :emitter, true)
					mat.set_attribute(:lmap, :density, 0.25)
					mat.set_attribute(:lmap, :power, 100.0)
					mat.alpha = 0.01
				end
	
				# area lights with canonical-ish names
				if (matname.include?("light")) or (matname.include?("lite"))
					unless (matname.include?("light1_2") or matname.include?("light3_6") or matname.include?("light3_7"))
						mat.set_attribute(:lmap, :emitter, true)
						mat.set_attribute(:lmap, :additive, true)
						mat.set_attribute(:lmap, :density, 0.0)
						mat.set_attribute(:lmap, :power, 1000.0)
					end
				end
	
				# random area lights
				if (matname.include?("metal5_8")) or (matname.include?("slipside"))
					mat.set_attribute(:lmap, :emitter, true)
					mat.set_attribute(:lmap, :additive, true)
					mat.set_attribute(:lmap, :density, 0.0)
					mat.set_attribute(:lmap, :power, 1000.0)
				end
	
				if (matname.include?("+0_med")) or (matname.include?("rune")) or (matname.include?("+0slip")) or (matname.include?("slipside"))
					mat.set_attribute(:lmap, :additive, true)
				end
	end
	
	def AddBrush(mapbytes, mid)
		map = Dheader_t.new(mapbytes)

		amodel = Model_t.new(mapbytes[map.lump_models.offset0 + Model_t.round_byte_length * mid, Model_t.round_byte_length])		
		group = Sketchup.active_model.entities.add_group
		faces = Face_t.new(mapbytes[map.lump_faces.offset0 + Face_t.round_byte_length * amodel.face_id, Face_t.round_byte_length * amodel.face_num])
		nodes = Dnode_t.new(mapbytes[map.lump_nodes.offset0, map.lump_nodes.size0])

		leafs = Dleaf_t.new(mapbytes[map.lump_leafs.offset0, map.lump_leafs.size0])		
		leaffaces = mapbytes[map.lump_leaffaces.offset0, map.lump_leaffaces.size0].unpack('v*')

		#WalkNodes(nodes, 0)

		# read mipheader and all miptexs
		mats = []
		mipheader = Mipheader_t.new(mapbytes[map.lump_textures.offset0, Mipheader_t.round_byte_length])
		texoffsets = mapbytes[map.lump_textures.offset0 + Mipheader_t.round_byte_length, mipheader.numtex * 4].unpack('V*')
		for tid in 0...mipheader.numtex
			mip = Miptex_t.new(mapbytes[map.lump_textures.offset0 + texoffsets[tid],  Miptex_t.round_byte_length])
			#ensure its zero terminated so we can save it
			matname = mip.name
			matname = mip.name[0,mip.name.index(/\x00/)] if (mip.name.index(/\x00/) != nil)
			# map to valid filename
			matname[0] = '_' if matname[0] == '*'

			mat = Sketchup.active_model.materials[matname]
			if not mat
				if mip.offset1 != 0
					pixels = mapbytes[map.lump_textures.offset0 + texoffsets[tid] + mip.offset1, mip.width * mip.height].bytes
				end
				
				# using single palette or embedded palettes?
				palette = @qpalette
				if (map.version == 30) and (mip.offset1 != 0)
					palette = mapbytes[map.lump_textures.offset0 + texoffsets[tid] + mip.offset8 + (mip.width * mip.height)/64 + 2, 768].bytes
				end
				mat = AddTexture(matname, pixels, mip, palette)
	
				DecorateMaterial(matname, mat)

			end
			
			mats[tid] = mat
		end

		amodel.face_num.times do
			
			vertices = []
			surfedges = mapbytes[map.lump_surfedges.offset0 + 4 * faces.ledge_id, 4*faces.ledge_num].unpack('V*')
			mid = 2**31
			max_unsigned = 2**32
			surfedges.each_index {|n| surfedges[n] = ((surfedges[n]>=mid) ? surfedges[n] - max_unsigned : surfedges[n])}
			for e in 0...faces.ledge_num do
			
				if surfedges[e] < 0
					anedge = Edge_t.new(mapbytes[map.lump_edges.offset0 + Edge_t.round_byte_length * -surfedges[e], Edge_t.round_byte_length])
					vindex = anedge.v1
				else
					anedge = Edge_t.new(mapbytes[map.lump_edges.offset0 + Edge_t.round_byte_length * surfedges[e], Edge_t.round_byte_length])
					vindex = anedge.v0
				end
				
				vertex = Vec3_t.new(mapbytes[map.lump_vertexes.offset0 + Vec3_t.round_byte_length * vindex, Vec3_t.round_byte_length]) 
				vertices.push Geom::Point3d.new(vertex.x,vertex.y,vertex.z)

			end

			plane = Plane_t.new(mapbytes[map.lump_planes.offset0 + Plane_t.round_byte_length * faces.plane_id, Plane_t.round_byte_length])
			normal = Geom::Vector3d.new(plane.normal.x, plane.normal.y, plane.normal.z)

			if faces.side != 0
				normal = normal.reverse
				vertices = vertices.reverse
			end
			
			# SU add_face is very picky, so condition data
			#vertices.uniq!
			
			
			begin
				face = group.entities.add_face vertices
			rescue
				puts "add_face: failed"
				puts "#{vertices[0][0].to_f} #{vertices[0][1].to_f} #{vertices[0][2].to_f}"
				puts "#{vertices[1][0].to_f} #{vertices[1][1].to_f} #{vertices[1][2].to_f}"
				puts "#{vertices[2][0].to_f} #{vertices[2][1].to_f} #{vertices[2][2].to_f}"
				face = group.entities.add_face vertices[0..2]
			end
			
			face.reverse! if normal.dot(face.normal) < 0
			
			texinfo = Texinfo_t.new(mapbytes[map.lump_texinfo.offset0 + Texinfo_t.round_byte_length * faces.texinfo_id, Texinfo_t.round_byte_length])
			mat = mats[texinfo.texture_id]

			# ensure liquids face up, facedness seems inconsistent..
			if (mat.name.include?("lava") or mat.name.include?("slime") or mat.name.include?("water"))
				if (face.normal.dot(Geom::Vector3d.new(0,0,1)) < 0)
					puts "wrong facedness #{mat.name}"
					face.reverse!
				end
			end

			# some we want to make doublesided
			# 
			dsided = ((mat.name[0] == '_') or (mat.name[0] == '!') or (mat.name[0,3] == "sky"))

			pos_tex = []
			for i in 0...vertices.size do
				u = texinfo.distS + QuakeImporter.pdot(vertices[i], Geom::Vector3d.new(texinfo.vectorS.x,texinfo.vectorS.y,texinfo.vectorS.z))
				v = texinfo.distT + QuakeImporter.pdot(vertices[i], Geom::Vector3d.new(texinfo.vectorT.x,texinfo.vectorT.y,texinfo.vectorT.z))
				
				# accumulate the first 3 coordinate non-zero area pairs
				if (pos_tex.length < 6)
					area = 1
					if pos_tex.length >= 4
						v1 = Geom::Vector3d.new(pos_tex[2][0]-pos_tex[0][0], pos_tex[2][1]-pos_tex[0][1], pos_tex[2][2]-pos_tex[0][2])
						v2 = Geom::Vector3d.new(pos_tex[2][0]-vertices[i].x, pos_tex[2][1]-vertices[i].y, pos_tex[2][2]-vertices[i].z)
						area = (v1 * v2).length				
					end

					if area > 0
						pos_tex += [[vertices[i].x, vertices[i].y, vertices[i].z]]
						pos_tex += [[u/mat.texture.image_width, v/mat.texture.image_height]]
					end
				end
			end	
	
			begin
				face.position_material(mat, pos_tex, true)
				if dsided == true
					face.position_material(mat, pos_tex, false)
				end
			rescue
				puts "position_material: failed"
			end
			
			faces = faces.next
		end	
		
		return group
	end

	def AddModel(rootPath, model)

		unless @qpalette
			aFile = File.open(rootPath + "/gfx/palette.lmp","rb")
			@qpalette = aFile.read(768).bytes
			aFile.close		
		end

		if File.exist?(rootPath + "/progs/" + model + ".mdl")
			aFile = File.open(rootPath + "/progs/" + model + ".mdl","rb")
			progbytes = aFile.read(2<<20) 
			aFile.close

			defn = Sketchup.active_model.definitions[model]
			unless defn
				defn = Sketchup.active_model.definitions.add(model)

				ident = MdlIdent_t.new(progbytes)
				mdl = Mdl_t.new(prog.next)
				puts "mdl.version: #{ident.version}"
				puts "#{model}: skins(#{mdl.numskins}) geom(#{mdl.numverts},#{mdl.numtris})"			
				offset = MdlIdent_t.round_byte_length + Mdl_t.round_byte_length

				for sk in 0...mdl.numskins

					skin = Skin_t.new(progbytes[offset, Skingroup_t.round_byte_length])
					puts "skin: group(#{skin.group})"
					offset += Skin_t.round_byte_length

					if skin.group == 1
						skingroup = Skingroup_t.new(skin)
						puts "skingroup: group(#{skingroup.group}) nb(#{skingroup.nb}) time(#{skingroup.time})"
						offset += Skingroup_t.round_byte_length - Skin_t.round_byte_length
						offset += 4 * (skingroup.nb-1)
					end
				
					matname = model + sk.to_s
					mat = Sketchup.active_model.materials[matname]
					if not mat
					
						pixels = progbytes[offset, mdl.skinwidth * mdl.skinheight].bytes
						img = QImage.new(mdl.skinwidth, mdl.skinheight)
						for y in 0...mdl.skinheight
							for x in 0...mdl.skinwidth 
								pix = pixels[y*mdl.skinwidth+x].to_i
								color = Geom::Vector3d.new(@qpalette[pix*3+0],@qpalette[pix*3+1],@qpalette[pix*3+2])
								img.plot(x,y, color)

								# pure blue is chromakey
								if color[0] == 0 && color[1] == 0 && color[2] > 240
									img.transparent(x,y)
								end
							end
						end
						filename = TEMP + matname + ".tga"
						img.writeTGA(filename)
					
						mat = Sketchup.active_model.materials.add(matname)
						mat.texture = filename
						
						# set some material lighting attributes
						if (matname[0,5] == "flame")
							mat.set_attribute(:lmap, :additive, true)
						end
					end
					offset += mdl.skinwidth * mdl.skinheight
				end

				stvert = Stvert_t.new(progbytes[offset, Stvert_t.round_byte_length * mdl.numverts])
				offset += Stvert_t.round_byte_length * mdl.numverts
				triangle = Triangle_t.new(progbytes[offset, Triangle_t.round_byte_length * mdl.numtris])
				offset += Triangle_t.round_byte_length * mdl.numtris

				morphs = []
				for i in 0...mdl.numframes
					frameheader = Frame_t.new(progbytes[offset, progbytes.length])
					offset += Frame_t.round_byte_length
					numposes = 1
					if frameheader.group == 1
						framegroupheader = Framegroup_t.new(frameheader)
						# skip past framegroupheader + timing array
						offset += Framegroup_t.round_byte_length - Frame_t.round_byte_length;
						offset += 4 * (framegroupheader.nb-1)
						numposes = framegroupheader.nb
					end

					numposes.times do
						frame = Simpleframe_t.new(progbytes[offset, progbytes.length])
						offset += Simpleframe_t.round_byte_length
						verts = Trivert_t.new(frame.next)
						vertices = []
						mdl.numverts.times do
							x = verts.x * mdl.scale.x + mdl.origin.x
							y = verts.y * mdl.scale.y + mdl.origin.y
							z = verts.z * mdl.scale.z + mdl.origin.z
							vertices.push Geom::Point3d.new(x,y,z)
							verts = verts.next
						end
						morphs.push vertices
						offset += Trivert_t.round_byte_length * mdl.numverts
					end
				end
				puts "#{morphs.length} poses read"

				# choose a pose to use
				vertices = morphs[mdl.numframes / 4]

				uvs = []
				onseam = []
				oou = 1.0 / mdl.skinwidth
				oov = 1.0 / mdl.skinheight
				mdl.numverts.times do					
					uvs.push [stvert.s * oou + oou*0.5, stvert.t * oov + oov*0.5]
					onseam.push stvert.onseam
					stvert = stvert.next
				end

				mdl.numtris.times do
					begin
						face = defn.entities.add_face [vertices[triangle.index2], vertices[triangle.index1], vertices[triangle.index0]]
						
						uv0 = [uvs[triangle.index0][0],uvs[triangle.index0][1]]
						uv1 = [uvs[triangle.index1][0],uvs[triangle.index1][1]]
						uv2 = [uvs[triangle.index2][0],uvs[triangle.index2][1]]
						unless triangle.facesfront==1
							uv0[0] += 0.5 if onseam[triangle.index0]!=0
							uv1[0] += 0.5 if onseam[triangle.index1]!=0
							uv2[0] += 0.5 if onseam[triangle.index2]!=0
						end
						pos_tex = [vertices[triangle.index0], uv0, vertices[triangle.index1], uv1, vertices[triangle.index2], uv2]
						begin
							face.position_material(mat, pos_tex, true) 
						rescue
						end
					rescue
						puts "error: #{triangle.index0} #{triangle.index1} #{triangle.index2}"
					end

					triangle = triangle.next
				end
				
				#defn.entities.add_group(group)
				
			end

			instance = Sketchup.active_model.entities.add_instance(defn, Geom::Transformation.new)
			return instance
		end
		
		if File.exist?(rootPath + "/maps/" + model + ".bsp")
			aFile = File.open(rootPath + "/maps/" + model + ".bsp","rb")
			mapbytes = aFile.read(2<<20) 
			aFile.close
			return AddBrush(mapbytes, 0)
		end
		
		return AddMarker()
	end
	
	def GetEntities(mapbytes)
		map = Dheader_t.new(mapbytes)
		mapbytes[map.lump_entities.offset0, map.lump_entities.size0] 
	end
	
	def ParseEntity(proxy, current, rootPath)

		puts "Quake1Parser::ParseEntity"

		classname = getkeystring(current, "classname", nil)

		# some stuff we're not interested in
		return false if (classname == "func_episodegate")
		
		# some stuff creates additional elements
		if classname == "info_player_start"
			eye = getkeyvector(current, "origin", "0 0 0")
			eye.z += 72

			dir = getkeyval(current, "angle", 0.0) * Math::PI / 180
			ltm = Geom::Transformation.rotation(Geom::Point3d.new, Geom::Vector3d.new(0,0,1), dir)
			
			Sketchup.active_model.active_view.camera.set([eye.x,eye.y,eye.z], ltm.xaxis, Geom::Vector3d.new(0,0,1))
			Sketchup.active_model.active_view.camera.fov = 60
		end
		
		if classname == "info_intermission"
			p = Sketchup.active_model.pages.add
			p.use_hidden_layers = false

			eye = getkeyvector(current, "origin", "0 0 0")

			angles = getkeyvector(current, "mangle", "0 0 0")
			angles.x *= (Math::PI / 180)
			angles.y *= (Math::PI / 180)
			angles.z *= (Math::PI / 180)
			
			ltm = 
			#	Geom::Transformation.rotation(Geom::Point3d.new, Geom::Vector3d.new(1,0,0), angles.z) *				
				Geom::Transformation.rotation(Geom::Point3d.new, Geom::Vector3d.new(0,0,1), angles.y) *
				Geom::Transformation.rotation(Geom::Point3d.new, Geom::Vector3d.new(0,1,0), angles.x) *
				Geom::Transformation.new

			p.camera.set([eye.x,eye.y,eye.z], ltm.xaxis, Geom::Vector3d.new(0,0,1))
			p.camera.fov = 60.0
		end

		if classname[0,5] == "light"
			ltm = Geom::Transformation.new(getkeyvector(current, "origin", nil))
			ltm *= Geom::Transformation.new([0,0,3])
			defn = Sketchup.active_model.definitions["PointLightSource"]
			if defn
				instance = Sketchup.active_model.entities.add_instance(defn, ltm)
				instance.layer = "LU_lights"
				instance.set_attribute(:lightsource, :radius, getkeyval(current, "light", 100.0))
				instance.set_attribute(:lightsource, :lumen, getkeyval(current, "light", 250.0))
				style = getkeyval(current, "style", 0)
				style = 1 if (classname[6,10] == "fluoro")
				case Integer(style) & 15
					when 0
					# static
					when 1
					instance.set_attribute(:lightsource, :dynamic, 'true')
					instance.set_attribute(:lightsource, :rgbwave, 6)
					instance.set_attribute(:lightsource, :rgbfreq, 2.0)
					instance.set_attribute(:lightsource, :rgbbase, 0.2)
					instance.set_attribute(:lightsource, :rgbphase, rand())
					instance.set_attribute(:lightsource, :rgbsteps, 3)
					when 3
					instance.set_attribute(:lightsource, :dynamic, 'true')
					instance.set_attribute(:lightsource, :rgbwave, 6)
					instance.set_attribute(:lightsource, :rgbfreq, 0.2)
					instance.set_attribute(:lightsource, :rgbphase, rand())
					when 10
					instance.set_attribute(:lightsource, :dynamic, 'true')
					instance.set_attribute(:lightsource, :rgbwave, 6)
					instance.set_attribute(:lightsource, :rgbfreq, 0.75)
					instance.set_attribute(:lightsource, :rgbphase, rand())
					instance.set_attribute(:lightsource, :rgbsteps, 3)
					else
					instance.set_attribute(:lightsource, :dynamic, 'true')
					instance.set_attribute(:lightsource, :rgbwave, 4)
					instance.set_attribute(:lightsource, :rgbfreq, 0.5)
				end
			end
			proxy["style"] = style
			proxy["renderlayer"] = "NODRAW"
		end
		
		if classname[0,6] == "light_"
			dict = {"torch_small_walltorch" => "flame", "flame_small_white" => "flame2", "flame_small_yellow" => "flame2", "flame_large_yellow" => "flame2"}
			proxy["model"] = dict[classname[6..-1]]
			proxy["renderlayer"] = "lights" if proxy["model"]
		end

		if classname[0,5] == "item_"
			dict = {"weapon" => "g_shot",  "artifact_super_damage" => "quaddama", "sigil" => "end1", "key" => "m_g_key", "key2" => "m_s_key", "armor" => "armor",  "armorInv" => "armor", "armor1" => "armor", "armor2" => "armor", "health" => "b_bh25", "shells" => "b_shell0", "grenades" => "grenade", "spikes" => "b_nail0", "rockets" => "b_rock0", "cells" =>"b_batt0"}
			proxy["model"] = dict[classname[5..-1]]
		end

		if classname[0,7] == "weapon_"
			dict = {"lightning" => "g_light", "shotgun" => "g_shot", "supershotgun" => "g_shot", "nailgun" => "g_nail", "supernailgun" => "g_nail2", "rocketlauncher" => "g_rock", "grenadelauncher" => "g_rock2"}
			proxy["model"] = dict[classname[7..-1]]
		end

		if classname[0,8] == "monster_"
			dict = {"hell_knight" => "hknight", "demon1" => "demon", "army" => "enforcer"}
			proxy["model"] = dict[classname[8..-1]]
			proxy["model"] = classname[8..-1] unless proxy["model"]
		end

		if classname[0,5] == "trap_"
			dict = {"spikeshooter" => "k_spike"}
			proxy["model"] = dict[classname[5..-1]]
		end

		return super(proxy, current, rootPath);
	end

	def DecorateEntity(mesh, proxy, current, rootPath)

		classname = getkeystring(current, "classname", nil)

		if classname[0,5] == "func_"
			lip = getkeyval(current, "lip", 4)
			h = getkeyval(current, "height", 0)
			speed = getkeyval(current, "speed", 100)
			move = ''
			case proxy["angle"]
			
			when -1
			d = mesh.bounds.depth-lip+h
			move = "animate(Z, 0, #{d})"
			when 0
			d = mesh.bounds.width-lip+h
			move = "animate(X, 0, #{d})"
			when 90
			d = mesh.bounds.height-lip+h
			move = "animate(Y, 0, #{d})"
			when 180
			d = mesh.bounds.width-lip+h
			move = "animate(X, 0, #{-d})"
			when 270
			d = mesh.bounds.height-lip+h
			move = "animate(Y, 0, #{-d})"
			else
			d = mesh.bounds.depth-lip+h
			move = "animate(Z, 0, #{-d})"
			end
			move += ",time=#{(d/speed).abs},delay=#{proxy['delay']}"
			move += ",cycle,pause" if proxy['wait'] > 0
			
			mesh.set_attribute(:dynamic_attributes, :onclick, move)
		end

		if classname[0,7] == "weapon_"
			mesh.set_attribute(:dynamic_attributes, :onclick, "animate(RotZ, 0,360),time=2.0,flyback,forever")
			mesh.definition.set_attribute(:dynamic_attributes, :onclick, "animate(RotZ, 0,360),time=2.0,flyback,forever")
		end

		# add ALL key-value pairs as JSON-stylee
		mesh.set_attribute(:quake, :entity, proxy.collect {|e| "'#{e[0].to_s}' => '#{e[1].to_s}'"}.join(","))
	end
	
	def Validate(mapbytes, rootPath)
		
		puts "Quake1Parser::Validate: #{rootPath}"
	
		map = Dheader_t.new(mapbytes)
		
		# cache Vertex_t and Edge_t ?
		
		if File.exists?(rootPath + "/gfx/palette.lmp")
			aFile = File.open(rootPath + "/gfx/palette.lmp","rb")
			puts "Quake 1 palette"
			@qpalette = aFile.read(768).bytes
			aFile.close
		end

		if File.exists?(rootPath + "/pics/colormap.pcx")
			aFile = File.open(rootPath + "/pics/colormap.pcx","rb")
			puts "Quake 2 palette"
			aFile.seek(-768, IO::SEEK_END)
			@qpalette = aFile.read(768).bytes
			aFile.close
		end

		# gamma correct it
		gamma = 1.0 / 2.2
		gammatable = []
		for i in 0...256
			gammatable[i] = (((i/255.0) ** gamma) * 255).to_i
		end
		
		for i in 0...256
			@qpalette[3*i+0] = (gammatable[@qpalette[3*i+0]])
			@qpalette[3*i+1] = (gammatable[@qpalette[3*i+1]])
			@qpalette[3*i+2] = (gammatable[@qpalette[3*i+2]])
		end

		puts "map.version: #{map.version}"
		map.version == 29	or map.version == 38
	end
end

class HL1Parser < Quake1Parser
	@qadfiles = nil

	def WalkNodes(nodes, depth)
		puts "#{nodes.firstface} #{nodes.numfaces}"
		if (nodes.left > 0)
			
		end

	end

	def AddTexture(matname, pixels, mip, palette)
	
		puts "HL1Parser::AddTexture: #{matname} off:#{mip.offset1}"

		# ensure its zero terminated
		mipname = mip.name.downcase
		mipname = mip.name[0,mip.name.index(/\x00/)] if (mip.name.index(/\x00/) != nil)

		# these can be large so read incrementally
		if mip.offset1 == 0
		
			@wadfiles.each {|wadfilename|

					# is it even in this WAD?
					manifest = @wadcache[wadfilename]
					if manifest and (manifest.include?(mipname) == false)
						puts "#{mipname}: not in cached manifest for #{wadfilename}"
						next
					end
					newmanifest = []
					
					found = false
					aFile = File.open(wadfilename, "rb")
					wadbytes = aFile.read(Wadheader_t.round_byte_length)
					wadheader = Wadheader_t.new(wadbytes)
					puts "searching WAD #{wadfilename} (#{wadheader.numentries} entries) for #{mipname}"
					offset = wadheader.diroffset
					for wid in 0...wadheader.numentries
						aFile.seek(offset, IO::SEEK_SET)
						wadbytes = aFile.read(Wadentry_t.round_byte_length)
						wadentry = Wadentry_t.new(wadbytes)
						newmanifest.push wadentry.name.downcase
						
						offset += Wadentry_t.round_byte_length

						if ((wadentry.name).casecmp((mipname)) == 0)
							aFile.seek(wadentry.offset, IO::SEEK_SET)
							wadbytes = aFile.read(wadentry.dsize);
							
							mip = Miptex_t.new(wadbytes[0, Miptex_t.round_byte_length])
							pixels = wadbytes[mip.offset1, mip.width * mip.height].bytes
							palette = wadbytes[mip.offset8 + (mip.width * mip.height)/64 + 2, 256 * 3].bytes
							puts "#{wid}: FOUND   #{wadentry.name} #{wadentry.dsize} #{wadentry.msize} #{wadentry.offset}"

							# signal we've found it but complete the manifest
							found = true
							
						end
					end
					@wadcache[wadfilename] = newmanifest
					aFile.close
					break if found
			}
		end
		
		return super(matname, pixels, mip, palette)
	end

	def DecorateMaterial(matname, mat)
	
		puts "HL1Parser::DecorateMaterial: #{matname}"
		
		# area lights with canonical-ish names
		if (matname.include?("lgt")) or (matname.include?("lght"))
			mat.set_attribute(:lmap, :emitter, true)
			mat.set_attribute(:lmap, :additive, true)
			mat.set_attribute(:lmap, :density, 1.0)
			mat.set_attribute(:lmap, :power, 1000.0)
		end

		if (matname.include?("spot"))
			mat.set_attribute(:lmap, :emitter, true)
			mat.set_attribute(:lmap, :additive, true)
			mat.set_attribute(:lmap, :density, 0.0)
			mat.set_attribute(:lmap, :power, 2500.0)
		end

		# large emitters
		if (matname[1,5] == "toxic")
			mat.set_attribute(:lmap, :emitter, true)
			mat.set_attribute(:lmap, :fullbright, true)
			mat.set_attribute(:lmap, :density, 0.25)
			mat.set_attribute(:lmap, :power, 100.0)
			mat.alpha = 0.7
		end
		
		if (matname.include?("water"))
			mat.alpha = 0.4
		end
		
		if (matname.include?("glass"))
			mat.alpha = 0.25
		end
		
		return super(matname, mat)
		
	end

	def AddBrush(mapbytes, mid)

		puts "HL1Parser::AddBrush:  #{mid}"
		return super(mapbytes, mid)

	end

	def AddModel(rootPath, model)

		puts "HL1Parser::AddModel:  #{model}"

		if model.include?(".mdl")
			filename = "/" + model
		else
			filename = "/models/" + model + ".mdl"
		end

		if File.exist?(rootPath + filename)
			puts "READING #{rootPath + filename}"
			aFile = File.open(rootPath + filename,"rb")
			progbytes = aFile.read(2<<20)
			aFile.close

			defn = Sketchup.active_model.definitions[model]
			unless defn
				defn = Sketchup.active_model.definitions.add(model)

				ident = MdlIdent_t.new(progbytes)
				mdl = Studioheader_t.new(progbytes[MdlIdent_t.round_byte_length, Studioheader_t.round_byte_length])
				puts "mdl.version: #{ident.version}"
				puts "mdl.name: #{mdl.name} len(#{mdl.hlength}) eye(#{mdl.eyeposition.x},#{mdl.eyeposition.y},#{mdl.eyeposition.z})"
				puts "#{model}: numtex(#{mdl.numtextures}) skins(#{mdl.numskinref}) bones(#{mdl.numbones}) hitbox(#{mdl.numhitboxes}) seq(#{mdl.numseq})"
				if mdl.numtextures == 0
						puts "Fetching texture MDL"
						AddModel(rootPath, model.include?(".mdl") ? model.sub(".mdl", "t.mdl") : model + "t")
				end

				offset = MdlIdent_t.round_byte_length
				for sk in 0...mdl.numskinref

					mdltex = Studiotexture_t.new(progbytes[mdl.textureindex + Studiotexture_t.round_byte_length * sk, Studiotexture_t.round_byte_length])
					matname = mdltex.name
					matname = mdltex.name[0,mdltex.name.index(/\x00/)] if (mdltex.name.index(/\x00/) != nil)
					mat = Sketchup.active_model.materials[matname]
					if not mat
						puts "skin #{matname}: #{mdltex.width}x#{mdltex.height}"
						mip = Miptex_t.new
						mip.name = matname
						mip.width = mdltex.width
						mip.height = mdltex.height
						mip.offset1 = 1

						pixels = progbytes[mdltex.texindex, mip.width * mip.height].bytes
						palette = progbytes[mdltex.texindex + mip.width * mip.height, 768].bytes

						mat = AddTexture(matname, pixels, mip, palette)
	
						DecorateMaterial(matname, mat)
				
					end
				end
				 
				for bp in 0...mdl.numbodyparts
					part = Studiobodyparts_t.new(progbytes[mdl.bodypartindex + Studiobodyparts_t.round_byte_length * bp, Studiobodyparts_t.round_byte_length])
					puts "#{bp}: #{part.name} #{part.nummodels}"

					for modeli in 0...part.nummodels
						smodel = Studiomodel_t.new(progbytes[part.modelindex + Studiomodel_t.round_byte_length * modeli, Studiomodel_t.round_byte_length])
						puts "    #{modeli}: #{smodel.name} #{smodel.nummesh} #{smodel.numverts}"

						verts = Vec3_t.new(progbytes[smodel.vertindex, Vec3_t.round_byte_length * smodel.numverts])
						vertinfos = progbytes[smodel.vertinfoindex, Vec3_t.round_byte_length * smodel.numverts].bytes

						for meshi in 0...smodel.nummesh
							smesh = Studiomesh_t.new(progbytes[smodel.meshindex + Studiomesh_t.round_byte_length * meshi, Studiomesh_t.round_byte_length])
							puts "      #{meshi}: tri:#{smesh.numtris} normals:#{smesh.numnorms}  mat:#{smesh.skinref}"
							
							
						end
						
					end

				end
				 
			end

			instance = Sketchup.active_model.entities.add_instance(defn, Geom::Transformation.new)
			return instance
		end

		if File.exist?(rootPath + "/maps/" + model + ".bsp")
			aFile = File.open(rootPath + "/maps/" + model + ".bsp","rb")
			mapbytes = aFile.read(2<<20) 
			aFile.close
			return AddBrush(mapbytes, 0)
		end

		return AddMarker()
	end
	
	def GetEntities(mapbytes)
		map = Dheader_t.new(mapbytes)
		mapbytes[map.lump_entities.offset0, map.lump_entities.size0] 
	end
	
	def ParseEntity(proxy, current, rootPath)

		result = super(proxy, current, rootPath)
		
		puts "HL1Parser::ParseEntity"

		classname = getkeystring(current, "classname", nil)
		if classname == "worldspawn"
			skybox = getkeystring(current, "skyname", nil)
			if skybox
				puts "USING skybox: #{rootPath + '/env/' + skybox}"
			end

		elsif classname.include?("illusionary")
			proxy["renderlayer"] = "NODRAW"
		end

		return result
	end
	
	def Validate(mapbytes, rootPath)
	
		super(mapbytes, rootPath)
		
		puts "HL1Parser::Validate: #{rootPath}"
	
		# cache Vertex_t and Edge_t ?
		@wadfiles = Dir[rootPath + "/*.wad"] + Dir[rootPath + "/maps/*.wad"]
		@wadcache = {}
		puts "Found #{@wadfiles.length} WAD files"

		map = Dheader_t.new(mapbytes)
		return map.version == 30
	end
end
		

######### RUNTIME CODE!

class Scheduler
	def initialize
		@ready = []
		@running = []
	end
	
	def activate(ent, currenttime)
		@running.push ent
		ent.set_attribute(:engine, :nextstate, currenttime+30)
	end
	
	def deactivate(ent)
		@running.delete ent
	end
	
	def update(currenttime)
	
		for aready in @ready
			@running.push = ent
			@ready.delete aready
		end

		for arunning in @running
		
			# spin it to show its alive
			center = Geom::Point3d.new(arunning.bounds.min.x,arunning.bounds.min.y,arunning.bounds.min.z)
			center.x += arunning.bounds.max.x
			center.y += arunning.bounds.max.y
			center.z += arunning.bounds.max.z
			center.x *= 0.5
			center.y *= 0.5
			center.z *= 0.5			
			ltm = Geom::Transformation.new center, Geom::Vector3d.new(0,0,1), 0.01
			arunning.transform! ltm

			if arunning.get_attribute(:engine, :nextstate) > currenttime
				deactivate(arunning)
			end	
		end
	end
	
	def suspend
	
	end
	
	def resume
	
	end
		
end

class PlayGameTool
	
	def activate
		@timestamp = 0
		@id = UI.start_timer(0.1, true) {update}
		@scheduler = Scheduler.new
	end

	def deactivate(view)
		UI.stop_timer(@id)
	end


	def update
		@timestamp += 1
		
		# LOS activation
		
		@scheduler.update(@timestamp)
		
	end
	
	def onMouseMove(flags, x, y, view)
	

	end

	def onLButtonDown(flags, x, y, view)

		ph = view.pick_helper
		ph.do_pick(x,y)
		picked = ph.element_at(0)
		@scheduler.activate(picked, @timestamp) if picked.kind_of? Sketchup::Group
	end

	def onLButtonUp(flags, x, y, view)

	end
	
	def draw(view)
		# cache camera for LOS tests
	end
end

def playgame
	Sketchup.active_model.select_tool PlayGameTool.new
end


def QuakeImporter.watchdog(timeout)

	wd = Thread.new(Thread.current, timeout) { |towatch, tout|
		sleep(tout)
	
		puts "*" * 70
		puts "*" * 70
		puts "WATCH DOG TIMEOUT"
		puts "*" * 70
		puts "*" * 70

		towatch.raise "**** WATCHDOG timer ****"
	}

end

def QuakeImporter.stopdog(wd)
	Thread.kill(wd)
	nil
end

end # QuakeImporter


class Quake1Importer < Sketchup::Importer

  # This method is called by SketchUp to determine the description that
  # appears in the File > Import dialog's pulldown list of valid
  # importers.
  def description
    return "Quake1 level importer (*.bsp)"
  end

  # This method is called by SketchUp to determine what file extension
  # is associated with your importer.
  def file_extension
    return "bsp"
  end

  # This method is called by SketchUp to get a unique importer id.
  def id
    return "org.billyard.importers.quake1"
  end

  # This method is called by SketchUp to determine if the "Options"
  # button inside the File > Import dialog should be enabled while your
  # importer is selected.
  def supports_options?
    return false
  end

  # This method is called by SketchUp when the user clicks on the
  # "Options" button inside the File > Import dialog. You can use it to
  # gather and store settings for your importer.
  def do_options
    # In a real use you would probably store this information in an
    # instance variable.
    #my_settings = UI.inputbox(['Quake Import Option:'], ['1'], "Import Options")
  end

  # This method is called by SketchUp after the user has selected a file
  # to import. This is where you do the real work of opening and
  # processing the file.
  def load_file(file_path, status)

		# enable this to break out after N seconds
		#wd = QuakeImporter::watchdog(60)
		
		parser = QuakeImporter::Quake1Parser.new
		parser.Parse(File.dirname(file_path)+"/..", File.basename(file_path))
		Sketchup.active_model.name = "#{File.basename(file_path)}"
		Sketchup.active_model.description = "Quake map: #{File.basename(file_path)}"
		Sketchup.active_model.layers["INFO"].visible = false
		Sketchup.active_model.layers["NODRAW"].visible = false

		#QuakeImporter::stopdog(wd)

    return Sketchup::Importer::ImportSuccess
  end
end

Sketchup.register_importer(Quake1Importer.new)

class HL1Importer < Sketchup::Importer

  # This method is called by SketchUp to determine the description that
  # appears in the File > Import dialog's pulldown list of valid
  # importers.
  def description
    return "HalfLife1 level importer (*.bsp)"
  end

  # This method is called by SketchUp to determine what file extension
  # is associated with your importer.
  def file_extension
    return "bsp"
  end

  # This method is called by SketchUp to get a unique importer id.
  def id
    return "org.billyard.importers.hl1"
  end

  # This method is called by SketchUp to determine if the "Options"
  # button inside the File > Import dialog should be enabled while your
  # importer is selected.
  def supports_options?
    return false
  end

  # This method is called by SketchUp when the user clicks on the
  # "Options" button inside the File > Import dialog. You can use it to
  # gather and store settings for your importer.
  def do_options
    # In a real use you would probably store this information in an
    # instance variable.
    #my_settings = UI.inputbox(['Quake Import Option:'], ['1'], "Import Options")
  end

  # This method is called by SketchUp after the user has selected a file
  # to import. This is where you do the real work of opening and
  # processing the file.
  def load_file(file_path, status)

		# enable this to break out after N seconds
		wd = QuakeImporter::watchdog(120)
		
		parser = QuakeImporter::HL1Parser.new
		parser.Parse(File.dirname(file_path)+"/..", File.basename(file_path))
		Sketchup.active_model.name = "#{File.basename(file_path)}"
		Sketchup.active_model.description = "Half Life 1 map: #{File.basename(file_path)}"
		Sketchup.active_model.layers["INFO"].visible = false
		Sketchup.active_model.layers["NODRAW"].visible = false

		QuakeImporter::stopdog(wd)

    return Sketchup::Importer::ImportSuccess
  end
end

Sketchup.register_importer(HL1Importer.new)

