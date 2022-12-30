def spawn
	working = Sketchup.active_model.entities.select {|ent| ent.layer.name == "entities"}

	working.each {|ent|

		s = ent.get_attribute(:quake, :entity)
		if s
			kv = eval("{#{s}}")

			if kv["height"]
				ent.transform! Geom::Transformation.new([0,0,-kv["height"].to_f])

			end

			if (kv["spawnflags"].to_i & 1) == 1
				LMapExt.activate( ent.get_attribute(:lmap, :unitid))
			end
		end
	}

end

spawn
